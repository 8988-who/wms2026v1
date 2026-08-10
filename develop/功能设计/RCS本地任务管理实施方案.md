# RCS 本地任务管理实施方案

## Context（背景与目标）

当前 `com.wms.rcs` 模块只是一个 **WMS → RCS 的通用 API 代理**：唯一入口 [AgvController](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/controller/AgvController.java) 的 `commonRequest/{methodName}` 把请求透传给外部 AGV 调度系统，靠 [ApiRequestUtils.execute](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/ApiRequestUtils.java#L43-L115) 发起 HTTP 并异步落 `api_request_log` 日志。

问题：
- WMS 侧没有任务台账。任务下发/取消/查询只是转发，本地无法追溯、对账、做看板。
- [RcsTaskEntity](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java) / [RcsTaskVO](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/vo/RcsTaskVO.java) 是"孤儿"（无 Mapper/Service/Controller 引用），且实体与 [数据表定义](file:///d:/workcoding/wms20260712/develop/RCS具体功能实现.md) 存在字段/列名/状态字典差异。
- `wms_rcs_task` 与 `wms_rcs_task_lifecycle` 两张表目前完全未被使用。
- RCS 回调 WMS 的入站接口不存在（`AGV_taskReporter` / `AGV_warningTask` 等在 [ApiEnum](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/ApiEnum.java) 里是**出站**配置，没有对应的入站 Controller）。

目标：在"纯转发"之上增加 **RCS 任务本地全生命周期台账**——下发时落库、状态每次流转写历史、支持 CRUD/分页/查询，并预留 RCS 回调入站接口驱动状态流转。

> 说明：本方案给出**全部内容**，用户将按自身安排分步生成。各阶段相互独立、可增量落地。

---

## 关键约定（源自探索结论，务必遵守）

1. **实体列名映射**：DB 列是 `create_time / update_time / create_by / update_by`（见 [数据表定义](file:///d:/workcoding/wms20260712/develop/RCS具体功能实现.md#L101-L104)）。注意——这与 warehouse 模块的 `created_time/created_by` **不同**，`wms_rcs_task` 用的是单数形式。因此实体直接复用 [BaseEntity](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/base/BaseEntity.java) 的 `createTime/updateTime`（默认映射 `create_time/update_time`）即可，只需**额外补 `createBy/updateBy`**（默认映射 `create_by/update_by`）。**当前 [RcsTaskEntity](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java#L28-L36) 里 `@TableField(value="created_time")` 等映射是错的，必须改。**
2. **自动填充**：[AutoFillMetaObjectHandler](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) 按属性名 `createTime/updateTime/createBy/updateBy` 填充，属性上需带 `@TableField(fill=INSERT / INSERT_UPDATE)`。
3. **分页**：Query DTO 继承 [BaseQuery](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/base/BaseQuery.java)（提供 pageNum/pageSize/sortBy/order）。Service 构造 `Page<VO>` → Mapper 自定义分页查询 → Controller 用 [PageResult.success(iPage)](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/result/PageResult.java) 返回。
4. **返回体**：写操作返回 `Result.judge(boolean)`，读返回 `Result.success(data)`，分页直接返回 `PageResult<VO>`（不套 Result）。
5. **分层与命名**：完全对齐 [WmsAisleController](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/controller/WmsAisleController.java) 家族：Service `extends IService`、ServiceImpl `extends ServiceImpl<Mapper,Entity>` + `@RequiredArgsConstructor` + `@Transactional(rollbackFor=Exception.class)`、Mapper `@Mapper extends BaseMapper`、MapStruct Converter（`@Mapper(componentModel="spring")`，放在 `rcs/utils/`）、XML 放 `resources/mapper/rcs/`。
6. **权限点**：`@PreAuthorize("@ss.hasPerm('rcs:task:list|create|update|delete')")`（kebab-case 资源段）。项目无权限 seed SQL，菜单/按钮权限由运行时菜单模块维护，本方案不产出 SQL seed。
7. **日志枚举**：[LogModuleEnum](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/LogModuleEnum.java) 现有 `RCS_AGV(88)`，需新增 `RCS_TASK(89, "RCS本地任务管理")`。ActionType 用 `LIST/INSERT/UPDATE/DELETE/OTHER`。
8. **状态字典以表为准（6 态）**：`0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常`；任务类型 `1-搬运 2-充电 3-调度 4-巡检`；优先级 `1-低 2-中 3-高 4-紧急`。

---

## 阶段一：对齐实体 + 枚举（基础，先做）

**1.1 修正 [RcsTaskEntity](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java)**
- 删除错误的 `@TableField(value="created_time"...)` / `updated_time` 两个字段覆盖，改为直接继承 [BaseEntity](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/base/BaseEntity.java) 的 `createTime/updateTime`（映射 `create_time/update_time`）。
- 保留并修正 `createBy/updateBy` → `@TableField(value="create_by", fill=INSERT)` / `@TableField(value="update_by", fill=INSERT_UPDATE)`。
- 新增字段：`private Object payload;`（对应 `jsonb`，用 String 或自定义 TypeHandler；简单起见先用 `String payload` 存 JSON 文本，或 `@TableField(typeHandler=...)`）、`private LocalDateTime assignedAt;`（映射 `assigned_at`）。
- 更新注释：`taskType` 补 `4-巡检`；`status` 改为 6 态 `0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常`。

**1.2 新增生命周期实体** `rcs/model/entity/RcsTaskLifecycleEntity.java`，`@TableName("wms_rcs_task_lifecycle")`。
- 该表**没有** update_time/create_by/update_by，只有 `create_time`（见 [表定义](file:///d:/workcoding/wms20260712/develop/RCS具体功能实现.md#L160-L169)）。因此**不要继承 BaseEntity**，独立声明：`id`（@TableId AUTO）、`taskId`、`statusFrom`、`statusTo`、`operatorType`、`operatorId`、`remark`、`createTime`（`@TableField(fill=INSERT)`）。

**1.3 新增枚举** [LogModuleEnum](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/LogModuleEnum.java) 增加 `RCS_TASK(89, "RCS本地任务管理")`。

**1.4 新增状态/类型枚举（可选但推荐）** `rcs/enums/RcsTaskStatusEnum`、`RcsTaskTypeEnum`、`RcsTaskPriorityEnum`、`RcsOperatorTypeEnum`（`SYSTEM/ADMIN/AGV/EXTERNAL`）用于 VO 的 `*Label` 转换与流转合法性校验，避免魔法数字散落。

---

## 阶段二：任务 CRUD + 分页（核心台账）

新增文件（对齐 WmsAisle 家族）：

| 类型 | 路径 |
|------|------|
| Mapper | `rcs/mapper/RcsTaskMapper.java`（`@Mapper extends BaseMapper<RcsTaskEntity>`，声明 `Page<RcsTaskVO> getRcsTaskPage(Page<RcsTaskVO> page, RcsTaskQueryDTO q)`） |
| Mapper XML | `resources/mapper/rcs/RcsTaskMapper.xml`（resultMap + 分页 select，left join `sys_user` 取 `create_by_name/update_by_name`，`<where>/<if>` 过滤 taskCode/status/taskType/agvCode/cartCode/时间区间） |
| Service | `rcs/service/RcsTaskService.java`（`extends IService<RcsTaskEntity>`） |
| ServiceImpl | `rcs/service/impl/RcsTaskServiceImpl.java`（`extends ServiceImpl<RcsTaskMapper, RcsTaskEntity>`） |
| 表单 DTO | `rcs/model/dto/RcsTaskDTO.java`（含 id、taskType、taskTitle、fromLocation、toLocation、cartCode、priority、payload、remark，Jakarta 校验） |
| 查询 DTO | `rcs/model/dto/RcsTaskQueryDTO.java`（`extends BaseQuery`，过滤字段 + 时间区间） |
| Converter | `rcs/utils/RcsTaskConverter.java`（MapStruct，`toDTO/toEntity/toVO`；`*Label` 用枚举补齐） |
| Controller | `rcs/controller/RcsTaskController.java`（`@RequestMapping("/api/v1/rcs-task")`） |

**Controller 端点**（对齐 [WmsAisleController](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/controller/WmsAisleController.java)）：
- `GET /api/v1/rcs-task` → 分页列表 `PageResult<RcsTaskVO>`，`@Log(RCS_TASK, LIST)`
- `GET /api/v1/rcs-task/{id}` → 详情 `Result<RcsTaskVO>`（含生命周期时间线，见阶段四）
- `POST /api/v1/rcs-task` → 新建任务 `Result<Void>`，`@RepeatSubmit`，`@Log(INSERT)`
- `PUT /api/v1/rcs-task/{id}` → 修改（仅"待执行"态可改），`@Log(UPDATE)`
- `DELETE /api/v1/rcs-task/{ids}` → 删除（级联删 lifecycle 由外键 `ON DELETE CASCADE` 保证；建议仅允许删终态/待执行），`@Log(DELETE)`

**ServiceImpl 要点**：
- `taskCode` 生成规则统一（如 `RCS` + 日期 + 序列，可参考 [WmsCodeGeneratorService](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/utils/WmsCodeGeneratorService.java) 的思路；无强依赖则自实现）。
- 新建任务默认 `status=0(待执行)`、`submitTime=now`。
- 校验用 Hutool `Assert.notNull/isTrue`（与 WmsAisle 一致）。

---

## 阶段三：下发闭环（联动调用 RCS）

在 `RcsTaskServiceImpl` 注入现有 [AgvService](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/AgvService.java)，新增方法（同一 `@Transactional`）：

- `submit(Long taskId)`：本地任务 → 组装 params（reqCode 用 taskCode，路径/载具等）→ 调 `agvService.commonRequest(ApiEnum.AGV_submitTask, params)` → 成功回填 `rcsTaskId`、流转 `0→1(已派发)`、`assignedAt=now`；失败流转 `→5(异常)` 并记 `errorMsg`。
- `cancel(Long taskId)`：调 `AGV_cancelTask`（paramsClass=[AgvRequestDTO](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/dto/AgvRequestDTO.java)，需 `reqCode`），成功流转 `→4(已取消)`。
- `syncStatus(Long taskId)`：调 `AGV_queryTask` 主动查询 RCS 侧状态，映射回本地 status。

**注意事务边界**：`AgvService` 内部走的是 HTTP + 异步日志，本身不参与 DB 事务。本地库写入（状态流转、rcsTaskId 回填）在调用返回**之后**执行，确保远程失败时本地正确置为异常态。建议：先本地建单（阶段二）独立成功，再单独触发 submit，避免长事务持有 HTTP。

Controller 增补：
- `POST /api/v1/rcs-task/{id}/submit`、`POST /api/v1/rcs-task/{id}/cancel`、`POST /api/v1/rcs-task/{id}/sync`，均 `@Log(RCS_TASK, OTHER)`。

---

## 阶段四：生命周期历史（同事务写入）

**核心：状态流转统一入口。** 在 `RcsTaskServiceImpl` 内实现私有方法：

```
void changeStatus(RcsTaskEntity task, int toStatus, RcsOperatorType opType, String opId, String remark)
```

职责（均在**同一事务**内完成，满足"服务内同事务写入"）：
1. 记录 `statusFrom = task.getStatus()`，校验流转合法性（用状态枚举定义允许的迁移，非法抛业务异常）。
2. 更新主表 `status` 及对应时间戳：`1→assignedAt`、`2→startTime`、`3/4→finishTime`；异常态写 `errorMsg`。
3. `updateById(task)`。
4. 组装并插入一条 `RcsTaskLifecycleEntity`（`taskId/statusFrom/statusTo/operatorType/operatorId/remark`）。

所有会改变状态的路径（create、submit、cancel、回调）都必须经此方法，禁止直接 setStatus。

新增：
- `RcsTaskLifecycleMapper`（`@Mapper extends BaseMapper`）。
- `RcsTaskLifecycleService` / Impl（`extends IService`），或直接在 `RcsTaskServiceImpl` 注入 Mapper 简化。
- 详情接口 `GET /{id}` 的 VO 增加 `List<RcsTaskLifecycleVO> lifecycles`（按 create_time 排序），前端可画时间线。

---

## 阶段五：RCS 回调入站接口（打通反向链路）

新增 `rcs/controller/RcsReporterController.java`，`@RequestMapping("/api/v1/rcs/reporter")`，接收 RCS 主动回馈：
- `POST /task`（对应 RCS 的任务执行过程回馈）：按 `rcsTaskId` 反查本地任务 → `changeStatus` 驱动 `1→2→3` 等流转，operatorType=`EXTERNAL`。
- `POST /task/warning`（任务异常告警）：流转 `→5(异常)`，写 `errorMsg`。
- `POST /robot/warning`（机器人告警）：记录/告警（可先仅落日志）。

安全：回调接口通常由外部 RCS 调用，需与前台鉴权区分。确认放行策略——是走独立 token/白名单还是纳入 `@ss` 权限（**此点建议实现前与安全/对接方确认**）。

**枚举修复（配套）**：[ApiEnum.java#L94-L98](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/ApiEnum.java#L94-L98) 中被注释掉的 `AGV_banishZone`/`AGV_homingZone`（reporter 完成回馈）因枚举名冲突不可用，导致 `/api/robot/reporter/zone/banish|homing` 两条路径不可达。若回馈链路需要，改用不冲突的枚举名恢复（如 `AGV_banishZoneReporter` / `AGV_homingZoneReporter`）。

---

## 涉及文件清单（汇总）

**修改**
- [RcsTaskEntity.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java) — 列名映射、补 payload/assignedAt、状态注释
- [RcsTaskVO.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/model/vo/RcsTaskVO.java) — 补 payload/assignedAt/lifecycles，`create_by_name/update_by_name` 与表列对齐
- [LogModuleEnum.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/LogModuleEnum.java) — 新增 `RCS_TASK(89)`
- [ApiEnum.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/ApiEnum.java) — （阶段五）恢复两条 reporter 回馈枚举，重命名去冲突

**新增（Java）**
- `rcs/mapper/RcsTaskMapper.java`、`rcs/mapper/RcsTaskLifecycleMapper.java`
- `rcs/service/RcsTaskService.java`、`rcs/service/impl/RcsTaskServiceImpl.java`
- （可选）`rcs/service/RcsTaskLifecycleService.java` + impl
- `rcs/model/dto/RcsTaskDTO.java`、`rcs/model/dto/RcsTaskQueryDTO.java`
- `rcs/model/entity/RcsTaskLifecycleEntity.java`、`rcs/model/vo/RcsTaskLifecycleVO.java`
- `rcs/utils/RcsTaskConverter.java`
- `rcs/enums/RcsTaskStatusEnum.java`、`RcsTaskTypeEnum.java`、`RcsTaskPriorityEnum.java`、`RcsOperatorTypeEnum.java`
- `rcs/controller/RcsTaskController.java`、`rcs/controller/RcsReporterController.java`（阶段五）

**新增（资源）**
- `resources/mapper/rcs/RcsTaskMapper.xml`

**数据库**：`wms_rcs_task`、`wms_rcs_task_lifecycle`、`api_request_log` 及各自序列/索引/外键，DDL 已在 [RCS具体功能实现.md](file:///d:/workcoding/wms20260712/develop/RCS具体功能实现.md) 中，执行到目标库即可。

---

## 验证方式（端到端）

1. **建表**：在目标 PostgreSQL 执行 [RCS具体功能实现.md](file:///d:/workcoding/wms20260712/develop/RCS具体功能实现.md) 的 DDL（含序列/索引/外键）。
2. **配置**：确认 `sys_config` 存在 `wms.rcs.baseurl`（[ApiRequestUtils.getBaseurl](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/ApiRequestUtils.java#L117-L124) 从 Redis 缓存的 sys_config 读取）。
3. **编译**：`mvn -q -pl wms compile`（确认 MapStruct 生成 Converter 实现、无映射错误）。
4. **CRUD 验证**：启动后经 Swagger/前端调用 `POST /api/v1/rcs-task` 建单 → `GET` 分页/详情查得，`create_by/create_time` 自动填充正确（验证阶段一列名修正生效）。
5. **下发闭环**：对建好的任务调 `POST /{id}/submit`，验证 `wms_rcs_task.status=1`、`rcs_task_id` 已回填、`assigned_at` 有值；同时 `api_request_log` 新增一条 `AGV_submitTask` 记录。
6. **生命周期**：每次状态变更后查 `wms_rcs_task_lifecycle`，确认每次流转一条记录且 `status_from/status_to` 正确，详情接口返回完整时间线。
7. **回调**（阶段五）：用 MCP 浏览器或 curl 模拟 RCS 回调 `POST /api/v1/rcs/reporter/task`，验证按 `rcs_task_id` 反查并驱动 `1→2→3` 流转、lifecycle 落 `operator_type=EXTERNAL`。
8. **异常路径**：故意让 RCS 返回非 0（或断开 baseurl），验证任务落 `status=5(异常)`、`error_msg` 有值，且本地事务未污染其它数据。

---

## 待确认（实现前）

- **回调接口鉴权策略**（阶段五）：独立 token/IP 白名单 vs 纳入 `@ss` 权限体系——取决于与 RCS 对接方约定。
- **payload 存储方式**：`jsonb` 列在实体侧用 `String` + 手写 JSON，还是引入 MyBatis-Plus JSON TypeHandler（`@TableField(typeHandler=JacksonTypeHandler.class)` + `@TableName(autoResultMap=true)`）。推荐后者，更类型安全。
