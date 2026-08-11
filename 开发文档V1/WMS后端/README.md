# WMS 后端（wms 工程）功能开发文档

> 本文档描述 `d:\workcoding\wms20260712\wms` 工程实现的功能。
> 按**功能模块**拆分文档，每个模块的 md 文件详细描述：模块怎么实现、每个 Java 文件的作用与引用的包、对应的数据表设计（来源 [public.sql](../../wms/sql/public.sql)）。

---

## 一、文档结构

| 模块文档 | 功能说明 | 状态 |
|---------|---------|------|
| [rcs.md](./rcs.md) | AGV 调度（RCS）对接：出站接口调用、入站回调、任务台账与状态机 | ✅ 已完成 |
| [auth.md](./auth.md) | 认证授权：登录/登出/令牌刷新/验证码 | ✅ 已完成 |
| [system.md](./system.md) | 系统管理：用户/角色/菜单/部门/字典/配置/日志 | ✅ 已完成 |
| [file.md](./file.md) | 文件存储：本地 / MinIO / 阿里云 OSS 三种后端 | ✅ 已完成 |
| [warehouse.md](./warehouse.md) | 仓库管理：库位/巷道/点位三级层级、编码生成、级联 | ✅ 已完成 |
| [carriermanagementsystem.md](./carriermanagementsystem.md) | 载具管理：料车型号/料车/装载明细、装车取走、扫码 | ✅ 已完成 |
| [business.md](./business.md) | 业务扩展：外部接口请求日志 | ✅ 已完成 |
| [message.md](./message.md) | 消息推送：SSE 实时推送 | ✅ 已完成 |
| [common.md](./common.md) | 公共基础：统一结果/异常/枚举/注解/工具类 | ✅ 已完成 |
| [framework.md](./framework.md) | 框架基础设施：安全/限流/日志切面/缓存/全局异常/接口文档 | ✅ 已完成 |

---

## 二、工程技术栈总览

数据来源：[pom.xml](../../wms/pom.xml)

| 分类 | 技术选型 | 版本 | 用途 |
|------|---------|------|------|
| 语言 | JDK 17 | 17 | 需 `--add-opens java.base/java.lang=ALL-UNNAMED`（Orika 反射） |
| 框架 | Spring Boot | 4.0.5 | Web / Security / Redis / Cache / Mail / Validation / AOP |
| ORM | MyBatis-Plus | 3.5.15 | 通用 Mapper、分页、数据权限（jsqlparser） |
| 数据库 | PostgreSQL | 14+ | 使用 jsonb 类型（如 RcsTask.payload） |
| 缓存 | Redis + Redisson | — | 缓存 / 分布式锁 / 防重复提交 / 限流 |
| 安全 | Spring Security + JWT | — | 双令牌（JWT/Redis 两套 TokenManager） |
| 映射 | MapStruct + Orika | 1.6.3 / 1.5.4 | 编译期 DTO↔Entity 转换 / 运行时深拷贝 |
| 文档 | Knife4j + springdoc | 4.5.0 / 2.8.9 | OpenAPI 3 |
| Excel | EasyExcel（fastexcel） | 1.3.0 | 导入导出 |
| 对象存储 | MinIO / OSS / 本地 | 8.5.10 | 按 `oss.type` 切换 |
| 工具 | Hutool / fastjson2 / ip2region | — | 断言 / JSON / IP 归属地 |
| 定时 | XXL-Job + @Scheduled | 3.2.0 | 分布式调度 / 在线用户数统计 |

---

## 三、数据库表总览（public.sql）

`wms` 工程数据库共 23 张表（public.sql）：`sys_*` 为第三方脚手架表（system 模块），业务自建表以 `wms_*` / `api_request_log` 命名。

### 3.1 业务自建表（wms_* / api_request_log）

| 表名 | 归属模块 | 用途 | 核心字段 |
|------|---------|------|---------|
| `wms_location` | warehouse | 库位/区域主表（多厂区隔离，parent_id 管归属，floor 管楼层） | location_code / location_type / parent_id / floor / status |
| `wms_aisle` | warehouse | 巷道/通道表（区域下一级，AGV 路径规划） | aisle_code / location_id / aisle_purpose / is_handover_point / point_count |
| `wms_point` | warehouse | 地标/点位表（仅坐标点，不承载库存） | point_code / aisle_id / barcode / coordinate / sort_order / status |
| `wms_cart_model` | carriermanagementsystem | 料车型号配置 | model_code / max_capacity / layer_count |
| `wms_cart` | carriermanagementsystem | 料车实例台账 | cart_code / model_id / current_quantity / status / actual_capacity |
| `wms_cart_item` | carriermanagementsystem | 料车装载明细（装车/取走） | cart_id / product_code / sort_order / status / loaded_at / taken_at |
| `wms_rcs_task` | rcs | RCS 调度任务台账（6 态全生命周期） | task_code / task_type / status / priority / payload(jsonb) / rcs_task_id |
| `wms_rcs_task_lifecycle` | rcs | 任务状态变更历史（每次流转一条） | task_id / status_from / status_to / operator_type / operator_id |
| `api_request_log` | business | 外部系统接口调用日志（链路追踪/性能监控） | api_code / api_url / req_params / res_params / duration / trace_id / is_success |

### 3.2 脚手架表（sys_*，system 模块）

| 表名 | 用途 | 核心字段 |
|------|------|---------|
| `sys_user` | 系统用户 | username / nickname / password / dept_id / status |
| `sys_role` | 系统角色（含数据权限级别） | name / code / status / data_scope |
| `sys_menu` | 系统菜单（目录/菜单/外链/按钮，生成前端路由） | parent_id / type / route_path / component / perm |
| `sys_dept` | 部门管理（树形，含厂区编码） | name / code / parent_id / tree_path / plant_code |
| `sys_dict` | 数据字典类型 | dict_code / name / status |
| `sys_dict_item` | 数据字典项 | dict_code / value / label / tag_type / sort |
| `sys_config` | 系统配置（key-value） | config_key / config_value |
| `sys_log` | 系统操作日志 | module / action_type / operator_name / ip / browser / execution_time |
| `sys_notice` | 系统通知公告 | title / content / type / target_type / publish_status |
| `sys_user_notice` | 用户通知公告关联（已读状态） | notice_id / user_id / is_read / read_time |
| `sys_user_role` | 用户角色关联 | user_id / role_id |
| `sys_role_menu` | 角色菜单关联 | role_id / menu_id |
| `sys_role_dept` | 角色部门关联（自定义数据权限范围） | role_id / dept_id |
| `sys_user_social` | 用户第三方账号绑定（微信等） | user_id / platform / openid / unionid / session_key |

> 完整建表语句见 [public.sql](../../wms/sql/public.sql)。每张表的字段设计、索引、外键在各模块文档中对应小节描述。

---

## 四、如何阅读各模块文档

每个模块 md 统一按以下结构编写：

1. **模块概述** —— 解决什么业务问题，对外提供哪些能力；
2. **数据表设计** —— 表结构、字段含义、索引/外键（来源 public.sql）；
3. **Java 文件清单** —— 每个文件：作用、引用的主要包、实现要点；
4. **核心实现逻辑** —— 关键流程（状态流转、闭环、事务边界等）；
5. **技术栈** —— 该模块实际用到的技术。

> Java 文件链接均为相对路径（`../../../wms/src/main/java/...`），IDE 中 Ctrl+点击可跳转源码。

---

## 五、全局功能索引（功能 → 文档章节）

> 使用方式：想改某个功能 → 查下表 → 打开对应模块文档的章节 → 点击文档中的 Java 文件链接直达源码。
> 表中"关键代码入口"为建议起点（多为 Service 实现方法）。

### 5.1 认证与权限

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 账号密码登录 | [auth.md](./auth.md) §5.1 | `AuthServiceImpl.login` |
| 登出 / 令牌刷新 | [auth.md](./auth.md) §5.3 | `TokenManager.invalidateToken` / `refreshToken` |
| 短信验证码登录（已停用 C-02） | [auth.md](./auth.md) §5.2 | `AuthServiceImpl.sendSmsCode`（待启用需先整改） |
| 图形验证码 | [framework.md](./framework.md) §2.8 | `CaptchaService` |
| 安全过滤链与放行配置 | [auth.md](./auth.md) §5.4 | `SecurityConfig` / `TokenAuthenticationFilter` |
| 接口权限 `@PreAuthorize` | [framework.md](./framework.md) §2.1 | `PermissionService` |
| 数据权限（行级过滤） | [framework.md](./framework.md) §4.2 | `MyDataPermissionHandler` |
| 令牌双模式（JWT / Redis） | [framework.md](./framework.md) §4.4 | `JwtTokenManager` / `RedisTokenManager` |

### 5.2 系统管理

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 用户增删改 / 导入导出 / 改密 | [system.md](./system.md) §5.1 | `UserServiceImpl` / `UserImportListener` |
| 角色管理 / 权限缓存 / 踢下线 | [system.md](./system.md) §5.3 | `RoleMenuServiceImpl` / `TokenManager` |
| 菜单树与前端路由生成 | [system.md](./system.md) §5.2 | `MenuServiceImpl` / `RouteVO` |
| 部门管理 | [system.md](./system.md) §2.1 | `DeptServiceImpl` |
| 字典管理 + SSE 实时通知 | [system.md](./system.md) §5.4 | `DictServiceImpl` + `SseService.sendDictChange` |
| 系统配置缓存 | [system.md](./system.md) §5.5 | `ConfigServiceImpl` |
| 操作日志 / PV-UV 统计 | [system.md](./system.md) §5.6 | `LogServiceImpl` |

### 5.3 仓库管理

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 区域 / 巷道 / 点位增删改 | [warehouse.md](./warehouse.md) §4.1-4.2 | `WmsLocationServiceImpl` / `WmsAisleServiceImpl` / `WmsPointServiceImpl` |
| 自动编码规则 | [warehouse.md](./warehouse.md) §5.1 | `WmsCodeGeneratorService`（Redis INCR） |
| 级联停用 | [warehouse.md](./warehouse.md) §5.2 | `WmsCascadeServiceImpl` |
| 点位计数 point_count | [warehouse.md](./warehouse.md) §5.3 | `WmsPointServiceImpl` + `WmsAisleMapper.xml` |

### 5.4 料车管理

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 料车型号配置 | [carriermanagementsystem.md](./carriermanagementsystem.md) §4.3 | `CartModelServiceImpl` |
| 料车状态维护 / 容量计算 | [carriermanagementsystem.md](./carriermanagementsystem.md) §3.3、§5.4 | `CartServiceImpl` / `CartMapper.xml` |
| 装车（5 重校验） | [carriermanagementsystem.md](./carriermanagementsystem.md) §5.1 | `CartItemServiceImpl.saveCartItem` |
| 取走 / 删除 | [carriermanagementsystem.md](./carriermanagementsystem.md) §5.2 | `takeCartItem` / `batchTakeCartItems` |
| 扫码装车 / 扫码取走 | [carriermanagementsystem.md](./carriermanagementsystem.md) §5.3 | `loadByBarcode` / `takeByBarcode` |

### 5.5 AGV 调度（RCS）

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 任务下发闭环 | [rcs.md](./rcs.md) §5.2 | `RcsTaskServiceImpl.saveAndSubmitRcsTask` |
| 任务取消闭环 | [rcs.md](./rcs.md) §5.3 | `cancelRcsTask` |
| AGV 回调处理 | [rcs.md](./rcs.md) §5.4 | `handleTaskReport` / `handleTaskWarning` |
| 任务状态机 | [rcs.md](./rcs.md) §5.1 | `RcsTaskStatusEnum` + `changeStatus` |
| 外部接口统一调用 | [common.md](./common.md) §3.1 | `ApiRequestUtils.execute` |
| 接口请求日志 | [business.md](./business.md) §5 | `ApiRequestLogServiceImpl.saveLogAsync` |

### 5.6 消息与文件

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| SSE 会话建立 / 推送 / 清理 | [message.md](./message.md) §5.1-5.2 | `SseService` / `SseSessionRegistry` |
| 在线人数统计 | [message.md](./message.md) §5.3 | `OnlineUserCountTask` |
| 文件上传 / 删除 | [file.md](./file.md) §5.2-5.3 | `FileService`（MinIO / Local / OSS） |
| 存储后端切换 | [file.md](./file.md) §5.1 | `oss.type` 条件装配 |

### 5.7 公共与横切

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 统一响应体 / 错误码 | [common.md](./common.md) §3.2 | `Result` / `ResultCode` |
| 全局异常处理 | [framework.md](./framework.md) §4.3 | `GlobalExceptionHandler` |
| 限流 / 防重复提交 | [framework.md](./framework.md) §2.2 | `RateLimitAspect` / `RepeatSubmitAspect` |
| 操作日志切面 `@Log` | [framework.md](./framework.md) §2.2 | `LogAspect` |
| 审计字段自动填充 | [framework.md](./framework.md) §2.6、[rcs.md](./rcs.md) §3.4 | `AutoFillMetaObjectHandler` |
| 定时任务 | [framework.md](./framework.md) §2.5 | `XxlJob` / `@Scheduled` |
| 邮件 / 短信 | [framework.md](./framework.md) §2.7 | `MailService` / `SmsService` |
