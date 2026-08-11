# 认证模块（auth）

## 1. 模块概述

本模块是系统的**认证中心**，对外提供登录、登出、令牌刷新与图形验证码能力，并与框架层（`framework.security`、`framework.captcha`、`framework.integration.sms`）协作完成身份认证闭环。

核心业务能力：

- **账号密码登录**：`POST /api/v1/auth/login`，走 Spring Security `AuthenticationManager`（默认 `DaoAuthenticationProvider`）→ 校验通过后由 `TokenManager` 签发 JWT（含访问令牌 + 刷新令牌）；
- **图形验证码**：`GET /api/v1/auth/captcha` 获取，登录请求由 `CaptchaValidationFilter` 在认证前拦截校验（防暴力破解）；
- **令牌刷新**：`POST /api/v1/auth/refresh-token`，用刷新令牌换取新的访问令牌；
- **退出登录**：`DELETE /api/v1/auth/logout`，将访问令牌加入失效集合（黑名单），清除 Security 上下文；
- **短信验证码登录（已下线，C-02 整改）**：`loginBySms` / `sendSmsCode` 相关接口入口已在 Controller 层整体注释停用，Provider/Service 相关类保留但不可达（详见 [5.2 节](#52-短信验证码登录已下线c-02)）。

> 本模块不建任何表：用户身份数据来自 `sys_user`，验证码/令牌状态存于 Redis；安全规则（放行路径、Provider 装配、认证失败 JSON 响应）由本模块内的 `SecurityConfig` 与各类 Handler 负责，框架层仅提供通用组件。

---

## 2. 数据表设计（来源 public.sql）

**无独立建表**，复用 `sys_user`（用户身份校验）与 Redis（验证码、令牌状态）两个存储。

### 2.1 `sys_user` —— 系统用户表（[public.sql](../../wms/sql/public.sql)）

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（序列 `sys_user_id_seq`） | 主键 |
| username | varchar(64) | 用户名（登录账号） |
| nickname | varchar(64) | 昵称 |
| gender | int2 DEFAULT 1 | 性别（1-男 2-女 0-保密） |
| password | varchar(100) | 密码（由 `PasswordEncoder` 加密存储与比对） |
| dept_id | int8 | 部门 ID |
| avatar | varchar(255) | 用户头像 URL（文件模块上传产物） |
| mobile | varchar(20) | 联系方式（短信登录主键，见 4.2） |
| status | int2 DEFAULT 1 | 状态（1-正常 0-禁用，认证时校验） |
| email | varchar(128) | 用户邮箱 |
| create_time / create_by / update_time / update_by | timestamp / int8 | 审计字段 |
| is_deleted | int2 DEFAULT 0 | 逻辑删除标识（0-未删除 1-已删除） |

### 2.2 Redis 键（framework 常量 `RedisConstants`）

| 键 | 用途 | 说明 |
|------|------|------|
| `captcha:*` | 图形验证码缓存 | 由 `CaptchaService.generate()` 生成并写缓存，登录前由 `CaptchaValidationFilter` 校验后删除 |
| `sms:code:{mobile}` | 短信登录验证码缓存 | 5 分钟有效（`AuthServiceImpl.sendSmsCode`），因接口下线当前仅保留逻辑 |

---

## 3. 数据库交互

### 3.1 数据访问方式

认证模块**自身无独立建表**，数据库访问集中在"认证校验"链路：

- **读取 `sys_user`**：登录时由 `AuthenticationManager` → `DaoAuthenticationProvider` → `UserDetailsService.loadUserByUsername(username)` 查询用户（框架层实现 `SecurityUserDetailsService`），同时加载角色编码与权限标识集合；密码比对由 `PasswordEncoder` 完成，数据库不存明文；
- **`AuthServiceImpl` 本身不直接操作数据库**：登录/登出/刷新令牌均不写库，认证状态全部放在 **Redis**（见 2.2），即"认证状态无 DB 写入"。

### 3.2 Redis 交互（认证状态存储）

| 操作 | 键 | 说明 |
|------|----|------|
| 图形验证码 | `captcha:{id}` | `CaptchaService.generate()` 生成并写入，`CaptchaValidationFilter` 校验后删除（一次性） |
| 短信验证码 | `sms:code:{mobile}` | 5 分钟有效；发送失败仍写入（C-02 已知问题），接口已下线 |
| 令牌失效（登出/黑名单） | JWT jti / Redis token | `TokenManager.invalidateToken` 将令牌拉黑 |

### 3.3 事务边界

登录链路为**纯 DB 读 + Redis 写**，无数据库写事务；登出仅操作 Redis 与本地 `SecurityContext`，均无 `@Transactional`。

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/auth/...`；以下"引用的包"为该文件 import 中的主要部分。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [AuthController.java](../../wms/src/main/java/com/wms/auth/controller/AuthController.java) | 认证接口入口：`/api/v1/auth`（captcha / login / logout / refresh-token） | `com.wms.auth.service.AuthService`、`com.wms.auth.model.form.LoginForm`、`com.wms.common.result.Result`、`com.wms.common.annotation.Log/RateLimit`、`com.wms.common.enums.LogModuleEnum/ActionTypeEnum`、`com.wms.framework.captcha.model.CaptchaInfo`、`com.wms.framework.security.model.AuthenticationToken`、`io.swagger.v3.oas.annotations.*`、`jakarta.validation.Valid`、`org.springframework.web.bind.annotation.*` | `@Tag(name="01.认证中心")`；登录加 `@RateLimit` 限流与 `@Log(module=LOGIN)` 操作日志；**短信登录两个接口（login/sms、sms/code）已整体注释下线（C-02）**，恢复需先接入真实短信服务并改为服务端随机验证码 |
| [LoginForm.java](../../wms/src/main/java/com/wms/auth/model/form/LoginForm.java) | 登录请求体（form） | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank`、`lombok.Data` | 字段：username/password（`@NotBlank` 必填）+ captchaId/captchaCode（图形验证码，供过滤器读取） |

### 4.2 服务层（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [AuthService.java](../../wms/src/main/java/com/wms/auth/service/AuthService.java) | 认证服务接口 | `com.wms.framework.captcha.model.CaptchaInfo`、`com.wms.framework.security.model.AuthenticationToken` | 声明 login / loginBySms / sendSmsCode / logout / getCaptcha / refreshToken 六个方法 |
| [AuthServiceImpl.java](../../wms/src/main/java/com/wms/auth/service/impl/AuthServiceImpl.java) | 认证服务实现（核心） | `cn.hutool.core.util.StrUtil`、`com.wms.common.constant.RedisConstants`、`com.wms.framework.captcha.service.CaptchaService`、`com.wms.framework.security.token.TokenManager`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.auth.security.model.SmsAuthenticationToken`、`com.wms.framework.integration.sms.enums.SmsTypeEnum`、`com.wms.framework.integration.sms.service.SmsService`、`org.springframework.data.redis.core.RedisTemplate`、`org.springframework.security.authentication.AuthenticationManager/UsernamePasswordAuthenticationToken`、`org.springframework.security.core.context.SecurityContextHolder` | ①`login`：构造未认证的 `UsernamePasswordAuthenticationToken` → `authenticationManager.authenticate`（DaoAuthenticationProvider 经 UserDetailsService 取用户 + PasswordEncoder 比对）→ `TokenManager.generateToken` 签发 JWT → 认证对象写入 `SecurityContextHolder` 供登录日志 AOP 使用；②`logout`：取当前令牌 → `tokenManager.invalidateToken` 失效 → 清上下文；③`getCaptcha`：委托 `captchaService.generate()`；④`refreshToken`：委托 `tokenManager.refreshToken`；⑤短信登录方法保留但接口已下线 |

### 4.3 安全配置层（security）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SecurityConfig.java](../../wms/src/main/java/com/wms/auth/security/config/SecurityConfig.java) | Spring Security 全局配置（使用方配置，非框架默认） | `org.springframework.security.crypto.password.PasswordEncoder`、`org.springframework.data.redis.core.RedisTemplate`、`com.wms.framework.security.token.TokenManager`、`com.wms.framework.security.service.SecurityUserDetailsService`、`com.wms.framework.captcha.service.CaptchaService`、`com.wms.framework.security.config.SecurityProperties`、`com.wms.framework.security.filter.TokenAuthenticationFilter`、`com.wms.framework.security.port.UserAuthenticationPort`、`com.wms.auth.security.filter.CaptchaValidationFilter`、`com.wms.auth.security.handler.*`、`com.wms.auth.security.provider.SmsAuthenticationProvider`、`org.springframework.security.authentication.ProviderManager/DaoAuthenticationProvider`、`org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity`、`org.springframework.security.config.http.SessionCreationPolicy`、`cn.hutool.core.util.ArrayUtil` | `@EnableWebSecurity` + `@EnableMethodSecurity`；`SecurityFilterChain`：ignoreUrls 放行 + 其余 `authenticated()`；无状态会话（STATELESS）、关闭 CSRF/formLogin/httpBasic；`CaptchaValidationFilter` 插在 `UsernamePasswordAuthenticationFilter` 之前，`TokenAuthenticationFilter`（框架 Starter 过滤器）插在 `AuthorizationFilter` 之前；`WebSecurityCustomizer` 放行 unsecuredUrls；装配 `DaoAuthenticationProvider`（注入 userDetailsService + PasswordEncoder）与 `SmsAuthenticationProvider`，组合为 `ProviderManager` |
| [SmsAuthenticationProvider.java](../../wms/src/main/java/com/wms/auth/security/provider/SmsAuthenticationProvider.java) | 短信验证码认证 Provider | `org.springframework.security.authentication.AuthenticationProvider/DisabledException`、`org.springframework.security.core.userdetails.UsernameNotFoundException`、`org.springframework.data.redis.core.RedisTemplate`、`com.wms.framework.security.port.UserAuthenticationPort`、`com.wms.framework.security.model.SecurityUser/SecurityUserDetails`、`com.wms.auth.security.exception.SmsCaptchaException`、`com.wms.auth.security.model.SmsAuthenticationToken`、`cn.hutool.core.util.StrUtil/ObjectUtil`、`com.wms.common.constant.RedisConstants` | 流程：按手机号查用户（`userAuthPort.getAuthInfoByMobile`）→ 校验 status=1 → 与 Redis 缓存验证码比对 → 成功后删除缓存 → 返回已认证的 `SmsAuthenticationToken`；`supports()` 仅接受 SmsAuthenticationToken；**当前不可达（接口已下线）** |
| [SmsAuthenticationToken.java](../../wms/src/main/java/com/wms/auth/security/model/SmsAuthenticationToken.java) | 短信认证令牌模型 | `org.springframework.security.authentication.AbstractAuthenticationToken`、`org.springframework.security.core.GrantedAuthority`、`org.springframework.security.core.authority.AuthorityUtils` | 未认证：principal=手机号、credentials=验证码；已认证：principal=SecurityUserDetails、credentials=null；提供静态工厂 `authenticated(...)` |
| [CaptchaValidationFilter.java](../../wms/src/main/java/com/wms/auth/security/filter/CaptchaValidationFilter.java) | 登录图形验证码校验过滤器 | `org.springframework.web.filter.OncePerRequestFilter`、`org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher`、`org.springframework.web.util.ContentCachingRequestWrapper`、`com.wms.framework.captcha.service.CaptchaService`、`com.wms.framework.captcha.exception.CaptchaException`、`com.wms.framework.web.util.ResponseWriter`、`com.wms.common.result.ResultCode`、`com.wms.common.constant.SecurityConstants`、`cn.hutool.json.JSONObject/JSONUtil`、`cn.hutool.core.util.StrUtil`、`org.springframework.util.StreamUtils` | 仅匹配 `POST SecurityConstants.LOGIN_PATH`；要求 JSON Content-Type；读取并缓存请求体解析 captchaId/captchaCode → `captchaService.validate`；校验通过后用 `RepeatableReadRequestWrapper` 包装（支持重复读 body）放行，失败直接写 JSON 错误响应 |
| [JsonAuthenticationEntryPoint.java](../../wms/src/main/java/com/wms/auth/security/handler/JsonAuthenticationEntryPoint.java) | 认证失败（401）JSON 处理器 | `org.springframework.security.web.AuthenticationEntryPoint`、`org.springframework.security.authentication.BadCredentialsException/InsufficientAuthenticationException`、`com.wms.framework.web.util.ResponseWriter`、`com.wms.common.result.ResultCode` | BadCredentials → `USER_PASSWORD_ERROR`；InsufficientAuthentication → `ACCESS_TOKEN_INVALID`；其余 → `USER_LOGIN_EXCEPTION`，统一返回 Result JSON |
| [JsonAccessDeniedHandler.java](../../wms/src/main/java/com/wms/auth/security/handler/JsonAccessDeniedHandler.java) | 无权限（403）JSON 处理器 | `org.springframework.security.web.access.AccessDeniedHandler`、`org.springframework.security.access.AccessDeniedException`、`com.wms.framework.web.util.ResponseWriter`、`com.wms.common.result.ResultCode` | 统一返回 `ACCESS_PERMISSION_EXCEPTION` |
| [SmsCaptchaException.java](../../wms/src/main/java/com/wms/auth/security/exception/SmsCaptchaException.java) | 短信验证码业务异常 | `org.springframework.security.core.AuthenticationException` | 继承 AuthenticationException，用于验证码为空/错误/过期场景 |
| [MobileNotBoundException.java](../../wms/src/main/java/com/wms/auth/security/exception/MobileNotBoundException.java) | 手机号未绑定异常 | `org.springframework.security.core.AuthenticationException` | 携带 openid/sessionKey（微信小程序登录未绑定手机号场景预留），当前无调用方 |

---

## 5. 核心实现逻辑

### 5.1 账号密码登录流程（login）

```
POST /api/v1/auth/login ─► CaptchaValidationFilter（图形验证码校验）
                            │ 校验通过（失败直接写 JSON 返回）
                            ▼
       AuthServiceImpl.login(username, password)
         ① new UsernamePasswordAuthenticationToken(未认证)
         ② authenticationManager.authenticate(token)
              └─ ProviderManager 委托 DaoAuthenticationProvider
                   ├─ retrieveUser：SecurityUserDetailsService.loadUserByUsername（查 sys_user）
                   ├─ additionalAuthenticationChecks：PasswordEncoder 比对密码
                   └─ 校验 status=1 正常
         ③ TokenManager.generateToken(authentication) ──► 签发 JWT（访问令牌 + 刷新令牌）
         ④ 认证对象写入 SecurityContextHolder（供 @Log 登录日志 AOP 取登录人）
         ⑤ 返回 AuthenticationToken 给前端
```

### 5.2 短信验证码登录（已下线，C-02）

当前实现链路为：`AuthController.loginBySms/sendSmsCode` → `AuthServiceImpl.loginBySms/sendSmsCode` → `SmsAuthenticationProvider.authenticate`（查 `sys_user.mobile` → 比对 Redis 验证码 → 签发 JWT）。

**整改状态（重要）**：
- `AuthController` 中 `POST /login/sms` 与 `POST /sms/code` 两个接口**已整体注释下线**（C-02）；
- 原因：`sendSmsCode` 未接入厂商短信服务，验证码为**固定测试值 "1234"**，且**发送失败仍会写入 Redis**，暴露接口将形成"任意手机号登录"后门；
- 启用前置条件：① 接入真实短信服务；② 验证码改为服务端随机生成，且**仅在发送成功后**写入缓存；
- 恢复方式：接入短信后取消 `AuthController` 相关注释即可，Service/Provider/Token 类均已保留。

### 5.3 令牌刷新与退出

- **refreshToken**：`POST /api/v1/auth/refresh-token?refreshToken=...` → `TokenManager.refreshToken(refreshToken)`，校验刷新令牌有效性后签发新的令牌对；
- **logout**：`DELETE /api/v1/auth/logout` → `SecurityUtils.getAccessToken()` 取当前访问令牌 → `tokenManager.invalidateToken(token)`（加入失效集合）→ `SecurityContextHolder.clearContext()`。

### 5.4 安全过滤链装配（SecurityConfig）

```
TokenAuthenticationFilter（框架 Starter，校验 JWT，抛异常交 ExceptionTranslationFilter）
        ▲ 后置
AuthorizationFilter（授权决策）
        ▲ 前置
CaptchaValidationFilter（本模块，仅校验登录路径的图形验证码，直接写 JSON）
        ▲
UsernamePasswordAuthenticationFilter（原登录处理位，本项目中表单登录已关闭）
```

- 放行规则来自 `SecurityProperties.ignoreUrls / unsecuredUrls`（配置文件）；
- 无状态（STATELESS）、CSRF 关闭，`@EnableMethodSecurity` 支持 `@PreAuthorize("@ss.hasPerm(...)")` 方法级权限（业务模块使用）。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| Spring Security | `AuthenticationManager` / `DaoAuthenticationProvider` 密码认证、`AuthenticationEntryPoint` / `AccessDeniedHandler` 统一异常响应、FilterChain 过滤链、方法级权限 |
| JWT（`TokenManager`，framework.security） | 登录/刷新签发令牌对、退出失效令牌（黑名单） |
| Redis（`RedisTemplate`） | 图形验证码、短信验证码缓存（`RedisConstants.Captcha`）与令牌失效集合 |
| `PasswordEncoder` | 密码加密存储与登录比对 |
| Hutool（StrUtil / JSONUtil） | 字符串处理、请求体 JSON 解析 |
| Knife4j / Swagger 注解 | 接口文档（`@Tag` / `@Operation` / `@Schema` / `@Parameter`） |
| `@RateLimit`（Redisson） | 登录接口限流防暴力破解 |
| `@Log` AOP | 登录/退出操作日志埋点（`LogModuleEnum.LOGIN`） |
