# WMS 后端代码检测文档（DMJC）

> 检测对象：`d:\workcoding\wms20260712\wms`
> 检测依据：《阿里巴巴 Java 开发手册（嵩山版）》 + 业务逻辑一致性 + OWASP 安全基线 + 数据库 DDL（`wms/sql/public.sql`）
> 技术栈：Spring Boot 4.0.5 / JDK 17 / MyBatis-Plus 3.5.15 / PostgreSQL 16 / Redis / MinIO
> 检测日期：2026-08-10（含 SQL 脚本核对后修订）
> 检测范围：common、framework、auth、rcs、carriermanagementsystem、warehouse、system、business.log、file、message 全部模块

---

## 一、结论摘要

整体工程分层清晰（Controller / Service / Mapper / 领域模型分离，framework 层通过 Port 解耦 system 模块），遵循了较多既定工程约定（LambdaUpdateWrapper 显式字段、RCS 远程调用置于事务外、taskCode 作 reqCode 幂等、生命周期与主状态同事务、payload 用 JacksonTypeHandler + autoResultMap、日志异步落库）。错误码遵循阿里 A/B/C 五位规范，密码使用 BCrypt，限流采用 Redis + Lua 滑动窗口。

但仍存在若干**严重的安全隐患和业务一致性缺陷**，需优先修复。问题按严重程度分布如下（已结合 `public.sql` 修订）：

| 级别 | 数量（去重后约） | 典型问题 |
|------|------|----------|
| 🔴 严重（Blocker/Critical） | 13 | JWT 密钥硬编码、短信验证码固定 1234、MinIO 桶公共读写、文件上传无校验、SQL 注入、字典删除顺序错误、RCS 状态机非法流转、point_count 触发器损坏且未挂载 |
| 🟠 主要（Major） | 30+ | 事务缺失/缺 rollbackFor、updateById null 字段、回调无鉴权、缓存不一致、暴力破解无防护、N+1 查询、料车/编码并发竞态（降级）、DB 唯一约束缺失、外键删除策略冲突、model_id 类型不匹配 |
| 🟡 次要（Minor） | 30+ | 魔法值、命名/注释不规范、包装类拆箱 NPE、大字段全量返回、递归无环检测、字典项无索引、业务表缺逻辑删除 |

> **SQL 脚本核对带来的关键修订**：
> - **C-10 料车并发、C-11 编码生成并发**：DB 实际已存在 `uk_item_product_code`/`uk_item_cart_sort`/`uk_aisle|location|point_plant_code` 等唯一约束，唯一性有兜底，二者由 🔴 **降级为 🟠**（仅剩容量竞态/数量漂移/未捕获冲突重试）。
> - **C-13/C-15 新发现（🔴）**：`wms_aisle.point_count` 注释称「触发器自动维护」，但唯一函数 `update_updated_at_column()` 引用了不存在的列 `NEW.updated_at`（应为 `updated_time`）且**全库无任何 `CREATE TRIGGER`**，触发器实为损坏且从未生效。
> - **新增 DB 层问题（C-16~C-21）**：`config_key`/`dict_code` 缺唯一约束、`wms_cart.model_id` 为 int4 与实体 Long 不匹配、序列上限仅 21 亿、外键 NO ACTION/RESTRICT/CASCADE 与物理删除逻辑冲突、多数业务表缺逻辑删除字段。

> **项目自定义《开发规范指南》符合性核查（详见第七节）**：多条「死红线」被违反（SQL 注入 `${}`、密钥/口令硬编码、MinIO 公开、文件上传无校验、接口无鉴权），与上述 C/M 级发现重合；规范专属新增项：**N-01** 后端缺 `.editorconfig`、**N-02** 全项目无敏感信息脱敏（🔴）、**N-03** DB 审计字段按前缀分治——`sys_`（脚手架）保持原样、`wms_`（自研）以 `created_time/updated_time` 为项目标准，非违规，仅 `wms_` 业务表待补 `is_deleted`、**N-04** `wms_cart_item` 索引超上限、**N-05** 后端零单元/集成测试（🔴）。

**必须立即修复的 Top 5**：
1. JWT 密钥硬编码且 dev/prod 相同（可伪造任意用户身份）
2. 短信登录验证码固定为 `"1234"`（任何人可登录）
3. MinIO 桶被代码自动设为公共读写（任意匿名读/写/删文件）
4. 文件上传无类型校验 + 删除接口路径穿越且无权限（任意文件上传/删除）
5. 生产 Redis 无密码 / DB 弱口令（配置文件明文入库）

---

## 二、严重问题（🔴 Blocker / Critical）

### 2.1 安全类严重问题

#### C-01 JWT 密钥硬编码在配置文件，dev/prod 使用相同弱示例值
- **位置**：[application-dev.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml)（`security.jwt.secret-key`）、[application-prod.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml)
- **问题**：`secret-key: SecretKey012345678901234...` 明文写入代码库，且 dev 与 prod 使用完全相同的可预测密钥。任何拿到源码者可伪造任意用户（含超管）的 JWT。
- **违反**：OWASP A02 加密失败；阿里手册「禁止敏感信息硬编码」。
- **建议**：改为 `${JWT_SECRET_KEY}` 从环境变量/配置中心注入；不同环境独立高熵随机密钥；`JwtTokenManager` 构造时密钥长度不足应 fail-fast。
- **整改状态（2026-08-10 已修复）**：dev [application-dev.yml:110-111](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml#L110-L111) 改为 `${JWT_SECRET:<开发默认强随机值>}`（本地开发可用默认值）；prod [application-prod.yml:88-89](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml#L88-L89) 改为 `${JWT_SECRET}` **无默认值**，未注入则启动失败（配合 `SecurityProperties.JwtConfig` 的 `@NotNull`）。移除了明文硬编码密钥，dev/prod 不再共用同一值。部署时需在生产环境注入 `JWT_SECRET`（≥64 字符随机值，可用 `openssl rand -base64 48` 生成）。

#### C-02 短信登录验证码硬编码为固定值 "1234"，且发送失败仍写入缓存
- **位置**：[AuthServiceImpl.java:84](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java#L84)、[AuthServiceImpl.java:89-95](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java#L89-L95)
- **问题**：`String code = "1234";` 固定验证码，任何人凭 1234 即可短信登录。且短信发送失败仅记录日志（`catch` 吞异常），随后**无条件**将验证码写入 Redis，即使短信从未发出攻击者仍可登录。
- **违反**：OWASP A07 认证失败；阿里手册「不允许吞异常」。
- **建议**：改用 `SecureRandom` 生成 6 位随机码；短信发送成功后才写 Redis；发送失败抛业务异常。删除生产遗留 TODO。
- **同类**：[UserServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) 的 `sendMobileCode` / `sendEmailCode` 同样固定 `"123456"`（属换绑手机/邮箱场景，需登录态，风险低于登录后门，待用户确认是否一并禁用）。
- **整改状态（2026-08-10 已修复）**：采用「禁用接口保留代码」方案，登录短信与换绑手机/邮箱固定码一并处理——
  ① **登录短信**：[AuthController.java:57-83](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/controller/AuthController.java#L57-L83) 注释下线 `loginBySms`、`sendSmsCode` 两个接口；dev/prod 白名单移除 `/api/v1/auth/sms/code` 放行（[application-dev.yml:118](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml#L118)、[application-prod.yml:96](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml#L96)）；[AuthServiceImpl.sendSmsCode](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java#L73-L84) 追加安全警示 Javadoc。
  ② **换绑手机/邮箱**：[UserController.java:241-250](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/controller/UserController.java#L241-L250) 注释下线 `/mobile/code`、[UserController.java:270-279](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/controller/UserController.java#L270-L279) 注释下线 `/email/code` 两个发码接口；[UserServiceImpl.sendMobileCode](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java#L435-L443)、[UserServiceImpl.sendEmailCode](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java#L524-L531) 追加安全警示 Javadoc。
  Service/Provider/Token 类均保留，接入厂商短信/邮箱服务后取消接口注释并改随机码（发送成功后才写缓存）即可恢复。⚠️ 下线期间「绑定或更换手机号/邮箱」因无法获取验证码将不可用（已在 Controller 注释中说明）。

#### C-03 MinIO 存储桶被代码自动设置为公共读写
- **位置**：[MinioFileServiceImpl.java:110-127](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java#L110-L127)（`publicBucketPolicy`）
- **问题**：`createBucketIfAbsent` 为新桶设置 `Principal:{"AWS":["*"]}` 且 Action 含 `s3:PutObject / s3:DeleteObject / s3:GetObject`，任何匿名公网用户可读/写/删桶内文件。
- **违反**：OWASP A01 访问控制失效 / A05 安全配置错误。
- **建议**：移除公共写权限；如需公网读取仅授予只读 `s3:GetObject`；上传走后端签名 URL；桶策略由运维显式管理。
- **整改状态（2026-08-10 已修复）**：经确认 MinIO 文件功能当前仅用于「用户头像上传」，核心 WMS 业务未使用，故按用户决策采用「禁用接口保留代码」方案（与 C-02 同思路）——[FileController.java:30-61](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/controller/FileController.java#L30-L61) 注释下线 `uploadFile`、`deleteFile` 两个接口。接口下线后 `createBucketIfAbsent` 不再被触发，公共桶策略实际不会执行，漏洞利用面归零。**本次未改动 MinIO 桶策略代码与已上传文件，故存量头像 URL 不受影响（不会图裂）**。⚠️ 恢复前置条件：日后如需启用文件上传，须先完成 ①`MinioFileServiceImpl` 桶改私有（删 `publicBucketPolicy`/去 `setBucketPolicy`）+ 走预签名 URL（并修复 [第76行](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java#L76) `substring(0, indexOf("?"))` 截断鉴权 query 的隐性 bug）、②C-04 上传/删除加固，再取消接口注释。

#### C-04 文件上传无类型/大小/文件名校验，删除接口存在路径穿越且无权限
- **位置**：[FileController.java:30-54](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/controller/FileController.java#L30-L54)、[LocalFileServiceImpl.java:34-61](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/LocalFileServiceImpl.java#L34-L61)、[MinioFileServiceImpl.java:52-89](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java#L52-L89)、[AliyunFileServiceImpl.java:46-64](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/AliyunFileServiceImpl.java#L46-L64)
- **问题**：
  1. 无扩展名白名单、无 MIME 校验，可上传 .jsp/.html/.svg 等；`FileInfo.name` 回显原始文件名，配合 SVG/HTML 可存储型 XSS。
  2. `deleteFile` 无 `@PreAuthorize`，任何登录用户可删任意文件；本地实现 `storagePath + filePath` 若含 `../` 可穿越目录删除任意可达文件。
- **违反**：OWASP A01 / A03。
- **建议**：扩展名 + MIME 白名单；用 `FilenameUtils.getName` 去路径并校验非法字符；删除按存储 key 且校验归属、规范化路径拒绝 `..`；上传/删除接口加权限注解。
- **整改状态（2026-08-10 已缓解）**：本问题的利用入口（`uploadFile`/`deleteFile` 接口）已随 C-03 一并注释下线（[FileController.java:30-61](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/controller/FileController.java#L30-L61)），当前无法通过接口触发上传/删除，路径穿越与无校验风险的**利用面暂时归零**。但 Service 层加固代码（扩展名/MIME 白名单、`FilenameUtils.getName` 去路径、删除校验归属+拒绝 `..`、接口 `@PreAuthorize`）**尚未落地**，仅为「接口下线」而非「代码修复」。⚠️ 恢复文件上传前必须先补齐上述加固，否则漏洞随接口恢复而复现。

#### C-05 生产 Redis 无密码 / 数据库弱口令，凭据明文入库
- **位置**：[application-dev.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml)、[application-prod.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml)
- **问题**：生产 PostgreSQL 弱口令（如 `postgres`），生产 Redis 无密码，均与项目硬约束「Redis 必须启用密码并绑定内网」冲突；口令明文写入代码库。
- **违反**：OWASP A05。
- **建议**：全部改 `${DB_PASSWORD}` / `${REDIS_PASSWORD}` 注入；生产 Redis 设强密码并绑定内网；轮换已泄露口令。

#### C-06 用户列表排序参数 `order` 无白名单，存在 SQL 注入
- **位置**：[UserMapper.xml:74](file:///d:/workcoding/wms20260712/wms/src/main/resources/mapper/system/UserMapper.xml#L74)、[BaseQuery.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/base/BaseQuery.java)
- **问题**：`ORDER BY u.${queryParams.sortBy} ${queryParams.order}`。`sortBy` 有 `@ValidField` 白名单，但 `order` 无任何校验，以 `${}` 直接拼接，可注入。
- **违反**：阿里手册「用户可控值禁止 `${}` 直接拼接」。
- **建议**：`order` 加白名单（仅 `ASC`/`DESC`，忽略大小写），或 XML `<choose>` 固定枚举分支。
- **整改状态（2026-08-10 已修复）**：采用**双层防御**——① 应用层白名单：给 [ValidField](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/annotation/ValidField.java#L35-L38) 增加 `ignoreCase` 属性、[FieldValidator](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/validator/FieldValidator.java#L27-L36) 支持忽略大小写匹配，[BaseQuery.order](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/base/BaseQuery.java#L33-L35) 加 `@ValidField(allowedValues={"ASC","DESC"}, ignoreCase=true)`，非法值在参数校验阶段即被拒绝（`sortBy` 原白名单不受影响）；② XML 兜底：[UserMapper.xml:71-85](file:///d:/workcoding/wms20260712/wms/src/main/resources/mapper/system/UserMapper.xml#L71-L85) 将 `${queryParams.order}` 改为 `<choose>` 固定输出常量 `ASC`/`DESC`，**彻底移除对 order 原始输入的 `${}` 拼接**。经全库 mapper 排查，其余 `${}` 均为编译期常量引用（`@枚举@常量`），非用户可控，无其他注入点。`sortBy` 仍以 `${}` 拼接但受 `@ValidField(allowedValues={create_time,update_time})` 白名单保护。

#### C-07 CORS 允许任意来源且开启凭证
- **位置**：[CorsConfig.java:25-31](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/config/CorsConfig.java#L25-L31)
- **问题**：`setAllowedOriginPatterns("*")` + `addAllowedHeader/Method(ALL)` + `setAllowCredentials(true)` 同时开启，携带凭证的跨域请求可来自任意源。
- **建议**：`allowCredentials(true)` 时必须配置受信任域名白名单，禁止与 `*` 组合。
- **整改状态（2026-08-10 已修复）**：[CorsConfig.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/config/CorsConfig.java) 改为 `@ConfigurationProperties(prefix="cors")` 从配置注入受信任来源白名单 `cors.allowed-origins`，移除硬编码 `"*"`；白名单为空时**启动即抛异常**（fail-fast，杜绝误配成全放行）。各环境独立配置：dev [application-dev.yml:103-108](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml#L103-L108) 仅放行 `http://localhost:*` / `http://127.0.0.1:*` 本地前端；prod [application-prod.yml:81-85](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml#L81-L85) 通过环境变量 `${CORS_ALLOWED_ORIGINS}`（无默认值，未注入则启动失败）注入受信任域名。`allowCredentials(true)` 不再与 `*` 组合，仅与具体白名单配合，消除携带凭证的任意源跨域风险。

### 2.2 业务逻辑类严重问题

#### C-08 字典删除逻辑顺序错误，字典项永远无法级联删除
- **位置**：[DictServiceImpl.java:157-168](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java#L157-L168)
- **问题**：先 `this.removeByIds(ids)` 删字典，再 `this.listByIds(ids)` 查字典编码。此时字典已删，`list` 为空，字典项删除被跳过 → 产生孤儿数据。**已验证确认**。
- **建议**：先 `listByIds` 取 `dictCodes`，再删字典，最后删字典项，三步同一 `@Transactional(rollbackFor = Exception.class)`。
- **整改状态（2026-08-10 已修复）**：[DictServiceImpl.deleteDictByIds:155-171](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java#L155-L171) 调整为正确顺序——① 先 `listByIds` 查出字典（缓存 `dictCodes`）→ ② 删字典 → ③ 按 `dictCodes` 删字典项；`@Transactional` 补全 `rollbackFor = Exception.class`。因字典为逻辑删除（`is_deleted`），原代码删后再查恒为空、字典项永不删除，现已修正，字典项能正确级联删除，不再产生孤儿数据。

#### C-09 RCS 任务状态机缺少非法流转校验，终态可被回退
- **位置**：[RcsTaskServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java)（`changeStatus` / `mapReportToStatus` / `handleTaskReport`）
- **问题**：`changeStatus` 只做「目标==当前则跳过」的幂等，无流转合法性校验。RCS 回调乱序/重复时，已 `FINISHED` 的任务收到迟到的 `START` 回馈会被改回 `EXECUTING`；`handleTaskReport` 未像 `handleTaskWarning` 那样先判 `isFinalStatus`，终态可被重新激活。违反硬约束「状态机不应有非法流转」。
- **建议**：建立状态流转白名单矩阵（终态不可再变），非法流转记录日志并拒绝；`handleTaskReport` 先判终态。
- **整改状态（2026-08-10 已修复，⚠️ 临时方案）**：建立状态流转白名单矩阵并在 `changeStatus` 统一校验，改动四处——
  ① **流转矩阵单一数据源**：[RcsTaskStatusEnum.java:66-118](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/enums/RcsTaskStatusEnum.java#L66-L118) 新增 `TRANSITIONS` 白名单表 + `of(Integer)` / `isFinal()` / `canTransfer(from, to)` 方法。当前口径：`FINISHED`/`CANCELLED` 锁死终态（不流向任何状态）；`EXCEPTION` 允许重试恢复到 `ASSIGNED`/`EXECUTING`、允许被 `CANCELLED`，但不允许直接 `FINISHED`；`EXECUTING` 不允许回退 `ASSIGNED`。日后仅需调整此表即可校准口径，无需改校验逻辑。
  ② **changeStatus 加流转校验**：[RcsTaskServiceImpl.changeStatus](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) 在「目标==当前幂等跳过」之后追加 `canTransfer` 校验，**非法流转记 `warn` 日志并 `return` 跳过（不抛异常）**——适配 RCS 回调乱序/重复投递，避免单条乱序回馈导致整个回调事务回滚。
  ③ **handleTaskReport 终态拦截**：[RcsTaskServiceImpl.java:303-311](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java#L303-L311) 在状态映射后、回填 AGV 前新增终态判断，终态任务对迟到回馈仅记 `info` 日志不流转，与 `handleTaskWarning` 行为一致（解决「已完成任务被迟到 START 回馈打回 EXECUTING」的核心 bug）。
  ④ **isFinalStatus 委托收敛**：[RcsTaskServiceImpl.java:339](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java#L339)（`handleTaskWarning` 调用点）改为委托 `RcsTaskStatusEnum.of(status).isFinal()`，终态定义收敛到枚举单一来源。
  ⚠️ **临时方案说明**：所有改动均加「C-09 临时方案，待测试后调整」注释。`EXCEPTION 可重试恢复`（→ASSIGNED/EXECUTING）、`PENDING/ASSIGNED 可跳中间态直接流转`等口径为初版规则，待用户完成 RCS 联调测试后再校准，届时仅调整 `TRANSITIONS` 表即可。**本环境无 mvn/mvnw，未编译验证**，需用户在本地构建后按状态流转场景验证（正常派发→执行→完成链路、终态收到迟到回馈仅记录不回退、异常重试恢复、非法流转仅 warn 不影响事务）。

#### C-10 料车装车/取走存在并发竞态（🟠 结合 SQL 后降级为主要）
- **位置**：[CartItemServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java)（`saveCartItem` / `updateCartAfterChange`）
- **SQL 校正**：`public.sql` 确认 `wms_cart_item` 已存在唯一约束 [uk_item_product_code UNIQUE(product_code)](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1403) 与 [uk_item_cart_sort UNIQUE(cart_id, sort_order)](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1402)。因此下列第 2、3 点的**唯一性在 DB 层已有兜底**，并发重复插入会被数据库拒绝（抛 `DuplicateKeyException`），不会产生脏数据。本条整体**降级为主要（🟠）**，仅剩容量校验竞态与数量漂移仍需处理。
- **问题**：
  1. （仍有效）容量校验为「查计数→判断→插入」非原子，并发下可能双双通过校验致**超载**——`wms_cart_item` 无「按 cart_id 统计在车数 ≤ 容量」的约束，DB 无法拦截。
  2. （已有 DB 兜底）`sortOrder` 同车唯一「查 max→+1→插入」并发下会撞 `uk_item_cart_sort`，第二个请求报错——不会重复，但用户侧表现为**装车偶发失败**，应捕获冲突后重试取新序号。
  3. （已有 DB 兜底）`productCode` 全局唯一应用层 `selectCount` 之外有 `uk_item_product_code` 兜底——不会重复，但仍应捕获 `DuplicateKeyException` 转友好提示，而非直接 500。
  4. （仍有效）`updateCartAfterChange` 读 Cart→计算→`updateById` 覆盖 status/current_quantity，无乐观锁，并发互相覆盖导致 `current_quantity` 数量漂移（此为冗余计数字段，DB 无约束保护）。
- **建议**：容量校验与 `current_quantity` 维护按 cartId 加 Redisson 分布式锁或 Cart 表加 version 乐观锁；应用层唯一校验保留用于提前给出友好提示，但必须捕获 DB 唯一冲突兜底重试；`updateCartAfterChange` 改用 LambdaUpdateWrapper 显式 set（符合项目既定约定）。

#### C-11 warehouse 编码生成并发竞态（🟠 结合 SQL 后降级为主要）
- **位置**：[WmsCodeGeneratorService.java:89-98](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/utils/WmsCodeGeneratorService.java#L89-L98)
- **SQL 校正**：`public.sql` 确认三张表编码列**已有 DB 唯一约束兜底**——[uk_aisle_plant_code UNIQUE(plant_code, aisle_code)](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1344)、[uk_location_plant_code UNIQUE(plant_code, location_code)](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1432)、[uk_point_plant_code UNIQUE(plant_code, point_code)](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1464)。因此「Redis 异常时静默产生重复编码」不成立，重复插入会被 DB 拒绝。本条整体**降级为主要（🟠）**。
- **问题**：
  1. （仍有效）`initSeqIfAbsent` 用 `setIfAbsent` 抢占后再 `maxSeqSupplier.get()` 查库 `set`，初始化与自增非原子，首批并发可能重复/跳号；Redis 丢失/过期后重新初始化仍可能得到重复候选值。
  2. （已有 DB 兜底）候选编码撞唯一约束时不会入库脏数据，但当前代码未捕获 `DuplicateKeyException` 重试，用户侧表现为**新增偶发失败并返回 500**（且失败后 Redis 序号可能已 `incr`，进一步加剧跳号）。
- **建议**：初始化用 Lua 原子化或分布式锁保证首批唯一；插入捕获唯一冲突后重取序号重试；DB 唯一约束保留作为最终防线。

#### C-12 菜单 saveMenu 无事务 + 缓存/treePath 不一致
- **位置**：[MenuServiceImpl.java:288-341](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java#L288-L341)
- **问题**：`saveMenu` 无 `@Transactional`，`saveOrUpdate` 成功后 `updateChildrenTreePath`（`this.` 自调用递归）若失败，父菜单已保存但子节点 treePath 未更新；新增按钮权限时未刷新角色权限缓存（仅编辑时刷新），赋权延迟生效。
- **建议**：加 `@Transactional(rollbackFor = Exception.class)`；treePath 级联与主保存同事务；新增涉权菜单也刷新权限缓存。

#### C-13 库区 point_count「双保险」口径割裂，且注释所称「触发器自动维护」实为损坏且未挂载（🔴 SQL 新发现）
- **位置**：[WmsAisleMapper.xml](file:///d:/workcoding/wms20260712/wms/src/main/resources/mapper/warehouse/WmsAisleMapper.xml)（子查询实时计算）、[WmsPointServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java)（`point_count ± 1` 手动维护）、[public.sql:756](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L756)、[public.sql:1021-1030](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1021-L1030)
- **问题**：
  1. （原结论仍有效）分页查询永远用子查询 `COUNT(*)` 实时计算，而写路径手动维护 `point_count` 字段却从不被查询使用，两套口径并存易长期偏离。
  2. **（SQL 新发现）** `wms_aisle.point_count` 注释明确写「**由触发器自动维护**」（[public.sql:756](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L756)），但该「触发器」在 DB 中根本不存在，且函数本身已损坏：
     - 唯一的函数 [update_updated_at_column()](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1021-L1030) 引用 `NEW.updated_at`，而**全库所有表的审计列名均为 `updated_time`**（不存在 `updated_at` 列），一旦被触发即抛 `record "new" has no field "updated_at"`；
     - 全脚本**没有任何 `CREATE TRIGGER` 语句**（已 grep 确认），函数从未挂载到任何表；
     - 即便挂载，该函数也只维护时间戳，与 `point_count` 计数毫无关系——注释描述与函数职责南辕北辙。
  3. 结论：`point_count` 实际完全依赖 Java 代码手动 `±1` 维护，注释是**误导性的假象**；若后续开发者按注释信赖触发器而移除手动维护，字段将永久失准。
- **建议**：
  1. 立即修正/删除误导注释；明确 `point_count` 由应用层维护（或彻底改为查询实时计算并移除该字段）。
  2. 若确需时间戳触发器：修复函数为 `NEW.updated_time`，并补 `CREATE TRIGGER ... BEFORE UPDATE ... EXECUTE FUNCTION update_updated_at_column()`；否则删除该无用损坏函数。
  3. 保留手动维护则提供对账/重算任务校正历史偏差。

#### C-14 数据权限拦截器字符串拼接 SQL（与注释矛盾）
- **位置**：[MyDataPermissionHandler.java:232-266](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/mybatis/interceptor/MyDataPermissionHandler.java#L232-L266)
- **问题**：类注释宣称「用 JSQLParser 避免字符串拼接」，但 `buildDeptAndSubExpression`/`buildCustomDeptExpression` 实际把 deptId/customDeptIds/列名拼进 SQL 字符串再 parse。当前输入来自 Token（可信）风险有限，但列名/别名若被扩展为可配置即形成注入面，且与设计意图不符。
- **建议**：统一用 JSQLParser `InExpression + ExpressionList` 构建，或对列名/别名做白名单校验。

### 2.3 数据库设计（DDL）层面问题（依据 `public.sql` 补充）

> 说明：以下依据 [public.sql](file:///d:/workcoding/wms20260712/wms/sql/public.sql)（PostgreSQL 16，导出于 2026-08-10）核对，是对前述静态代码结论的实证校正与补充。

#### C-15 唯一函数 `update_updated_at_column()` 引用错误列名且从未挂载触发器（🔴 严重）
- **位置**：[public.sql:1021-1030](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1021-L1030)
- **问题**：函数体 `NEW.updated_at = CURRENT_TIMESTAMP;` 引用的 `updated_at` 列在**任何表中都不存在**（全库审计列统一为 `updated_time`）；且全脚本**无任何 `CREATE TRIGGER`**（已 grep 确认），函数是「死代码」。一旦有人补挂触发器即会运行时报错 `record "new" has no field "updated_at"`，导致对应表的 UPDATE 全部失败。这是横跨 DB 与代码的隐藏地雷（详见 C-13）。
- **建议**：修复为 `NEW.updated_time` 并显式 `CREATE TRIGGER`，或直接删除该无用函数，避免误用。

#### C-16 `wms_cart.model_id` 数据库为 int4，实体映射为 Long，且序列上限仅 21 亿（🟠 主要）
- **位置**：[public.sql:766](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L766)（`"model_id" int4 NOT NULL`）、[Cart.java:42](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cart/model/entity/Cart.java#L42)（`private Long modelId;`）、[public.sql:169](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L169)/[public.sql:191](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L191)（`wms_cart_id_seq`/`wms_cart_model_id_seq` MAXVALUE 2147483647）
- **问题**：
  1. 类型不一致：`wms_cart_model.id`/`wms_cart.id` 为 int4（受序列 MAXVALUE 2147483647 约束），但外键宿主 `wms_cart.model_id` 也为 int4，而 Java 实体 `Cart.modelId`/`CartModel.id` 用 `Long`（int8）。当前数据量小无碍，但类型语义割裂，且与其余表统一使用 int8 主键不一致。
  2. 序列上限风险：`wms_cart_id_seq`、`wms_cart_model_id_seq` 上限为 int4 上限（21.4 亿），远小于其余表的 int8 上限（9.2×10^18），是设计遗漏。
- **建议**：统一料车相关主键/外键为 int8，序列 MAXVALUE 改 9223372036854775807，与实体 `Long` 对齐。

#### C-17 `sys_config.config_key` 无唯一约束，配置 key 可重复（🟠 主要）
- **位置**：[public.sql:1189-1192](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1189-L1192)（仅主键，无 `config_key` 唯一索引）
- **问题**：`config_key` 是业务上的「配置项唯一标识」，代码常按 key 读取配置。但 DB 未建唯一约束，重复 key 时按 key 查询结果不确定，缓存刷新（M-15）也会产生歧义。
- **建议**：`ALTER TABLE sys_config ADD CONSTRAINT uk_config_key UNIQUE(config_key)`（逻辑删除场景可改建 `WHERE is_deleted = 0` 的部分唯一索引）。

#### C-18 `sys_dict.dict_code` 仅普通索引无唯一约束（放大 C-08 字典删除隐患，🟠 主要）
- **位置**：[public.sql:1207-1211](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1207-L1211)（`idx_dict_code` 为普通 btree 索引）
- **问题**：应用层 [DictServiceImpl.saveDict](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java#L79-L83) 用 `count` 校验 `dict_code` 唯一，但 DB 无唯一约束兜底——并发新增或应用层校验遗漏时可产生**重复字典编码**。而 `sys_dict_item` 通过 `dict_code` 关联字典项，一旦重复，C-08 的错误删除与字典项级联将进一步失准（删一个 code 会误删/漏删另一个同 code 字典的字典项）。
- **建议**：`dict_code` 加唯一约束（同样可用部分唯一索引兼容逻辑删除）；同时修复 C-08 的删除顺序。

#### C-19 `sys_dict_item` 无 `dict_code` 索引，按字典编码查询/删除全表扫描（🟡 次要）
- **位置**：[public.sql:1218-1221](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1218-L1221)（仅主键）
- **问题**：字典项按 `dict_code` 查询（`getDictItems`）与级联删除（C-08）是高频路径，但该列无索引，数据增长后每次全表扫描。
- **建议**：`CREATE INDEX idx_dict_item_dict_code ON sys_dict_item(dict_code)`。

#### C-20 外键删除策略与应用层物理删除逻辑冲突（🟠 主要）
- **位置**：[public.sql:1517](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1517)、[public.sql:1522](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1522)、[public.sql:1527](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1527)、[public.sql:1532-1533](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1532-L1533)、[public.sql:1538](file:///d:/workcoding/wms20260712/wms/sql/public.sql#L1538)
- **问题**：这些业务表**采用物理外键 + 无逻辑删除字段**，删除策略与代码删除逻辑存在冲突：
  1. `fk_item_cart_id`（cart_item→cart）为 `ON DELETE NO ACTION`：`CartServiceImpl.deleteCart` 若直接物理删除料车、而车上仍有 `wms_cart_item`，将被外键拒绝（报 500）——印证 M-19「deleteCart 未校验在车物品」。
  2. `fk_aisle_location_id`、`fk_point_aisle_id`、`fk_point_location_id` 为 `ON DELETE RESTRICT`：删除库区/巷道若仍有下级巷道/点位会被拒绝，级联删除需应用层自上而下先删子级，否则报错回滚。
  3. `fk_wms_rcs_task_lifecycle_task` 为 `ON DELETE CASCADE`：删除 RCS 任务会连带删除其全部生命周期记录，可能与「保留历史审计」诉求冲突（审计数据不应随主任务物理消失）。
- **建议**：明确删除语义——业务数据优先逻辑删除；物理删除前应用层先校验/按依赖顺序级联；生命周期等审计表建议改逻辑删除或保留策略，避免 CASCADE 丢史。

#### C-21 大量业务表缺逻辑删除字段，与 system 模块的软删风格不统一（🟡 次要）
- **位置**：`wms_cart`/`wms_cart_item`/`wms_cart_model`/`wms_aisle`/`wms_location`/`wms_point`/`wms_rcs_task`/`api_request_log` 等表 DDL（无 `is_deleted` 列）；对比 `sys_config`/`sys_dept`/`sys_dict` 等均有 `is_deleted`
- **问题**：system 模块普遍逻辑删除，而 warehouse/料车/rcs 表为物理删除，风格割裂；物理删除叠加物理外键（C-20）导致删除行为脆弱且不可恢复。
- **建议**：统一删除策略；关键业务表补 `is_deleted` 逻辑删除并配 MyBatis-Plus `@TableLogic`。

---

## 三、主要问题（🟠 Major）

### 3.1 事务与数据一致性

| 编号 | 位置 | 问题 | 建议 |
|------|------|------|------|
| M-01 | [DeptServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DeptServiceImpl.java)、[DictItemServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DictItemServiceImpl.java)、[ConfigServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/ConfigServiceImpl.java) | 多步写方法完全无 `@Transactional`（如 dept `deleteByIds` for 循环多次 update） | 补 `@Transactional(rollbackFor = Exception.class)` |
| M-02 | DictServiceImpl `updateDict`/`deleteDictByIds`、RoleServiceImpl `assignMenusToRole`/`updateRoleStatus`/`deleteRoles` | 有 `@Transactional` 但缺 `rollbackFor`，默认不回滚受检异常 | 补全 `rollbackFor = Exception.class` |
| M-03 | [RcsTaskServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java)（`saveAndSubmitRcsTask`/`saveRcsTask`） | 建单方法为普通 `@Transactional` 而非 `REQUIRES_NEW`，注释称「独立事务」名不符实；若被外层事务调用，远程下发时任务尚未 commit，回填丢失 | 建单方法改 `REQUIRES_NEW` 或显式禁止在事务上下文调用 |

### 3.2 MyBatis / 持久层

| 编号 | 位置 | 问题 | 建议 |
|------|------|------|------|
| M-04 | UserServiceImpl `updateUser`、WmsAisle/Point/Location `updateXxx`、DictItem/Config `edit`、Cart `updateCart`、RcsTask `updateRcsTask` | 用 `converter.toEntity + updateById`，MyBatis-Plus 默认忽略 null 字段，无法清空字段；且依赖「忽略 null」隐式行为脆弱（配置一变即覆盖 status 等） | 改 `LambdaUpdateWrapper` 显式 set 允许编辑字段（符合项目既定约定） |
| M-05 | [ApiRequestLogController.java:41-55](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/business/log/controller/ApiRequestLogController.java#L41-L55)、[RcsTaskMapper.xml](file:///d:/workcoding/wms20260712/wms/src/main/resources/mapper/rcs/RcsTaskMapper.xml) | 列表分页返回 CLOB/jsonb 大字段（reqParams/resParams、payload） | 列表用 VO 排除大字段，详情接口才返回 |
| M-06 | [RoleServiceImpl.java:352-364](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/RoleServiceImpl.java#L352-L364) | `getRoleDataScopes` 循环内逐个查库（双重 N+1），登录/鉴权高频路径 | 一次 `in` 查询 + 批量查关联 |
| M-07 | [CartItemServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java)（`batchTakeCartItems`） | 循环内逐条调用自身事务方法（Spring 自调用事务不新开），N 件 = N 次 Cart 读写，放大竞态 | 批量 update 明细 + 去重 cartId 各更新一次 |

### 3.3 安全与鉴权

| 编号 | 位置 | 问题 | 建议 |
|------|------|------|------|
| M-08 | [RcsReporterController.java:54-81](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/controller/RcsReporterController.java#L54-L81) | RCS 回调接口完全无鉴权（仅 TODO），可伪造回馈驱动任意任务状态流转（结合 C-09 更严重） | 固定 token / IP 白名单 / 签名校验 |
| M-09 | [AgvController.java:31-37](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/controller/AgvController.java#L31-L37) | `commonRequest/{methodName}` 允许前端传任意 method + params 直调 RCS 全部接口，绕过状态机/幂等，仅粗粒度权限 | method 白名单；生产关闭或仅管理员；未知 method 抛 BusinessException |
| M-10 | [FileController.java:46-54](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/controller/FileController.java#L46-L54) | 文件删除/上传无 `@PreAuthorize`，任意登录用户可删任意文件（水平越权） | 加权限注解；记录归属仅允许删本人文件 |
| M-11 | 登录流程 [AuthServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java)、SmsAuthenticationProvider | 无登录失败次数限制/账号锁定；短信登录路径在 ignore-urls 且无 @RateLimit，4 位码 5 分钟内可暴力猜（校验失败不清缓存） | 失败计数+锁定；短信码失败累计即失效；`/login/sms` 加限流 |
| M-12 | ignore-urls：`/api/v1/logs/**`、`/doc.html`、`/v3/api-docs/**`（prod `knife4j.production: false`） | 日志接口/Swagger 文档生产环境未鉴权公开，信息泄露与踩点 | logs 必须鉴权；prod 关闭文档或加访问控制 |
| M-13 | [RedisTokenManager.java:88-111](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/security/token/RedisTokenManager.java#L88-L111) | `Optional.of(oldAccessTokenValue)` 当值为 null 抛 NPE，刷新失败；refreshToken 未旋转，会话固定风险 | 改 `Optional.ofNullable`；刷新时旋转 refreshToken 并失效旧值 |
| M-14 | 图形验证码配置（`code.type: math`, `length: 1`） | 1 位算术验证码答案空间极小，对抗爆破无效 | 提升为 4-6 位随机字符/多位算术，增强干扰 |

### 3.4 缓存与异常

| 编号 | 位置 | 问题 | 建议 |
|------|------|------|------|
| M-15 | [ConfigServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/ConfigServiceImpl.java)（`save/edit/delete`） | 改配置后从不调用 `refreshCache`，缓存长期返回旧值 | 写操作后调用 `refreshCache()` 或增量更新 hash |
| M-16 | [UserImportListener.java:88-157](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/listener/UserImportListener.java#L88-L157) | 逐行 `count` 查重（N+1）+ 逐行 save，无批处理、非 Spring 代理无事务，部分失败无法回滚；同批重复 username 查不到本批已插 | 预先批量查重；累积批量 save；持久化移入 Spring Service 方法加事务 |
| M-17 | [AgvServiceImpl.java:45-53](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/AgvServiceImpl.java#L45-L53) | `JSONObject.parse(result)` 无异常保护，非 JSON 响应抛异常；msg 为 null 时拼出 "AGV系统null" | try/catch 包裹解析；msg 做 null 兜底 |
| M-18 | 递归树构建 [MenuServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java)、[DeptServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DeptServiceImpl.java) | 树构建/`updateChildrenTreePath` 递归无环检测，数据成环时栈溢出/死循环写库 | 递归传入已访问 id 集合做环检测或限制最大深度 |
| M-19 | 多步删除 [RcsTaskServiceImpl](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java)/[CartServiceImpl](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cart/service/impl/CartServiceImpl.java) | 逗号分割 `Long.parseLong` 未捕获 `NumberFormatException`（返回 500）；`deleteCart` 未校验车上是否仍有在车物品，产生孤儿 cart_item | 统一 ID 解析并校验；删除前校验/级联；解析异常转 BusinessException |

### 3.5 并发与锁

| 编号 | 位置 | 问题 | 建议 |
|------|------|------|------|
| M-20 | [RepeatSubmitAspect.java:49-56](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/aspect/RepeatSubmitAspect.java#L49-L56) | `tryLock` 后无 try/finally 释放锁，锁生命周期无显式管理，expire 非法值将长期锁死 | try/finally 中 `if (isHeldByCurrentThread) unlock()` |
| M-21 | [ValidatorUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/ValidatorUtils.java)、[IPUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/IPUtils.java) | Spring 单例注入静态字段（反模式）；`searcher` 静态可变字段无 volatile，初始化可见性隐患 | 用 SpringUtils 惰性获取或改普通 Bean；静态字段加 volatile |
| M-22 | RCS 下发幂等 [RcsTaskServiceImpl](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) | 本地无「下发中」中间态，重试连点两请求都读到 PENDING 各发一次远程（RCS 侧靠 reqCode 去重，但本地记两条生命周期） | 下发前 CAS `PENDING→ASSIGNING`，仅成功者发起远程 |

---

## 四、次要问题（🟡 Minor）

### 4.1 命名 / 常量 / 注释

- **魔法值未用枚举**：料车/仓库/system 模块大量硬编码状态码 `0/1/2/3/4`（如 [CartItemServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java)、[WmsAisleServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/service/impl/WmsAisleServiceImpl.java)、DictItemServiceImpl、UserServiceImpl），已定义 `CartStatusEnum`/`WmsStatusEnum`/`StatusEnum` 却未使用；`ApiRequestUtils` 中 `"POST"/"GET"/"code"/"0"/5000` 等字面量。建议统一用枚举/常量。
- **命名拼写**：[StringUtils.java:322](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/StringUtils.java#L322) `ishttp`→`isHttp`；`curreCharIsUpperCase`/`nexteCharIsUpperCase` 拼写错误；[CaptchaConfig.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/captcha/config/CaptchaConfig.java) `fontWight`→`fontWeight`；[LocalFileServiceImpl.java:37](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/LocalFileServiceImpl.java#L37) 多余分号 `;;`。
- **注释与实现不符**：[StringUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/StringUtils.java) `@BelongsPackage` 包路径错误、`@Description: TODO` 遗留；[OrikaUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/OrikaUtils.java) `@Description: TODO`；[RateLimitAspect.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/aspect/RateLimitAspect.java) 注释称抛 BusinessException 实抛 RateLimitException；[RedisCacheConfig.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/cache/RedisCacheConfig.java) `@ConditionalOnProperty` 注释误引用 xxl.job；AGV 系列类注释风格（`@BelongsProject`）与项目统一的 `@author/@since` 不一致；脚手架原作者 `Ray.Hao/haoxr/Theo` 遗留在业务类。
- **空文件**：[framework/mybatis/exception/DataPermissionException.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/mybatis/exception/DataPermissionException.java)（空且与 common 下同名类混淆）、[framework/job/handler/XxlJobSampleHandler.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/job/handler/XxlJobSampleHandler.java)（空）建议删除。

### 4.2 OOP / NPE / 集合

- **包装类拆箱 NPE**：[SecurityUserDetails.java:98-100](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/security/model/SecurityUserDetails.java#L98-L100) `isEnabled()` 直接返回 `Boolean`，反序列化为 null 时拆箱 NPE（影响全部鉴权）→ 改 `Boolean.TRUE.equals(this.enabled)`；CartItem/Cart `status == 2`/`== 4`、Wms `status == 0` 对 Integer 用 `==` 拆箱，null 时 NPE。
- **包装类比较应用 equals**：多处对 Integer 状态用 `==`/`!=`，应用 `equals` 或枚举 `.getValue().equals(...)`。
- **裸类型泛型**：[ExcelUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/ExcelUtils.java) `Class clazz`→`Class<T>`；[ApiEnum.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/ApiEnum.java) `Class paramsClass`→`Class<?>`。
- **NPE 风险**：[UserServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java) `getCurrentUserInfo` 中 `getOne` 可能返回 null 直接 `.getGender()`；`DeptServiceImpl` 返回 `Collections.EMPTY_LIST` 原始类型→改 `Collections.emptyList()`。
- **工具类未私有构造**：[SecurityUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/security/util/SecurityUtils.java)、StringUtils、ExcelUtils 缺私有构造。
- **序列化**：[Result.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/result/Result.java)、[PageResult.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/result/PageResult.java) 实现 Serializable 但缺 serialVersionUID。

### 4.3 异常 / 日志

- **printStackTrace / 吞异常**：[AliyunSmsService.java:73](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/integration/sms/service/impl/AliyunSmsService.java#L73) `e.printStackTrace()`；[MailService.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/integration/mail/service/MailService.java) catch 仅记 message 后吞掉；AliyunFileServiceImpl/LocalFileServiceImpl 抛 `new RuntimeException("...")` 丢弃 cause。
- **日志丢堆栈**：IPUtils/MailService/SecurityUserDetailsService 多处 `log.error("...", e.getMessage())` 丢失堆栈 → 应把 `e` 作为最后参数。
- **抛裸 RuntimeException**：[ApiEnum.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/enums/ApiEnum.java)、[ApiRequestUtils.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/ApiRequestUtils.java) 及料车模块大量 `throw new RuntimeException(...)`（RCS 模块用 BusinessException），前端无法区分业务/系统异常 → 统一 BusinessException。
- **异常信息透传前端**：[GlobalExceptionHandler.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java) 多处 `Result.failed(e.getMessage())` 可能泄露内部实现（表名/SQL/类路径）；参数校验异常用 `log.error` 应降为 `warn`。

### 4.4 其他

- **验证码失败不删缓存**：[CaptchaService.java:84-100](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/captcha/service/CaptchaService.java#L84-L100) 仅成功时 delete，失败可无限尝试（已有 `USER_VERIFICATION_CODE_ATTEMPT_LIMIT_EXCEEDED` 错误码未用）。
- **SSE 资源与并发**：[SseSessionRegistry.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/message/registry/SseSessionRegistry.java) 无单用户/全局连接数上限（DoS）；`SseEmitter.send` 非线程安全，heartbeat 定时线程与 broadcast 业务线程可能并发写同一 emitter → 每 emitter 加锁串行化 + 限制连接数。
- **字段遮蔽**：RcsTaskEntity/Cart/CartItem/WmsAisle/WmsPoint/ApiRequestLog 在子类重复声明 createTime/updateTime（BaseEntity 已有），`@EqualsAndHashCode(callSuper=true)` 与同名字段并存易生隐蔽 bug → 由 BaseEntity 统一列名映射。
- **匹配逻辑脆弱**：[RcsTaskServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java) `mapReportToStatus` 用 `contains("END")`/`contains("PUT")` 会误命中 SUSPEND/INPUT → 改精确枚举映射。
- **@SneakyThrows 滥用**：FileController/MinioFileServiceImpl/AliyunFileServiceImpl 掩盖受检异常。
- **@Valid/@Validated 混用**：[RcsTaskController.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/controller/RcsTaskController.java) 同类内混用；UserProfileForm 等缺 @Valid。
- **重复方法**：Cart/CartModel 的 `getFilterOptions` 与 `getFormOptions` 返回完全相同，Operation 描述与实际不符。
- **全表扫描去重**：Wms 各 `getFilterOptions/getFormOptions` 用 `list()` 拉全表 stream distinct，应下推 DB `SELECT DISTINCT`。

---

## 五、值得肯定的实现

- 错误码 `ResultCode` 严格遵循阿里 A/B/C 五位设计。
- 限流采用 Redis + Lua 滑动窗口保证原子性。
- `OperationLogExecutorConfig` 手动创建线程池并显式设置核心数/队列/拒绝策略（符合阿里禁用 Executors）。
- 密码使用 BCrypt；`OrikaUtils` 用静态内部类（IoDH）实现懒加载线程安全单例。
- RCS 远程调用置于事务外，`applyXxx` 用 `REQUIRES_NEW` + `@Lazy self` 规避自调用失效；取消失败抛 BusinessException 不改本地状态（符合硬约束）。
- 生命周期与主状态在同一事务内变更；payload 用 JacksonTypeHandler + autoResultMap 映射 jsonb。
- 各 Mapper XML 模糊查询统一用 `#{}` 占位（除 C-06 的 order 外无 `${}` 注入）。
- 日志异步落库、catch 异常避免影响主流程；`WmsPointServiceImpl` 用 `GREATEST(point_count-1,0)` 防负数。
- **DB 层面（依据 public.sql）**：核心业务唯一性已有约束兜底——`uk_item_product_code`/`uk_item_cart_sort`（料车明细）、`uk_aisle|location|point_plant_code`（库区/巷道/点位编码）、`uk_wms_rcs_task_task_code`（RCS 幂等）、`uk_user_username`/`uk_user_mobile`、`uk_role_code`/`uk_role_name`、`uk_dept_code`、关联表 `uk_roleid_menuid`/`uk_roleid_deptid`/`sys_user_role` 复合主键；符合项目工程约定的性能索引齐备（`idx_cart_item_cart_status`、`idx_item_cart_status_order`、`idx_point_aisle_id`、`idx_wms_rcs_task_status_time`、`idx_api_request_log_trace_id` 等）。

---

## 六、修复优先级建议

**第一批（安全，立即修复）**
C-01 JWT 密钥外置 → C-02 短信固定码 → C-03 MinIO 桶权限 → C-04 文件上传/删除 → C-05 Redis/DB 口令 → C-06 order 注入 → M-08 RCS 回调鉴权 → M-10 文件接口越权。

**第二批（业务一致性，尽快修复）**
C-08 字典删除顺序 → C-09 RCS 状态机 → C-13/C-15 point_count 触发器修复/注释校正 → C-12 菜单事务/缓存 → C-10 料车并发（容量竞态/数量漂移，唯一性已有 DB 兜底，补冲突重试）→ C-11 编码并发（补冲突重试）→ C-17/C-18 补 config_key/dict_code 唯一约束 → C-20 外键删除策略与应用层级联对齐 → M-01/M-02/M-03 事务补全 → M-04 updateById 显式字段 → M-15 配置缓存刷新 → M-16 用户导入批处理/事务。

**第三批（迭代优化）**
全部次要项：魔法值改枚举、命名/注释统一、包装类拆箱防护、大字段裁剪、递归环检测、异常类型统一、SSE 连接治理；C-16 料车主键/序列改 int8、C-19 补 dict_item 索引、C-21 业务表统一逻辑删除策略等 DB 层优化。

---

## 七、项目自定义《开发规范指南》符合性核查

> 依据：[规范.md](file:///d:/workcoding/wms20260712/develop/%E8%A7%84%E8%8C%83/%E8%A7%84%E8%8C%83.md)（项目《开发规范指南（纯规则版）》）逐条核对。图例：✅ 符合 / ⚠️ 部分符合 / ❌ 不符合 / — 无法静态判定。

### 7.1 逐条对照总表

| 章节 | 规则要点 | 结论 | 说明 / 定位 |
|------|----------|:----:|------|
| 一 命名与风格 | 包名全小写、类大驼峰、方法小驼峰、常量全大写、布尔 is/has/can、禁 flag | ⚠️ | 主体符合；但 [StringUtils.java:322](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/common/util/StringUtils.java#L322) `ishttp`、`curreCharIsUpperCase`/`nexteCharIsUpperCase`、CaptchaConfig `fontWight` 等拼写不规范（见 4.1） |
| 一 缩进/行宽 | 4 空格禁 Tab、行宽 ≤150 | — | 需 CI/格式化校验，静态未逐行核 |
| 一 IDE 配置 | 统一 `.editorconfig` / 格式化模板 | ❌ | **后端 `wms/` 无 `.editorconfig`**（仅 [wmsui/.editorconfig](file:///d:/workcoding/wms20260712/wmsui/.editorconfig)、[wmspda/.editorconfig](file:///d:/workcoding/wms20260712/wmspda/.editorconfig) 有）→ 后端未固化格式化模板（**N-01**） |
| 二 注释文档 | 类注释含功能/作者/日期，public 写 Javadoc | ⚠️ | 多数到位；但 `@Description: TODO` 遗留、`@BelongsPackage` 错误、脚手架作者 `Ray.Hao/haoxr` 未清理（见 4.1） |
| 二 废弃代码直接删 / TODO 标负责人+日期 | | ❌ | [AuthServiceImpl.java:82-83](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java#L82-L83) 注释掉随机码 + 裸 `TODO` 无负责人/日期；多处空文件未删（见 4.1） |
| 三 异常处理 | 业务异常继承 BusinessException+错误码 | ⚠️ | RCS 模块规范；但料车/common 大量 `throw new RuntimeException(...)`（M/4.3 已列） |
| 三 全局拦截统一 JSON | | ✅ | [GlobalExceptionHandler.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java) `@RestControllerAdvice` + `Result` |
| 三 禁吞异常 / 禁 printStackTrace | | ❌ | [AliyunSmsService.java:73](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/integration/sms/service/impl/AliyunSmsService.java#L73) `e.printStackTrace()`；C-02 短信异常被 catch 吞掉；MailService 吞异常 |
| 四 日志级别标准 | ERROR/WARN/INFO/DEBUG 分级，禁循环内 INFO | ⚠️ | 参数校验异常误用 `log.error`（应 warn，见 4.3） |
| 四 关键业务标识 | 日志含 userId/orderId 便于追踪 | ⚠️ | 部分 `log.error("...", e.getMessage())` 丢堆栈（见 4.3） |
| 四 敏感信息脱敏 | 手机号/密钥等脱敏 | ❌ | **全项目无脱敏工具/逻辑**（grep 无 mask/脱敏）；手机号在 SMS/用户查询中全号使用（**N-02**） |
| 四 SLF4J+Logback，禁 System.out | | ✅ | 有 [logback-spring.xml](file:///d:/workcoding/wms20260712/wms/src/main/resources/logback-spring.xml)，业务代码**无 `System.out`**（grep 确认） |
| 五 表名小写下划线单数、禁 tbl_ | | ✅ | `sys_user`/`wms_cart` 等均符合 |
| 五 必备字段 id/gmt_create/gmt_modified/deleted | | ⚠️ | **命名以项目自定标准为准（非违规）**：`sys_` 为第三方脚手架表，沿用 `create_time`/`update_time`/`is_deleted`，保持原样不动；`wms_` 为自研表，统一采用 `created_time`/`updated_time`/`created_by`/`updated_by` 作为项目标准，后续开发以此为准。规范文档应更新为该口径。**真正待整改的仅剩**：`wms_` 业务表缺逻辑删除列 `is_deleted`（见 C-21，仍有效）（**N-03**） |
| 五 时间用 timestamp、布尔用 smallint/boolean | | ✅ | 全表 `timestamp(6)`、状态/删除用 `int2` |
| 五 禁 SELECT * | | ✅ | Mapper XML **无 `SELECT *`**（grep 确认，显式列名） |
| 五 UPDATE/DELETE 带 WHERE | | ⚠️ | 主体符合，但 C-06 `${order}` 注入面仍存 |
| 五 连表 ≤3 张 | | ⚠️ | UserMapper 分页 4 表 join（`sys_user`+`sys_dept`+`sys_user_role`+`sys_role`）略超建议（见 [UserMapper.xml](file:///d:/workcoding/wms20260712/wms/src/main/resources/mapper/system/UserMapper.xml)） |
| 五 MyBatis 禁 ${} | | ❌ | C-06/C-14 存在 `${}`（`order` 注入、数据权限拼接） |
| 五 单表索引 ≤5 | | ⚠️ | `wms_cart_item` 索引 5 个 + 2 唯一约束（`idx_cart_item_cart_status`/`idx_cart_item_product_code`/`idx_item_batch_no`/`idx_item_cart_status_order`/`idx_item_loaded_at`），接近/略超上限，可评估合并（**N-04**） |
| 六 Redis Key `业务:标识` | | ✅ | `RedisConstants` 采用冒号分层命名 |
| 六 缓存 TTL / 一致性 | | ❌ | C-13 双口径；M-15 配置改后不刷缓存（违反"更新库后删缓存"） |
| 七 MinIO Bucket 小写连字符 | | — | 命名由配置决定，未见硬编码违规 |
| 七 文件 UUID 命名、路径分层 | | ⚠️ | 需核对上传实现命名策略 |
| 七 访问权限默认私有、禁永久公开 | | ❌ | **C-03 桶被设为公共读写**，直接违反"默认私有/禁永久公开链接"死线 |
| 七 上传前后双校验、限类型大小 | | ❌ | **C-04 无类型/大小/文件名校验** |
| 十 安全底线 SQL 注入 | | ❌ | C-06 `${}` 注入（违反死红线） |
| 十 敏感配置禁硬编码 | | ❌ | **C-01 JWT 密钥、C-05 DB/Redis 口令硬编码**（违反死红线，须环境变量/配置中心） |
| 十 用户数据脱敏 | | ❌ | 同 N-02 无脱敏 |
| 十 接口认证鉴权 | | ❌ | M-08 RCS 回调无鉴权、M-10 文件接口无 `@PreAuthorize`、M-12 日志/文档接口公开 |
| 十 文件上传禁用户文件名/白名单/防遍历 | | ❌ | **C-04 直接回显原始文件名、删除路径可穿越** |
| 九 测试 Service ≥70%、命名规范、集成测试 | | ❌ | **后端 `wms/src/test` 目录不存在**（Glob 无任何测试类）→ 零测试覆盖（**N-05**） |
| 八 Git 分支模型 / 约定式提交 / PR Review | | — | 需查 Git 历史与仓库设置，代码库静态不可判定 |
| 十一 质量门禁 / SonarQube / CI | | — | 未见 CI 配置文件，需运维确认 |

### 7.2 本次新增违规项（规范专属，编号 N-）

- **N-01（🟠）后端缺 `.editorconfig`/格式化模板**：违反「一、IDE 配置」。前端有而后端无，团队格式化无法统一 → 在 `wms/` 补 `.editorconfig` 并接入 spotless/checkstyle。
- **N-02（🔴）全项目无敏感信息脱敏**：违反「四、日志」「十、死红线」。手机号/密钥等在日志与返回体可能全量出现 → 提供脱敏工具（手机号 `138****1234`）并在日志/序列化层统一应用。
- **N-03（�）DB 审计字段命名：以项目自定标准为准，非违规**：明确项目约定——`sys_` 系第三方脚手架表，沿用其原生命名（`create_time`/`update_time`/`is_deleted`），**保持原样不改**；`wms_` 系自研表，统一采用 `created_time`/`updated_time`/`created_by`/`updated_by`，作为本项目及后续开发的**唯一标准**。规范.md 第五节的 `gmt_create`/`gmt_modified`/`deleted` 措辞应更新为此口径，两套命名按前缀分治不算冲突。**唯一仍需整改的**：`wms_` 业务表（`wms_cart`/`wms_cart_item`/`wms_cart_model`/`wms_aisle`/`wms_location`/`wms_point`/`wms_rcs_task` 等）缺逻辑删除列 `is_deleted`，建议按项目标准补齐并配 `@TableLogic`（见 C-21）。
- **N-04（🟡）`wms_cart_item` 索引数接近/超上限**：违反「五、单表索引 ≤5」→ 评估 `idx_cart_item_product_code`（已被 `uk_item_product_code` 覆盖，可删）等冗余索引。
- **N-05（🔴）后端零单元/集成测试**：违反「九、测试」「十一、CI 门禁」。`wms/src/test` 不存在 → 优先为 Service 核心逻辑（认证、字典删除、料车装取、RCS 状态机）补测试，目标覆盖率 ≥70%。

> 说明：规范中大量「死红线」违规项（SQL 注入、密钥硬编码、MinIO 公开、文件上传、无脱敏、接口鉴权）与本文档第二/三节的 C/M 级发现**高度重合**，此处仅做规范映射，具体整改见对应编号。规范专属的新增项为 N-01~N-05。

---

## 八、关键文件索引

| 模块 | 核心文件 |
|------|----------|
| 认证/安全 | [AuthServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java)、[SecurityConfig.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/auth/security/config/SecurityConfig.java)、[JwtTokenManager.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/security/token/JwtTokenManager.java)、[RedisTokenManager.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/security/token/RedisTokenManager.java) |
| RCS | [RcsTaskServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/RcsTaskServiceImpl.java)、[AgvServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/service/impl/AgvServiceImpl.java)、[RcsReporterController.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/rcs/controller/RcsReporterController.java) |
| 料车 | [CartItemServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java)、[CartServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/carriermanagementsystem/cart/service/impl/CartServiceImpl.java) |
| 仓库 | [WmsCodeGeneratorService.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/utils/WmsCodeGeneratorService.java)、[WmsCascadeServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/warehouse/service/impl/WmsCascadeServiceImpl.java) |
| 系统 | [UserServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/UserServiceImpl.java)、[RoleServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/RoleServiceImpl.java)、[MenuServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/MenuServiceImpl.java)、[DictServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/service/impl/DictServiceImpl.java)、[UserImportListener.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/system/listener/UserImportListener.java) |
| 框架 | [MyDataPermissionHandler.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/mybatis/interceptor/MyDataPermissionHandler.java)、[CorsConfig.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/config/CorsConfig.java)、[GlobalExceptionHandler.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java) |
| 文件 | [FileController.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/controller/FileController.java)、[MinioFileServiceImpl.java](file:///d:/workcoding/wms20260712/wms/src/main/java/com/wms/file/service/impl/MinioFileServiceImpl.java) |
| 配置 | [application-dev.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-dev.yml)、[application-prod.yml](file:///d:/workcoding/wms20260712/wms/src/main/resources/application-prod.yml) |
| 数据库 | [public.sql](file:///d:/workcoding/wms20260712/wms/sql/public.sql)（DDL：唯一约束/索引/外键/触发器函数） |

---

*本文档由静态代码审查 + 数据库 DDL（`public.sql`）核对生成，行号基于检测日期源码/脚本状态。并发/唯一性类结论已按 DB 实际约束校正：料车明细与库区编码唯一性有 DB 兜底（C-10/C-11 降级为主要），而 `point_count` 触发器损坏且未挂载为新发现严重项（C-13/C-15）。建议按第六节优先级分批整改并补充单元/集成测试。*
