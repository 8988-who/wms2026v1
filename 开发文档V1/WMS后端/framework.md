# 框架基础设施模块（framework）

## 1. 模块概述

本模块是工程的**横切能力底座**，不承载具体业务，为所有业务模块（auth/system/rcs/warehouse/carriermanagementsystem/business 等）提供统一的基础设施：

- **安全（security）**：令牌双模式（JWT 无状态 / Redis 有状态）、`TokenAuthenticationFilter` 认证过滤器、`@ss.hasPerm` 权限校验、`SecurityUtils` 当前用户上下文；通过 `UserAuthenticationPort`/`PermissionPort` 两个**端口接口**解耦 system 模块，framework 不反向依赖任何业务模块。
- **Web（web）**：`GlobalExceptionHandler` 全局异常、`@Log` 操作日志切面、`@RateLimit` 接口限流切面、`@RepeatSubmit` 防重复提交切面（Redisson 锁）、IP 全局限流过滤器、CORS/Jackson/线程池配置、`ResponseWriter` 统一响应写入。
- **缓存（cache）**：`RedisConfig`（自定义 RedisTemplate + JsonMapper）、`RedisCacheConfig`（@Cacheable 缓存管理器）、`CaffeineConfig`（本地缓存）。
- **接口文档（apidoc）**：springdoc + Knife4j 的 OpenAPI 配置与扩展（全局 Authorization、tag 排序）。
- **定时（job）**：XXL-Job 执行器注册配置（`xxl.job.enabled` 开关）。
- **MyBatis（mybatis）**：数据权限插件（JSQLParser 改写 SQL）、审计字段自动填充、分页插件。
- **集成（integration）**：邮件（JavaMailSender）、短信（阿里云 SMS）。
- **验证码（captcha）**：Hutool EasyCaptcha 图形验证码（Redis 存储校验）。

```
业务模块（auth/system/rcs/...）
        │ 依赖
        ▼
┌────────────────────────── framework ──────────────────────────┐
│ security(令牌/认证/权限)  web(异常/日志/限流/防重/CORS/Jackson) │
│ cache(Redis/Caffeine)    apidoc(OpenAPI)   job(XXL-Job)       │
│ mybatis(数据权限/填充/分页) integration(邮件/短信)  captcha     │
└────────────────────────── common（被 framework 引用）──────────┘
```

> 注意：Spring Security 过滤器链的装配类 [SecurityConfig.java](../../wms/src/main/java/com/wms/auth/security/config/SecurityConfig.java) 位于 **auth 模块**（`com.wms.auth.security.config`），因为"放行路径、响应格式"因项目而异，由使用方装配；framework 只提供过滤器、TokenManager、端口接口等**构件**。

---

## 2. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/framework/...`；以下"引用的包"为该文件 import 中的主要部分。framework 共 **53 个 Java 文件**（其中 2 个为空占位文件）。

### 2.1 security —— 安全基础设施

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SecurityProperties.java](../../wms/src/main/java/com/wms/framework/security/config/SecurityProperties.java) | 安全配置属性：映射 `security.*` 配置 | `org.springframework.boot.context.properties.ConfigurationProperties`、`jakarta.validation.constraints.*`（@NotEmpty/@NotNull/@Pattern/@Min）、`lombok.Data` | `session.type` 限定 `jwt\|redis-token`；`accessTokenTimeToLive`（默认 3600s）/`refreshTokenTimeToLive`（默认 604800s），-1 永不过期；`ignoreUrls`（完全绕过安全过滤器）/`unsecuredUrls`（匿名 API，web.ignoring）；`jwt.secretKey`（HS256 需 ≥32 字符）；`redisToken.allowMultiLogin`（默认 true 多设备登录） |
| [PasswordEncoderConfig.java](../../wms/src/main/java/com/wms/framework/security/config/PasswordEncoderConfig.java) | 密码编码器 Bean | `org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder`、`org.springframework.security.crypto.password.PasswordEncoder`、`org.springframework.context.annotation.Bean/Configuration` | 注册 `BCryptPasswordEncoder`，供 DaoAuthenticationProvider 与登录校验使用 |
| [TokenInvalidException.java](../../wms/src/main/java/com/wms/framework/security/exception/TokenInvalidException.java) | 令牌无效异常（access/refresh 过期或无效） | `com.wms.common.result.ResultCode`、`lombok.Getter` | 携带 `ResultCode`（A0230/A0231）的运行时异常，由全局异常处理器映射 HTTP 401 |
| [TokenAuthenticationFilter.java](../../wms/src/main/java/com/wms/framework/security/filter/TokenAuthenticationFilter.java) | 令牌认证过滤器：解析 Token 并填充 SecurityContext | `org.springframework.web.filter.OncePerRequestFilter`、`com.wms.framework.security.token.TokenManager`、`com.wms.common.constant.SecurityConstants`（BEARER_TOKEN_PREFIX）、`org.springframework.security.core.context.SecurityContextHolder`、`org.springframework.security.authentication.InsufficientAuthenticationException`、`cn.hutool.core.util.StrUtil` | 从 `Authorization: Bearer xxx` 头解析 Token；仅负责"校验+解析+setAuthentication"，**无效抛 `AuthenticationException` 交给 ExceptionTranslationFilter**（由 auth 模块的 `JsonAuthenticationEntryPoint` 写 401 响应）；注册在 `AuthorizationFilter` 之前 |
| [AuthenticationToken.java](../../wms/src/main/java/com/wms/framework/security/model/AuthenticationToken.java) | 认证令牌响应对象 | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Builder/Data` | 字段：`tokenType`/`accessToken`/`refreshToken`/`expiresIn`（秒），登录/刷新接口返回结构 |
| [RoleDataScope.java](../../wms/src/main/java/com/wms/framework/security/model/RoleDataScope.java) | 角色数据权限信息 | `lombok.*`、`java.io.Serializable` | `roleCode`/`dataScope`（1-所有 2-部门及子部门 3-本部门 4-本人 5-自定义）/`customDeptIds`（仅 dataScope=5 有效）；静态工厂 `all/deptAndSub/dept/self/custom`；支持多角色数据权限并集存储 |
| [SecurityUser.java](../../wms/src/main/java/com/wms/framework/security/model/SecurityUser.java) | 安全模块用户数据 POJO（端口返回类型） | `lombok.Data`、`java.util.List/Set` | 纯 JDK 类型、可序列化，不依赖 system 模块：userId/username/nickname/deptId/password/status/roles/dataScopes |
| [SecurityUserDetails.java](../../wms/src/main/java/com/wms/framework/security/model/SecurityUserDetails.java) | Spring Security 认证主体 | `org.springframework.security.core.userdetails.UserDetails`、`org.springframework.security.core.authority.SimpleGrantedAuthority`、`com.wms.common.constant.SecurityConstants`（ROLE_PREFIX）、`cn.hutool.core.collection.CollectionUtil` | 实现 UserDetails；`roles` 存**不带 ROLE_ 前缀**的角色码，`getAuthorities()` 运行时补 `ROLE_` 前缀转 SimpleGrantedAuthority；`hasAllDataScope()` 判任意角色 dataScope=1；构造器由 SecurityUser 转换（status==1 → enabled） |
| [TokenManager.java](../../wms/src/main/java/com/wms/framework/security/token/TokenManager.java) | 令牌管理器接口 | `org.springframework.security.core.Authentication`、`com.wms.framework.security.model.AuthenticationToken` | `generateToken/parseToken/validateToken/validateRefreshToken/refreshToken`，`invalidateToken`/`invalidateUserSessions` 为 default 空实现；两种实现靠 `@ConditionalOnProperty` 二选一装配 |
| [JwtTokenManager.java](../../wms/src/main/java/com/wms/framework/security/token/JwtTokenManager.java) | JWT 无状态令牌管理器（`session.type=jwt` 时装配） | `cn.hutool.jwt.JWT/JWTPayload/JWTUtil`、`com.wms.common.constant.JwtClaimConstants/RedisConstants/SecurityConstants`、`com.wms.common.result.ResultCode`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.data.redis.core.RedisTemplate`、`org.apache.commons.lang3.StringUtils` | 双令牌：access + refresh（refresh 带 `tokenType=true` claim）；claims 存 userId/deptId/dataScopes（RoleDataScope 列表）/roles/tokenVersion/jti；校验三重：① HS256 签名+过期 `jwt.setKey(secretKey).validate(0)` ② `tokenVersion` 与 Redis 中 `auth:user:token_version:{userId}` 比对（小于则失效，实现按用户下线）③ jti 黑名单 `auth:token:blacklist:{jti}`（登出时写入，TTL=剩余有效期）；`invalidateUserSessions` 用 `INCR` 版本号使该用户全部历史令牌失效 |
| [RedisTokenManager.java](../../wms/src/main/java/com/wms/framework/security/token/RedisTokenManager.java) | Redis 有状态令牌管理器（`session.type=redis-token` 时装配） | `cn.hutool.core.util.IdUtil`（fastSimpleUUID）、`com.wms.common.constant.RedisConstants/SecurityConstants`、`tools.jackson.databind.json.JsonMapper`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.data.redis.core.RedisTemplate` | 双 UUID 令牌；Redis 直接存 `SecurityUserDetails` 会话快照（password 置 null）：`auth:token:access:{token}`/`auth:token:refresh:{token}`/`auth:user:access:{userId}`/`auth:user:refresh:{userId}`；`validateToken` = key 存在性判断；`refreshToken` 删除旧 access 后签发新 access；`allowMultiLogin=false` 时新登录删除旧 access（单设备）；TTL=-1 不设过期 |
| [SecurityUserDetailsService.java](../../wms/src/main/java/com/wms/framework/security/service/SecurityUserDetailsService.java) | 认证用户加载服务 | `org.springframework.security.core.userdetails.UserDetailsService/UsernameNotFoundException`、`com.wms.framework.security.port.UserAuthenticationPort` | `loadUserByUsername` 经端口 `getAuthInfoByUsername` 查用户 → `new SecurityUserDetails(securityUser)`；不直接依赖 system 模块 |
| [PermissionService.java](../../wms/src/main/java/com/wms/framework/security/service/PermissionService.java) | 权限校验组件（SpEL bean `ss`） | `@Component("ss")`、`com.wms.framework.security.port.PermissionPort`、`com.wms.framework.security.util.SecurityUtils`、`org.springframework.util.PatternMatchUtils`、`cn.hutool.core.util.StrUtil/collection.CollectionUtil` | 供 `@PreAuthorize("@ss.hasPerm('sys:user:create')")` 调用；ROOT 直接放行；经 `PermissionPort.getRolePerms(roleCodes)` 查角色权限集合，`PatternMatchUtils.simpleMatch` 支持 `*` 通配；无权限记 warn 日志 |
| [UserAuthenticationPort.java](../../wms/src/main/java/com/wms/framework/security/port/UserAuthenticationPort.java) | 用户认证查询端口接口 | `com.wms.common.enums.SocialPlatformEnum`、`com.wms.framework.security.model.SecurityUser` | 声明 `getAuthInfoByUsername`/`getAuthInfoByMobile`/`getAuthInfoByOpenid(platform, openid)`；由 system 模块适配器实现 |
| [PermissionPort.java](../../wms/src/main/java/com/wms/framework/security/port/PermissionPort.java) | 权限查询端口接口 | `java.util.Set` | `getRolePerms(Set<String> roleCodes)` 返回权限标识集合；由 system 模块适配器实现 |
| [SecurityUtils.java](../../wms/src/main/java/com/wms/framework/security/util/SecurityUtils.java) | 当前登录用户工具 | `org.springframework.security.core.context.SecurityContextHolder`、`org.springframework.web.context.request.RequestContextHolder/ServletRequestAttributes`、`com.wms.common.constant.SystemConstants`（ROOT_ROLE_CODE）、`org.springframework.http.HttpHeaders` | `getUser()`（Optional<SecurityUserDetails>）/getUserId/getUsername/getDeptId/getDataScopes/getRoles；`isRoot()` 判断 ROOT 角色；`getAccessToken()` 从请求头取原始 Authorization |

### 2.2 web —— Web 横切能力

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [GlobalExceptionHandler.java](../../wms/src/main/java/com/wms/framework/web/advice/GlobalExceptionHandler.java) | 全局统一异常处理器 | `org.springframework.web.bind.annotation.RestControllerAdvice/ExceptionHandler/ResponseStatus`、`com.wms.common.exception.BusinessException`、`com.wms.common.result.Result/ResultCode`、`com.wms.framework.security.exception.TokenInvalidException`、`com.wms.framework.web.exception.RateLimitException`、`jakarta.validation.*`（BindException/ConstraintViolationException）、`org.springframework.security.access.AccessDeniedException`、`tools.jackson.core.JacksonException`、`org.springframework.jdbc.BadSqlGrammarException`、`java.sql.SQLSyntaxErrorException/SQLIntegrityConstraintViolationException` | 约 18 个 `@ExceptionHandler`，全部返回统一 `Result` 结构；参数校验类消息用 `；` 拼接；HTTP 状态：业务异常/参数异常 200、Token 401、限流 429、SQL/未知异常 500、NoHandler 404；`AccessDeniedException`/`AuthenticationException` **重新抛出**交由 Spring Security 处理器；SQL 错误码 C03xx；`convertMessage` 正则抽取 Jackson 反序列化失败字段并提示"字段类型错误" |
| [LogAspect.java](../../wms/src/main/java/com/wms/framework/web/aspect/LogAspect.java) | 操作日志切面（`@Log` 异步写 sys_log） | `org.aspectj.lang.annotation.Aspect/Around/Pointcut`、`com.wms.common.annotation.Log`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.util.IPUtils`、`com.wms.system.model.entity.SysLog`、`com.wms.system.service.LogService`、`cn.hutool.http.useragent.UserAgentUtil`、`org.springframework.beans.factory.annotation.Qualifier`（operationLogExecutor）、`java.util.concurrent.Executor` | `@Around("@annotation(logAnnotation)")`；`finally` 中组装 SysLog（module/actionType/title/content/operatorId/operatorName/requestUri/method/ip/省市区(ip2region)/device/os/browser/status(失败=0)/errorMsg/executionTime）；经 `operationLogExecutor` 异步 `logService.save`，失败仅记日志不影响主流程 |
| [RateLimitAspect.java](../../wms/src/main/java/com/wms/framework/web/aspect/RateLimitAspect.java) | 接口级限流切面（`@RateLimit` Redis 滑动窗口） | `org.aspectj.lang.annotation.Aspect/Around`、`com.wms.common.annotation.RateLimit`、`com.wms.framework.web.ratelimit.SlidingWindowScript`、`com.wms.framework.web.config.RateLimitProperties`、`com.wms.framework.web.exception.RateLimitException`、`com.wms.common.constant.RedisConstants/SecurityConstants`、`cn.hutool.crypto.digest.DigestUtil`、`org.springframework.data.redis.core.RedisTemplate` | key=`rate_limit:{prefix}:{user}:{uri}`，user=Token 的 SHA-256 或 IP；limit/window 注解优先、否则取全局默认（5 次/60s）；每次响应写 `X-RateLimit-Limit/Remaining/Reset` 头；超限抛 `RateLimitException(A0502)` 由全局处理器返回 429 |
| [RepeatSubmitAspect.java](../../wms/src/main/java/com/wms/framework/web/aspect/RepeatSubmitAspect.java) | 防重复提交切面（`@RepeatSubmit` Redisson 锁） | `org.aspectj.lang.annotation.Aspect/Around/Pointcut`、`com.wms.common.annotation.RepeatSubmit`、`org.redisson.api.RLock/RedissonClient`、`cn.hutool.crypto.digest.DigestUtil`、`cn.hutool.json.JSONUtil`、`com.wms.common.exception.BusinessException`、`com.wms.common.result.ResultCode` | key=`lock:resubmit:{user}:{method:URI}:{bodyHash}`（bodyHash=args 的 JSON SHA-256，**同一接口不同请求体不误判重复**）；`lock.tryLock(0, expire, SECONDS)`，抢锁失败抛 `DUPLICATE_SUBMISSION(A0506)`；**注意：锁未显式 unlock**，靠过期自动释放 |
| [CorsConfig.java](../../wms/src/main/java/com/wms/framework/web/config/CorsConfig.java) | CORS 跨域配置 | `org.springframework.web.filter.CorsFilter`、`org.springframework.web.cors.CorsConfiguration/UrlBasedCorsConfigurationSource`、`org.springframework.boot.web.servlet.FilterRegistrationBean`、`@ConfigurationProperties(prefix="cors")` | `allowedOrigins` 从配置注入**受信任域名白名单**（支持 `http://localhost:*` 等 pattern），**配置为空直接抛 IllegalStateException 防误配成全放行**；`allowCredentials(true)`（与白名单配套，禁止 `*`）；order=-101（早于 Security 的 -100） |
| [JacksonConfig.java](../../wms/src/main/java/com/wms/framework/web/config/JacksonConfig.java) | 全局 JSON 序列化配置 | `tools.jackson.databind.json.JsonMapper`（Jackson 3）、`tools.jackson.databind.ser.std.ToStringSerializer`、`tools.jackson.databind.cfg.DateTimeFeature`、`java.text.SimpleDateFormat` | 统一：时区 GMT+8、日期格式 `yyyy-MM-dd HH:mm:ss`、禁用 `WRITE_DATES_AS_TIMESTAMPS`；`Long/BigInteger` 序列化为 String（防前端精度丢失） |
| [OperationLogExecutorConfig.java](../../wms/src/main/java/com/wms/framework/web/config/OperationLogExecutorConfig.java) | 操作日志异步线程池 | `org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor`、`java.util.concurrent.ThreadPoolExecutor.CallerRunsPolicy` | Bean `operationLogExecutor`：core=1/max=2/queue=1000、线程名 `operation-log-`、优雅停机（wait 10s）、拒绝策略 CallerRuns |
| [RateLimitProperties.java](../../wms/src/main/java/com/wms/framework/web/config/RateLimitProperties.java) | 限流配置属性（`rate-limit.*`） | `org.springframework.boot.context.properties.ConfigurationProperties`、`lombok.Data` | `defaultLimit=5`、`defaultWindowSeconds=60`；嵌套 `ip`：`enabled=true`（生产建议开启）/`limit=1000`/`windowSeconds=60` |
| [IpRateLimitFilter.java](../../wms/src/main/java/com/wms/framework/web/filter/IpRateLimitFilter.java) | IP 全局限流过滤器 | `org.springframework.web.filter.OncePerRequestFilter`、`@Order(Ordered.HIGHEST_PRECEDENCE+5)`、`com.wms.framework.web.ratelimit.SlidingWindowScript`、`com.wms.framework.web.util.ResponseWriter`、`com.wms.common.constant.RedisConstants`、`com.wms.common.util.IPUtils`、`org.springframework.data.redis.core.RedisTemplate` | 所有请求进入 Controller 前按 IP 滑动窗口限流，key=`rate_limit:ip:{ip}`（默认 1000 次/60s）；写 `X-RateLimit-*` 头；超限时额外 `Retry-After` + `ResponseWriter` 直写 429（**在 Spring Security 链之前**，无需认证即可限流） |
| [RequestLogFilter.java](../../wms/src/main/java/com/wms/framework/web/filter/RequestLogFilter.java) | 请求日志过滤器 | `org.springframework.web.filter.CommonsRequestLoggingFilter`、`com.wms.common.util.IPUtils` | info 级别打印每个请求的 `ip` 与 `uri` |
| [SlidingWindowScript.java](../../wms/src/main/java/com/wms/framework/web/ratelimit/SlidingWindowScript.java) | Redis 滑动窗口 Lua 脚本（共享工具） | `org.springframework.data.redis.core.script.DefaultRedisScript`、`org.springframework.data.redis.core.RedisTemplate`、`java.util.UUID` | Lua 四步原子操作：`ZREMRANGEBYSCORE`（清窗口外旧请求）→`ZADD`（加当前请求）→`PEXPIRE`（key 过期=窗口+1s）→`ZCARD`（统计窗口内请求数）；一次网络往返避免竞态；**参数传 Long 而非 String**（避免 Jackson 序列化加引号导致 Lua `tonumber` 返回 nil） |
| [ResponseWriter.java](../../wms/src/main/java/com/wms/framework/web/util/ResponseWriter.java) | 统一 HTTP 响应写入器 | `cn.hutool.extra.servlet.JakartaServletUtil`、`cn.hutool.json.JSONUtil`、`com.wms.common.result.Result/ResultCode`、`org.springframework.http.HttpStatus/MediaType` | 供过滤器/Spring Security 处理器等**非 Controller 场景**写 JSON；`writeSuccess/writeError`；`mapHttpStatus` 映射：令牌类→401、权限→403、限流→429、其余→400 |
| [RateLimitException.java](../../wms/src/main/java/com/wms/framework/web/exception/RateLimitException.java) | 接口限流异常 | `com.wms.common.result.ResultCode`、`lombok.Getter` | 携带 ResultCode（A0502），由全局异常处理器映射 HTTP 429 |

### 2.3 cache —— 缓存

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [RedisConfig.java](../../wms/src/main/java/com/wms/framework/cache/RedisConfig.java) | RedisTemplate 序列化配置 + 统一 JsonMapper | `org.springframework.data.redis.core.RedisTemplate`、`org.springframework.data.redis.serializer.RedisSerializer/JacksonJsonRedisSerializer`、`tools.jackson.databind.json.JsonMapper`、`tools.jackson.databind.cfg.DateTimeFeature` | Key 用 String 序列化、Value 用自定义 JSON 序列化（**不写入类型信息**，避免集合序列化成带 @class 结构）；`JsonMapper` Bean 禁用日期时间戳；反序列化到具体类型时调用方显式 `convertValue` |
| [RedisCacheConfig.java](../../wms/src/main/java/com/wms/framework/cache/RedisCacheConfig.java) | @Cacheable 缓存管理器 | `org.springframework.cache.annotation.EnableCaching`、`org.springframework.data.redis.cache.RedisCacheManager/RedisCacheConfiguration/RedisCacheWriter`、`org.springframework.boot.cache.autoconfigure.CacheProperties`、`org.springframework.data.redis.serializer.RedisSerializer` | `@ConditionalOnProperty("spring.cache.enabled")` 时装配；Key String/Value JSON 序列化；按 `spring.cache.redis.*` 配置 TTL、空值缓存、key 前缀（默认 `name:` 单冒号，覆盖双冒号） |
| [CaffeineConfig.java](../../wms/src/main/java/com/wms/framework/cache/CaffeineConfig.java) | Caffeine 本地缓存 | `com.github.benmanes.caffeine.cache.Caffeine/CaffeineCacheManager`、`org.springframework.cache.CacheManager`、`@ConditionalOnProperty("spring.cache.type"="caffeine")` | 按 `spring.cache.caffeine.spec` 构建 CacheManager，与 RedisCacheManager 二选一 |

### 2.4 apidoc —— 接口文档

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [OpenApiConfig.java](../../wms/src/main/java/com/wms/framework/apidoc/OpenApiConfig.java) | OpenAPI 文档配置 | `io.swagger.v3.oas.models.OpenAPI/Info/Components/SecurityScheme/SecurityRequirement/Contact/License`、`org.springdoc.core.customizers.GlobalOpenApiCustomizer`、`com.wms.framework.security.config.SecurityProperties`、`org.springframework.util.AntPathMatcher` | 文档标题/版本（取 `project.version`）/联系方式；全局 APIKEY 鉴权（`Authorization` 头，Bearer JWT）；`globalOpenApiCustomizer` 遍历所有接口加 SecurityRequirement，命中 `ignoreUrls`（Ant 匹配）的路径不加 Authorization |
| [Knife4jOpenApiCustomizer.java](../../wms/src/main/java/com/wms/framework/apidoc/Knife4jOpenApiCustomizer.java) | Knife4j 增强扩展 | `com.github.xiaoymin.knife4j.*`（Knife4jProperties/Knife4jSetting/OpenApiExtensionResolver）、`org.springdoc.core.customizers.GlobalOpenApiCustomizer`、`org.springframework.context.annotation.ClassPathScanningCandidateComponentProvider`、`io.swagger.v3.oas.annotations.tags.Tag`、`org.springframework.web.bind.annotation.RestController` | `@Primary` 覆盖默认实现；customise 注入 Knife4j 扩展（setting/markdown）；`addOrderExtension` 扫描包下 `@ApiSupport` 的 RestController，给 OpenAPI tags 添加 `x-order` 实现分组排序 |

### 2.5 job —— 定时任务

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [XxlJobConfig.java](../../wms/src/main/java/com/wms/framework/job/XxlJobConfig.java) | XXL-Job 执行器配置 | `com.xxl.job.core.executor.impl.XxlJobSpringExecutor`、`org.springframework.boot.autoconfigure.condition.ConditionalOnProperty`、`org.springframework.beans.factory.annotation.Value` | `@ConditionalOnProperty("xxl.job.enabled")` 时装配 `XxlJobSpringExecutor`；从 `xxl.job.*` 注入 adminAddresses/accessToken/appname/address/ip/port/logPath/logRetentionDays |
| [XxlJobSampleHandler.java](../../wms/src/main/java/com/wms/framework/job/handler/XxlJobSampleHandler.java) | 定时任务示例占位 | 无（空文件） | 空占位文件，未实现 |

### 2.6 mybatis —— 数据访问增强

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [MybatisConfig.java](../../wms/src/main/java/com/wms/framework/mybatis/config/MybatisConfig.java) | MyBatis-Plus 插件装配 | `com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor`、`com.baomidou.mybatisplus.extension.plugins.inner.DataPermissionInterceptor/PaginationInnerInterceptor`、`com.baomidou.mybatisplus.annotation.DbType`、`com.baomidou.mybatisplus.core.config.GlobalConfig`、`org.springframework.transaction.annotation.EnableTransactionManagement` | `@EnableTransactionManagement` 开启事务；拦截器顺序：**数据权限**（DataPermissionInterceptor+MyDataPermissionHandler）→**分页**（PaginationInnerInterceptor，DbType.POSTGRE_SQL）；GlobalConfig 注册 `AutoFillMetaObjectHandler` |
| [MyDataPermissionHandler.java](../../wms/src/main/java/com/wms/framework/mybatis/interceptor/MyDataPermissionHandler.java) | 数据权限 SQL 改写控制器 | `com.baomidou.mybatisplus.extension.plugins.handler.DataPermissionHandler`、`net.sf.jsqlparser.*`（CCJSqlParserUtil/AndExpression/OrExpression/EqualsTo/Column/LongValue）、`com.wms.common.annotation.DataPermission`、`com.wms.common.enums.DataScopeEnum`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.framework.security.model.RoleDataScope` | 见 [3.2 数据权限 SQL 改写原理](#32-数据权限-sql-改写原理) |
| [AutoFillMetaObjectHandler.java](../../wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) | 审计字段自动填充 | `com.baomidou.mybatisplus.core.handlers.MetaObjectHandler`、`org.apache.ibatis.reflection.MetaObject`、`com.wms.framework.security.util.SecurityUtils`、`java.time.LocalDateTime` | insert：填 createTime/updateTime + 登录态下 createBy/updateBy；update：填 updateTime + updateBy；与实体 `@TableField(fill=INSERT/INSERT_UPDATE)` 配合，未登录（定时任务）时仅填时间 |
| [DataPermissionException.java](../../wms/src/main/java/com/wms/framework/mybatis/exception/DataPermissionException.java) | 数据权限异常（占位） | 无（空文件） | 空占位文件，未实现；数据权限失败异常见 common 模块同名类 |

### 2.7 integration —— 第三方集成

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [MailProperties.java](../../wms/src/main/java/com/wms/framework/integration/mail/config/MailProperties.java) | 邮件配置属性（`spring.mail.*`） | `org.springframework.boot.context.properties.ConfigurationProperties`、`lombok.Data` | host/port/username/password/from；嵌套 smtp.auth 与 starttls.enable |
| [MailConfig.java](../../wms/src/main/java/com/wms/framework/integration/mail/config/MailConfig.java) | 邮件发送器配置 | `org.springframework.mail.javamail.JavaMailSender/JavaMailSenderImpl`、`org.springframework.boot.context.properties.EnableConfigurationProperties`、`java.util.Properties` | 由 MailProperties 构建 `JavaMailSender` Bean，设置 `mail.smtp.auth` / `mail.smtp.starttls.enable` |
| [MailService.java](../../wms/src/main/java/com/wms/framework/integration/mail/service/MailService.java) | 邮件服务 | `org.springframework.mail.javamail.JavaMailSender/MimeMessageHelper`、`org.springframework.mail.SimpleMailMessage`、`jakarta.mail.internet.MimeMessage`、`org.springframework.core.io.FileSystemResource`、`jakarta.mail.MessagingException` | `sendMail`：SimpleMailMessage 纯文本；`sendMailWithAttachment`：MimeMessageHelper 支持 HTML + 附件；失败仅 log.error 不抛出 |
| [SmsService.java](../../wms/src/main/java/com/wms/framework/integration/sms/service/SmsService.java) | 短信服务接口 | `com.wms.framework.integration.sms.enums.SmsTypeEnum`、`java.util.Map` | `sendSms(mobile, smsType, templateParams)` 返回是否成功 |
| [AliyunSmsService.java](../../wms/src/main/java/com/wms/framework/integration/sms/service/impl/AliyunSmsService.java) | 阿里云短信实现 | `com.aliyuncs.*`（DefaultAcsClient/IAcsClient/CommonRequest/CommonResponse/DefaultProfile/MethodType/ClientException）、`cn.hutool.json.JSONUtil` | 按 smsType 取模板 Code（`sms.aliyun.templates.{type}`）；构建 CommonRequest：POST / `SendSms` / 版本 2017-05-25，Query 参数 RegionId/PhoneNumbers/SignName/TemplateCode/TemplateParam(JSON)；`response.getHttpResponse().isSuccess()` 判成功 |
| [AliyunSmsProperties.java](../../wms/src/main/java/com/wms/framework/integration/sms/config/AliyunSmsProperties.java) | 阿里云短信配置（`sms.aliyun.*`） | `org.springframework.boot.context.properties.ConfigurationProperties`、`lombok.Data`、`java.util.Map` | accessKeyId/accessKeySecret/domain/regionId/signName；`templates` Map（key 为 login/register 等用途，value 为模板 CODE） |
| [SmsTypeEnum.java](../../wms/src/main/java/com/wms/framework/integration/sms/enums/SmsTypeEnum.java) | 短信类型枚举 | `com.wms.common.base.IBaseEnum`、`lombok.Getter` | REGISTER("register")/LOGIN("login")/CHANGE_MOBILE("change-mobile")；value 对应 `sms.templates.*` 配置键 |

### 2.8 captcha —— 图形验证码

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [CaptchaProperties.java](../../wms/src/main/java/com/wms/framework/captcha/config/CaptchaProperties.java) | 验证码配置（`captcha.*`） | `org.springframework.boot.context.properties.ConfigurationProperties`、`lombok.Data` | type（circle/gif/line/shear）/width/height/interfereCount/textAlpha/expireSeconds；嵌套 code（type=math/random、length）与 font（name/weight/size） |
| [CaptchaConfig.java](../../wms/src/main/java/com/wms/framework/captcha/config/CaptchaConfig.java) | 验证码 Bean 装配 | `cn.hutool.captcha.generator.CodeGenerator/MathGenerator/RandomGenerator`、`java.awt.Font` | 按 `captcha.code.type` 装配 CodeGenerator（math→MathGenerator、random→RandomGenerator，其余抛异常）；`captchaFont` Font Bean |
| [CaptchaTypeEnum.java](../../wms/src/main/java/com/wms/framework/captcha/enums/CaptchaTypeEnum.java) | 验证码图片类型枚举 | 无 | CIRCLE / GIF / LINE / SHEAR |
| [CaptchaService.java](../../wms/src/main/java/com/wms/framework/captcha/service/CaptchaService.java) | 验证码生成与校验服务 | `cn.hutool.captcha.CaptchaUtil/AbstractCaptcha`、`cn.hutool.captcha.generator.CodeGenerator`、`cn.hutool.core.util.IdUtil`、`com.wms.common.constant.RedisConstants`、`com.wms.common.result.ResultCode`、`org.springframework.data.redis.core.RedisTemplate`、`java.awt.Font` | `generate`：按 type 创建圆点/GIF/线条/扭曲验证码 → setGenerator/setTextAlpha/setFont → code 以 `captcha:image:{captchaId}` 存 Redis（TTL=expireSeconds）→ 返回 captchaId + Base64；`validate`：校验后**一次性删除**，缺失→A0242 过期、不匹配→A0240 错误 |
| [CaptchaInfo.java](../../wms/src/main/java/com/wms/framework/captcha/model/CaptchaInfo.java) | 验证码响应对象 | `io.swagger.v3.oas.annotations.media.Schema`、`lombok.Builder/Data/NoArgsConstructor/AllArgsConstructor` | captchaId + captchaBase64 |
| [CaptchaException.java](../../wms/src/main/java/com/wms/framework/captcha/exception/CaptchaException.java) | 验证码异常 | `com.wms.common.result.ResultCode`、`lombok.Getter` | 携带 ResultCode（A0240/A0242）的运行时异常，由全局异常处理器统一返回 |

### 2.9 启动类

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsApplication.java](../../wms/src/main/java/com/wms/WmsApplication.java) | 应用启动类 | `org.springframework.boot.SpringApplication`、`org.springframework.boot.autoconfigure.SpringBootApplication`、`org.springframework.scheduling.annotation.EnableScheduling` | `@SpringBootApplication`（默认扫 `com.wms` 根包，覆盖 framework/common 及各业务模块）+ `@EnableScheduling` 开启 `@Scheduled` 定时任务 |

---

## 3. 数据库访问基础设施（横切能力）

framework **无业务表**，但为全工程提供数据库访问的横切增强（对应文件均在 [2.6 mybatis](#26-mybatis--数据访问增强) 小节）：

| 能力 | 实现 | 说明 |
|------|------|------|
| 分页 | MyBatis-Plus 分页插件 | 业务 SQL 无需写 LIMIT，`Page` 自动改写（`IPage` 入参触发） |
| 逻辑删除 | `logic-delete-field: isDeleted` | 作用于 `sys_*` 表（`is_deleted` 列）；`wms_*` 业务表无该列，走物理删除 |
| 审计字段填充 | [AutoFillMetaObjectHandler](../../wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) | 按实体 `@TableField(fill = FieldFill.INSERT / INSERT_UPDATE)` 自动填充 `created_time/updated_time/created_by/updated_by`（`wms_*` 表）；业务模块实体显式覆盖声明审计字段 |
| 数据权限 | [MyDataPermissionHandler](../../wms/src/main/java/com/wms/framework/mybatis/handler/MyDataPermissionHandler.java) | JSQLParser 改写 WHERE 注入行级权限（见 [4.2 数据权限 SQL 改写原理](#42-数据权限-sql-改写原理)）；未登录/定时任务不拦截 |
| JSON 字段映射 | JacksonTypeHandler | jsonb 类型读写（配合业务实体 `autoResultMap = true`，如 `RcsTask.payload`） |
| 自定义拦截器 | MybatisPlusInterceptor | 装配分页插件与数据权限 Handler 的容器 |

---

## 4. 核心实现逻辑

### 4.1 请求安全过滤链时序

```
HTTP 请求
  │
  ▼
CorsFilter（order=-101，CORS 白名单/凭证）
  │
  ▼
IpRateLimitFilter（order=HIGHEST_PRECEDENCE+5，IP 滑动窗口限流，超限 429 直写响应）
  │
  ▼
Spring Security FilterChain（SessionCreationPolicy.STATELESS）
  ├─ unsecuredUrls 已在 web.ignoring() 中放行（不进过滤器链，如 /doc.html、/v3/api-docs/**）
  ├─ ignoreUrls → permitAll（如 /api/v1/auth/login/**、/ws/**，仍会过 TokenAuthenticationFilter）
  ├─ CaptchaValidationFilter（auth 模块提供，UsernamePasswordAuthenticationFilter 之前，仅登录链路校验验证码）
  ├─ ExceptionTranslationFilter（捕获后续抛出的 AuthenticationException/AccessDeniedException）
  ├─ TokenAuthenticationFilter（AuthorizationFilter 之前，framework 提供）：
  │     解析 Authorization: Bearer xxx
  │     ├─ 无 Token → 直接放行（留给 AuthorizationFilter 判 401）
  │     └─ 有 Token → TokenManager.validateToken
  │           ├─ 无效 → clearContext + 抛 InsufficientAuthenticationException
  │           │         → ExceptionTranslationFilter → JsonAuthenticationEntryPoint → ResponseWriter 401(A0230)
  │           └─ 有效 → parseToken → SecurityContextHolder.setAuthentication(认证主体)
  └─ AuthorizationFilter：@PreAuthorize("@ss.hasPerm('xx:xx:xx')") 权限校验
         ├─ 通过 → 进入 Controller
         └─ 拒绝 → ExceptionTranslationFilter → JsonAccessDeniedHandler → 403(A0300)
  │
  ▼
DispatcherServlet → Controller 方法
  ├─ RateLimitAspect（@RateLimit 接口级限流，key=rate_limit:{prefix}:{user}:{uri}）
  ├─ RepeatSubmitAspect（@RepeatSubmit Redisson 锁防重）
  └─ LogAspect（@Log 成功后异步写 sys_log）
```

**关键点**：
- **放行分两层**：`ignoreUrls`（permitAll，仅绕过授权判定，Token 仍会被解析）与 `unsecuredUrls`（web.ignoring()，完全绕过安全过滤器，适合静态资源/文档）；
- **限流两级叠加**：先 IP 全局（过滤器层，未认证也能限），后接口级（AOP 层，可按用户维度细分）；
- **framework 只提供构件**，过滤器链装配、EntryPoint/AccessDeniedHandler 响应格式由 auth 模块 [SecurityConfig.java](../../wms/src/main/java/com/wms/auth/security/config/SecurityConfig.java) 决定。

### 4.2 数据权限 SQL 改写原理

由 `MybatisConfig` 注册的 `DataPermissionInterceptor` 在 **SQL 执行前** 调用 `MyDataPermissionHandler.getSqlSegment(where, mappedStatementId)`，对带 `@DataPermission` 注解的 Mapper 方法自动追加 WHERE 条件：

**前置判断（原样返回、不过滤）**：
1. `SecurityUtils.getUserId() == null`（未登录或定时任务）→ 不拦截（定时任务不受数据权限约束）；
2. `SecurityUtils.isRoot()`（ROOT 超级管理员）→ 不拦截；
3. 数据权限列表为空 → 不拦截；
4. 任一角色 `dataScope == 1`（所有数据）→ **并集策略**：跳过过滤；
5. 通过 `mappedStatementId` 反射定位 Mapper 方法，无 `@DataPermission` 注解 → 不拦截。

**过滤条件构建（多角色并集）**：`@DataPermission` 注解声明 `deptAlias/deptIdColumnName（默认 dept_id）/userAlias/userIdColumnName（默认 create_by）`。对每个角色的 `dataScope` 生成一个 Expression，再用 `OrExpression` 连接（**并集**），最后与原 WHERE 用 `AndExpression` 合并（带括号包裹）。单角色条件：

| dataScope | 生成的 SQL 条件 | 数据来源 |
|-----------|----------------|---------|
| 2 部门及子部门 | `{dept_id} IN (SELECT id FROM sys_dept WHERE id = {当前部门} OR FIND_IN_SET({当前部门}, tree_path))` | 当前用户 deptId + `sys_dept.tree_path` |
| 3 本部门 | `{dept_id} = {当前部门}` | 当前用户 deptId |
| 4 本人 | `{create_by} = {当前用户}` | 当前用户 userId |
| 5 自定义部门 | `{dept_id} IN ({customDeptIds})`，无自定义部门时返回 `1=0`（无权限） | 角色 `customDeptIds`（sys_role_dept） |
| 1 所有数据 | 无（跳过） | `sys_role.data_scope` |

**实现细节**：
- 条件用 **JSQLParser**（`CCJSqlParserUtil.parseCondExpression`）构建/解析，避免字符串拼接注入风险；部门及子部门/自定义部门条件为兼容不同 JSQLParser 版本的渲染差异，用**字符串拼 SQL 再解析**（注释中明确说明）；
- `sys_role.data_scope` 字段定义（来源 [public.sql](../../wms/sql/public.sql)）：`int2`，`1-所有数据 2-部门及子部门数据 3-本部门数据 4-本人数据 5-自定义部门数据`；自定义部门的部门 ID 存 `sys_role_dept(role_id, dept_id)`；
- 数据权限值在登录时随令牌下发（JWT claims `dataScopes` 或 Redis 会话快照），运行时由 `SecurityUtils.getDataScopes()` 读取。

### 4.3 全局异常处理结构

`GlobalExceptionHandler`（`@RestControllerAdvice`）是**唯一的异常出口**（Controller 层异常），所有 handler 返回统一 `Result{code,data,msg}`：

```
业务异常    BusinessException              → 200（code=A 段业务码，msg=自定义）
令牌异常    TokenInvalidException          → 401（A0230/A0231）
限流异常    RateLimitException             → 429（A0502）
参数校验    BindException / ConstraintViolationException
            / MethodArgumentNotValidException → 200（A0400/A0402，消息用 "；" 拼接所有字段）
            MissingServletRequestParameterException → 200（A0410）
            MethodArgumentTypeMismatchException / TypeMismatchException → 200（A0421）
请求体      HttpMessageNotReadableException → 200（正则抽取失败字段，提示"XX字段类型错误"）
JSON        JacksonException                → 200
路由        NoHandlerFoundException         → 404（C0113）
SQL         BadSqlGrammarException / SQLSyntaxErrorException
            / SQLIntegrityConstraintViolationException → 500（C03xx；"denied to user"→C0351）
其他        Exception（兜底）               → 500；AccessDeniedException/AuthenticationException 重抛给 Security
```

**设计要点**：
- 业务/参数类异常 HTTP 状态码固定 200（错误信息在 code/msg 中表达），令牌/限流/系统异常用真实 HTTP 状态；
- `AccessDeniedException`/`AuthenticationException` **不在此处理**，重新抛出交给 Spring Security 的 `JsonAccessDeniedHandler`/`JsonAuthenticationEntryPoint`（auth 模块）统一响应；
- `ResultCode` 全量错误码定义见 [common.md](./common.md) 第 3.2 节。

### 4.4 令牌双模式（JWT 无状态 vs Redis 有状态）

通过配置 `security.session.type`（`jwt` / `redis-token`）由 `@ConditionalOnProperty` 二选一装配 `TokenManager`，`TokenAuthenticationFilter` 只面向接口编程，**切换透明、两套并存**：

| 维度 | JwtTokenManager（无状态） | RedisTokenManager（有状态） |
|------|--------------------------|----------------------------|
| 令牌形态 | HS256 JWT（claims 自描述） | 随机 UUID（opaque token） |
| 会话存储 | 客户端持有，服务端不存；仅 Redis 辅助撤销/版本 | 服务端 Redis 存 `SecurityUserDetails` 快照（password=null） |
| 校验方式 | 签名+过期 → tokenVersion 比对 → jti 黑名单 | Redis key 是否存在 |
| 用户级下线 | `INCR auth:user:token_version:{userId}`，历史令牌版本落后即失效 | `invalidateUserSessions` 删除该用户全部 access/refresh key |
| 单令牌下线 | 登出时按 jti 写黑名单（TTL=剩余有效期） | 删除对应 access key |
| 单设备控制 | 不支持（无状态） | `allowMultiLogin=false` 时新登录删旧 access |
| 刷新策略 | refresh 校验后重签 access，refresh 复用 | refresh 换取新 access，同时删旧 access |
| 双令牌 TTL | access 默认 3600s / refresh 默认 604800s（-1 永不过期） | 同左（各自独立 TTL） |
| 适用场景 | 分布式无状态、降 Redis 压力 | 强一致会话、可强制下线 |

**共同点**：`AuthenticationToken{tokenType, accessToken, refreshToken, expiresIn}` 响应结构统一；登录流程均为 `AuthenticationManager` 认证成功后调用 `generateToken(authentication)`。

---

## 5. 技术栈

| 技术 | 用途 |
|------|------|
| Spring Security | 认证过滤器（TokenAuthenticationFilter）、`@PreAuthorize` 方法级权限、BCrypt 密码编码、Provider/过滤器链装配（auth 模块） |
| Hutool JWT（cn.hutool.jwt） | HS256 JWT 生成/解析/校验（JwtTokenManager） |
| Redis / Redisson | 令牌会话存储与撤销、滑动窗口限流（Lua）、防重复提交分布式锁、验证码存储、@Cacheable |
| Jackson 3（tools.jackson） | 全局 JSON 序列化（Long→String、GMT+8 日期）、Redis 序列化、反序列化失败提示 |
| MyBatis-Plus | 分页插件（POSTGRE_SQL）、DataPermissionInterceptor 数据权限、MetaObjectHandler 字段填充 |
| JSQLParser（net.sf.jsqlparser） | 数据权限 SQL 条件构建/改写 |
| springdoc + Knife4j | OpenAPI 3 文档、全局 Authorization、tag 排序扩展 |
| XXL-Job | 分布式任务调度执行器 |
| JavaMailSender / 阿里云 SMS SDK | 邮件发送 / 短信验证码发送 |
| Hutool EasyCaptcha（captcha 包） | 图形验证码生成（CIRCLE/GIF/LINE/SHEAR + math/random 文字） |
| ip2region（org.lionsoul.ip2region） | IP 归属地解析（操作日志省市区） |
| ThreadPoolTaskExecutor | 操作日志/接口日志异步落库（CallerRuns 兜底） |
