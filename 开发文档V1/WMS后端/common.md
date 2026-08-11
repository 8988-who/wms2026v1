# 公共基础模块（common）

## 1. 模块概述

本模块是全工程的**共享基础层**：**不依赖任何业务模块**（仅自身内部引用），被 framework 与所有业务模块（auth/system/rcs/warehouse/carriermanagementsystem/business 等）共同依赖。承载：

- **注解（annotation）**：`@Log`（操作日志）、`@RateLimit`（接口限流）、`@RepeatSubmit`（防重复提交）、`@DataPermission`（数据权限）、`@ValidField`（字段白名单校验）；
- **基类（base）**：`BaseEntity`（审计字段实体基类）、`BaseQuery`（分页查询基类）、`IBaseEnum`（枚举通用接口）；
- **常量（constant）**：`SystemConstants`、`SecurityConstants`、`RedisConstants`、`JwtClaimConstants`、`RcsConstants`；
- **枚举（enums）**：`ResultCode` 之外的业务枚举——`ApiEnum`（外部接口注册表）、`LogModuleEnum`（日志模块）、`ActionTypeEnum`（操作类型）、`DataScopeEnum`（数据权限）、`StatusEnum`、`EnvEnum`、`SocialPlatformEnum`；
- **异常（exception）**：`BusinessException`（业务异常）、`DataPermissionException`（数据权限异常）；
- **模型（model）**：`Option`（下拉选项）、`KeyValue`（键值对）、`BatchStatusForm`（批量状态表单）；
- **统一结果（result）**：`Result` / `PageResult` / `ExcelResult` / `ResultCode` / `IResultCode`；
- **工具（util）**：`ApiRequestUtils`（统一外部请求执行器，被 rcs 模块大量使用）、`OrikaUtils`（深拷贝）、`IPUtils`（IP/归属地）、`ExcelUtils`（EasyExcel 导入）、`SpringUtils`、`ValidatorUtils`、`StringUtils`、`ExceptionUtil`、`DateUtils`。

> 模块间依赖关系：framework 依赖 common（Result/ResultCode/注解/常量）；业务模块依赖 common + framework。

> **数据库交互：无**。common 为纯工具/注解/枚举/响应体层，不持有任何 Mapper 与数据表；唯一间接涉及 DB 的是 `ApiRequestUtils.execute` 在 finally 中触发 [business 模块](../../wms/src/main/java/com/wms/business/log/service/impl/ApiRequestLogServiceImpl.java) 异步写 `api_request_log`（跨模块行为，见 [business.md](./business.md) §3 数据库交互）。

---

## 2. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/common/...`；以下"引用的包"为该文件 import 中的主要部分。common 共 **40 个 Java 文件**。

### 2.1 annotation —— 注解

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [Log.java](../../wms/src/main/java/com/wms/common/annotation/Log.java) | 操作日志注解（方法级） | `com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`java.lang.annotation.*` | 必填 `module()`（日志模块）、`value()`（操作类型）；可选 `title()`（标题，默认"模块-操作"）、`content()`（自定义内容）；由 framework 的 `LogAspect` 消费 |
| [RateLimit.java](../../wms/src/main/java/com/wms/common/annotation/RateLimit.java) | 接口限流注解（方法级） | `java.lang.annotation.*`、`java.util.concurrent.TimeUnit` | `limit()`（窗口最大请求数，≤0 取全局默认 5）、`window()`（窗口大小，≤0 取默认 60）、`timeUnit()`（默认秒）、`prefix()`（key 分组标签，默认 api）；由 `RateLimitAspect` 消费 |
| [RepeatSubmit.java](../../wms/src/main/java/com/wms/common/annotation/RepeatSubmit.java) | 防重复提交注解（方法级） | `java.lang.annotation.*` | 仅 `expire()`（锁过期秒数，默认 5s）；由 `RepeatSubmitAspect`（Redisson 锁）消费 |
| [DataPermission.java](../../wms/src/main/java/com/wms/common/annotation/DataPermission.java) | 数据权限注解（类/方法级） | `java.lang.annotation.*` | `deptAlias()`（部门表别名，默认空）/`deptIdColumnName()`（部门 ID 列，默认 dept_id）/`userAlias()`/`userIdColumnName()`（用户 ID 列，默认 create_by）；由 `MyDataPermissionHandler` 反射读取 |
| [ValidField.java](../../wms/src/main/java/com/wms/common/annotation/ValidField.java) | 字段白名单校验注解 | `jakarta.validation.Constraint/Payload`、`com.wms.common.validator.FieldValidator` | `allowedValues()`（合法值列表）、`ignoreCase()`（是否忽略大小写，默认 false）；`@Constraint(validatedBy = FieldValidator.class)`，由 `FieldValidator` 实现校验 |

### 2.2 base —— 基类

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [BaseEntity.java](../../wms/src/main/java/com/wms/common/base/BaseEntity.java) | 实体基类（审计字段） | `com.baomidou.mybatisplus.annotation.*`（TableId/IdType.AUTO/TableField/FieldFill）、`com.fasterxml.jackson.annotation.JsonFormat/JsonInclude`、`lombok.Data`、`java.time.LocalDateTime` | 公共字段：`id`（自增主键）、`createTime`（`fill=INSERT`）、`updateTime`（`fill=INSERT_UPDATE`）；日期格式 `yyyy-MM-dd HH:mm:ss`、null 不序列化；由 `AutoFillMetaObjectHandler` 填充 |
| [BaseQuery.java](../../wms/src/main/java/com/wms/common/base/BaseQuery.java) | 分页查询参数基类 | `com.wms.common.annotation.ValidField`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.io.Serializable` | 公共参数：`pageNum`（默认 1）/`pageSize`（默认 10）/`sortBy`（限 create_time、update_time）/`order`（限 ASC/DESC，忽略大小写）；`isPaged()` 判是否分页 |
| [IBaseEnum.java](../../wms/src/main/java/com/wms/common/base/IBaseEnum.java) | 枚举通用接口 | `cn.hutool.core.util.ObjectUtil`、`java.util.EnumSet/Objects` | 定义 `getValue()/getLabel()`；静态工具：`getEnumByValue`、`getLabelByValue`（值→中文）、`getValueByLabel`，基于 EnumSet 全量扫描匹配 |

### 2.3 constant —— 常量

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SystemConstants.java](../../wms/src/main/java/com/wms/common/constant/SystemConstants.java) | 系统级常量 | 无（接口常量） | `ROOT_NODE_ID=0L`、`DEFAULT_PASSWORD="123456"`、`ROOT_ROLE_CODE="ROOT"`（超级管理员角色，SecurityUtils.isRoot 判断依据）、`HTTP/HTTPS` 前缀 |
| [SecurityConstants.java](../../wms/src/main/java/com/wms/common/constant/SecurityConstants.java) | 安全模块常量 | 无（接口常量） | `LOGIN_PATH="/api/v1/auth/login"`、`BEARER_TOKEN_PREFIX="Bearer "`（Token 前缀）、`ROLE_PREFIX="ROLE_"`（authorities 角色前缀，区分权限标识） |
| [RedisConstants.java](../../wms/src/main/java/com/wms/common/constant/RedisConstants.java) | Redis Key 常量 | 无（嵌套接口常量） | `RateLimit`（`rate_limit:{prefix}:{user}:{uri}`、`rate_limit:ip:{ip}`）；`Lock`（`lock:resubmit:{user}:{reqId}`）；`Auth`（`auth:token:access/refresh:{token}`、`auth:user:access/refresh:{userId}`、`auth:token:blacklist:{jti}`、`auth:user:token_version:{userId}`）；`Captcha`（`captcha:image:{id}` 等 5 类）；`System`（config/role:perms）；`CodeSeq`（库位/巷道/点位编码序列） |
| [JwtClaimConstants.java](../../wms/src/main/java/com/wms/common/constant/JwtClaimConstants.java) | JWT Claims 常量 | 无（接口常量） | `TOKEN_TYPE`/`USER_ID`/`DEPT_ID`/`DATA_SCOPES`（多角色数据权限列表）/`ROLES`（无 ROLE_ 前缀）/`TOKEN_VERSION`（用户级令牌失效版本号） |
| [RcsConstants.java](../../wms/src/main/java/com/wms/common/constant/RcsConstants.java) | RCS 对接常量 | 无（私有构造器，纯常量类） | 请求头标识：`X-lr-request-id`/`X-lr-version`/`X-lr-trace-id`；`VERSION="4.3"`（RCS 版本号，ApiRequestUtils 组装请求头用） |

### 2.4 enums —— 枚举

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiEnum.java](../../wms/src/main/java/com/wms/common/enums/ApiEnum.java) | 外部接口注册表（AGV/MES 接口配置） | `com.baomidou.mybatisplus.core.toolkit.StringUtils`、`com.wms.business.agv.*`（出站 DTO，如 AgvSubmitTaskDTO）、`com.wms.rcs.model.dto.AgvRequestDTO`、`lombok.Getter` | 每项配置：`code`（接口编码）/`methodName`（URL 拼接 + 按名查找键）/`name`（名称，日志用）/`desc`（仅 WebService 传 SOAPAction,方法名,命名空间）/`method`（POST/GET/WebService，决定 ApiRequestUtils 分发分支）/`module`（配置键 `wms.{module}.baseurl` + 返回值解析逻辑）/`paramsClass`（非空则请求前参数校验）；注册 AGV 出站接口 20 余项；**8 项 SPI 回调（RCS→WMS）已注释停用**（迁移至 RcsReporterController）；查找方法 `getApiEnumByMethodName`/`getApiEnumByModuleAndMethodName` |
| [LogModuleEnum.java](../../wms/src/main/java/com/wms/common/enums/LogModuleEnum.java) | 日志模块枚举 | `com.baomidou.mybatisplus.annotation.EnumValue`、`com.fasterxml.jackson.annotation.JsonValue`、`com.wms.common.base.IBaseEnum`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Getter` | 系统模块 1-9（登录/用户/角色/部门/菜单/字典/配置/文件/日志）；WMS 业务模块 81-89（点位/巷道/库位/料车型号/料车/料车物品/接口请求日志/AGV 调度/RCS 本地任务）；`@EnumValue` 存库、`@JsonValue` 序列化 |
| [ActionTypeEnum.java](../../wms/src/main/java/com/wms/common/enums/ActionTypeEnum.java) | 操作类型枚举 | `com.baomidou.mybatisplus.annotation.EnumValue`、`com.fasterxml.jackson.annotation.JsonValue`、`com.wms.common.base.IBaseEnum`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Getter` | 1-15：登录/登出/新增/修改/删除/授权/导出/导入/上传/下载/修改密码/重置密码/启用/禁用/查询列表；99 其他 |
| [DataScopeEnum.java](../../wms/src/main/java/com/wms/common/enums/DataScopeEnum.java) | 数据权限枚举 | `com.wms.common.base.IBaseEnum`、`lombok.Getter` | 1-所有数据/2-部门及子部门/3-本部门/4-本人/5-自定义部门；`isAll(value)` 判全量；`getByValue` 反查；多角色**并集策略**（见 framework.md 3.2） |
| [StatusEnum.java](../../wms/src/main/java/com/wms/common/enums/StatusEnum.java) | 通用状态枚举 | `com.wms.common.base.IBaseEnum`、`lombok.Getter` | ENABLE(1,启用)/DISABLE(0,禁用) |
| [EnvEnum.java](../../wms/src/main/java/com/wms/common/enums/EnvEnum.java) | 环境枚举 | `com.wms.common.base.IBaseEnum`、`lombok.Getter` | DEV(dev)/PROD(prod) |
| [SocialPlatformEnum.java](../../wms/src/main/java/com/wms/common/enums/SocialPlatformEnum.java) | 第三方登录平台枚举 | `com.baomidou.mybatisplus.annotation.EnumValue`、`com.wms.common.base.IBaseEnum`、`lombok.Getter` | WECHAT_MINI/WECHAT_MP/WECHAT_OPEN/ALIPAY/QQ/APPLE；供 `UserAuthenticationPort.getAuthInfoByOpenid` 使用 |

### 2.5 exception —— 异常

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [BusinessException.java](../../wms/src/main/java/com/wms/common/exception/BusinessException.java) | 业务异常（全局唯一业务异常类型） | `com.wms.common.result.IResultCode`、`lombok.Getter`、`org.slf4j.helpers.MessageFormatter` | 构造器：按 `IResultCode`（带错误码）、按 `IResultCode+message`（自定义消息）、按 message+cause、按 cause、按 `message+占位符`（MessageFormatter 格式化）；`GlobalExceptionHandler` 识别后返回 `Result.failed(resultCode, message)` |
| [DataPermissionException.java](../../wms/src/main/java/com/wms/common/exception/DataPermissionException.java) | 数据权限异常（系统级） | `lombok.Getter` | 携带 `mappedStatementId`（出问题的 Mapper 方法全路径）+ message；当数据权限拦截器拼接 SQL 失败时抛出（当前 MyDataPermissionHandler 尚未抛出，预留） |

### 2.6 model —— 通用模型

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [Option.java](../../wms/src/main/java/com/wms/common/model/Option.java) | 下拉选项对象 | `com.fasterxml.jackson.annotation.JsonInclude`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/NoArgsConstructor`、`java.util.List` | `value`/`label`/`tag`（标签类型，NON_EMPTY 才序列化）/`children`（子选项，树形下拉）；多个便捷构造器 |
| [KeyValue.java](../../wms/src/main/java/com/wms/common/model/KeyValue.java) | 键值对 | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/NoArgsConstructor` | `key`/`value`，通用键值传输 |
| [BatchStatusForm.java](../../wms/src/main/java/com/wms/common/model/BatchStatusForm.java) | 批量状态更新表单 | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotEmpty/NotNull`、`lombok.Data`、`java.util.List` | `ids`（ID 列表，@NotEmpty）+ `status`（状态，@NotNull，1 启用/0 停用）；供各业务批量启用/禁用接口复用 |

### 2.7 result —— 统一响应体

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [IResultCode.java](../../wms/src/main/java/com/wms/common/result/IResultCode.java) | 响应码接口 | 无 | 定义 `getCode()/getMsg()`；解耦"错误码来源"（ResultCode 枚举或自定义），`Result.failed(IResultCode)` 面向接口编程 |
| [ResultCode.java](../../wms/src/main/java/com/wms/common/result/ResultCode.java) | 响应码枚举（阿里规范 5 位错误码） | `com.wms.common.result.IResultCode`、`java.io.Serializable` | 详见 [3.2 统一响应体设计](#32-统一响应体设计resultcode-阿里规范错误码)；`getValue(code)` 反查（未命中默认 B0001） |
| [Result.java](../../wms/src/main/java/com/wms/common/result/Result.java) | 统一响应结构体 | `cn.hutool.core.util.StrUtil`、`lombok.Data`、`java.io.Serializable` | `code`（业务码）/`data`/`msg` 三字段；静态工厂 `success(data)/success(data,msg)/failed()/failed(msg)/failed(IResultCode)/failed(IResultCode,msg)/failed(IResultCode,msg,data)/judge(boolean)`；msg 为空时回退错误码默认消息 |
| [PageResult.java](../../wms/src/main/java/com/wms/common/result/PageResult.java) | 分页响应结构体 | `com.baomidou.mybatisplus.core.metadata.IPage`、`lombok.Data`、`java.util.Collections` | `code`/`msg`/`data{list, total}` 嵌套结构；`success(IPage)`（分页）/`success(List)`（不分页列表，total=0） |
| [ExcelResult.java](../../wms/src/main/java/com/wms/common/result/ExcelResult.java) | Excel 导入结果响应体 | `lombok.Data`、`java.util.ArrayList` | `code`（默认 00000）/`validCount`（有效条数）/`invalidCount`（无效条数）/`messageList`（错误提示集合） |

### 2.8 util —— 工具类

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [ApiRequestUtils.java](../../wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) | **统一外部请求执行器**（出站核心，被 rcs 模块大量使用） | `cn.hutool.http.HttpRequest/HttpResponse/HttpUtil/Header`、`cn.hutool.http.webservice.SoapClient`、`cn.hutool.core.util.IdUtil`、`com.alibaba.fastjson2.JSONObject`、`com.wms.business.log.model.entity.ApiRequestLog`、`com.wms.business.log.service.ApiRequestLogService`、`com.wms.common.enums.ApiEnum`、`com.wms.common.util.spring.SpringUtils`、`com.wms.common.constant.RcsConstants`、`com.wms.system.service.ISysConfigService`、`org.springframework.util.CollectionUtils`、`java.time.LocalDateTime` | 详见 [3.1 ApiRequestUtils 请求执行流程](#31-apirequestutils-请求执行流程) |
| [OrikaUtils.java](../../wms/src/main/java/com/wms/common/util/OrikaUtils.java) | 对象深拷贝工具（单例 MapperFacade） | `ma.glasnost.orika.MapperFacade`、`ma.glasnost.orika.impl.DefaultMapperFactory` | 静态内部类懒汉单例（线程安全）；`mapBean(src, dstClass)` 返回目标类型深拷贝；ApiRequestUtils 中用于 params → paramsClass DTO 转换 |
| [ValidatorUtils.java](../../wms/src/main/java/com/wms/common/util/ValidatorUtils.java) | 参数校验工具 | `jakarta.validation.Validator/ConstraintViolation`、`com.wms.common.exception.BusinessException`、`org.springframework.beans.factory.annotation.Autowired`、`org.springframework.stereotype.Component` | `@Autowired setValidator` 注入 Spring 管理的 Validator（支持动态 Locale）；`validateEntity(object, groups...)` 校验失败抛 `BusinessException(第一条消息)` |
| [StringUtils.java](../../wms/src/main/java/com/wms/common/util/StringUtils.java) | 字符串工具（继承 commons-lang3） | `org.apache.commons.lang3.StringUtils`（父类）、`org.springframework.util.AntPathMatcher`、`com.wms.common.constant.SystemConstants` | 扩展：`nvl`/`isEmpty(Collection/Map/数组/String)`/`isNull`/`isArray`/`hide`（区间打码）/`substring`/`hasText`/`ishttp`/`str2Set`/`str2List`/`containsAny`/`toUnderScoreCase`/`convertToCamelCase`/`toCamelCase`/`matches`/`isMatch`（Ant 通配）/`cast`/`padl` |
| [IPUtils.java](../../wms/src/main/java/com/wms/common/util/IPUtils.java) | IP 工具（获取客户端 IP + ip2region 归属地） | `cn.hutool.core.util.StrUtil`、`org.lionsoul.ip2region.xdb.Searcher`、`jakarta.annotation.PostConstruct`、`jakarta.servlet.http.HttpServletRequest`、`java.net.InetAddress/UnknownHostException`、`java.nio.file.Files/Path/StandardCopyOption` | `@PostConstruct` 将 classpath `/data/ip2region.xdb` 复制到临时文件并初始化 Searcher；`getIpAddr`：依次解析 `x-forwarded-for`（取第一个非 unknown，兼容多级代理）/Proxy-Client-IP/WL-Proxy-Client-IP/HTTP_CLIENT_IP/HTTP_X_FORWARDED_FOR/remoteAddr，本机回环取网卡 IP；`getRegion(ip)` 返回归属地（如 `国家|区域|省|市|ISP`，分隔符 `\|`，LogAspect 按位解析省/市） |
| [ExcelUtils.java](../../wms/src/main/java/com/wms/common/util/ExcelUtils.java) | Excel 导入工具 | `cn.idev.excel.EasyExcel`（fastexcel）、`cn.idev.excel.event.AnalysisEventListener`、`java.io.InputStream` | `importExcel(is, clazz, listener)`：EasyExcel 流式读取，逐行回调监听器 |
| [SpringUtils.java](../../wms/src/main/java/com/wms/common/util/spring/SpringUtils.java) | Spring 容器工具 | `org.springframework.context.ApplicationContext/ApplicationContextAware`、`org.springframework.stereotype.Component` | 实现 `ApplicationContextAware` 持有静态上下文；`getApplicationContext()`/`getBean(Class<T>)`；ApiRequestUtils 经它取 `ISysConfigService`/`ApiRequestLogService` |
| [ExceptionUtil.java](../../wms/src/main/java/com/wms/common/util/ExceptionUtil.java) | 异常信息工具 | 无 | `getExceptionMessage(Throwable)`：优先取 message，为空回退 `toString()`；ApiRequestUtils 记录 errMsg 用 |
| [DateUtils.java](../../wms/src/main/java/com/wms/common/util/DateUtils.java) | 日期工具 | `java.util.Date` | `getNowDate()` 返回当前时间 |

### 2.9 validator —— 校验器

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [FieldValidator.java](../../wms/src/main/java/com/wms/common/validator/FieldValidator.java) | `@ValidField` 的 ConstraintValidator | `jakarta.validation.ConstraintValidator/ConstraintValidatorContext`、`com.wms.common.annotation.ValidField`、`java.util.Arrays` | `initialize` 读取 allowedValues/ignoreCase；`isValid`：null 视为合法（由 @NotNull 管）、命中白名单（可忽略大小写）合法；BaseQuery.sortBy/order 即用此注解约束 |

---

## 3. 核心实现逻辑

### 3.1 ApiRequestUtils 请求执行流程

`ApiRequestUtils.execute(ApiEnum apiEnum, Map<String, String> headers, Map<String, Object> params)` 是 WMS 出站调用外部系统（AGV/RCS、MES）的**唯一入口**（rcs 模块 `AgvServiceImpl` 按 `ApiEnum` 调用它）。完整流程：

```
execute(apiEnum, headers, params)
 │
 ├─ ① 生成链路追踪 ID：traceId = IdUtil.fastSimpleUUID()
 │
 ├─ ② 参数校验（可选）：apiEnum.paramsClass 非空时
 │      params → OrikaUtils.mapBean 深拷贝为 paramsClass DTO
 │      → ValidatorUtils.validateEntity(dto)（失败抛 BusinessException）
 │
 ├─ ③ 拼接 URL：baseurl = SpringUtils.getBean(ISysConfigService)
 │                  .selectConfigByKey("wms.{module}.baseurl")（未配置抛异常）
 │      url = baseurl(stripEnd "/") + "/" + methodName(stripStart "/")（防双斜杠）
 │
 ├─ ④ 初始化日志：ApiRequestLog{apiCode, apiName, apiMethodName, apiUrl, module,
 │      reqTime, reqParams(JSON), traceId, retryCount=0}
 │
 ├─ ⑤ 组装统一请求头 mergeHeaders(headers, traceId)：
 │      X-lr-request-id = UUID（动态生成）、X-lr-version = RcsConstants.VERSION(4.3)、
 │      X-lr-trace-id = traceId；调用方传入 headers 覆盖默认值
 │
 ├─ ⑥ 按 apiEnum.method 分发：
 │      POST        → HttpUtil.createPost(url) + headerMap + body(JSON, Content-Type: application/json;charset=UTF-8)
 │      GET         → HttpUtil.createGet(url).form(params)
 │      WebService  → SoapClient.create(baseurl)：
 │                      header("SOAPAction", desc.split(",")[0])
 │                      setMethod(methods[1]=方法名, methods[2]=命名空间)
 │                      setParams(params, true).send(false)（WebService 无 HTTP 状态码）
 │      ↓
 │      resString = result.body()；httpCode = result.getStatus()
 │
 ├─ ⑦ 记录返回：requestLog.resParams = resString、httpCode
 │
 ├─ ⑧ 按模块解析 handleByModule(requestLog)：
 │      fastjson2 解析 resParams 取 code 字段
 │      resCode = code；isSuccess = "0".equals(code) ? "Y" : "N"
 │      （预留 if-else 扩展点，可按模块定制解析）
 │
 ├─ catch（异常）：isSuccess="N"、errMsg = ExceptionUtil.getExceptionMessage(e) 截断 5000 字符
 │      → 记 error 日志（含 traceId）→ 保存 exception 供最后重抛
 │
 └─ finally（无论如何执行）：
       duration = 当前时间 - startTime、resTime = now
       → SpringUtils.getBean(ApiRequestLogService.class).saveLogAsync(requestLog)
         （内部补 createBy/createName（当前登录用户）、createTime，
          提交 operationLogExecutor 异步线程池写 api_request_log 表，失败仅记日志）

 收尾：exception 非空 → 抛出 RuntimeException(apiEnum.name + "接口请求失败", e)
       否则返回 requestLog.getResParams()（响应体字符串，由调用方解析）
```

**关键设计**：
- **参数校验前置**：有 `paramsClass` 的接口在发请求前用 Bean Validation 校验，失败快速失败（抛 BusinessException），不产生外部调用与日志；
- **链路追踪**：一次调用一个 `traceId`，随 `X-lr-trace-id` 请求头发往对端，同时落入 `api_request_log.trace_id`，便于跨系统排障；
- **WebService 特殊处理**：`desc` 字段以逗号分隔依次承载 SOAPAction、方法名、命名空间；无 HTTP 状态码，仅返回字符串；
- **finally 兜底**：无论成功失败都会异步落一条日志（含耗时/HTTP 状态/成功标志），**调用方线程零阻塞**（线程池 core=1/max=2，CallerRuns 兜底）；
- **失败重抛**：调用失败不吞异常，向上抛 `RuntimeException` 让业务方（如 rcs 的 `AgvServiceImpl`）感知并处理（置任务异常/记录 errorMsg）。

### 3.2 统一响应体设计（ResultCode 阿里规范错误码）

**响应结构**：所有接口统一返回 `Result{code, data, msg}`（分页为 `PageResult{code, msg, data:{list, total}}`），`code` 为**字符串业务码**，与 HTTP 状态解耦（业务/参数错误 HTTP 200，令牌 401、限流 429、系统 500 等由框架层映射）。

**错误码规范**（参考《阿里巴巴 Java 开发手册》）：

| 号段 | 含义 | 项目中实际使用项 |
|------|------|-----------------|
| `00000` | 成功 | SUCCESS |
| `A****` | 用户端错误（参数/认证/权限/请求方式） | A0001 用户端错误；A0100 注册错误；A0130 校验码输入错误；A0200 登录异常、A0201 账户不存在、A0202 账户冻结、A0210 用户名或密码错误、**A0230/A0231 访问/刷新令牌无效**、A0240 验证码错误、A0241 尝试次数超限、A0242 验证码过期；A0300 权限异常、A0301 未授权；A0400 参数错误、A0402 无效输入、A0410 必填参数为空、A0421 参数格式不匹配；A0500 请求服务异常、**A0502 请求并发数超限**、**A0506 请勿重复提交**；A0700/A0710 文件异常 |
| `B****` | 系统端错误（超时/内部） | B0001 系统执行出错、B0100 系统执行超时 |
| `C****` | 第三方服务错误（数据库/外部依赖） | C0001 第三方服务出错、C0113 接口不存在、C0300 数据库服务出错、C0310 执行异常、C0313 语法错误、C0342 违反完整性约束、C0351 数据库访问被拒（演示环境提示） |

**设计要点**：
- `code` 为 **5 位字符串**（来源字母 A/B/C + 4 位编号），大类按 100 步长预留号段（A0200/A0300/A0400…），**后三位与 HTTP 状态码无关**；
- 枚举仅保留实际使用项，避免无限膨胀；`ResultCode.getValue(code)` 反查枚举，未命中回退 `B0001`；
- `Result.failed(IResultCode, msg)` 支持自定义消息覆盖默认文案（msg 为空时回退错误码默认）；
- 框架层消费点：`GlobalExceptionHandler`（业务/令牌/限流异常映射）、`ResponseWriter`（过滤器/安全处理器直接写响应）、`ApiRequestUtils`（对外部调用方协议独立，不依赖此结构）。

---

## 4. 技术栈

| 技术 | 用途 |
|------|------|
| Jakarta Bean Validation | `@ValidField`/`@Valid`/`@NotNull` 等注解与 `ValidatorUtils` 前置参数校验 |
| MyBatis-Plus 注解 | `@EnumValue`（枚举存库）、`@TableId/@TableField`（BaseEntity 审计字段） |
| Orika（ma.glasnost.orika） | Map 深度拷贝（params → paramsClass DTO）、通用 Bean 拷贝 |
| Hutool | HttpUtil/HttpRequest（POST/GET）、SoapClient（WebService）、IdUtil（traceId/requestId）、ObjectUtil、StrUtil |
| fastjson2（com.alibaba.fastjson2） | 外部响应 JSON 解析（code/message/data）、请求参数/日志序列化 |
| Jackson（com.fasterxml.jackson） | Result/PageResult/Option 等 JSON 序列化策略（@JsonInclude/@JsonValue） |
| ip2region（org.lionsoul.ip2region） | 客户端 IP 归属地解析 |
| fastexcel EasyExcel（cn.idev.excel） | Excel 流式导入（ExcelUtils + AnalysisEventListener） |
| commons-lang3 / slf4j MessageFormatter | 字符串工具父类 / BusinessException 占位符消息格式化 |


