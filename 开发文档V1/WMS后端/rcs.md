# RCS 对接与任务管理模块（rcs）

## 1. 模块概述

本模块负责与 **AGV 调度系统 RCS（版本 4.3）** 对接，实现搬运任务的自动化调度闭环。包含两大方向：

- **出站调用（WMS → RCS）**：WMS 按需调用 RCS 提供的接口（任务下发、取消、查询、区域控制、载具绑定等），统一走 `ApiEnum`（接口配置枚举）+ `ApiRequestUtils`（统一请求执行器）＋ `AgvController.commonRequest` 通用入口。
- **入站回调（RCS → WMS）**：RCS 主动回馈任务执行过程/告警/资源请求等，由 `RcsReporterController` 承接，反查本地任务并驱动状态流转。

核心业务能力：
- `wms_rcs_task` 任务台账 + `wms_rcs_task_lifecycle` 状态变更历史，任务 **6 态全生命周期可追溯**；
- 三个闭环：**下发闭环**（建单→下发→回填→派发）、**取消闭环**（取消→RCS 联动→落库）、**回调闭环**（RCS 回馈→映射→流转）；
- 状态机校验：非法流转拦截，终态锁死，异常可恢复。

```
┌──────────────┐   出站(通用请求)   ┌────────────────┐
│  WMS 业务侧   │ ─────────────────► │  RCS 调度系统    │
│ RcsTaskServiceImpl │  ApiRequestUtils  │  AGV 执行任务    │
└──────────────┘ ◄───────────────── └────────────────┘
       ▲          入站(回调)                │
       │      RcsReporterController         │
       │                                    ▼
   wms_rcs_task / wms_rcs_task_lifecycle（本地台账+历史）
```

---

## 2. 数据表设计（来源 public.sql）

### 2.1 `wms_rcs_task` —— RCS 任务表

任务台账主表，`payload` 使用 **jsonb** 类型（PostgreSQL 14+）。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| task_code | varchar(64) NOT NULL | 任务编号（业务主键，全局唯一，`uk_wms_rcs_task_task_code`） |
| task_type | int4 NOT NULL | 任务类型：1-搬运 2-充电 3-调度 4-巡检 |
| task_title | varchar(128) | 任务标题 |
| from_location / to_location | varchar(64) | 起点/终点位置编码（关联 wms_point.point_code） |
| cart_code | varchar(64) | 关联料车编码（关联 wms_cart.cart_code） |
| payload | jsonb | 任务扩展参数（JSON，物料信息、路径约束等） |
| status | int4 DEFAULT 0 | 任务状态：0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常 |
| priority | int4 DEFAULT 2 | 优先级：1-低 2-中 3-高 4-紧急 |
| agv_code | varchar(64) | 执行 AGV 编号 |
| rcs_task_id | varchar(64) | RCS 系统返回的外部任务 ID（下发成功后回填） |
| submit_time / assigned_at / start_time / finish_time | timestamp | 提交 / 派发 / 开始 / 完成时间 |
| error_msg | text | 异常信息 |
| remark | varchar(500) | 备注 |
| created_by / created_time / updated_by / updated_time | int8 / timestamp | 审计字段（created_time/updated_time 默认 CURRENT_TIMESTAMP） |

**索引**：`idx_wms_rcs_task_agv_code`、`idx_wms_rcs_task_cart_code`、`idx_wms_rcs_task_status_time`、`idx_wms_rcs_task_submit_time`、唯一索引 `uk_wms_rcs_task_task_code`。

### 2.2 `wms_rcs_task_lifecycle` —— 任务状态变更历史表

记录每次状态流转，**仅一个审计字段 created_time**（无 update_time/create_by/update_by），故不继承 BaseEntity 独立声明。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| task_id | int8 NOT NULL | 关联 wms_rcs_task.id（外键，删除任务级联删除历史） |
| status_from | int4 | 变更前状态 |
| status_to | int4 NOT NULL | 变更后状态 |
| operator_type | varchar(20) | 操作者类型：SYSTEM-系统自动 / ADMIN-管理员 / AGV-AGV自主 / EXTERNAL-外部系统 |
| operator_id | varchar(64) | 操作者标识（AGV 编号或用户 ID） |
| remark | varchar(255) | 变更备注 |
| created_time | timestamp DEFAULT CURRENT_TIMESTAMP | 状态变更时间 |

**约束**：外键 `fk_wms_rcs_task_lifecycle_task`（task_id → wms_rcs_task.id，ON DELETE CASCADE）；索引 `idx_wms_rcs_task_lifecycle_task_id`、`idx_wms_rcs_task_lifecycle_create_time`。

---

## 3. 数据库交互

本模块与数据库的全部交互集中在 [RcsTaskServiceImpl.java](../../wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java)、[RcsTaskMapper.java](../../wms/src/main/java/com/wms/rcs/mapper/RcsTaskMapper.java) 及其 [XML](../../wms/src/main/resources/mapper/rcs/RcsTaskMapper.xml)、[RcsTaskLifecycleMapper.java](../../wms/src/main/java/com/wms/rcs/mapper/RcsTaskLifecycleMapper.java)，底层为 **MyBatis-Plus**。

### 3.1 数据访问方式总览

| 能力 | 实现方式 | 说明 |
|------|---------|------|
| 通用 CRUD | 继承 `BaseMapper` / `ServiceImpl` | 单表增删改查零 SQL，如 `getById` / `save` / `updateById` / `removeById` / `getOne` |
| 条件构造 | `LambdaQueryWrapper` | 类型安全的条件查询，如按 taskCode / rcsTaskId 反查任务 |
| 分页查询 | 自定义 XML SQL + `Page` 对象 | 分页由 MyBatis-Plus 分页插件拦截改写，SQL 中只需写业务查询与 JOIN |

### 3.2 与数据库交互点明细（按业务流程）

| 流程 | 数据库操作 | 说明 |
|------|-----------|------|
| 分页列表 `getRcsTaskPage` | `RcsTaskMapper.getRcsTaskPage(page, query)` | XML 动态 SQL：LEFT JOIN `sys_user` 取创建/更新人昵称；条件动态拼接；`payload` 经 JacksonTypeHandler 反序列化为 Map |
| 详情 `getRcsTaskDetail` | `getById(id)` + `rcsTaskLifecycleMapper.selectList` | 查主表后按 taskId 查全部生命周期（按时间+ID 升序），组装状态时间线 |
| 建单 `saveRcsTask` | `save(entity)` + `rcsTaskLifecycleMapper.insert` | 同一事务：插入主表（status=待执行）+ 写入初始生命周期（null→待执行），保证从建单起可追溯 |
| 状态流转 `changeStatus` | `updateById(task)` + `insert(lifecycle)` | 唯一状态流转入口，同一事务写主表状态/时间戳 + 一条历史；目标状态与当前相同则跳过（幂等） |
| 下发成功 `applyAssigned` | `getById` + `updateById` + `insert` | `REQUIRES_NEW` 独立事务：回填 rcs_task_id + 流转已派发 |
| 下发失败 `applyException` | `getById` + `updateById` + `insert` | `REQUIRES_NEW` 独立事务：流转异常并记录 error_msg |
| 取消落库 `applyCancelled` | `getById` + `updateById` + `insert` | `REQUIRES_NEW` 独立事务：流转已取消 |
| 修改 `updateRcsTask` | `updateById(entity)` | 仅待执行可改；强制回写 taskCode/status/submitTime，防止业务主键与状态被表单覆盖 |
| 删除 `deleteRcsTasks` | `removeById(taskId)` | 逐个删除；**生命周期历史不手动删**，由外键 `fk_wms_rcs_task_lifecycle_task` ON DELETE CASCADE 级联清理 |
| 回调反查 `findTask` | `getOne(LambdaQueryWrapper)` | taskCode 优先、rcsTaskId 兜底，`getOne(..., false)` 多结果不抛异常 |

### 3.3 jsonb 字段（payload）的读写映射

`wms_rcs_task.payload` 为 PostgreSQL **jsonb** 类型，Java 侧映射为 `Map<String, Object>`，两处配置保证读写一致：

- **实体** [RcsTaskEntity.java](../../wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java)：`@TableName(value = "wms_rcs_task", autoResultMap = true)` + `@TableField(typeHandler = JacksonTypeHandler.class)` —— `autoResultMap` 使 MyBatis 为该字段生成对应 ResultMap；
- **XML** [RcsTaskMapper.xml](../../wms/src/main/resources/mapper/rcs/RcsTaskMapper.xml)：`resultMap` 中同样声明 `typeHandler="com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler"`。

### 3.4 审计字段自动填充

- `wms_rcs_task.created_by / created_time / updated_by / updated_time`：实体上 `@TableField(fill = FieldFill.INSERT / INSERT_UPDATE)`，由框架层 [AutoFillMetaObjectHandler](../../wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) 在 insert/update 时按属性名自动填充；
- `wms_rcs_task_lifecycle` 仅 `created_time` 一个审计字段（表设计如此，实体不继承 BaseEntity）。

### 3.5 事务边界总结

| 方法 | 事务传播 | 目的 |
|------|---------|------|
| `saveRcsTask` | `@Transactional` | 建单与初始生命周期原子提交 |
| `changeStatus` | `@Transactional` | 主表状态 + 历史记录原子写入 |
| `applyAssigned / applyException / applyCancelled` | `@Transactional(REQUIRES_NEW)` | 远程调用结果独立事务落库，互不影响主流程 |
| `updateRcsTask / deleteRcsTasks / handleTaskReport / handleTaskWarning` | `@Transactional` | 各自业务原子性 |
| 远程调用（AGV_submitTask / AGV_cancelTask） | **事务外** | 避免远程调用长时间占用数据库连接 |

> 设计要点：`saveAndSubmitRcsTask` 通过 `@Lazy self` 代理调用 `self.saveRcsTask(...)` / `self.applyAssigned(...)`，保证 `@Transactional` 在代理上生效（规避同类方法自调用事务失效），同时实现"建单事务"与"结果落库事务"的隔离。

### 3.6 分页 SQL 关键片段（RcsTaskMapper.xml）

```xml
<select id="getRcsTaskPage" resultMap="RcsTaskVOResultMap">
    SELECT t.id, t.task_code, t.payload, ..., 
           su1.nickname AS created_by_name, su2.nickname AS updated_by_name
    FROM wms_rcs_task t
    LEFT JOIN sys_user su1 ON t.created_by = su1.id
    LEFT JOIN sys_user su2 ON t.updated_by = su2.id
    <where>
        <if test="queryParams.status != null"> AND t.status = #{queryParams.status} </if>
        <!-- taskCode/agvCode/cartCode 用 LIKE；submitTime 用区间 -->
    </where>
    ORDER BY t.submit_time DESC NULLS LAST, t.id DESC
</select>
```

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/rcs/...`；以下"引用的包"为该文件 import 中的主要部分。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [AgvController.java](../../wms/src/main/java/com/wms/rcs/controller/AgvController.java) | AGV 通用请求接口入口：`POST /api/v1/agv/commonRequest/{methodName}` | `com.wms.rcs.service.AgvService`、`com.wms.common.annotation.Log`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.Result`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize`、`org.springframework.web.bind.annotation.*` | 按 methodName 路由到具体 RCS 接口；`@PreAuthorize("@ss.hasPerm('rcs:agv:request')")` 权限控制；`@Log(module=RCS_AGV)` 记录操作日志 |
| [RcsTaskController.java](../../wms/src/main/java/com/wms/rcs/controller/RcsTaskController.java) | RCS 本地任务管理接口：分页/详情（含时间线）/新增(自动下发)/下发重试/取消/修改/删除 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.result.PageResult/Result`、`com.wms.rcs.model.dto/vo.*`、`jakarta.validation.Valid`、`org.springframework.security.access.prepost.PreAuthorize`、`lombok.RequiredArgsConstructor` | 权限标识 `rcs:task:*` 细分操作；新增与下发、取消接口加 `@RepeatSubmit` 防重复提交；分页返回 `PageResult<RcsTaskVO>` |
| [RcsReporterController.java](../../wms/src/main/java/com/wms/rcs/controller/RcsReporterController.java) | RCS 回调入站接口：`POST /api/v1/rcs/reporter/**`（task / task-warning / robot-warning / resource / eqpt / zone-homing / zone-banish / bind） | `com.wms.rcs.model.dto.Rcs*ReportDTO`、`com.wms.rcs.service.RcsTaskService`、`com.wms.common.annotation.Log`、`lombok.RequiredArgsConstructor/Slf4j`、`org.springframework.web.bind.annotation.*` | 外部调用**不走 @ss 权限**（需在安全放行清单中放行 `/api/v1/rcs/reporter/**`）；统一返回 `{"code":"0","message":"success"}`，未匹配到任务也返回成功码，避免 RCS 侧重试风暴；resource 回调为占位实现，其余仅落日志 |

### 4.2 服务层（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [AgvService.java](../../wms/src/main/java/com/wms/rcs/service/AgvService.java) | AGV 服务接口：按 methodName / 按 ApiEnum 两种方式发起通用请求 | `com.wms.common.enums.ApiEnum`、`com.wms.common.result.Result` | 接口定义，返回 `Result<Object>` |
| [AgvServiceImpl.java](../../wms/src/main/java/com/wms/rcs/service/impl/AgvServiceImpl.java) | AGV 服务实现 | `com.alibaba.fastjson2.JSONObject`、`com.wms.common.util.ApiRequestUtils/StringUtils`、`com.wms.common.enums.ApiEnum`、`com.wms.common.result.Result`、`lombok.extern.slf4j.Slf4j` | ①按 `ApiEnum.getApiEnumByModuleAndMethodName("rcs", methodName)` 查配置 → ②`ApiRequestUtils.execute(apiEnum, null, params)` 发请求 → ③fastjson2 解析，`code=="0"` 判成功，成功返回 data、失败返回 "AGV系统+msg" |
| [RcsTaskService.java](../../wms/src/main/java/com/wms/rcs/service/RcsTaskService.java) | 任务业务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.service.IService`、`com.wms.rcs.model.dto/vo/entity.*` | 继承 `IService<RcsTaskEntity>`；声明分页/详情/新增(自动下发)/下发/取消/修改/删除 + `handleTaskReport`/`handleTaskWarning` 回调处理 |
| [RcsTaskServiceImpl.java](../../wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) | 任务业务核心实现（状态机唯一入口） | `cn.hutool.core.lang.Assert/IdUtil/StrUtil`、`com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.common.enums.ApiEnum`、`com.wms.common.exception.BusinessException`、`com.wms.common.result.Result/ResultCode`、`com.wms.rcs.enums.RcsOperatorTypeEnum/RcsTaskStatusEnum`、`com.wms.rcs.mapper.*`、`org.springframework.context.annotation.Lazy`、`org.springframework.transaction.annotation.Propagation/Transactional` | 详见 [5. 核心实现逻辑](#5-核心实现逻辑) |

### 4.3 持久层（mapper）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [RcsTaskMapper.java](../../wms/src/main/java/com/wms/rcs/mapper/RcsTaskMapper.java) | 任务持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.rcs.model.dto.RcsTaskQueryDTO`、`com.wms.rcs.model.entity.RcsTaskEntity`、`com.wms.rcs.model.vo.RcsTaskVO`、`org.apache.ibatis.annotations.Mapper` | 继承 BaseMapper；声明分页查询 `getRcsTaskPage(Page, QueryDTO)`，SQL 在 XML 中 |
| [RcsTaskMapper.xml](../../wms/src/main/resources/mapper/rcs/RcsTaskMapper.xml) | 任务分页 SQL | MyBatis XML（`resultMap` + `JacksonTypeHandler` 处理 jsonb） | LEFT JOIN sys_user 取创建/更新人昵称；`payload` 用 `JacksonTypeHandler` 从 jsonb 映射为 Map；条件动态拼接（taskCode/taskType/status/priority/agvCode/cartCode/submitTime 区间）；`ORDER BY submit_time DESC NULLS LAST, id DESC` |
| [RcsTaskLifecycleMapper.java](../../wms/src/main/java/com/wms/rcs/mapper/RcsTaskLifecycleMapper.java) | 状态变更历史持久层 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.wms.rcs.model.entity.RcsTaskLifecycleEntity`、`org.apache.ibatis.annotations.Mapper` | 仅继承 BaseMapper，无自定义 SQL |

### 4.4 实体层（model/entity）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [RcsTaskEntity.java](../../wms/src/main/java/com/wms/rcs/model/entity/RcsTaskEntity.java) | 任务实体 | `com.baomidou.mybatisplus.annotation.*`（TableName/TableField/FieldFill）、`com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler`、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.*`、`lombok.Data/EqualsAndHashCode` | `@TableName(value="wms_rcs_task", autoResultMap=true)`；审计字段映射到 `created_time/updated_time/created_by/updated_by`（`FieldFill.INSERT/INSERT_UPDATE` 自动填充）；`payload` 用 `JacksonTypeHandler` 映射 jsonb |
| [RcsTaskLifecycleEntity.java](../../wms/src/main/java/com/wms/rcs/model/entity/RcsTaskLifecycleEntity.java) | 状态变更历史实体 | `com.baomidou.mybatisplus.annotation.*`（TableId/IdType/TableField/TableName/FieldFill）、`com.fasterxml.jackson.annotation.*`、`lombok.Data`、`java.io.Serializable` | `@TableName("wms_rcs_task_lifecycle")`；**不继承 BaseEntity**（表无 update 字段），仅 created_time 自动填充 |

### 4.5 传输对象（model/dto、model/vo）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [AgvRequestDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/AgvRequestDTO.java) | AGV 出站请求 DTO 公共父类 | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank`、`lombok.Getter/Setter`、`java.io.Serializable` | 承载 `reqCode`（全局唯一请求编号，重复提交沿用同一编号，保证 RCS 侧幂等） |
| [RcsTaskDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsTaskDTO.java) | 任务表单 DTO | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotNull`、`org.hibernate.validator.constraints.Range`、`lombok.Getter/Setter` | 接收可编辑字段（taskType/taskTitle/fromLocation/toLocation/cartCode/payload/priority/remark）；taskCode/status/时间由服务端控制，不接收 |
| [RcsTaskQueryDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsTaskQueryDTO.java) | 分页查询条件 | `com.wms.common.base.BaseQuery`、Lombok | 继承 BaseQuery（pageNum/pageSize/sortBy）；筛选字段：taskCode/taskType/status/priority/agvCode/cartCode/submitTimeStart/submitTimeEnd |
| [RcsTaskReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsTaskReportDTO.java) | RCS 任务执行回馈请求体（入站） | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.io.Serializable`、`java.util.Map` | 兼容不同 RCS 版本字段命名：任务标识 `taskCode`（首选）/`taskId`（兜底）；状态语义兼容字符串 `method` 与数值 `status`；`extra` 承接扩展字段 |
| [RcsTaskWarningDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsTaskWarningDTO.java) | 任务异常告警请求体（入站） | 同 RcsTaskReportDTO | 告警反查与回馈一致，匹配后任务流转"异常"并写告警信息 |
| [RcsBindReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsBindReportDTO.java) / [RcsEqptReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsEqptReportDTO.java) / [RcsHomingReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsHomingReportDTO.java) / [RcsBanishReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsBanishReportDTO.java) / [RcsResourceReportDTO.java](../../wms/src/main/java/com/wms/rcs/model/dto/RcsResourceReportDTO.java) | 绑定解绑/外设/归巢/驱离/资源请求回调体（入站） | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.io.Serializable` | SPI 回调占位 DTO，当前仅承接字段并落日志 |
| [RcsTaskVO.java](../../wms/src/main/java/com/wms/rcs/model/vo/RcsTaskVO.java) | 任务视图对象 | Lombok | 在实体字段基础上增加 `taskTypeLabel/statusLabel/priorityLabel`（枚举中文）与 `createdByName/updatedByName`（创建/更新人昵称） |
| [RcsTaskLifecycleVO.java](../../wms/src/main/java/com/wms/rcs/model/vo/RcsTaskLifecycleVO.java) | 状态历史视图对象 | Lombok | 增加 `statusFromLabel/statusToLabel` 状态中文描述 |

### 4.6 枚举（enums）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [RcsTaskStatusEnum.java](../../wms/src/main/java/com/wms/rcs/enums/RcsTaskStatusEnum.java) | 任务状态枚举 + **状态机** | `lombok.Getter` | 6 态（0待执行/1已派发/2执行中/3已完成/4已取消/5异常）；`TRANSITIONS` 白名单矩阵定义合法流转；`canTransfer(from,to)` 校验、`isFinal` 终态判定、`getLabelByValue` 描述 |
| [RcsTaskTypeEnum.java](../../wms/src/main/java/com/wms/rcs/enums/RcsTaskTypeEnum.java) | 任务类型枚举 | `lombok.Getter` | 1搬运/2充电/3调度/4巡检，`getLabelByValue` |
| [RcsTaskPriorityEnum.java](../../wms/src/main/java/com/wms/rcs/enums/RcsTaskPriorityEnum.java) | 优先级枚举 | `lombok.Getter` | 1低/2中/3高/4紧急 |
| [RcsOperatorTypeEnum.java](../../wms/src/main/java/com/wms/rcs/enums/RcsOperatorTypeEnum.java) | 操作者类型枚举 | `lombok.Getter` | SYSTEM/ADMIN/AGV/EXTERNAL，写入 lifecycle.operator_type |

### 4.7 转换器（utils）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [RcsTaskConverter.java](../../wms/src/main/java/com/wms/rcs/utils/RcsTaskConverter.java) | 任务对象转换器 | `org.mapstruct.Mapper/AfterMapping/MappingTarget`、`com.wms.rcs.enums.*`、`com.wms.rcs.model.dto/entity/vo.*` | `@Mapper(componentModel="spring")` 编译期生成实现；`@AfterMapping` 在 DTO↔Entity↔VO 映射后补齐枚举中文描述 |

### 4.8 跨模块依赖（common）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiEnum.java](../../wms/src/main/java/com/wms/common/enums/ApiEnum.java) | API 接口配置枚举（统一管理 AGV/MES 接口配置） | `com.baomidou.mybatisplus.core.toolkit.StringUtils`、`com.wms.business.agv.*`（出站 DTO）、`com.wms.rcs.model.dto.AgvRequestDTO`、`lombok.Getter` | 每项配置：code（接口编码）/methodName（URL 拼接 + 按名查找键）/name/desc（WebService 用）/method（POST/GET/WebService）/module（配置键 `wms.{module}.baseurl` + 返回值解析逻辑）/paramsClass（非空则请求前参数校验）；SPI 回调 8 项已注释停用（迁移至 RcsReporterController）；查找方法 `getApiEnumByMethodName` / `getApiEnumByModuleAndMethodName` |
| [RcsConstants.java](../../wms/src/main/java/com/wms/common/constant/RcsConstants.java) | RCS 常量定义 | 无（纯常量类，私有构造器） | 请求头标识：`X-lr-request-id`、`X-lr-version`、`X-lr-trace-id`；版本号 `4.3` |
| [ApiRequestUtils.java](../../wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) | 统一请求执行器（出站核心） | Hutool HttpUtil / SoapClient、OrikaUtils、fastjson2、异步线程池 | 详见 README 公共工具章节（待编写）；组装请求头（requestId/version/traceId）、按 ApiEnum.method 分发 POST/GET/WebService、请求前用 paramsClass 做参数校验、`finally` 中异步记录 api_request_log、失败支持重试 |

---

## 5. 核心实现逻辑

### 5.1 状态机（RcsTaskStatusEnum + RcsTaskServiceImpl.changeStatus）

**状态定义**：`0-待执行 → 1-已派发 → 2-执行中 → 3-已完成 / 4-已取消 / 5-异常`

**合法流转矩阵（TRANSITIONS 白名单）**：

| from \ to | 待执行(0) | 已派发(1) | 执行中(2) | 已完成(3) | 已取消(4) | 异常(5) |
|-----------|:--:|:--:|:--:|:--:|:--:|:--:|
| 待执行(0) | — | ✅ | ✅ | ✅ | ✅ | ✅ |
| 已派发(1) | — | — | ✅ | ✅ | ✅ | ✅ |
| 执行中(2) | — | — | — | ✅ | ✅ | ✅ |
| 已完成(3) | 终态，不可流转 | | | | | |
| 已取消(4) | 终态，不可流转 | | | | | |
| 异常(5) | ✅(重试下发) | ✅ | ✅ | — | ✅ | — |

- **已完成/已取消为终态**：迟到回调/人工操作均不再流转；
- **异常可恢复**：异常态可回到待执行（重试下发）或已派发/执行中/已取消；
- **禁止回退**：执行中不可回退到已派发/待执行。

**changeStatus**（状态流转唯一入口）：
1. `RcsTaskStatusEnum.canTransfer(from, to)` 校验合法性，非法流转记 warn 日志并跳过（不抛异常）；
2. 同一事务内：更新主表 `status` + 对应时间戳（派发/开始/完成）→ 插入一条 `wms_rcs_task_lifecycle`（含 from/to/operatorType/operatorId/remark）。

### 5.2 下发闭环（saveAndSubmitRcsTask / submitRcsTask）

```
新增/重试 ─► 校验(仅待执行可下发) ─► [事务外] AGV_submitTask
             ▲                        │ reqCode = 本地任务编号（幂等）
             │                        ▼
             │                    RCS 返回 code=0 ?
             │                    ├─ 是：经 @Lazy self 代理触发 REQUIRES_NEW 事务
             │                    │    回填 rcs_task_id ─► 流转 已派发(1)
             │                    └─ 否：经 self 代理触发 REQUIRES_NEW 事务
             │                          流转 异常(5)，记录 errorMsg，可再次下发
             └────── 本地建单(待执行) 已落库（与远程下发不同事务）
```

**关键设计**：
- **远程调用在数据库事务之外**：避免远程调用长时间占用数据库连接；
- **`@Lazy self` 自注入代理**：下发成功/失败后的库写操作经代理触发 `@Transactional(REQUIRES_NEW)`，规避同类方法自调用导致事务注解失效；
- **建单与下发分离**：下发失败不回滚本地任务，而是置为"异常"，支持人工重试；
- **reqCode = 本地任务编号**：保证 RCS 侧幂等（同一请求重复提交使用同一编号）。

### 5.3 取消闭环（cancelRcsTask）

```
取消 ─► 校验终态拒绝
        ├─ 待执行(0)：本地直接流转 已取消(4)
        └─ 已派发(1)/执行中(2)：
             [事务外] AGV_cancelTask ─► 成功：落库 已取消(4)
                                        └► 失败：抛 BusinessException，本地状态不变
```

### 5.4 回调闭环（handleTaskReport / handleTaskWarning）

```
RCS 回馈 ─► 反查本地任务：taskCode 优先，rcsTaskId 兜底
            ├─ 未匹配：仅记日志，返回成功码（避免重试风暴）
            └─ 匹配：
                 mapReportToStatus 兼容映射（字符串 method / 数值 status → 本地 6 态）
                 ─► changeStatus(operatorType=EXTERNAL)
                       ├─ 终态任务收到迟到回馈：仅记录，不流转
                       └─ 异常告警：流转 异常(5) + 写 errorMsg
```

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MyBatis-Plus | 通用 Mapper、LambdaQueryWrapper 条件查询、Page 分页、JacksonTypeHandler 处理 jsonb |
| Spring `@Transactional` / `Propagation.REQUIRES_NEW` | 状态流转同事务写入主表+历史；远程调用结果独立事务落库 |
| `@Lazy` 自注入代理 | 解决同类方法自调用事务失效 |
| MapStruct | DTO/Entity/VO 编译期转换 + @AfterMapping 补枚举描述 |
| Hutool | Assert 断言、IdUtil（雪花/任务编号）、StrUtil、HttpUtil/SoapClient 发请求 |
| fastjson2 | 响应 JSON 解析（code/message/data） |
| PostgreSQL jsonb | 任务扩展参数存储 |
| Spring Security `@PreAuthorize` | 接口级权限（rcs:task:* / rcs:agv:request） |
| `@RepeatSubmit`（Redisson） | 新增/下发/取消防重复提交 |
| `@Log` AOP | 操作日志埋点 |
| Knife4j | 接口文档注解 |
