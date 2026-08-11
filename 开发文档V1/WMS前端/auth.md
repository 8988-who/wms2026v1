# 认证授权模块（auth）

## 1. 模块概述

认证授权模块负责系统身份认证与凭证管理的完整链路，包含以下能力：

- **登录**：用户名 + 密码 + 图形验证码登录，支持"记住我"（令牌持久化到 localStorage / sessionStorage 二选一）；
- **验证码**：登录/注册页按需向后端拉取图形验证码（Base64 图片）；
- **令牌管理**：双令牌（accessToken + refreshToken）存取、静默刷新（401 单飞刷新）、登出清除；
- **用户信息**：登录后拉取 `/api/v1/users/me` 获取用户资料、角色（roles）、权限码（perms）；
- **权限判断**：`hasPerm()` 工具函数按按钮权限码 / 角色判断，超管角色（ROOT）放行；
- **会话失效处理**：`redirectToLogin()` 统一兜底，清理全局状态并携带 `redirect` 参数跳回登录页；
- **SSE 令牌注入**：登出时通过 `resetAllState()` 清理所有 SSE 连接（见 message 模块）。

> 说明：注册（Register.vue）与重置密码（ResetPwd.vue）表单目前为"开发中"占位，仅前端表单与校验，提交动作调用 `ElMessage.warning("开发中 ...")`，未接入后端接口。

## 2. 页面与路由

| 路由路径 | 页面组件（链接） | 功能概述 |
| --- | --- | --- |
| `/login` | [login/index.vue](../../wmsui/src/views/login/index.vue) | 登录主页面：左侧品牌区（wms系统简介 + 安全可靠/高效稳定/灵活扩展特性），右侧登录表单（用户名、密码、验证码、记住我、忘记密码切换）；内置 `LoginPage` 与 `ResetPwd` 双表单切换（`transition` 切换，无独立路由）；`ThemeSwitch` 主题切换与 `LangSelect` 语言切换 |
| （子组件，非独立路由） | [login/components/Register.vue](../../wmsui/src/views/login/components/Register.vue) | 注册表单：用户名、密码、确认密码、验证码、同意协议勾选；提交目前仅 `ElMessage.warning("开发中 ...")`；未被 login/index.vue 引用（遗留组件） |
| （子组件，非独立路由） | [login/components/ResetPwd.vue](../../wmsui/src/views/login/components/ResetPwd.vue) | 重置密码表单：仅用户名输入；提交目前仅 `ElMessage.warning("开发中 ...")`；由登录页"忘记密码？"链接通过 `update:modelValue` 事件切换进入 |

路由守卫相关流程（[guards/permission.ts](../../wmsui/src/router/guards/permission.ts)）：
- 未登录访问白名单（`/login`）之外路由 → 跳 `/login?redirect=<当前路径>`；
- 已登录访问 `/login` → 重定向首页 `/`；
- 首次进入时若用户信息为空则调用 `userStore.getUserInfo()`，再生成动态路由。

## 3. 后端接口

### 3.1 AuthAPI（[api/auth/index.ts](../../wmsui/src/api/auth/index.ts)，Base URL `/api/v1/auth`）

| API 函数名 | HTTP 方法与路径 | 说明 |
| --- | --- | --- |
| `login(data: LoginRequest)` | POST `/api/v1/auth/login` | 登录；请求体为 username/password/captchaId/captchaCode，多租户场景才附带 tenantId；返回 `LoginResult`（accessToken/refreshToken/tokenType/expiresIn） |
| `switchTenant(tenantId: number)` | POST `/api/v1/auth/switch-tenant` | 切换租户，返回新的令牌对（多租户场景） |
| `refreshToken(refreshToken: string)` | POST `/api/v1/auth/refresh-token` | 刷新令牌；`params` 携带 refreshToken，请求头 `Authorization: "no-auth"`（请求拦截器约定：该值会被删除，跳过 token 注入） |
| `logout()` | DELETE `/api/v1/auth/logout` | 登出（后端使 refreshToken 失效） |
| `getCaptcha()` | GET `/api/v1/auth/captcha` | 获取图形验证码，返回 `CaptchaInfo{captchaId, captchaBase64}` |

### 3.2 用户信息（[api/system/user/index.ts](../../wmsui/src/api/system/user/index.ts)）

| API 函数名 | HTTP 方法与路径 | 说明 |
| --- | --- | --- |
| `UserAPI.getInfo()` | GET `/api/v1/users/me` | 获取当前登录用户信息（昵称、头像、roles、perms），由 userStore.getUserInfo() 调用 |

### 3.3 令牌自动注入与刷新（[utils/request.ts](../../wmsui/src/utils/request.ts)）

- **请求拦截器**：默认给每个请求注入 `Authorization: Bearer <accessToken>`；调用方显式设置 `"no-auth"` 则跳过；
- **响应拦截器**：`code === ACCESS_TOKEN_INVALID`（401 令牌过期）时先尝试 `userStore.refreshTokenOnce()` 静默刷新并用新令牌重放原请求（`WeakSet` 防止同一请求无限重试）；刷新失败或 `REFRESH_TOKEN_INVALID` 时走 `redirectToLogin()` 踢回登录页；`PERMISSION_DENIED`（403）时刷新权限码并提示。

## 4. 文件清单

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
| --- | --- | --- | --- |
| [views/login/index.vue](../../wmsui/src/views/login/index.vue) | 登录页 | `element-plus`（el-form/el-input/el-button/el-checkbox/el-tooltip/el-image/el-tag）、`@element-plus/icons-vue`（User/Lock/Loading/Refresh/Clock）、`vue-router`（useRoute/router）、`pinia`（useUserStore）、`@/utils/auth`（AuthStorage）、`@/api/auth`（AuthAPI）、`vue-i18n`（LangSelect 内部）、`@/settings`（appConfig）、`@/components/ThemeSwitch` | ①`onMounted` 拉验证码，点击验证码图可刷新；②`handleLoginSubmit`：el-form validate → userStore.login → 成功按 `route.query.redirect`（decodeURIComponent 后）跳转，失败自动刷新验证码；③CapsLock 检测提示；④"记住我"默认值取自 `AuthStorage.getRememberMe()`；⑤`component` ref 在 `login`/`resetPwd` 间切换表单（仅引入 ResetPwd） |
| [views/login/components/Register.vue](../../wmsui/src/views/login/components/Register.vue) | 注册表单（开发中） | `element-plus`（el-form/el-input/el-button/el-checkbox/el-link/el-tooltip/el-text）、`@element-plus/icons-vue`（User/Lock）、`vue-i18n`（useI18n）、`@/api/auth`（AuthAPI） | ①确认密码校验（与密码一致）；②验证码拉取复用 AuthAPI.getCaptcha；③`submit` 仅 `ElMessage.warning("开发中 ...")`，未接入后端；④通过 `emit("update:modelValue","login")` 返回登录 |
| [views/login/components/ResetPwd.vue](../../wmsui/src/views/login/components/ResetPwd.vue) | 重置密码表单（开发中） | `element-plus`（el-form/el-input/el-button/el-link/el-text）、`@element-plus/icons-vue`（User）、`vue-i18n`（useI18n） | ①仅校验用户名非空；②`submit` 仅 `ElMessage.warning("开发中 ...")`，未接入后端 |
| [api/auth/index.ts](../../wmsui/src/api/auth/index.ts) | 认证 API 封装 | `@/utils/request`（axios 实例）、`./types`（LoginRequest/LoginResult/CaptchaInfo） | 集中定义 5 个接口；login 按需拼接 tenantId；refreshToken 使用 `"no-auth"` 头约定跳过 token 注入 |
| [api/auth/types.ts](../../wmsui/src/api/auth/types.ts) | 认证类型定义 | 无（纯类型） | `LoginRequest`（含可选 captchaId/captchaCode/rememberMe/tenantId）、`LoginResult`（accessToken/refreshToken/tokenType/expiresIn）、`CaptchaInfo` |
| [stores/user.ts](../../wmsui/src/stores/user.ts) | 用户状态 Store | `pinia`（defineStore）、`@/api/auth`、`@/api/system/user`、`@/utils/auth`（AuthStorage）、`@/stores/permission`、`@/stores/dict`、`@/stores`（useTagsViewStore）、`@/composables`（cleanupSseServices） | ①`login()`：调 AuthAPI.login → 存双令牌（按 rememberMe 决定存储介质）；②`refreshTokenOnce()`：单飞刷新（共享同一次刷新请求，Promise 去重）；③`getUserInfo()`：拉 `/users/me` 并 `Object.assign` 到 userInfo；④`logout()`：调 AuthAPI.logout + resetAllState；⑤`resetAllState()`：重置用户状态 + 重置动态路由 + 清空字典缓存 + 关闭全部标签页 + `cleanupSseServices()` 清理 SSE 连接；⑥`isLoggedIn()`：判断 accessToken 是否存在；⑦导出 `useUserStoreHook`（组件外使用） |
| [utils/auth.ts](../../wmsui/src/utils/auth.ts) | 凭证存取与权限工具 | `./storage`（Storage）、`@/constants`（STORAGE_KEYS/ROLE_ROOT）、`@/stores/user`（useUserStoreHook）、`@/router` | ①`AuthStorage`：按 rememberMe 决定令牌读写 localStorage 还是 sessionStorage（`vea:auth:*` 键）；②`hasPerm(value, type)`：按钮权限（perms）与角色（roles）双模式，ROOT 角色放行；③`redirectToLogin()`：防抖单次执行，ElNotification 提示 → resetAllState → 携带 redirect 跳 `/login`，失败强制 `window.location.href` |
| [utils/storage.ts](../../wmsui/src/utils/storage.ts) | 存储工具类（辅助） | `@/constants`（APP_PREFIX/STORAGE_KEYS） | localStorage/sessionStorage 统一封装，自动 JSON 序列化；`clearByPrefix`/`clearAllProject` 批量清理 |
| [constants/index.ts](../../wmsui/src/constants/index.ts) | 常量（辅助） | 无 | `ROLE_ROOT = "ROOT"`；`STORAGE_KEYS` 统一键名（`vea:auth:access_token` 等） |
| [utils/request.ts](../../wmsui/src/utils/request.ts) | axios 实例与拦截器（辅助） | `axios`、`qs`、`@/enums/api`（ApiCodeEnum）、`@/stores/user`、`@/stores/permission`、`@/utils/auth` | baseURL=`VITE_APP_BASE_API`（dev `/dev-api`、prod `/prod-api`）；请求拦截注入 Bearer token；响应拦截按 code 分流：成功解包 data / 401 单飞刷新重放 / 403 刷新权限码 |
| [router/guards/permission.ts](../../wmsui/src/router/guards/permission.ts) | 路由守卫（辅助） | `vue-router`、`nprogress`、`@/stores`（useUserStore/usePermissionStore）、`@/stores/tenant` | 登录态判断、首次进入拉取用户信息并生成动态路由、404 检测、未登录跳转带 redirect |

## 5. 核心实现逻辑

### 5.1 登录流程

```
登录页 onMounted → getCaptcha()（GET /api/v1/auth/captcha，缓存 captchaId + Base64 图片）
        ↓
用户输入 → handleLoginSubmit：
  ① el-form validate()（用户名必填、密码≥6位、验证码必填）
  ② userStore.login(loginRequest)：
     - AuthAPI.login() → POST /api/v1/auth/login
     - 记录 rememberMe 状态
     - AuthStorage.setTokens(accessToken, refreshToken, rememberMe)
       （rememberMe=true 写入 localStorage，否则写入 sessionStorage）
  ③ 成功 → router.push(decodeURIComponent(redirect || "/"))
  ④ 失败 → 重新拉取验证码（防止验证码失效）
```

### 5.2 令牌刷新（单飞）

- 任意请求返回 `ACCESS_TOKEN_INVALID` 时，响应拦截器调用 `userStore.refreshTokenOnce()`；
- `refreshTokenOnce` 用模块级 `refreshPromise` 去重：并发多个 401 只发一次 `POST /api/v1/auth/refresh-token`；
- 刷新成功后用新 token 重放原请求（`retriedRequests` WeakSet 防止死循环）；
- 刷新失败或 `REFRESH_TOKEN_INVALID` → `redirectToLogin()`（清状态 → 跳登录页）。

### 5.3 登出 / 会话重置

```
logout() → AuthAPI.logout()（DELETE /api/v1/auth/logout）→ resetAllState()
resetAllState() 统一清理：
  ① resetUserState()：AuthStorage.clearAuth()（local + session 双清理）+ userInfo 置空
  ② usePermissionStoreHook().resetRouter()：移除动态路由
  ③ useDictStoreHook().clearDictCache()：清空字典缓存
  ④ useTagsViewStore().delAllViews()：关闭所有标签页
  ⑤ cleanupSseServices()：断开并清理 SSE 连接（EventSource 资源释放）
```

### 5.4 注册 / 重置密码（当前状态）

- 两个表单均已实现 UI 与前端校验（确认密码一致性、CapsLock 提示、验证码拉取），但 `submit` 仅弹出 `ElMessage.warning("开发中 ...")`；
- Register.vue 当前未被 login/index.vue 引用；ResetPwd.vue 由登录页"忘记密码？"切换进入（`component` 状态切换，非路由跳转）；
- 未定义对应的后端注册/重置密码接口调用。

## 6. 技术栈

- **框架**：Vue 3.5（`<script setup>` + `defineOptions`/`defineModel`）+ TypeScript
- **状态管理**：Pinia（组合式 Store：user/permission/dict/tagsView/tenant）
- **路由**：vue-router 4（`beforeEach` 权限守卫 + 动态路由）
- **UI**：Element Plus（el-form/el-input/el-button/el-checkbox/el-tooltip/el-image/el-tag/el-notification 等）+ `@element-plus/icons-vue`
- **HTTP**：axios（baseURL 取 `VITE_APP_BASE_API`，`/dev-api` / `/prod-api` 环境区分；请求/响应双拦截器）+ qs（数组参数序列化）
- **存储**：原生 localStorage / sessionStorage（Storage 工具类统一封装，键前缀 `vea:`）
- **国际化**：vue-i18n（登录页 LangSelect 语言切换，表单文案走 `t("login.xxx")`）
- **构建**：Vite（`@` 别名指向 `src`；`import.meta.env` 读取环境变量）
