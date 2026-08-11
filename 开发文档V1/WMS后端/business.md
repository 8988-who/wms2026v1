# 接口请求日志与AGV出站参数模块（business）

## 1. 模块概述

本模块由两部分组成，均服务于"WMS 与外部系统（RCS/AGV 调度系统等）接口调用"这一条主链路：

- **接口请求日志（`business.log`）**：承载唯一数据表 `api_request_log`，对每一次经 `ApiRequestUtils.execute` 发起的外部接口调用（POST/GET/WebService）**异步落库**，记录请求/响应报文、HTTP/业务状态码、耗时、重试次数与链路追踪 ID，供链路追踪与性能监控使用；
- **AGV 出站参数 DTO（`business.agv`）**：21 个 AGV 出站请求参数对象，全部继承 `com.wms.rcs.model.dto.AgvRequestDTO`（复用 `reqCode` 幂等键），被 [ApiEnum.java](../../wms/src/main/java/com/wms/common/enums/ApiEnum.java) 通过 `import com.wms.business.agv.*` 引用，作为各 AGV 接口的 `paramsClass` 与 RCS 模块配合使用（详见 [rcs.md](./rcs.md)）。**本子目录不承载任何业务逻辑，纯参数定义**。

> 另：`business.plc.handler` 下的 `OnlinePlcHandler.java` / `OfflinePlcHandler.java` 为**整文件注释掉的死代码**（引用了旧版不存在的包 `com.wms.business.agv.domain` 等），不参与编译，仅作历史回溯留存。

关键流程简述：

```
业务侧（如 rcs 模块 RcsTaskServiceImpl）──► ApiRequestUtils.execute(ApiEnum, headers, params)
    ├─ paramsClass 非空 → OrikaUtils.mapBean + ValidatorUtils.validateEntity 参数校验
    ├─ 按 method 分发 POST / GET / WebService（Hutool 执行）
    ├─ 统一组装请求头（X-lr-request-id / X-lr-version / X-lr-trace-id）
    └─ finally 中构造 ApiRequestLog → ApiRequestLogService.saveLogAsync 异步落库（不阻塞主流程）
                                               ▲
                          API 查询入口（ApiRequestLogController，供前端/运维查看）
```

---

## 2. 数据表设计（来源 [public.sql](../../wms/sql/public.sql)）

### 2.1 `api_request_log` —— 接口请求日志表

记录所有外部系统接口调用，支持链路追踪与性能监控。主键由序列 `api_request_log_id_seq` 自增。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8 NOT NULL（默认 nextval 序列） | 主键ID（自增） |
| api_code | varchar(64) | 接口编码 |
| api_method_name | varchar(128) | 接口方法名 |
| api_url | varchar(512) | 接口地址 |
| api_name | varchar(128) | 接口名称 |
| req_params | text | 请求参数（JSON格式） |
| res_params | text | 返回参数（JSON格式） |
| is_success | varchar(1) | 是否成功：Y-成功，N-失败 |
| err_msg | text | 错误信息 |
| module | varchar(64) | 所属模块（如 RCS、WMS、MES） |
| req_time | timestamp(6) | 请求时间 |
| res_time | timestamp(6) | 返回时间 |
| http_code | varchar(16) | HTTP状态码（200、404、500等） |
| res_code | varchar(16) | 业务返回状态码 |
| duration | int8 | 耗时（毫秒） |
| retry_count | int4 DEFAULT 0 | 重试次数 |
| trace_id | varchar(64) | 链路追踪ID |
| created_by | int8 | 创建人ID |
| created_time | timestamp(6) DEFAULT CURRENT_TIMESTAMP | 创建时间 |
| updated_by | int8 | 更新人ID |
| updated_time | timestamp(6) DEFAULT CURRENT_TIMESTAMP | 更新时间 |
| remark | varchar(500) | 备注 |

---

## 3. 数据库交互

数据访问集中在 [ApiRequestLogServiceImpl.java](../../wms/src/main/java/com/wms/business/log/service/impl/ApiRequestLogServiceImpl.java)，基于 **MyBatis-Plus**（`ServiceImpl<ApiRequestLogMapper, ApiRequestLog>`）。

### 3.1 数据访问方式

| 能力 | 实现方式 | 说明 |
|------|---------|------|
| 通用 CRUD | 继承 `ServiceImpl` | 直接使用 `save` / `remove` / `page` |
| 条件构造 | `LambdaQueryWrapper` | 类型安全动态条件 |
| 分页 | `Page` + `page()` | MyBatis-Plus 分页插件 |

### 3.2 交互点明细

| 方法 | 数据库操作 | 说明 |
|------|-----------|------|
| `findList(queryDTO)` | `page(page, wrapper)` | 条件：module/apiCode/apiUrl/apiName/isSuccess/reqParams（部分 `like`），`orderByDesc(reqTime)` |
| `saveLogAsync(requestLog)` | `super.save()` | **异步线程池**执行；代码手动填充 createBy/createName/updateBy/updateName/createTime/updateTime（取自 `SecurityUtils.getUser()`），不走 AutoFillMetaObjectHandler |
| `delLogAsync(requestLog)` | `super.remove(wrapper)` | 异步删除 `is_success='N'` 且 `remark` 匹配的历史报错日志 |

### 3.3 事务边界

所有日志写操作为**异步线程池**（`operationLogExecutor`，core=1/max=2/queue=1000，CallerRunsPolicy）内独立提交：

- 与业务主事务隔离，**外层事务回滚不影响日志落库**（`ApiRequestUtils.execute` 的 finally 异步记日志设计的关键）；
- 异步内异常仅记录 error 日志，不向上抛出，避免影响调用方。

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/business/...`；以下"引用的包"为该文件 import 中的主要部分。

### 4.1 控制器层（log/controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiRequestLogController.java](../../wms/src/main/java/com/wms/business/log/controller/ApiRequestLogController.java) | 接口请求日志查询入口：`GET /api/v1/api-request-logs`（分页）、`GET /api/v1/api-request-logs/{id}`（详情） | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.business.log.model.entity.ApiRequestLog`、`com.wms.business.log.model.dto.ApiRequestLogQueryDTO`、`com.wms.business.log.service.ApiRequestLogService`、`com.wms.common.annotation.Log`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`io.swagger.v3.oas.annotations.*`、`lombok.RequiredArgsConstructor`、`org.springframework.web.bind.annotation.*` | 分页接口标注 `@Log(module = API_REQUEST_LOG, value = LIST)` 记操作日志；返回 `PageResult<ApiRequestLog>`；详情直接 `getById(id)`。**日志写入不走此控制器**（由公共工具类触发） |

### 4.2 服务层（log/service、log/service/impl）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiRequestLogService.java](../../wms/src/main/java/com/wms/business/log/service/ApiRequestLogService.java) | 日志服务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.service.IService`、`com.wms.business.log.model.entity.ApiRequestLog`、`com.wms.business.log.model.dto.ApiRequestLogQueryDTO` | 继承 `IService<ApiRequestLog>`；声明 `findList` 分页查询、`saveLogAsync` 异步保存、`delLogAsync` 异步删除自动任务报错历史 |
| [ApiRequestLogServiceImpl.java](../../wms/src/main/java/com/wms/business/log/service/impl/ApiRequestLogServiceImpl.java) | 日志服务实现（**异步落库核心**） | `cn.hutool.core.util.StrUtil`、`com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.business.log.model.entity.ApiRequestLog`、`com.wms.business.log.mapper.ApiRequestLogMapper`、`com.wms.framework.security.util.SecurityUtils`、`lombok.extern.slf4j.Slf4j`、`org.springframework.beans.factory.annotation.Qualifier`、`java.util.concurrent.Executor` | 构造注入 `@Qualifier("operationLogExecutor")` 线程池；`findList` 用 `LambdaQueryWrapper` 动态拼接条件（module/apiCode 等值、apiUrl/apiName/reqParams 模糊），`orderByDesc(reqTime)` + `Page` 分页；`saveLogAsync` / `delLogAsync` 详见 [5. 核心实现逻辑](#5-核心实现逻辑) |

### 4.3 持久层（log/mapper）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiRequestLogMapper.java](../../wms/src/main/java/com/wms/business/log/mapper/ApiRequestLogMapper.java) | 日志持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.wms.business.log.model.entity.ApiRequestLog`、`org.apache.ibatis.annotations.Mapper` | 仅继承 `BaseMapper<ApiRequestLog>`，无自定义 SQL，无 XML |

### 4.4 实体与传输对象（log/model）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiRequestLog.java](../../wms/src/main/java/com/wms/business/log/model/entity/ApiRequestLog.java) | 接口请求日志实体 | `com.baomidou.mybatisplus.annotation.FieldFill/TableField/TableName`、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.JsonFormat/JsonInclude`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode`、`org.apache.ibatis.type.JdbcType`、`java.time.LocalDateTime` | `@TableName("api_request_log")` 继承 `BaseEntity`；`reqParams/resParams` 标注 `@TableField(jdbcType = JdbcType.CLOB)`；审计字段显式声明 `@TableField(value = "created_by/created_time/updated_by/updated_time", fill = FieldFill.INSERT / INSERT_UPDATE)`（与 BaseEntity 属性名 `createBy/createTime/updateBy/updateTime` 映射列名），`createName/updateName` 仅存名称无对应列 |
| [ApiRequestLogQueryDTO.java](../../wms/src/main/java/com/wms/business/log/model/dto/ApiRequestLogQueryDTO.java) | 日志查询条件 DTO | `com.wms.common.base.BaseQuery`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode`、`java.io.Serializable` | 继承 `BaseQuery`（pageNum/pageSize）；筛选字段：module、apiCode、apiUrl、apiName、isSuccess、reqParams |
| [ApiRequestLogVO.java](../../wms/src/main/java/com/wms/business/log/model/vo/ApiRequestLogVO.java) | 日志视图对象 | `com.fasterxml.jackson.annotation.JsonFormat`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.time.LocalDateTime` | 与实体字段基本一致，额外增加 `isSuccessLabel`（成功/失败中文描述）；当前控制器未使用（直接返回实体） |

### 4.5 AGV 出站参数 DTO（agv）

21 个 DTO 全部继承 `com.wms.rcs.model.dto.AgvRequestDTO`（复用请求编号 `reqCode` 幂等键），经 `import com.wms.business.agv.*` 被 [ApiEnum.java](../../wms/src/main/java/com/wms/common/enums/ApiEnum.java) 引用，与 ApiEnum 中 21 个 `AGV_*` 出站接口一一对应（`paramsClass`），由 rcs 模块 `AgvController.commonRequest` 配合使用：

| 文件 | 用途（对应 ApiEnum 接口 / URL） |
|------|------|
| [AgvSubmitTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvSubmitTaskDTO.java) | 任务下发（`AGV_submitTask` / task/submit）。最核心接口：taskType 决定流程类型（PF-LMR-COMMON 潜伏车等），targetRoute 步骤集合（COLLECT 取货/DELIVERY 送货/ROTATE 旋转） |
| [AgvCancelTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvCancelTaskDTO.java) | 任务取消（`AGV_cancelTask` / task/cancel） |
| [AgvContinueTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvContinueTaskDTO.java) | 任务继续执行（`AGV_continueTask` / task/extend/continue） |
| [AgvGroupTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvGroupTaskDTO.java) | 任务组（`AGV_groupTask` / task/group） |
| [AgvPreTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvPreTaskDTO.java) | 预调度任务下发（`AGV_preTask` / task/pretask） |
| [AgvPriorityTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvPriorityTaskDTO.java) | 任务优先级设置（`AGV_priorityTask` / task/priority） |
| [AgvQueryTaskDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvQueryTaskDTO.java) | 查询任务状态（`AGV_queryTask` / task/query） |
| [AgvPauseZoneDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvPauseZoneDTO.java) | 按区域暂停/恢复机器人（`AGV_pauseZone` / zone/pause） |
| [AgvHomingZoneDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvHomingZoneDTO.java) | 区域机器人归巢（`AGV_homingZone` / zone/homing） |
| [AgvBanishZoneDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvBanishZoneDTO.java) | 区域驱离机器人（`AGV_banishZone` / zone/banish） |
| [AgvBlockadeZoneDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvBlockadeZoneDTO.java) | 区域封锁机器人（`AGV_blockadeZone` / zone/blockade） |
| [AgvBindCarrierDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvBindCarrierDTO.java) | 载具与站点绑定（`AGV_bindCarrier` / carrier/bind）：carrierCode + siteCode + carrierDir |
| [AgvLockCarrierDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvLockCarrierDTO.java) | 载具禁用/启用（`AGV_lockCarrier` / carrier/lock） |
| [AgvQueryCarrierDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvQueryCarrierDTO.java) | 查询载具状态（`AGV_queryCarrier` / carrier/query） |
| [AgvBindSiteDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvBindSiteDTO.java) | 存储/搬运对象绑定解绑（`AGV_bindSite` / site/bind） |
| [AgvLockSiteDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvLockSiteDTO.java) | 站点禁用/启用（`AGV_lockSite` / site/lock） |
| [AgvNotifyEqptDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvNotifyEqptDTO.java) | 外设执行通知（`AGV_notifyEqpt` / eqpt/notify） |
| [AgvNotifyGbtEqptDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvNotifyGbtEqptDTO.java) | 国标外设通知（`AGV_notifyGbtEqpt` / /spi/wcs/robot/eqpt/notifyGbt） |
| [AgvQueryRobotDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvQueryRobotDTO.java) | 查询机器人状态（`AGV_queryRobot` / robot/query）：singleRobotCode |
| [AgvBindMatlabelDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvBindMatlabelDTO.java) | 料标签绑定（`AGV_bindMatlabel` / matlabel/bind） |
| [AgvUnbindMatlabelDTO.java](../../wms/src/main/java/com/wms/business/agv/AgvUnbindMatlabelDTO.java) | 料标签解绑（`AGV_unbindMatlabel` / matlabel/unbind） |

> 说明：文件均为 `@Getter/@Setter` + `@Schema` 注解的纯参数类，字段带 `@NotBlank/@NotEmpty` 等 Bean Validation 约束（请求前由 `ApiRequestUtils` 校验），此处不再逐个列 import。SPI 回调类（bindReporter/warningTask 等 9 项）已注释停用，未保留对应 DTO。

### 4.6 遗留目录（plc）

| 文件 | 作用 | 实现要点 |
|------|------|---------|
| [OnlinePlcHandler.java](../../wms/src/main/java/com/wms/business/plc/handler/OnlinePlcHandler.java) / [OfflinePlcHandler.java](../../wms/src/main/java/com/wms/business/plc/handler/OfflinePlcHandler.java) | 历史 PLC 补料信号处理（**整文件注释，死代码**） | 全部代码行被注释，引用旧版 `com.wms.business.agv.domain.TWmsAgvTask`、`com.wms.business.log.enums.ApiEnum` 等已不存在的包，不参与编译，仅作历史回溯 |

### 4.7 跨模块协作（common / framework）

| 文件 | 作用 | 说明 |
|------|------|------|
| [ApiRequestUtils.java](../../wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) | 统一请求执行器 | 出站调用的唯一入口，`finally` 中构造日志并调用 `saveLogAsync` 异步落库（详见 [5](#5-核心实现逻辑)）；本模块日志表因此被写入 |
| [ApiEnum.java](../../wms/src/main/java/com/wms/common/enums/ApiEnum.java) | API 接口配置枚举 | `import com.wms.business.agv.*` 引用本模块 21 个 DTO 作为 `paramsClass`；`module` 决定 baseurl 配置键与返回解析逻辑 |
| [OperationLogExecutorConfig.java](../../wms/src/main/java/com/wms/framework/web/config/OperationLogExecutorConfig.java) | 操作日志线程池 Bean | `operationLogExecutor`：core=1 / max=2 / queue=1000，`CallerRunsPolicy`，shutdown 等待 10 秒；同时服务于 `@Log` 切面与本模块日志落库 |

---

## 5. 核心实现逻辑

### 5.1 ApiRequestUtils.execute 的 finally 异步落库时序

```
ApiRequestUtils.execute(ApiEnum, headers, params)
│
├─ ① 记录 startTime，生成 traceId（IdUtil.fastSimpleUUID）
├─ ② 参数校验：paramsClass 非空 → OrikaUtils.mapBean 转 DTO → ValidatorUtils.validateEntity 校验 @NotBlank 等约束
├─ ③ 拼 URL：baseurl（配置键 wms.{module}.baseurl，未配置抛异常）+ methodName
├─ ④ 初始化 ApiRequestLog：apiCode/apiName/apiMethodName/apiUrl/module/reqTime/reqParams(JSON)/traceId/retryCount=0
├─ ⑤ 组装请求头 mergeHeaders(headers, traceId)：X-lr-request-id（动态UUID）、X-lr-version（4.3）、X-lr-trace-id，调用方传入覆盖
├─ ⑥ 按 ApiEnum.method 分发：
│      POST  → doPost（JSON body，Content-Type: application/json;charset=UTF-8）
│      GET   → doGet（form 参数）
│      WebService → doWebService（SoapClient，desc 拆 SOAPAction/方法名/命名空间）
│      └─ 回填 resParams（响应 body）、httpCode
├─ ⑦ handleByModule 解析：JSON 取 code，code=="0" → isSuccess=Y，否则 N；回填 resCode
│
├─ catch(Exception)：
│      isSuccess=N；errMsg=截断 5000 字符的异常信息；记录异常对象
│
└─ finally：                     ← ★ 日志落库点（无论成功失败必执行）
       ├─ duration = now - startTime（耗时毫秒）
       ├─ resTime = LocalDateTime.now()
       └─ SpringUtils.getBean(ApiRequestLogService.class).saveLogAsync(requestLog)  ← 异步，不阻塞主流程

收尾：存在异常则 throw new RuntimeException(接口名 + "接口请求失败", exception)；否则返回 resParams
```

**设计要点**：
- **`finally` 保证 100% 记录**：无论请求成功、业务失败还是网络异常，日志都会异步落库；`catch` 只影响 `isSuccess/errMsg` 字段；
- **`saveLogAsync` 异步化**：日志写入与业务主流程解耦，即使日志保存失败也不影响外部接口调用结果与性能；
- **`traceId` 贯穿**：请求头 `X-lr-trace-id` 与 `api_request_log.trace_id` 同值，供跨系统链路追踪；`retry_count` 预留重试标记。

### 5.2 saveLogAsync 异步落库（ApiRequestLogServiceImpl）

```
saveLogAsync(ApiRequestLog requestLog)
├─ ① 从 SecurityUtils.getUser() 取当前登录用户（如有）填充 createBy/createName/updateBy/updateName
├─ ② 显式 setCreateTime / setUpdateTime（LocalDateTime.now()）
└─ ③ operationLogExecutor.execute(() -> {
        try { super.save(requestLog); }        // MyBatis-Plus 单表 insert
        catch (Exception e) { log.error("保存接口请求日志失败 apiCode={}", ...); }  // 吞异常，不影响调用方
     })
```

**异步线程池**（[OperationLogExecutorConfig.java](../../wms/src/main/java/com/wms/framework/web/config/OperationLogExecutorConfig.java)）：`ThreadPoolTaskExecutor`，core=1、max=2、queue=1000，拒绝策略 `CallerRunsPolicy`（队列满时由调用线程同步执行兜底，避免日志丢失），应用关闭时等待任务完成最多 10 秒。

### 5.3 分页查询 findList

`LambdaQueryWrapper<ApiRequestLog>` 动态拼接：`module`/`apiCode`/`isSuccess` 等值匹配，`apiUrl`/`apiName`/`reqParams` 模糊匹配（`StrUtil.isNotBlank` 判空），固定 `orderByDesc(reqTime)`；`new Page<>(pageNum, pageSize)` 分页，交由 MyBatis-Plus 分页插件改写。

### 5.4 报错历史清理 delLogAsync

`operationLogExecutor.execute` 异步删除自动任务的历史报错日志：条件为 `isSuccess = 'N'` 且 `remark` 等于给定值（同一业务批次），供自动任务重试场景清理旧的失败记录。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MyBatis-Plus | `BaseMapper`/`ServiceImpl` 通用 CRUD、`LambdaQueryWrapper` 条件查询、`Page` 分页；`ApiRequestLog` 通过 `@TableName` + `BaseEntity` 映射 `api_request_log` |
| `ThreadPoolTaskExecutor`（operationLogExecutor） | 日志异步落库线程池，`CallerRunsPolicy` 兜底、关闭等待 10 秒 |
| Hutool | `StrUtil` 判空、`HttpUtil/HttpRequest` 发起 POST/GET、`SoapClient` 调用 WebService、`IdUtil` 生成 requestId/traceId |
| fastjson2 | 请求/响应参数序列化（`JSONObject.toJSONString`）、响应 `code` 解析判定成功 |
| Spring `@Qualifier` 注入 | 指定注入名 `operationLogExecutor` 的 Executor Bean |
| `@Log` AOP（`LogModuleEnum.API_REQUEST_LOG`） | 查询接口操作日志埋点（复用同一线程池） |
| Bean Validation（`@NotBlank` 等） | AGV DTO 字段约束，请求前统一校验 |
| Knife4j / Swagger 注解 | AGV DTO 字段说明与查询接口文档 |
