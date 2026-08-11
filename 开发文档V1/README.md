# WMS 后端功能开发文档

> 本文档按**功能模块**整理后端代码。每个功能统一描述四要素：
>
> 1. **功能说明** —— 这个功能用来干什么；
> 2. **关键实现文件** —— 点击文件名可跳转到对应 Java 源码（相对链接）；
> 3. **实现方式** —— 代码是怎么实现这个功能的（分层、流程、核心逻辑）；
> 4. **技术栈** —— 用到了哪些框架/组件/技巧。
>
> 新增功能描述请参考第四章的【文件描述模板】与第五章【编写规范】。

---

## 一、文档使用说明

- 阅读顺序：先看 [二、技术栈总览](#二技术栈总览) → [三、功能模块总览](#三功能模块总览) → [四、各功能模块详解](#四各功能模块详解)。
- 所有文件链接使用相对路径，IDE 中 `Ctrl+点击` 即可跳转源码，推送到 Git 仓库后在 GitHub/Gitee 上也可直接点击。
- 每新增一个功能/一个核心类，按第四章模板在本文档对应模块下追加一节。
- 本文档描述的是后端 `wms` 工程，前端见 `../wmsui`、PDA 端见 `../wmspda`（另有独立说明文档）。

---

## 二、技术栈总览

数据来源：[pom.xml](../wms/pom.xml)

| 分类 | 技术选型 | 版本 | 说明 |
|------|---------|------|------|
| 语言/基础 | JDK | 17 | 需 `--add-opens java.base/java.lang=ALL-UNNAMED`（Orika 反射需要） |
| 框架 | Spring Boot | 4.0.5 | Web / Security / Redis / Cache / Mail / Validation / AspectJ / Actuator |
| ORM | MyBatis-Plus | 3.5.15 | `mybatis-plus-spring-boot4-starter` + `jsqlparser`（数据权限/分页插件） |
| 数据库 | PostgreSQL | 14+ | 依赖 `jsonb`（RcsTask.payload）；驱动 42.7.4 |
| 连接池 | Druid | 1.2.24 | 监控、防注入、连接池 |
| 缓存 | Redis + Caffeine | — | Redis 缓存/分布式锁/限流；Caffeine 本地缓存 |
| 分布式锁 | Redisson | 4.1.0 | 防重复提交、幂等控制 |
| 安全 | Spring Security + JWT | — | JWT 无状态 / Redis 有状态双 Token 管理器，权限注解 |
| 对象映射 | MapStruct | 1.6.3 | DTO ↔ Entity ↔ VO 编译期转换 |
| 对象映射 | Orika | 1.5.4 | 运行时深拷贝（OrikaUtils），外部接口参数映射 |
| 接口文档 | Knife4j + springdoc | 4.5.0 / 2.8.9 | OpenAPI 3 文档 |
| Excel | EasyExcel（fastexcel） | 1.3.0 | 用户导入/导出、模板下载 |
| 定时任务 | XXL-Job | 3.2.0 | 分布式调度（可选开启） |
| 对象存储 | MinIO / 阿里云 OSS / 本地 | 8.5.10 | 按 `oss.type` 配置切换 |
| 工具库 | Hutool | 5.8.41 | 断言/ID/HTTP/日期等 |
| JSON | fastjson2 | 2.0.43 | 序列化、类型处理器 |
| IP 归属地 | ip2region | 2.7.0 | 日志登录记录显示地区 |
| 短信/小程序 | 阿里云 SMS / 微信小程序 SDK | — | 短信验证码（当前停用）、微信小程序登录 |
| 消息推送 | SSE（Server-Sent Events） | — | 字典变更、在线用户数实时推送 |

---

## 三、功能模块总览

| 模块 | 功能点 | 核心文件（点击跳转） |
|------|--------|----------------------|
| auth | 登录 / 登出 / 令牌刷新 / 验证码 | [AuthController](../wms/src/main/java/com/wms/auth/controller/AuthController.java)、[AuthServiceImpl](../wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java) |
| system | 用户 / 角色 / 菜单 / 部门 / 字典 / 配置 / 日志 | [UserController](../wms/src/main/java/com/wms/system/controller/UserController.java)、[UserServiceImpl](../wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) |
| file | 文件上传/删除（本地 / OSS / MinIO） | [FileController](../wms/src/main/java/com/wms/file/controller/FileController.java)、[MinioFileServiceImpl](../wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java) |
| warehouse | 库位/区域、巷道、点位（三级层级） | [WmsLocationController](../wms/src/main/java/com/wms/warehouse/controller/WmsLocationController.java)、[WmsPointServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java) |
| carriermanagementsystem | 料车型号 / 料车 / 装车取走（扫码） | [CartController](../wms/src/main/java/com/wms/carriermanagementsystem/cart/controller/CartController.java)、[CartItemServiceImpl](../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java) |
| rcs | AGV 接口对接 / RCS 任务全生命周期 | [AgvController](../wms/src/main/java/com/wms/rcs/controller/AgvController.java)、[RcsTaskServiceImpl](../wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) |
| business | 外部接口请求日志 | [ApiRequestLogController](../wms/src/main/java/com/wms/business/log/controller/ApiRequestLogController.java)、[ApiRequestUtils](../wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) |
| message | SSE 消息推送 | [SseService](../wms/src/main/java/com/wms/message/service/SseService.java) |
| common | 公共基础（注解/常量/枚举/结果/工具） | [Result](../wms/src/main/java/com/wms/common/result/Result.java)、[ApiEnum](../wms/src/main/java/com/wms/common/enums/ApiEnum.java) |
| framework | 安全 / 限流 / 日志切面 / 缓存 / 全局异常 | [GlobalExceptionHandler](../wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java)、[LogAspect](../wms/src/main/java/com/wms/framework/web/aspect/LogAspect.java) |

---

## 四、各功能模块详解

---

### 4.1 认证授权模块（auth）

**功能说明**：统一认证中心，提供账号密码登录、图形验证码、令牌刷新、登出；短信登录接口当前已按整改停用。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [AuthController](../wms/src/main/java/com/wms/auth/controller/AuthController.java) | 认证入口，暴露登录/登出/刷新/验证码端点 | REST 接口，`@PreAuthorize` 或白名单放行，登录接口加限流 | Spring MVC、Security 注解 |
| [AuthServiceImpl](../wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java) | 认证业务编排 | 组合 `AuthenticationManager` + `TokenManager` + `CaptchaService` 完成登录、令牌生成与刷新 | Spring Security、JWT |
| [LoginForm](../wms/src/main/java/com/wms/auth/model/form/LoginForm.java) | 登录表单 DTO | `@NotBlank` 等 JSR-303 校验注解 | Validation |

**实现方式**：账号密码登录流程为 控制器 → `AuthenticationManager.authenticate`（表单认证）→ 校验通过后 `TokenManager.generate` 签发双令牌（accessToken + refreshToken）→ 返回统一 `Result`。图形验证码由 `CaptchaService` 生成并缓存到 Redis，登录前经 `CaptchaValidationFilter` 校验。

**技术栈**：Spring Security、JWT、Redis、Validation、Knife4j 注解。

---

### 4.2 系统管理模块（system）

**功能说明**：后台管理基础能力——用户、角色、菜单、部门、字典、系统配置、操作日志。`sys_*` 表为脚手架自带，按脚手架规范维护。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [UserController](../wms/src/main/java/com/wms/system/controller/UserController.java) | 用户 CRUD + 状态/密码/导入导出/个人中心 | 标准 REST 资源接口，权限标识 `sys:user:*` | Spring MVC、Security |
| [UserServiceImpl](../wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) | 用户业务 | 密码 BCrypt 加密、变更后使会话失效、EasyExcel 导入导出（`UserImportListener` 逐行校验） | MyBatis-Plus、BCrypt、EasyExcel |
| [RoleServiceImpl](../wms/src/main/java/com/wms/system/service/impl/RoleServiceImpl.java) | 角色业务 | 分配菜单/数据权限，变更后刷新权限缓存并失效相关会话 | MyBatis-Plus、Redis |
| [MenuServiceImpl](../wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java) | 菜单业务 | 递归建树、构建前端路由（`RouteVO`）、级联删除子菜单 | MyBatis-Plus、JacksonTypeHandler（JSON 字段） |
| [DeptServiceImpl](../wms/src/main/java/com/wms/system/service/impl/DeptServiceImpl.java) | 部门业务 | 递归建树 + `treePath` 生成 + 防止循环引用 + 级联删除 | MyBatis-Plus |
| [DictServiceImpl](../wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java) | 字典业务 | CRUD + 变更时发 SSE 通知前端刷新 | MyBatis-Plus、SSE |
| [ConfigServiceImpl](../wms/src/main/java/com/wms/system/service/impl/ConfigServiceImpl.java) | 系统配置 | 启动时 `@PostConstruct` 全量加载到 Redis，`refreshCache` 全量刷新；外部接口 baseUrl 等参数在此维护 | MyBatis-Plus、Redis |
| [LogServiceImpl](../wms/src/main/java/com/wms/system/service/impl/LogServiceImpl.java) | 操作日志 | 分页查询 + PV/UV 趋势/概览统计（连续日期补齐） | MyBatis-Plus、自定义 SQL |
| [UserConverter](../wms/src/main/java/com/wms/system/converter/UserConverter.java) | 实体转换 | `@Mapper(componentModel = "spring")` 编译期生成实现 | MapStruct |

**技术栈**：MyBatis-Plus、Spring Security（`@ss.hasPerm` 权限表达式）、Redis、MapStruct、EasyExcel、SSE、BCrypt。

---

### 4.3 文件存储模块（file）

**功能说明**：统一文件上传/删除，支持三种存储后端（本地磁盘 / 阿里云 OSS / MinIO），通过配置 `oss.type` 切换，无需改业务代码。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [FileController](../wms/src/main/java/com/wms/file/controller/FileController.java) | 上传/删除接口 | `MultipartFile` 接收，委托 `FileService` | Spring MVC |
| [FileService](../wms/src/main/java/com/wms/file/service/FileService.java) | 存储服务抽象 | 定义 `uploadFile/deleteFile`，策略接口 | 策略模式 |
| [MinioFileServiceImpl](../wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java) | MinIO 实现 | 自动建桶、返回对象存储访问 URL | MinIO SDK |
| [LocalFileServiceImpl](../wms/src/main/java/com/wms/file/service/impl/LocalFileServiceImpl.java) | 本地实现 | 按日期分目录 + UUID 重命名 | 文件 IO |
| [AliyunFileServiceImpl](../wms/src/main/java/com/wms/file/service/impl/AliyunFileServiceImpl.java) | OSS 实现 | 上传返回 `https://{bucket}.{endpoint}` 格式 URL | 阿里云 OSS SDK |
| [MinioProperties](../wms/src/main/java/com/wms/file/config/MinioProperties.java) | 配置属性 | `@ConfigurationProperties` 绑定 `oss.minio.*` | Spring Boot |

**实现方式**：`@ConditionalOnProperty(oss.type=...)` 条件装配对应的实现 Bean；业务侧只依赖 `FileService` 接口，切换存储后端仅需改配置。

**技术栈**：MinIO / 阿里云 OSS SDK、条件装配、`@ConfigurationProperties`。

---

### 4.4 仓库管理模块（warehouse）

**功能说明**：仓库基础数据管理，三级层级「库位/区域(`wms_location`) → 巷道(`wms_aisle`) → 点位(`wms_point`)」。支持自动编码、级联停用、点位数量统计。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [WmsLocationController](../wms/src/main/java/com/wms/warehouse/controller/WmsLocationController.java) | 库位/区域 CRUD | 标准 REST 资源接口 | Spring MVC |
| [WmsLocationServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsLocationServiceImpl.java) | 库位/区域业务 | 新增自动编码 `{plantCode}-{3位序号}`、停用级联巷道/点位、多级筛选 | MyBatis-Plus |
| [WmsAisleServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsAisleServiceImpl.java) | 巷道业务 | 新增自动编码 `{locationCode}-A{3位序号}`、校验区域状态、级联停用点位 | MyBatis-Plus |
| [WmsPointServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java) | 点位业务 | 新增自动编码 `{aisleCode}-P{3位序号}`；写入时手动维护巷道 `point_count`（`point_count+1/-1`），展示时 SQL 实时计算——**双保险机制** | MyBatis-Plus、LambdaUpdateWrapper `setSql` |
| [WmsCascadeServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsCascadeServiceImpl.java) | 级联操作 | 停用区域→级停巷道→级停点位，直接操作 Mapper 避免循环依赖 | MyBatis-Plus |
| [WmsCodeGeneratorService](../wms/src/main/java/com/wms/warehouse/utils/WmsCodeGeneratorService.java) | 编码生成器 | 基于 Redis `INCR` 原子自增生成编码，避免并发重复 | Redis |
| [WmsAisleConverter](../wms/src/main/java/com/wms/warehouse/utils/WmsAisleConverter.java) | 实体转换 | DTO ↔ Entity 互转 | MapStruct |
| [WmsPointMapper.xml](../wms/src/main/resources/mapper/warehouse/WmsPointMapper.xml) | 分页 SQL | JOIN `wms_location` + `wms_aisle` 取完整关联名称 | MyBatis XML |

**实现方式**：以点位新增为例——①校验所属巷道存在且启用 → ②回填区域/厂区/楼层冗余字段 → ③`WmsCodeGeneratorService.generatePointCode` 生成 `{aisleCode}-P{序号}` → ④入库 → ⑤`setSql("point_count = point_count + 1")` 维护巷道统计。编码与计数均在同一事务内，保证一致性。

**技术栈**：MyBatis-Plus、Redis INCR、MapStruct、`LambdaUpdateWrapper.setSql`、`@Transactional`。

---

### 4.5 载具管理系统模块（carriermanagementsystem）

**功能说明**：料车业务，三级结构「料车型号(`wms_cart_model`) → 料车(`wms_cart`) → 装载明细(`wms_cart_item`)」。核心能力是**装车/取走**及**扫码装车/取走**（对接条码机/PDA）。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [CartModelController](../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/controller/CartModelController.java) | 型号配置 CRUD | 标准 REST 资源接口 | Spring MVC |
| [CartModelServiceImpl](../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/service/impl/CartModelServiceImpl.java) | 型号业务 | CRUD + 缓存 | MyBatis-Plus、Redis/Caffeine |
| [CartController](../wms/src/main/java/com/wms/carriermanagementsystem/cart/controller/CartController.java) | 料车 CRUD + 批量状态 + 可用料车 | 标准 REST 资源接口 | Spring MVC |
| [CartServiceImpl](../wms/src/main/java/com/wms/carriermanagementsystem/cart/service/impl/CartServiceImpl.java) | 料车业务 | CRUD + 批量状态 + 双保险状态更新（实时计算 + 手动维护） | MyBatis-Plus |
| [CartItemController](../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/controller/CartItemController.java) | 装载明细 + 装车/取走 + 扫码端点 | 提供 `load-by-barcode` / `take-by-barcode` / `batch-take-by-barcodes` 等扫码接口 | Spring MVC |
| [CartItemServiceImpl](../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java) | 装车/取走核心逻辑 | 装车前做 5 重校验（料车存在且非维修、条码全局唯一、顺序号同车唯一、有效容量、数量超限）；取走/删除仅允许操作在车/已取走记录；扫码接口按 `cartCode`/`productCode` 反查再复用同一套校验 | MyBatis-Plus、`@Transactional` |
| [CartStatusEnum](../wms/src/main/java/com/wms/carriermanagementsystem/common/enums/CartStatusEnum.java) | 状态枚举 | 1-空闲 2-使用中 3-已满载 4-维修 | 枚举 |
| [CartItemStatusEnum](../wms/src/main/java/com/wms/carriermanagementsystem/common/enums/CartItemStatusEnum.java) | 明细状态枚举 | 1-在车 2-已取走 | 枚举 |
| [CartMapper.xml](../wms/src/main/resources/mapper/carriermanagementsystem/CartMapper.xml) | 料车分页 SQL | 子查询实时计算 `current_quantity` 与 `status` | MyBatis XML |

**实现方式**：装车（`saveCartItem`）核心流程——①校验料车存在且非维修状态 → ②`productCode` 全局唯一校验（防并发重复装车）→ ③`sortOrder` 必须大于同车当前最大顺序号 → ④有效容量 = `COALESCE(actual_capacity, model.max_capacity)` → ⑤实时 `COUNT(status=1)` 判断是否超限 → ⑥写明细并维护料车 `current_quantity/status`。料车数量**双保险**：查询时 SQL 实时计算保证展示正确，写入时 Service 手动维护保证字段同步。

**技术栈**：MyBatis-Plus、`@Transactional`、LambdaQueryWrapper/LambdaUpdateWrapper、MapStruct。

---

### 4.6 RCS 对接与任务管理模块（rcs）

**功能说明**：对接 AGV 调度系统（RCS，版本 4.3）。包含两部分：①**AGV 出站接口**——按 `ApiEnum` 枚举配置调用 RCS 的 `AGV_groupTask`/`submitTask`/`cancelTask`/`queryTask` 等；②**RCS 本地任务管理**——`wms_rcs_task` 台账 + `wms_rcs_task_lifecycle` 状态历史，任务 6 态全生命周期可追溯，并实现「下发」「取消」「回调」三个闭环。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [ApiEnum](../wms/src/main/java/com/wms/common/enums/ApiEnum.java) | AGV 接口配置枚举 | 集中定义接口 code/methodName/method(POST/GET/WebService)/paramsClass，按 module+methodName 查找 | 枚举 |
| [ApiRequestUtils](../wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) | 统一请求入口 | 组装请求头（requestId/version/traceId）、参数映射到 DTO 并校验、POST/GET/WebService 三种方式发送、`finally` 异步记录请求日志到 `api_request_log`、耗时/traceId/重试次数 | Hutool Http/SoapClient、Orika、异步日志 |
| [AgvController](../wms/src/main/java/com/wms/rcs/controller/AgvController.java) | AGV 通用请求接口 | `POST /api/v1/agv/commonRequest/{methodName}`，按 methodName 路由 | Spring MVC |
| [AgvServiceImpl](../wms/src/main/java/com/wms/rcs/service/impl/AgvServiceImpl.java) | AGV 服务实现 | 从 `ApiEnum` 查配置 → 调 `ApiRequestUtils.execute` → 解析 `code=0` 判断成功 | fastjson2 |
| [RcsTaskStatusEnum](../wms/src/main/java/com/wms/rcs/enums/RcsTaskStatusEnum.java) | 任务状态枚举 + 状态机 | 6 态（0待执行/1已派发/2执行中/3已完成/4已取消/5异常）；`TRANSITIONS` 白名单矩阵定义合法流转（终态锁死、异常可恢复）；`canTransfer` 判定 | 枚举 + EnumMap |
| [RcsTaskController](../wms/src/main/java/com/wms/rcs/controller/RcsTaskController.java) | 任务管理接口 | 分页/详情/新增自动下发/重试下发/取消联动/修改/删除 | Spring MVC |
| [RcsTaskServiceImpl](../wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) | 任务业务核心 | 统一 `changeStatus` 同事务更新状态+写 lifecycle；`saveAndSubmit` 建单后立即下发；**远程调用在事务外**，结果经 `@Lazy self` 代理触发 `REQUIRES_NEW` 独立事务落库（下发成功回填 `rcs_task_id`→已派发，失败→异常可重试）；取消联动 `AGV_cancelTask` 成功才落已取消；回调按 `taskCode` 优先、`rcsTaskId` 兜底反查 | MyBatis-Plus、`@Transactional(REQUIRES_NEW)`、自注入代理 |
| [RcsTaskConverter](../wms/src/main/java/com/wms/rcs/utils/RcsTaskConverter.java) | 实体转换 | DTO↔Entity↔VO 互转，`@AfterMapping` 补齐枚举中文描述 | MapStruct |
| [RcsTaskMapper.xml](../wms/src/main/resources/mapper/rcs/RcsTaskMapper.xml) | 任务分页 SQL | JOIN `sys_user` 取创建/更新人昵称，payload 用 JacksonTypeHandler 映射 jsonb | MyBatis XML、PostgreSQL jsonb |

**实现方式（三个闭环）**：

1. **下发闭环**：`POST /{id}/submit` → 校验仅"待执行"可下发 → 事务外调 `AGV_submitTask`（`reqCode` 用本地任务编号保证 RCS 侧幂等）→ 成功经代理触发新事务回填外部任务号并流转"已派发"；失败流转"异常"（可通过 submit 重试）。
2. **取消闭环**：`POST /{id}/cancel` → 终态拒绝；"待执行"未下发则本地直接取消；"已派发/执行中"先在事务外调 `AGV_cancelTask`，成功后才落"已取消"，失败抛 `BusinessException` 且不改变状态。
3. **回调闭环**：`POST /api/v1/rcs/reporter/**`（外部 RCS 主动回馈）→ 按 `taskCode`/`taskId` 反查本地任务 → `mapReportToStatus` 兼容字符串 `method` 与数值 `status` 映射到本地 6 态 → 经 `changeStatus(operatorType=EXTERNAL)` 驱动流转并写历史；终态任务对迟到回馈仅记录不流转；未匹配任务仅记录日志并返回成功码避免重试风暴。

**状态机**：`changeStatus` 是唯一状态流转入口，写入前用 `RcsTaskStatusEnum.canTransfer` 校验合法性（非法流转记 warn 日志并跳过），同一事务内更新主表状态/时间戳并插入一条 `wms_rcs_task_lifecycle`。

**技术栈**：MyBatis-Plus、`@Transactional`/`REQUIRES_NEW`、`@Lazy` 自注入代理（规避自调用事务失效）、Hutool HTTP/SoapClient、Orika、fastjson2、PostgreSQL jsonb、Redis（可选）。

---

### 4.7 外部接口请求日志模块（business）

**功能说明**：记录所有对外系统接口调用（如 AGV）的请求/响应/耗时/链路 ID，便于问题追溯与对账。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [ApiRequestLogController](../wms/src/main/java/com/wms/business/log/controller/ApiRequestLogController.java) | 日志查询接口 | 分页 + 详情 | Spring MVC |
| [ApiRequestLog](../wms/src/main/java/com/wms/business/log/model/entity/ApiRequestLog.java) | 日志实体 | 记录 apiCode/apiUrl/reqParams/resParams/isSuccess/module/duration/retryCount/traceId | MyBatis-Plus |
| [ApiRequestLogServiceImpl](../wms/src/main/java/com/wms/business/log/service/impl/ApiRequestLogServiceImpl.java) | 日志业务 | `saveLogAsync` 异步落库，不阻塞主流程 | 异步线程池 |

**实现方式**：`ApiRequestUtils.execute` 在 `finally` 中调用 `saveLogAsync` 异步保存；`handleByModule` 预留按模块定制解析的扩展点（if-else）。

**技术栈**：MyBatis-Plus、Spring 异步线程池。

---

### 4.8 消息推送模块（message）

**功能说明**：基于 SSE 实现服务端 → 前端实时推送：字典变更通知、在线用户数广播、系统消息。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [SseService](../wms/src/main/java/com/wms/message/service/SseService.java) | SSE 业务服务 | 创建连接（超时 30 分钟）、发送字典变更/在线数/系统消息 | SSE |
| [SseSessionRegistry](../wms/src/main/java/com/wms/message/registry/SseSessionRegistry.java) | 会话注册表 | 维护用户 → SseEmitter 映射，支持多设备、心跳检测、僵尸连接清理 | SSE |
| [OnlineUserCountTask](../wms/src/main/java/com/wms/message/job/OnlineUserCountTask.java) | 在线数统计 | 定时任务（每 3 分钟）统计并广播 | Spring `@Scheduled` |
| [SseTopics](../wms/src/main/java/com/wms/message/topic/SseTopics.java) | 主题常量 | DICT / ONLINE_COUNT / SYSTEM | 常量接口 |

**技术栈**：SSE（`SseEmitter`）、Spring 定时任务、Redis（会话/在线统计）。

---

### 4.9 公共基础模块（common）

**功能说明**：全工程共享的注解、基类、常量、枚举、统一结果体、工具类，**不得依赖任何业务模块**。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [Result](../wms/src/main/java/com/wms/common/result/Result.java) | 统一响应体 | code/data/msg 三要素，`success/failed/judge` 静态工厂 | Lombok |
| [ResultCode](../wms/src/main/java/com/wms/common/result/ResultCode.java) | 错误码 | 遵循阿里规范：SUCCESS(00000)/USER_ERROR(A0001)/SYSTEM_ERROR(B0001) | 枚举 |
| [PageResult](../wms/src/main/java/com/wms/common/result/PageResult.java) | 分页响应 | 封装 `IPage` 为 list + total | 泛型 |
| [BusinessException](../wms/src/main/java/com/wms/common/exception/BusinessException.java) | 业务异常 | 携带错误码，支持参数化消息 | SLF4J |
| [BaseEntity](../wms/src/main/java/com/wms/common/base/BaseEntity.java) | 实体基类 | id + createTime + updateTime | Lombok |
| [BaseQuery](../wms/src/main/java/com/wms/common/base/BaseQuery.java) | 查询参数基类 | pageNum/pageSize/sortBy/order，`isPaged()` 判断 | Lombok |
| [Log](../wms/src/main/java/com/wms/common/annotation/Log.java) | 操作日志注解 | 标注 Controller 方法自动记录操作日志 | 注解 + AOP |
| [RateLimit](../wms/src/main/java/com/wms/common/annotation/RateLimit.java) | 限流注解 | 基于 Redis 滑动窗口防高频调用 | 注解 + AOP |
| [RepeatSubmit](../wms/src/main/java/com/wms/common/annotation/RepeatSubmit.java) | 防重复提交 | Redisson 分布式锁实现幂等 | Redisson |
| [ApiEnum](../wms/src/main/java/com/wms/common/enums/ApiEnum.java) | AGV 接口配置枚举 | 见 4.6 | 枚举 |
| [LogModuleEnum](../wms/src/main/java/com/wms/common/enums/LogModuleEnum.java) | 日志模块枚举 | 覆盖系统 + 仓库 + 料车 + RCS 各模块 | 枚举 |
| [ExcelUtils](../wms/src/main/java/com/wms/common/util/ExcelUtils.java) | Excel 工具 | EasyExcel 流式读取 | EasyExcel |
| [IPUtils](../wms/src/main/java/com/wms/common/util/IPUtils.java) | IP 工具 | 获取客户端真实 IP + 归属地 | ip2region |
| [OrikaUtils](../wms/src/main/java/com/wms/common/util/OrikaUtils.java) | 对象映射工具 | 运行时深拷贝，懒汉式单例 | Orika |
| [SpringUtils](../wms/src/main/java/com/wms/common/util/spring/SpringUtils.java) | 容器工具 | 静态获取 Bean（供静态工具类使用） | Spring `ApplicationContextAware` |

**技术栈**：Lombok、MyBatis-Plus（基类/插件）、Hutool、Orika、EasyExcel、ip2region、Redisson。

---

### 4.10 框架基础设施模块（framework）

**功能说明**：工程级横切能力——安全过滤链、Token 管理、权限校验、全局异常、操作日志切面、限流、缓存、接口文档。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [GlobalExceptionHandler](../wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java) | 全局异常处理 | `@RestControllerAdvice` 统一转 `Result`，覆盖校验/Token/限流/SQL 异常 | Spring AOP |
| [LogAspect](../wms/src/main/java/com/wms/framework/web/aspect/LogAspect.java) | 操作日志切面 | `@Log` 注解方法执行后异步写 `sys_log`（IP/设备/浏览器/耗时/异常） | AOP + 异步 |
| [RateLimitAspect](../wms/src/main/java/com/wms/framework/web/aspect/RateLimitAspect.java) | 接口限流切面 | Redis 滑动窗口计数，渐进式 `X-RateLimit-*` 响应头 | Redis + Lua |
| [RepeatSubmitAspect](../wms/src/main/java/com/wms/framework/web/aspect/RepeatSubmitAspect.java) | 防重复提交切面 | Redisson 分布式锁实现请求幂等 | Redisson |
| [TokenAuthenticationFilter](../wms/src/main/java/com/wms/framework/security/filter/TokenAuthenticationFilter.java) | Token 认证过滤器 | 从 Authorization 头提取 Token 填充 SecurityContext | Spring Security |
| [JwtTokenManager](../wms/src/main/java/com/wms/framework/security/token/JwtTokenManager.java) | JWT 无状态令牌 | 双令牌 + jti 黑名单 + tokenVersion 失效 | JWT |
| [RedisTokenManager](../wms/src/main/java/com/wms/framework/security/token/RedisTokenManager.java) | Redis 有状态令牌 | 支持多设备登录控制 | Redis |
| [SecurityUtils](../wms/src/main/java/com/wms/framework/security/util/SecurityUtils.java) | 安全工具 | 获取当前用户/ID/部门/数据权限/角色 | Spring Security |
| [MyDataPermissionHandler](../wms/src/main/java/com/wms/framework/mybatis/interceptor/MyDataPermissionHandler.java) | 数据权限拦截器 | 基于 JSQLParser 改写 SQL，支持全部/部门及子部门/本部门/本人/自定义 | MyBatis-Plus、JSQLParser |
| [AutoFillMetaObjectHandler](../wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) | 字段自动填充 | insert/update 自动填 createTime/updateTime/createBy/updateBy | MyBatis-Plus |
| [RedisConfig](../wms/src/main/java/com/wms/framework/cache/RedisConfig.java) | Redis 配置 | 自定义 `RedisTemplate`（String Key + Jackson JSON Value） | Redis |
| [CaffeineConfig](../wms/src/main/java/com/wms/framework/cache/CaffeineConfig.java) | 本地缓存 | `spring.cache.type=caffeine` 条件激活 | Caffeine |
| [OpenApiConfig](../wms/src/main/java/com/wms/framework/apidoc/OpenApiConfig.java) | 接口文档 | 配置标题/联系人/全局 Authorization 安全方案 | Knife4j |
| [CorsConfig](../wms/src/main/java/com/wms/framework/web/config/CorsConfig.java) | 跨域配置 | 允许任意来源/请求头/方法 | Spring Web |

**技术栈**：Spring Security、JWT、Redis、Redisson、MyBatis-Plus 插件、JSQLParser、AOP、Caffeine、Knife4j。

---

## 五、文件描述模板

> 新增功能或核心类时，按以下模板在本文档相应模块下追加。**「干什么」必须业务化，"怎么实现"必须落到代码/框架层面，技术要点写清楚为什么用。**

```markdown
### 5.x 功能名（模块名）

**功能说明**：一句话说明该功能解决什么业务问题、面向谁使用。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [XxxController.java](../wms/src/main/java/com/wms/xxx/controller/XxxController.java) | 接口入口 | REST 接口，权限标识 `xxx:yyy:zzz` | Spring MVC、Security |
| [XxxServiceImpl.java](../wms/src/main/java/com/wms/xxx/service/impl/XxxServiceImpl.java) | 业务实现 | ①…②…③…（按步骤写核心流程） | MyBatis-Plus、Redis、@Transactional |

**实现方式**：以「新增/核心操作」为例——①校验… → ②… → ③入库 → ④联动…。关键点：xx 用 xx 技术保证 xx（并发/一致性/幂等）。

**技术栈**：…（列出实际用到的，不堆砌）
```

### 模板示例（可直接套用）

```markdown
**功能说明**：点位管理。维护仓库三级层级中最末级「点位」数据，支持自动编码、级联停用、巷道点位计数。

**核心实现文件**

| 文件 | 用途 | 实现方式 | 技术 |
|------|------|---------|------|
| [WmsPointServiceImpl](../wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java) | 点位业务 | 新增前校验所属巷道启用 → 自动生成编码 → 入库 → `setSql` 维护 point_count | MyBatis-Plus、Redis INCR |

**实现方式**：新增点位时——①校验所属巷道存在且启用 → ②回填区域/厂区/楼层冗余字段 → ③`WmsCodeGeneratorService.generatePointCode` 生成 `{aisleCode}-P{序号}`（Redis INCR 防并发重复） → ④入库 → ⑤`point_count = point_count + 1`。全程同一事务，保证编码与统计一致。

**技术栈**：MyBatis-Plus、Redis、MapStruct、`@Transactional`。
```

---

## 六、编写规范建议

1. **一个模块一个小节**：新增模块在「三、功能模块总览」加一行，并复制 4.x 小节模板。
2. **链接必须可点击**：一律使用相对路径 `../wms/src/main/java/...`，不要写绝对路径（换机器/上 Git 会失效）。
3. **"干什么"写业务、"怎么实现"写代码**：避免只写"实现 CRUD"，要写出校验规则、状态流转、并发/事务处理等关键逻辑。
4. **技术栈如实填写**：只列文件里真实用到的，必要时注明"为什么用"（如 REQUIRES_NEW 是为了避免远程调用占用长事务连接）。
5. **重大整改留痕**：涉及状态机、事务、安全策略等关键改动，可在模块末尾追加「⚠️ 注意」说明当前口径与待验证事项（参考 DMJC.md 整改记录）。
6. **保持与代码同步**：重构后及时更新对应小节，防止文档与源码脱节。
