# 前端工程基础设施（framework）

> 本文档描述 `d:\workcoding\wms20260712\wmsui` 工程的**非业务页面**基础设施：启动装配、请求封装、路由与权限守卫、状态管理、布局系统、公共组件与构建配置。业务页面（登录/系统管理/仓库/载具等）见对应模块文档。
> 源码均为实际读取，依赖列取自文件真实 `import`。

---

## 1. 模块概述

- **定位**：提供所有业务页面共用的工程能力，业务页面（`src/views`）只需"写页面 + 配 CURD 配置"，其余能力由基础设施接管。
- **能力清单**：
  - **启动装配**：`main.ts` 按固定顺序装配指令/国际化/路由/状态/图标/权限守卫/SSE。
  - **请求层**：`utils/request.ts` 统一 axios 实例，令牌注入、401 自动刷新重试、权限不足自动重建路由、blob 透传、错误提示。
  - **路由层**：`router` 常量路由 + 后端菜单驱动的动态路由 + 全局导航守卫（白名单/404/标题）。
  - **状态层**：Pinia 七个 store（user/permission/dict/settings/tags-view/tenant/app）。
  - **权限**：`directives` 提供 `v-hasPerm` 按钮级权限指令；`utils/auth.ts` 提供 `hasPerm` 函数与 `redirectToLogin`。
  - **布局层**：`layouts` 四种布局模式（Left/Top/Mix/Double）+ 9 个布局组件 + 3 个布局 composables。
  - **公共组件**：CURD 四件套（PageSearch/PageContent/PageModal/usePage）是所有列表页的通用模板；另有字典、上传、分页、图表等 20+ 业务无关组件。
  - **实时推送**：`composables/sse` 基于 fetch 自研 SSE 客户端，驱动字典缓存失效与在线人数显示。
  - **构建配置**：Vite 8（Rolldown+Oxc）、UnoCSS 原子化、SCSS 主题变量、环境变量代理与多租户开关。

---

## 2. 目录结构与职责

| 目录 | 职责 |
|------|------|
| `src/main.ts` | 应用入口，装配顺序见 §5.1 |
| `src/settings.ts` | 全局设置：应用信息（标题/版本/多租户开关）与默认偏好（主题/布局/尺寸/语言） |
| `src/utils` | 请求（request）/认证（auth）/存储（storage）/主题（theme）/校验（validate）/格式化（format）/下载（download）/租户（tenant） |
| `src/router` | 常量路由定义 + 权限守卫（动态路由、白名单、404） |
| `src/stores` | Pinia 状态：user/permission/dict/settings/tags-view/tenant/app |
| `src/directives` | 自定义指令：v-hasPerm / v-hasRole（`directives/index.ts` 仅注册 hasPerm） |
| `src/enums` | 枚举：api（响应码）/business（业务）/common（通用）/settings（设置） |
| `src/constants` | 常量：存储键名、ROOT 角色、平台租户 ID |
| `src/plugins` | vxe-table 全局配置、NProgress 进度条配置 |
| `src/composables` | 组合式函数：SSE 客户端/字典同步/在线人数、分页表格、表格多选 |
| `src/layouts` | 布局系统：4 种模式 + 9 个布局组件 + 3 个布局 composables |
| `src/components` | 公共组件：CURD 四件套、字典（DictSelect/DictTag）、上传（3 个）、分页、图表、富文本等 |
| `src/lang` | vue-i18n 国际化（zh-cn/en 语言包 + 路由标题翻译工具） |
| `src/api` | 后端接口封装（按业务模块分目录，`index.ts` 请求 + `types.ts` 类型） |
| `src/styles` | 全局 SCSS 样式与主题变量（variables.scss / element-plus 覆盖等） |

---

## 3. 环境与构建配置

### 3.1 vite.config.ts（[vite.config.ts](../../wmsui/vite.config.ts)）

| 配置点 | 说明 |
|--------|------|
| 别名 | `@` → `src`（`resolve(import.meta.dirname, "src")`） |
| SCSS 预置 | `additionalData: @use "@/styles/variables.scss" as *;`，所有 scss 自动注入布局变量 |
| 开发服务器 | host 0.0.0.0、端口取 `env.VITE_APP_PORT`、`open: true` |
| 代理 | `[env.VITE_APP_BASE_API]` → `env.VITE_APP_API_URL`，`rewrite` 剥离代理前缀（如 `/dev-api/api/v1/...` → `/api/v1/...`） |
| Mock | `VITE_MOCK_DEV_SERVER === "true"` 时挂载 `mockDevServerPlugin()`（vite-plugin-mock-dev-server） |
| AutoImport | `unplugin-auto-import`：自动导入 `vue`/`@vueuse/core`/`pinia`/`vue-router`/`vue-i18n` + `ElementPlusResolver({ importStyle: "sass" })`（ElMessage/ElMessageBox 等全局可用），`vueTemplate: true` |
| Components | `unplugin-vue-components`：ElementPlusResolver + 自定义组件目录 `src/components`、`src/**/components`（业务页 components 子目录也自动注册） |
| optimizeDeps | 预构建 vue/element-plus/axios/exceljs/echarts/vxe-table/qs/path-browserify/lodash-es 等，并列出 element-plus 全部组件的样式入口避免按需发现触发重载 |
| 构建 | Vite 8：Rolldown + Oxc minify（默认）、`cssMinify: "lightningcss"`、chunk 警告阈值 1200、产物按 js/assets/img/fonts/media 分目录、带 hash |
| define | `__APP_INFO__`（pkg.name/version + buildTimestamp）注入，供 `settings.ts` 读取 |

### 3.2 uno.config.ts（[uno.config.ts](../../wmsui/uno.config.ts)）

- presets：`presetUno()`、`presetAttributify()`（属性化写法）、`presetIcons()`（本地 SVG 图标集合 `svg`，通过 `FileSystemIconLoader` 读取 `src/assets/icons/*.svg`，缺 fill 自动补 `fill="currentColor"`，调用写法 `i-svg:图标名`）。
- safelist：启动时扫描 `src/assets/icons` 目录生成全部图标名，保证动态类名（如 `i-svg:{{icon}}`）不被 Tree-shake。
- shortcuts：`wh-full`、`flex-center`、`flex-x-center`、`flex-y-center`、`flex-x-start`、`flex-x-between`、`flex-x-end`。
- theme：`primary` 映射到 `var(--el-color-primary)`；断点扩展至 4xl（2560px）。
- transformers：`transformerDirectives`、`transformerVariantGroup`。

### 3.3 环境变量（.env.development / .env.production）

| 变量 | 开发环境 | 生产环境 | 作用 |
|------|---------|---------|------|
| `VITE_APP_PORT` | 3000 | — | 开发服务器端口 |
| `VITE_APP_TITLE` | wms系统 | wms系统 | 应用标题（settings.appConfig.title） |
| `VITE_APP_BASE_API` | `/dev-api` | `/prod-api` | axios baseURL 与代理前缀 |
| `VITE_APP_API_URL` | http://localhost:8000 | — | 代理目标（后端地址） |
| `VITE_MOCK_DEV_SERVER` | false | — | 是否启用本地 Mock |
| `VITE_APP_TENANT_ENABLED` | false | false | 多租户开关（决定是否加载租户上下文/显示租户切换） |

### 3.4 settings.ts（[settings.ts](../../wmsui/src/settings.ts)）

- `appConfig`：`name/version`（来自 `__APP_INFO__.pkg`）、`title`（`VITE_APP_TITLE`）、`tenantEnabled`（`VITE_APP_TENANT_ENABLED==="true"`）。
- `themeColorNames`：primary/success/warning/danger/info 五个主题色名。
- `themePalettePresets`：3 套预设配色（arco/ant-design/element-plus），`defaultThemePalette = themePalettePresets[0]`（ArcoD，主色 #165DFF）。
- `defaults`：所有用户偏好的默认值——主题跟随系统（`prefers-color-scheme`）、布局 LEFT、尺寸 DEFAULT、语言 zh-cn、页签 CARD 样式、显示 Logo/页签、水印关闭、切换动画 fade-slide 等。

---

## 4. 文件清单

### 4.1 启动装配

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [main.ts](../../wmsui/src/main.ts) | 应用入口，固定装配顺序 | `vue`(createApp)、`element-plus/theme-chalk/dark/css-vars.css`、`@element-plus/icons-vue`、`@/directives`(setupDirective)、`@/lang`(setupI18n)、`@/router`(setupRouter)、`@/stores`(setupStore)、`@/router/guards/permission`(setupPermissionGuard)、`@/composables`(setupSse) | 顺序：setupDirective→setupI18n→setupRouter→setupStore→`Object.entries(ElementPlusIcons)` 全局注册全部图标→setupPermissionGuard→setupSse→mount("#app")；样式导入顺序 dark 变量→index.scss→uno.css→animate.css |

### 4.2 请求与工具（src/utils）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [request.ts](../../wmsui/src/utils/request.ts) | axios 实例 + 拦截器 | `axios`、`qs`、`@/enums/api`(ApiCodeEnum)、`@/stores/user`(useUserStoreHook)、`@/stores/permission`(usePermissionStoreHook)、`@/utils/auth`(AuthStorage,redirectToLogin)、`@/api/common`(ApiResult) | ①baseURL=`VITE_APP_BASE_API`、timeout 50s、`paramsSerializer: qs.stringify(arrayFormat:"repeat")`（数组参数 `ids=1&ids=2`）；②请求拦截器注入 `Bearer token`，`Authorization==="no-auth"` 跳过（refresh-token 用）；③响应成功：blob/arraybuffer 直接透传，`code===ApiCodeEnum.SUCCESS` 返回 `data`，否则 ElMessage.error；④响应失败：无 response 提示网络失败；`A0230` 走 `refreshTokenOnce()` 单飞刷新后重试（WeakSet 防死循环），`A0231` 静默重定向登录，`A0301` 调 `refreshPermissions()` 重建动态路由，其余提示 msg |
| [auth.ts](../../wmsui/src/utils/auth.ts) | 令牌存取与登录状态 | `./storage`(Storage)、`@/constants`(STORAGE_KEYS,ROLE_ROOT)、`@/stores/user`(useUserStoreHook)、`@/router` | `AuthStorage`：rememberMe=true 存 localStorage，否则存 sessionStorage；`hasPerm(value,type)` 校验按钮/角色权限（ROOT 角色全通过）；`redirectToLogin` 带防重入标志，重置全部状态后跳 `/login?redirect=` |
| [storage.ts](../../wmsui/src/utils/storage.ts) | localStorage/sessionStorage 封装 | `@/constants`(APP_PREFIX,STORAGE_KEYS) | 静态类：set/get/remove/sessionSet/sessionGet/sessionRemove/clear/clearMultiple/clearByPrefix/clearAllProject/getAllProjectKeys；JSON 自动序列化，解析失败回退原始字符串 |
| [tenant.ts](../../wmsui/src/utils/tenant.ts) | 多租户判断 | `@/settings`(appConfig)、`@/constants`(PLATFORM_TENANT_ID) | `isTenantEnabled()` 读开关；`isPlatformTenantId()` 判断平台租户（不参与套餐/菜单配置） |
| [theme.ts](../../wmsui/src/utils/theme.ts) | 主题颜色计算与切换 | `@/enums`(ThemeMode)、`@/settings`(themeColorNames) | `generateThemeColors` 从主色生成 base/light-1..9/dark-2 全量 CSS 变量（Element Plus 运行时需要）；`applyTheme` 写 `--el-color-*` 到 `documentElement` 并派发 `--theme-update-trigger`；`toggleDarkMode` 切换 `html.dark` 类；`watchSystemTheme` 监听系统主题 |
| [validate.ts](../../wmsui/src/utils/validate.ts) | 校验工具 | `element-plus`(FormItemRule) | `isExternal`/`isValidURL`/`isEmail`/`isMobile` + `VALIDATORS`（required/email/mobile/url/number/integer 规则生成器） |
| [format.ts](../../wmsui/src/utils/format.ts) | 格式化工具 | 无 | `formatGrowthRate`（百分比去尾零）/`formatFileSize`/`formatNumber`（千分位）/`formatCurrency`（¥ 前缀） |
| [download.ts](../../wmsui/src/utils/download.ts) | 文件下载 | 无 | `downloadFile(response, customFileName?)`：解析 `Content-Disposition`（优先 `filename*=UTF-8''`，兜底 `filename=`），Blob + 临时 `<a>` 触发下载 |
| [index.ts](../../wmsui/src/utils/index.ts) | 工具统一出口 | 上述各文件 | `export { ... } from "./validate"` 等聚合导出 |

### 4.3 路由与守卫（src/router）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [router/index.ts](../../wmsui/src/router/index.ts) | 常量路由 + 路由实例 | `vue-router`(createRouter,createWebHashHistory,RouteRecordRaw)、`@/layouts/index.vue` | `createWebHashHistory()` 哈希路由；`constantRoutes`：`/redirect/:path(.*)`、`/login`、`/`（redirect `/dashboard`，子路由 dashboard[affix+keepAlive]/401/404/profile/`/detail/:id(\\d+)`）；`scrollBehavior` 滚动归零；导出 `setupRouter(app)` 与 `Layout` 懒加载 |
| [guards/permission.ts](../../wmsui/src/router/guards/permission.ts) | 全局导航守卫 | `vue-router`(RouteRecordRaw)、`@/plugins/nprogress`、`@/stores`(usePermissionStore,useUserStore)、`@/stores/tenant`(useTenantStoreHook)、`@/utils/tenant` | `whiteList=["/login"]`；beforeEach：未登录→白名单放行否则跳登录（带 redirect）；已登录访问 /login→首页；未生成动态路由→拉用户信息→`initTenantContext()`（启用多租户时 loadTenant，静默失败）→`generateRoutes()`→逐个 `router.addRoute`→`{...to, replace:true}` 重放导航；`to.matched.length===0`→404（从登录页来的回退首页）；支持 `meta.title`/query.title 动态标题；afterEach 收 NProgress |
| [router/index.ts](../../wmsui/src/router/index.ts)（返回） | 同 4.3 第一行 | — | — |

### 4.4 状态管理（src/stores）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.ts](../../wmsui/src/stores/index.ts) | store 装配入口 | `pinia`(createPinia) | `createPinia()` 单例；`setupStore(app)` 注册；`export *` 重导出全部 store 与 `store` |
| [user.ts](../../wmsui/src/stores/user.ts) | 用户状态（登录/信息/令牌刷新） | `@/api/auth`、`@/api/system/user`、`@/utils/auth`(AuthStorage)、`@/stores/permission`、`@/stores/dict`、`@/stores`(useTagsViewStore)、`@/composables`(cleanupSseServices) | `login`（存 token）、`getUserInfo`、`logout`、`refreshTokenOnce`（单飞：并发 401 共享一次 refresh 请求，`refreshPromise` 模式）、`doRefreshToken`（调 `/auth/refresh-token`）、`resetAllState`（清用户态+permission.resetRouter+dict 缓存+tags-view+SSE 连接）、`isLoggedIn`（有无 accessToken） |
| [permission.ts](../../wmsui/src/stores/permission.ts) | 动态路由构建 | `vue-router`(RouteRecordRaw)、`@/router`(constantRoutes,router)、`@/stores/user`、`@/utils`(isExternal)、`@/api/system/menu` | `generateRoutes`：`MenuAPI.getRoutes()` → `transformRoutes`（后端 RouteItem→RouteRecordRaw，顶层 `Layout` 组件换成懒加载 Layout，子级目录壳去掉组件）→ `filterRoutes`（剔除外链）→ 返回待 `addRoute` 的路由，全量存 `routes`；`resolveComponent` 用 `import.meta.glob("../views/**/*.vue")` 解析 `xxx.vue`/`xxx/index.vue`，未命中回退 404；`resetRouter` 移除动态路由（保留常量）；`reloadRoutes`/`refreshPermissions` 均带防并发标志；`mixLayoutSideMenus` 供 Mix/Double 布局 |
| [dict.ts](../../wmsui/src/stores/dict.ts) | 字典缓存 | `@/stores`(store)、`@/api/system/dict`、`@/constants`(STORAGE_KEYS) | `dictCache = useStorage(...)` 持久化到 localStorage；`requestQueue` 按 dictCode 防重复请求；`loadDictItems`/`getDictItems`/`removeDictItem`/`clearDictCache` |
| [settings.ts](../../wmsui/src/stores/settings.ts) | 界面设置（主题/布局/页签） | `@/enums`(SidebarColor,ThemeMode,LayoutMode,TagsViewStyle)、`@/utils/theme`(applyTheme,generateThemeColors,toggleDarkMode,toggleSidebarColor,watchSystemTheme,resolveThemeMode)、`@/constants`、`@/settings`(defaults,themePalettePresets) | 全部偏好用 `useStorage` 持久化；`theme` 变化 watch：AUTO 模式挂系统主题监听，`resolvedTheme` 驱动 `toggleDarkMode`+`applyTheme(generateThemeColors(...))`；`sidebarColorScheme` 切换 `sidebar-color-blue` 类；grayMode/colorWeak 滤镜与类；`applyThemePalette`/`updateThemeColor`（自定义色置为 `custom`）/`resetSettings` |
| [tags-view.ts](../../wmsui/src/stores/tags-view.ts) | 页签（visited/cached） | `vue-router`(useRouter,useRoute,LocationQuery)、`@/utils`(isExternal) | `visitedViews` 与 `cachedViews`（keepAlive 用）；`addView`/`delView`/`delOtherViews`/`delLeftViews`/`delRightViews`/`delAllViews`/`closeCurrentView`/`toLastView`（关闭当前后跳最后一个页签，Dashboard 用 `/redirect` 重载）；affix 固定页签始终保留 |
| [tenant.ts](../../wmsui/src/stores/tenant.ts) | 多租户状态 | `@/api/system/tenant`、`@/api/auth`、`@/utils/auth`(AuthStorage)、`@/constants`(STORAGE_KEYS) | `currentTenantId/currentTenant/tenantList`；`loadTenant`（守卫调用）：恢复本地→拉租户列表→校验本地租户失效则清除→优先后端当前租户→兜底第一个；`switchTenant`：先 `refreshTokenIfSupported`（调 `/auth/switch-tenant` 换 token）再切换并持久化；`clearTenant`/`setTenantList` |
| [app.ts](../../wmsui/src/stores/app.ts) | 应用级状态（设备/尺寸/语言/侧栏） | `element-plus/es/locale/lang/zh-cn`、`element-plus/es/locale/lang/en`、`@/enums`(DeviceEnum,SidebarStatus)、`@/constants`、`@/settings`(defaults) | `device`（desktop/mobile）、`size`、`language`、`sidebarStatus`（持久化）、`sidebar{opened,withoutAnimation}`、`secondarySidebar`（双栏布局第二列）、`activeTopMenuPath`、`contentFullscreen`、`locale` computed（按语言返回 EP 语言包）；toggle/close/openSidebar 等动作 |

### 4.5 指令与枚举、常量（src/directives / enums / constants）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [directives/index.ts](../../wmsui/src/directives/index.ts) | 指令装配 | `vue`(App)、`./permission`(hasPerm) | `app.directive("hasPerm", hasPerm)` 全局注册 |
| [directives/permission/index.ts](../../wmsui/src/directives/permission/index.ts) | 权限指令实现 | `vue`(Directive,DirectiveBinding)、`@/stores`(useUserStore)、`@/constants`(ROLE_ROOT) | `hasPerm`/`hasRole` 两个指令：mounted 校验 `binding.value`（string 或数组），ROOT 角色或 `*:*:*` 放行，无权限 `el.parentNode.removeChild(el)`；参数不合法抛错 |
| [enums/api.ts](../../wmsui/src/enums/api.ts) | API 响应码 | 无 | `ApiCodeEnum`：SUCCESS=`00000`、ACCESS_TOKEN_INVALID=`A0230`、REFRESH_TOKEN_INVALID=`A0231`、PERMISSION_DENIED=`A0301`、CHOOSE_TENANT=`A0250`（const enum，请求层判定依据） |
| [enums/business.ts](../../wmsui/src/enums/business.ts) | 业务枚举 | 无 | `MenuTypeEnum`(C目录/M菜单/E外链/B按钮)、`MenuScopeEnum`(1平台/2业务)、`UserGender` |
| [enums/common.ts](../../wmsui/src/enums/common.ts) | 通用枚举 | 无 | `DialogMode`(create/edit/view)、`CommonStatus`(0禁用/1启用)、`AuditStatus`(0待审/1通过/2拒绝) |
| [enums/settings.ts](../../wmsui/src/enums/settings.ts) | 设置枚举 | `@/api/common`(OptionItem) | `ThemeMode`(light/dark/auto)、`SidebarColor`(classic-blue/minimal-white)、`TagsViewStyle`(line/card)、`LayoutMode`(left/top/mix/double)、`SidebarStatus`、`ComponentSize`、`LanguageEnum`、`DeviceEnum`、`PageSwitchingAnimationEnum`+选项表 |
| [enums/index.ts](../../wmsui/src/enums/index.ts) | 枚举聚合 | 上述各文件 | `export *` 统一出口 |
| [constants/index.ts](../../wmsui/src/constants/index.ts) | 常量定义 | 无 | `APP_PREFIX="vea"`、`ROLE_ROOT="ROOT"`、`PLATFORM_TENANT_ID=0`、`STORAGE_KEYS`（认证/租户/系统/UI/应用 5 组存储键，命名 `vea:分类:键`） |

### 4.6 插件（src/plugins）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [vxe-table.ts](../../wmsui/src/plugins/vxe-table.ts) | vxe-table 全局配置 | `vxe-table`(VXETable) | `configureVxeTable()`：table（showHeader/overFlow tooltip/autoResize/border inner/rowConfig keyField `_VXE_ID`）、pager（pageSize 10、pageSizes [10,20,50]、完整 layouts 序列）、modal 默认属性；注：当前 CURD 列表实际用 el-table，vxe-table 配置保留备用 |
| [nprogress.ts](../../wmsui/src/plugins/nprogress.ts) | 路由进度条 | `nprogress`、`nprogress/nprogress.css` | `NProgress.configure({ easing, speed:500, showSpinner:false, trickleSpeed:200, minimum:0.3 })` 后默认导出 |

### 4.7 组合式函数（src/composables）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.ts](../../wmsui/src/composables/index.ts) | 组合式函数出口 | `./sse`、`./usePageTable`、`./useTableSelection` | `setupSse`/`cleanupSseServices` + `useSse/useDictSync/useOnlineCount` + `useTableSelection`/`usePageTable` |
| [usePageTable.ts](../../wmsui/src/composables/usePageTable.ts) | 分页列表通用状态 | `vue`(reactive,ref)、`@/api/common`(BaseQueryParams,PageResult) | `loading/list/total/params`；`fetchData`（请求回填）、`handleQuery`（回第一页）、`handleResetQuery`（onBeforeReset→resetParams→fetch）、`resetParams`（Object.assign 保持引用） |
| [useTableSelection.ts](../../wmsui/src/composables/useTableSelection.ts) | 表格多选状态 | `vue`(computed,ref) | `selectedIds/selectedCount/hasSelection`、`handleSelectionChange`（flatMap 取 id）、`isSelected`、`clearSelection`（仅清数组，UI 需自行 clearSelection） |
| [sse/useSse.ts](../../wmsui/src/composables/sse/useSse.ts) | 自研 SSE 客户端（单例） | `@/utils/auth`(AuthStorage) | `fetch + AbortController + ReadableStream` 手动解析 `event:/data:` 行，按事件分发（Map<event,Set<handler>>）；连接超时 10s；指数退避重连（5s 起倍增至上限 2min，最多 10 次）；主动 disconnect 不重连；`SseConnectionState` 三态；默认地址 `${VITE_APP_BASE_API}/api/v1/sse/connect`，带 Bearer token |
| [sse/useDictSync.ts](../../wmsui/src/composables/sse/useDictSync.ts) | 字典实时同步（单例） | `@/stores/dict`(useDictStoreHook)、`./useSse` | 订阅 `dict` 事件：收到字典变更消息后 `removeDictItem(dictCode)` 并回调注册的 `onDictChange` 监听；`initialize/cleanup` 与 SSE 生命周期绑定 |
| [sse/useOnlineCount.ts](../../wmsui/src/composables/sse/useOnlineCount.ts) | 在线人数（单例） | `vue`(onMounted,getCurrentInstance)、`./useSse` | 订阅 `online-count` 事件更新 `onlineUserCount/lastUpdateTime`（readonly 暴露）；autoInit 时组件 mounted 触发 connect |
| [sse/index.ts](../../wmsui/src/composables/sse/index.ts) | SSE 服务装配 | `./useDictSync`、`./useOnlineCount`、`./useSse` | `setupSse()`（main.ts 调用）：初始化字典同步 + 在线人数；`cleanupSseServices()`：清理全部并断开（登出时用） |

### 4.8 布局系统（src/layouts）

#### 4.8.1 入口与模式

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/layouts/index.vue) | 布局根组件 | `vue-router`(useRoute)、`./composables/useLayout`、`./composables/useLayoutDevice`、`@/enums/settings`(LayoutMode)、`./modes/*`、`./components/LayoutSettings.vue` | 按 `route.meta.layout` 覆盖或全局 `settingsStore.layout` 动态切换 Left/Top/Mix/Double 四种模式组件；始终渲染 `LayoutSettings` 抽屉（设置面板）；挂载 `useLayoutDevice()` 监听窗口 |
| [BaseLayout.vue](../../wmsui/src/layouts/BaseLayout.vue) | 布局容器骨架 | `./composables/useLayout` | 提供 `layout-root` 根类 + 移动端展开侧栏时的遮罩层（`showOverlay` prop，Mix 布局传 false）；`layoutClass` 由 useLayout 计算（is-sidebar-collapsed/open/is-mobile/layout--x） |
| [modes/LeftLayout.vue](../../wmsui/src/layouts/modes/LeftLayout.vue) | 左侧菜单布局 | `./composables/useLayout`、`@/stores`(useAppStore)、`BaseLayout`、`LayoutLogo/LayoutNavbar/LayoutTagsView/LayoutMain/LayoutSidebar` | 左侧固定侧栏（Logo+`LayoutSidebar` 垂直菜单）+ 右侧 Navbar/TagsView/Main；`contentFullscreen` 时隐藏侧栏与 Navbar；SCSS 使用 `@/styles/mixins` 的 `$sidebar-width` 等变量 |
| [modes/TopLayout.vue](../../wmsui/src/layouts/modes/TopLayout.vue) | 顶部菜单布局 | `@vueuse/core`(useWindowSize)、`useLayout`、`@/stores`(useAppStore,usePermissionStore)、`LayoutSidebar`(menu-mode="horizontal")、`LayoutToolbar/LayoutTagsView/LayoutMain` | 顶部 sticky 头部：Logo + 水平 `LayoutSidebar` 菜单 + `LayoutToolbar`；`topMenuItems` 取 permissionStore.routes 过滤 hidden |
| [modes/MixLayout.vue](../../wmsui/src/layouts/modes/MixLayout.vue) | 混合布局（顶+侧） | `@vueuse/core`(useWindowSize)、`useLayout`、`useMixMenu`、`@/stores`(useAppStore,useSettingsStore)、`@/enums/settings`(SidebarColor,ThemeMode)、`variables.module.scss`、`LayoutSidebarItem/LayoutMenuIcon/LayoutLogo/LayoutToolbar` | 顶部水平菜单（`el-menu mode="horizontal"`，顶栏数据 `topMenuItems`）+ 左侧垂直 `LayoutSidebarItem` 递归渲染 `sideMenuRoutes`；`useMenuColors` 判断暗色/经典蓝时用深色菜单变量 |
| [modes/DoubleLayout.vue](../../wmsui/src/layouts/modes/DoubleLayout.vue) | 双列菜单布局 | `useLayout`、`useMixMenu`、`@/stores`(useAppStore)、`@/settings`(appConfig)、`@/lang/utils`(translateRouteTitle)、`LayoutLogo/LayoutNavbar/LayoutTagsView/LayoutMain/LayoutSidebar/LayoutMenuIcon` | 左侧双列：第一列图标按钮（`topMenuItems`，切换顶部菜单路径）+ 第二列子菜单（`sideMenuRoutes`，`LayoutSidebar`，`collapse-override` 控制）；Navbar 传 `toggle-target="secondary"` 控制第二列展开 |

#### 4.8.2 布局组件（components/）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [LayoutSidebar.vue](../../wmsui/src/layouts/components/LayoutSidebar.vue) | 菜单容器（垂直/水平） | `path-browserify`、`element-plus`(MenuInstance)、`vue-router`(RouteRecordRaw)、`@/enums/settings`(SidebarColor,ThemeMode)、`@/stores`(useSettingsStore,useAppStore)、`@/utils`(isExternal)、`variables.module.scss`、`LayoutSidebarItem` | props：data/basePath/menuMode(vertical\|horizontal)/alwaysExpand/collapseOverride；`resolveFullPath` 用 path.resolve 拼父路径；展开项记录 + `syncActiveParentMenus` 给包含激活项的父级 `el-sub-menu` 加 `has-active-child` 类；暗色/经典蓝时注入深色菜单变量 |
| [LayoutSidebarItem.vue](../../wmsui/src/layouts/components/LayoutSidebarItem.vue) | 菜单单项递归 | `path-browserify`、`vue-router`(RouteRecordRaw)、`@/utils`(isExternal)、`@/lang/utils`(translateRouteTitle)、`LayoutMenuIcon`、`AppLink` | 只有一个可见子路由且非 alwaysShow 时渲染为单个 `el-menu-item`（经 AppLink），否则 `el-sub-menu` 递归自身渲染子树；隐藏项（meta.hidden）跳过 |
| [LayoutMenuIcon.vue](../../wmsui/src/layouts/components/LayoutMenuIcon.vue) | 菜单图标 | `vue`（无额外依赖，用全局注册的 el-icon） | `el-icon` 开头走 Element Plus 图标组件，否则 `i-svg:` 本地 SVG 图标 |
| [LayoutNavbar.vue](../../wmsui/src/layouts/components/LayoutNavbar.vue) | 顶栏 | `@/stores`(useAppStore)、`@/components/Hamburger`、`@/components/Breadcrumb`、`LayoutToolbar` | 左：Hamburger（`toggle-target` 支持切换 primary/secondary）+ Breadcrumb；右：`LayoutToolbar` |
| [LayoutToolbar.vue](../../wmsui/src/layouts/components/LayoutToolbar.vue) | 顶栏右侧工具组 | `vue-i18n`(useI18n)、`vue-router`、`@/settings`(defaults)、`@/enums/settings`、`@/stores`、`@/components/CommandPalette/Fullscreen/SizeSelect/LangSelect/TenantSwitcher`、`@/stores/tenant` | 桌面端显示：CommandPalette(Ctrl+K 搜索)、Fullscreen、SizeSelect、LangSelect、TenantSwitcher（`canSwitchTenant && tenantList.length>1` 时显示，切换后刷新页面）；用户头像下拉（个人中心/退出登录，退出走 `userStore.logout` 后跳 /login）；设置抽屉开关；`toolbarToneClass` 按主题/布局自动适配明暗 |
| [LayoutTagsView.vue](../../wmsui/src/layouts/components/LayoutTagsView.vue) | 页签栏 | `vue-router`、`path-browserify`(resolve)、`@/enums`(TagsViewStyle)、`@/lang/utils`、`@/stores`(useAppStore,usePermissionStore,useSettingsStore,useTagsViewStore)、`@/utils`(isExternal) | 从 `permissionStore.routes` 提取 affix 页签常驻；当前路由加入 visitedViews；支持 line/card 两种样式；右侧操作（刷新当前/内容全屏/关闭其它/左右/全部）；右键上下文菜单（Teleport 到 body，边界自适应定位）；滚轮横向滚动 |
| [LayoutMain.vue](../../wmsui/src/layouts/components/LayoutMain.vue) | 主内容区 | `vue-router`、`@/stores`(useSettingsStore,useTagsViewStore)、`variables.module.scss`、`@/views/error/404.vue` | `<router-view>` 外包 `<transition>`（按 pageSwitchingAnimation 动画）+ `<keep-alive :include="cachedViews">`；`currentComponent` 按 fullPath 生成具名包装组件（渲染失败回退 404，容量>100 淘汰最旧）；高度 = 100vh - navbar - tagsView；内置 el-backtop |
| [LayoutLogo.vue](../../wmsui/src/layouts/components/LayoutLogo.vue) | Logo 区 | `@/settings`(appConfig)、`@/assets/images/logo.png` | `router-link` 到 `/`，collapse 时只显示图标；顶部布局下背景透明 |
| [LayoutSettings.vue](../../wmsui/src/layouts/components/LayoutSettings.vue) | 设置抽屉 | `@/settings`(themePalettePresets 等)、`@/stores/settings`、`@/enums`、`vue-i18n` | 右滑抽屉（380px）：主题明暗（light/dark/auto）、预设配色切换 + 自定义色板、侧栏配色、布局模式、页签样式、水印/Logo/页签开关、页面切换动画、重置设置 |

#### 4.8.3 布局 composables（composables/）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [useLayout.ts](../../wmsui/src/layouts/composables/useLayout.ts) | 布局共享响应式状态 | `vue-router`(useRoute)、`@/stores`(useAppStore,usePermissionStore,useSettingsStore)、`@/enums/settings`(DeviceEnum)、`@/settings`(defaults) | 计算属性：isMobile/currentLayout/isSidebarOpen/showTagsView/showSettings/showLogo/layoutClass（is-sidebar-collapsed 等类）/routes/sideMenuRoutes/activeTopMenuPath/activeMenu（meta.activeMenu 优先）；toggleSidebar/closeSidebar |
| [useLayoutDevice.ts](../../wmsui/src/layouts/composables/useLayoutDevice.ts) | 设备断点适配 | `@vueuse/core`(useWindowSize)、`@/stores`(useAppStore)、`@/enums/settings`(DeviceEnum) | 三档断点：≥992 桌面宽屏（侧栏展开）、768~992 桌面窄屏（侧栏收缩）、<768 移动端（侧栏隐藏）；watchEffect 同步 device 与 sidebar |
| [useMixMenu.ts](../../wmsui/src/layouts/composables/useMixMenu.ts) | 混合/双栏菜单联动 | `vue-router`、`./useLayout`、`@/stores`(useAppStore,usePermissionStore)、`@/utils`(isExternal) | `topMenuItems`（单子路由提升为顶级入口，用子路由的 title/icon）；`activeSideMenuPath`；`resolvePath`（相对路径拼在 activeTopMenuPath 下）；`handleTopMenuSelect` 切换后 `setMixLayoutSideMenus` 并跳第一个叶子页；watch route.path 保持顶/侧菜单同步 |

### 4.9 公共组件（src/components）

#### 4.9.1 CURD 四件套（重点）

所有列表页的标准模板：**[PageSearch](../../wmsui/src/components/CURD/PageSearch.vue)（搜索区）+ [PageContent](../../wmsui/src/components/CURD/PageContent.vue)（表格/工具栏/分页）+ [PageModal](../../wmsui/src/components/CURD/PageModal.vue)（新增/编辑弹窗）+ [usePage](../../wmsui/src/components/CURD/usePage.ts)（胶水逻辑）**，配置类型见 [types.ts](../../wmsui/src/components/CURD/types.ts)。业务页面只需声明三份配置对象即可获得完整 CRUD。

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [PageSearch.vue](../../wmsui/src/components/CURD/PageSearch.vue) | 搜索表单 | `@element-plus/icons-vue`(ArrowUp,ArrowDown)、`element-plus`(FormInstance)、`@/components/InputTag`、`./types` | props `searchConfig`；`formItems` 渲染为 el-form 表单项，`type` 映射到 componentMap（input/select/cascader/input-number/date-picker/time-picker/time-select/tree-select/input-tag/custom-tag/custom 插槽）；`showNumber` 控制默认展示项数（默认 3）+ 展开/收起；`grid` 开启自适应网格（UnoCSS 断点 1~6 列）；`colon` 标签冒号、`cardAttrs`/`form` 透传；expose：`getQueryParams`、`toggleVisible`；emit：`queryClick`/`resetClick` |
| [PageContent.vue](../../wmsui/src/components/CURD/PageContent.vue) | 表格 + 工具栏 + 分页 + 导入导出 | `@vueuse/core`(useDateFormat,useThrottleFn)、`element-plus`(genFileId,FormInstance,FormRules,UploadInstance,UploadRawFile,UploadUserFile,TableInstance)、`exceljs`(Column,Workbook,动态 import)、`@/utils/auth`(hasPerm)、`./types` | 见下方 4.9.2 细述 |
| [PageModal.vue](../../wmsui/src/components/CURD/PageModal.vue) | 新增/编辑/查看弹窗（dialog/drawer） | `@vueuse/core`(useThrottleFn)、`lodash-es/cloneDeep`、`element-plus`(FormInstance,FormRules)、`@/components/InputTag`、`@/components/IconSelect`、`./types` | props `modalConfig`；componentMap 映射 16 种表单控件（input/select/switch/cascader/input-number/input-tag/time-picker/time-select/date-picker/tree-select/custom-tag/text/radio/checkbox/icon-select/custom）；options 由 childrenMap（el-option/el-radio/el-checkbox）渲染；`formData`/`formRules` 由 formItems 初始化（input-tag/cascader 默认 []，input-number 默认 null，其余 ""）；`handleSubmit`（节流 3s）→ beforeSubmit → formAction（成功 emit submitClick）或 emit customSubmit；expose：`setFormData`（cloneDeep 回填+pk）/`setModalVisible`/`getFormData`/`setFormItemData`/`handleDisabled`（查看模式禁用） |
| [usePage.ts](../../wmsui/src/components/CURD/usePage.ts) | 页面胶水逻辑 | `vue`(ref)、`./types` | 持有 searchRef/contentRef/addModalRef/editModalRef 四个实例引用；`handleQueryClick/handleResetClick`（搜索参数 + 筛选参数 → contentRef.fetchPageData(query, true)）；`handleAddClick`（打开弹窗+启用）；`handleEditClick/handleViewClick`（打开弹窗、回填行数据，可传 callback 变换数据、可指定 RefImpl 复用同一弹窗）；`handleSubmitClick`（提交后按搜索条件刷新列表）；`handleExportClick`（按搜索条件导出）；`handleSearchClick`（切换搜索区显隐）；`handleFilterChange`（列筛选联动查询） |
| [types.ts](../../wmsui/src/components/CURD/types.ts) | 四件套类型定义 | `element-plus`(DialogProps,DrawerProps,FormItemRule,PaginationProps,FormProps,TableProps,ColProps,ButtonProps,CardProps)、`vue`(CSSProperties)、`./PageContent.vue` 等、`@/api/common`(PageResult) | 见下方 4.9.3 细述 |

#### 4.9.2 PageContent 能力细述（[PageContent.vue](../../wmsui/src/components/CURD/PageContent.vue)）

**props**：仅 `contentConfig: IContentConfig`。**emits**：`addClick`、`exportClick`、`searchClick`、`toolbarClick(name)`、`editClick(row)`、`filterChange(data)`、`operateClick(data: IOperateData)`。

**工具栏**：
- 左侧 `toolbar`（默认项有 add/delete/import/export，文本/图标/权限在 `buttonConfig` 内置）；`perm` 支持 `"create"` 这类简写，经 `getButtonPerm` 用 `permPrefix` 拼成 `sys:user:create` 完整标识，或直接传含 `:` 的完整权限；按钮统一 `v-hasPerm` 指令控制显隐；delete 在无选中时禁用。
- 右侧 `defaultToolbar`（默认 refresh/filter/imports/exports/search，圆形图标）；`filter` 为列显隐弹层（el-popover + checkbox 绑定 `col.show`）。

**表格**：`el-table` + `cols` 列配置（自动补 `columnKey=prop`、selection 列默认 `reserveSelection` 实现跨页多选，`row-key=pk`）。每列按 `templet` 渲染内置模板：
- `image`（el-image 预览，支持数组）、`list`（selectList 映射中文）、`url`（el-link）、`switch`（行内开关，change 调 `modifyAction`，`hasButtonPerm` 控制禁用）、`input`（行内编辑，blur 调 modifyAction）、`price`/`percent`、`icon`（el-icon 或 i-svg）、`date`（useDateFormat 格式化）、`tool`（操作列按钮组：edit/view/delete 或自定义 IToolsButton，`render(row)` 条件显隐）、`custom`（交给父组件插槽 `<slot :name="col.slotName ?? col.prop">`）。

**分页**：`pagination` 可为 false（不分页）或对象（与默认值合并：background、layout、pageSize 20、pageSizes [10,20,30,50]）；请求参数名默认 `pageNum/pageSize`，可由 `request` 配置覆盖；`pagePosition` 控制左右对齐。

**数据流**：`fetchPageData(formData, isRestart)`（启动即调用一次）→ `indexAction` 合并分页参数 + `getFilterParams()` 筛选参数 + formData 查询；`handleRefresh` 用 `lastFormData` 重查；分页 size/current change 触发刷新。

**删除**：`handleDelete(id?)` 单选或批量（`removeIds`）→ ElMessageBox 确认 → `deleteAction(ids)` → 成功清空选择 + `tableRef.clearSelection()` + 刷新。

**导出**（前端导出，exceljs）：工具栏 `exports` 打开导出弹窗——文件名/工作表名/数据来源（当前页/选中行/全量 `exportsAction`）/字段多选 → 动态 `import("exceljs")` 生成 xlsx 下载。后端导出 `export` 走 `exportAction`（blob + Content-Disposition 解析）。

**导入**：`import`（后端导入 `importAction`）/`imports`（前端导入 `importsAction`：exceljs 解析第一个工作表，第一行做表头）；支持 `importTemplate` 模板下载。

**defineExpose**：`fetchPageData`、`exportPageData`、`getFilterParams`、`getSelectionData`、`handleRefresh`。

#### 4.9.3 CURD types.ts 关键类型细述（[types.ts](../../wmsui/src/components/CURD/types.ts)）

| 类型 | 关键字段 |
|------|---------|
| `ISearchConfig` | `permPrefix`、`colon`、`formItems: IFormItems<ISearchComponent>`、`isExpandable`、`showNumber`(默认3)、`cardAttrs`、`form`、`grid: boolean\|"left"\|"right"` |
| `IContentConfig` | `permPrefix`、`table`(el-table 透传)、`pagePosition`、`pagination`(boolean\|Partial)、`indexAction`（列表请求，返回 PageResult 或数组）、`request`（分页字段名 pageName/limitName）、`modifyAction`（行内修改 {pk,field,value}）、`deleteAction`、`exportAction`（后端导出）、`exportsAction`（前端全量导出）、`importTemplate`、`importAction`（后端导入）、`importsAction`（前端导入）、`pk`(默认id)、`toolbar`、`defaultToolbar`、`cols`（列定义，含 templet/operat/slotName/show/initFn 等扩展） |
| `IModalConfig` | `permPrefix`、`colon`、`pk`、`component: "dialog"\|"drawer"`、`dialog`/`drawer` 属性透传、`form`、`formItems: IFormItems<IComponentType>`、`beforeSubmit`、`formAction` |
| `IFormItems` | `type`（组件类型）、`tips`、`label`、`prop`、`attrs`、`options`（select/radio/checkbox 选项，支持 Ref）、`rules`、`initialValue`、`slotName`（custom 插槽名）、`hidden`、`col`（栅格）、`events`、`initFn` |
| `IToolsButton` | `name`、`text`、`perm`（简写或完整）、`attrs`（ButtonProps+style）、`render(row)` 条件渲染 |
| `IOperateData` | `name`、`row`、`column`、`$index` |

#### 4.9.4 其他公共组件（概述 + 重点）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [DictSelect/index.vue](../../wmsui/src/components/DictSelect/index.vue) | 字典下拉/单选/复选 | `@/stores`(useDictStore) | props：code(必填)/modelValue/type(select\|radio\|checkbox)/placeholder/disabled/style；mounted 按需 `loadDictItems` 拉字典；内部 selectedValue 与 options 同步后 emit update:modelValue（数字/字符串匹配） |
| [DictTag/index.vue](../../wmsui/src/components/DictTag/index.vue) | 字典值标签 | `@/stores`(useDictStore) | props：code/modelValue/size；watch code+modelValue → loadDictItems → 按 value 找 label 与 tagType（el-tag 着色） |
| [Upload/FileUpload.vue](../../wmsui/src/components/Upload/FileUpload.vue) | 多文件上传 | `element-plus`(UploadRawFile 等)、`@/api/file`(FileAPI) | `http-request` 自定义上传：FormData 调 `FileAPI.upload`（带进度百分比）；`defineModel` 双向绑定 `FileInfo[]`；大小/数量校验、成功合并、失败移除、可下载/删除 |
| [Upload/SingleImageUpload.vue](../../wmsui/src/components/Upload/SingleImageUpload.vue) | 单图上传（picture-card） | `element-plus`、`@/api/file`(FileAPI) | accept 格式二次校验（image/*、扩展名、MIME）；上传成功回填 `modelValue` URL，悬浮删除 |
| [Upload/MultiImageUpload.vue](../../wmsui/src/components/Upload/MultiImageUpload.vue) | 多图上传（picture-card） | `element-plus`、`@/api/file`(FileAPI) | 卡片列表 + 预览（el-image-viewer 支持缩放/下标）+ 删除；modelValue 为 URL 数组 |
| [Pagination/index.vue](../../wmsui/src/components/Pagination/index.vue) | 通用分页 | `element-plus`(el-pagination) | `defineModel` 双向绑定 page/limit；total 变小自动回退最后一页；emit `pagination`；autoScroll/hidden |
| [ECharts/index.vue](../../wmsui/src/components/ECharts/index.vue) | ECharts 封装 | `echarts/core`、`echarts/charts`(Bar,Line,Pie)、`echarts/components`(Grid,Tooltip,Legend)、`echarts/renderers`(CanvasRenderer)、`@vueuse/core`(useResizeObserver) | 按需注册；init/setOption；useResizeObserver 自动 resize；options 深度 watch 更新；卸载 dispose |
| [WangEditor/index.vue](../../wmsui/src/components/WangEditor/index.vue) | 富文本编辑器 | `@wangeditor-next/editor/dist/css/style.css`、`@wangeditor-next/editor-for-vue`(Toolbar,Editor)、`@/api/file`(FileAPI) | v-model 双向绑定 HTML；图片 `customUpload` 走 FileAPI.uploadFile 后 insertFn；编辑器实例用 shallowRef |
| [IconSelect/index.vue](../../wmsui/src/components/IconSelect/index.vue) | 图标选择器 | `@element-plus/icons-vue`、UnoCSS 图标类 | el-popover + 输入框触发；SVG 图标（`i-svg:`）/Element Plus 图标两个 Tab，可搜索；选中回写 `el-icon-xxx` 或 `xxx` |
| [InputTag/index.vue](../../wmsui/src/components/InputTag/index.vue) | 标签输入 | `element-plus`(InputInstance) | `defineModel<string[]>`；el-tag 列表 + 输入框回车/blur 新增，可关闭删除 |
| [TableSelect/index.vue](../../wmsui/src/components/TableSelect/index.vue) | 表格选择弹层 | `element-plus`(el-popover,el-form)、`vue` | 输入框触发 popover，内含查询表单（formItems）+ 分页表格 + 确定回填选中行，返回选中数据 |
| [OperationColumn/index.vue](../../wmsui/src/components/OperationColumn/index.vue) | 自适应宽操作列 | `element-plus`(el-table-column) | 插槽渲染操作按钮；`listDataLength` 与局部指令 v-auto 在挂载/更新时测量按钮总宽并自适应列宽（minWidth 兜底 80px） |
| [CopyButton/index.vue](../../wmsui/src/components/CopyButton/index.vue) | 复制按钮 | `@element-plus/icons-vue`(DocumentCopy) | 优先 `navigator.clipboard`，降级 `document.execCommand("copy")` 隐藏 input |
| [Hamburger/index.vue](../../wmsui/src/components/Hamburger/index.vue) | 侧栏折叠按钮 | `@/stores`(useSettingsStore)、`@/enums/settings`(ThemeMode,SidebarColor,LayoutMode) | 暗色或 Mix+经典蓝时白色图标；emit toggleClick |
| [Fullscreen/index.vue](../../wmsui/src/components/Fullscreen/index.vue) | 全屏切换 | `@vueuse/core`(useFullscreen) | 全屏/退出图标切换 |
| [ThemeSwitch/index.vue](../../wmsui/src/components/ThemeSwitch/index.vue) | 主题明暗切换 | `vue-i18n`、`@/stores`(useSettingsStore)、`@/enums`(ThemeMode)、`@element-plus/icons-vue`(Moon,Sunny,Monitor) | 下拉切换 light/dark/auto；图标随当前主题 |
| [LangSelect/index.vue](../../wmsui/src/components/LangSelect/index.vue) | 语言切换 | `vue-i18n`、`@/stores/app`(useAppStore)、`@/enums/settings`(LanguageEnum) | 中/英切换：`locale.value=lang` + `appStore.changeLanguage`（驱动 EP locale 与菜单翻译） |
| [SizeSelect/index.vue](../../wmsui/src/components/SizeSelect/index.vue) | 组件尺寸切换 | `vue-i18n`、`@/enums/settings`(ComponentSize)、`@/stores/app`(useAppStore) | default/large/small 三档，写 appStore.size（App.vue 的 el-config-provider 消费） |
| [TenantSwitcher/index.vue](../../wmsui/src/components/TenantSwitcher/index.vue) | 租户切换下拉 | `@element-plus/icons-vue`(ArrowDown)、`@/stores/tenant` | 显示 tenantList，emit `change(tenantId)`（LayoutToolbar 中调用 switchTenant 后刷新） |
| [CommandPalette/index.vue](../../wmsui/src/components/CommandPalette/index.vue) | Ctrl+K 菜单搜索 | `./useCommandPalette` | 搜索面板：按菜单 title 过滤（不匹配路径避免噪音）、键盘上下+回车、历史记录（localStorage 存 5 条）、排除 /redirect/login/401/404 |
| [AppLink/index.vue](../../wmsui/src/components/AppLink/index.vue) | 内部/外部链接统一组件 | `@/utils`(isExternal) | 外链渲染 `<a target="_blank">`，内部渲染 router-link；外链拦截默认跳转改 window.open |
| [Breadcrumb/index.vue](../../wmsui/src/components/Breadcrumb/index.vue) | 面包屑 | `vue-router`、`path-to-regexp`(compile)、`@/router`、`@/lang/utils`(translateRouteTitle) | 取 route.matched 有 title 的层级（`meta.breadcrumb===false` 隐藏）；动态路由参数用 compile 补全；末级纯文本 |
| [TextScroll/index.vue](../../wmsui/src/components/TextScroll/index.vue) | 公告文本滚动 | `element-plus`(el-icon,Bell,Close) | 无缝滚动（内容复制两份）、预设样式（default/success/warning/danger/info）、打字机效果、悬停暂停、可关闭 |
| [GithubCorner/index.vue](../../wmsui/src/components/GithubCorner/index.vue) | GitHub 角标 | 无 | 空壳组件（已移除，仅保留引用兼容） |

> 登录相关（`views/login/index.vue` 及其 `components/Register.vue`、`ResetPwd.vue`、`views/error/*`、`views/redirect.vue`、`views/iframe.vue`）属于页面层，见 [auth.md](./auth.md) 与系统文档，不在本文档范围。

---

## 5. 核心实现逻辑

### 5.1 启动装配顺序（main.ts）

```
createApp(App)
  → setupDirective(app)        注册 v-hasPerm 指令
  → setupI18n(app)             vue-i18n（legacy:false，locale 取 appStore.language，含中英文包）
  → setupRouter(app)           createWebHashHistory 路由实例
  → setupStore(app)            createPinia
  → Object.entries(ElementPlusIcons).forEach(app.component)   全局注册全部 @element-plus/icons-vue 图标
  → setupPermissionGuard()     beforeEach/afterEach 守卫 + NProgress
  → setupSse()                 字典同步 + 在线人数 SSE 服务
  → app.mount("#app")
```

注意：`ElementPlusIcons` 全局注册放在 pinia 之后、守卫之前；`setupSse` 在守卫之后调用（其内部 `useDictSync/useOnlineCount` 依赖 store 已就绪）。`setupPermissionGuard` 内部使用 `useUserStore` 等，依赖 pinia 已注册。

### 5.2 请求拦截器流程（utils/request.ts）

```
请求发出
  └─ 请求拦截器：Authorization==="no-auth" 时移除该头（refresh-token/登录用）；
                  否则注入 `Bearer ${AuthStorage.getAccessToken()}`
  └─ 响应成功回调：
      responseType ∈ {blob, arraybuffer} → 原样透传（下载/导入）
      code === "00000"(SUCCESS)          → 直接返回 response.data（业务数据）
      其他                              → ElMessage.error(msg) 并 reject
  └─ 响应失败回调（HTTP 或业务异常态）：
      无 response          → "网络连接失败"
      code === "A0230"     → ① WeakSet 标记 config 防死循环（同一 config 只重试一次）
                             ② userStore.refreshTokenOnce() 单飞刷新（并发 401 共享同一次刷新）
                             ③ 新 token 更新 headers → http(config) 原样重放
                             ④ 刷新失败 → redirectToLogin("登录已过期，请重新登录")
      code === "A0231"     → redirectToLogin(notify=false)（Refresh 令牌失效，静默踢回登录）
      code === "A0301"     → permissionStore.refreshPermissions()（重拉用户信息 + reloadRoutes 重建动态路由）
                             再提示 msg（如角色/菜单被调整后的即时刷新）
      其他                 → ElMessage.error(msg || "请求失败")
```

**令牌刷新单飞**：`userStore.refreshTokenOnce()` 用模块级 `refreshPromise` 缓存进行中的刷新请求，多个并发 401 只发一次 `/auth/refresh-token`，完成（无论成败）后置空，后续 401 可再次刷新。

### 5.3 权限守卫流程（router/guards/permission.ts）

```
beforeEach(to, from)
  ├─ NProgress.start()
  ├─ 未登录（无 accessToken）：
  │    白名单 ["/login"] 内 → 放行
  │    否则 → /login?redirect=to.fullPath（编码保留目标）
  ├─ 已登录且访问 /login → 重定向 /
  ├─ isRouteGenerated === false（首次进入）：
  │    ① 用户信息为空 → userStore.getUserInfo()（含 roles/perms）
  │    ② initTenantContext()：VITE_APP_TENANT_ENABLED=true 时 tenantStore.loadTenant()，失败静默
  │    ③ permissionStore.generateRoutes()：MenuAPI.getRoutes() → transformRoutes → filterRoutes
  │    ④ 逐个 router.addRoute(route)
  │    ⑤ return { ...to, replace: true } 重放本次导航（走已生成的路由表）
  ├─ 已生成路由但 to.matched 为空（404 检测）：
  │    从 /login 跳来的无效路径 → 回退 /（避免不同用户权限差导致的 404 误判）
  │    否则 → /404
  ├─ 动态标题：to.params.title 或 to.query.title 覆盖 meta.title
  └─ 异常：resetAllState() → 跳 /login
afterEach → NProgress.done()
```

### 5.4 布局四模式切换机制

1. **选择**：`layouts/index.vue` 中 `currentLayoutComponent` = `route.meta.layout ?? settingsStore.layout`，按 `LayoutMode`（left/top/mix/double）映射到对应 `modes/*` 组件，支持**单页覆盖**全局布局。
2. **状态**：`useLayout` 统一提供 `currentLayout/isSidebarOpen/isMobile/showTagsView/showLogo/layoutClass/routes` 等；`useLayoutDevice` 按窗口宽度（≥992/768~992/<768）同步 `device` 与侧栏展开态。
3. **菜单数据**：Left/Top 直接用 `permissionStore.routes`（过滤 meta.hidden）；Mix/Double 用 `useMixMenu` —— 顶部取一级菜单（单子路由提升为顶级），侧边随 `activeTopMenuPath` 通过 `permissionStore.setMixLayoutSideMenus` 动态取该一级菜单的 children；路由变化时 watch 同步顶/侧激活态。
4. **渲染**：所有模式共用 `BaseLayout`（移动端遮罩 + layout 类）；内容区统一 `LayoutNavbar + LayoutTagsView + LayoutMain`（keep-alive + transition）。
5. **个性化**：`LayoutSettings` 抽屉修改 settingsStore（布局/主题/配色/页签样式等），全部 `useStorage` 持久化到 localStorage，刷新不丢。

### 5.5 CURD 页面通用模式（usePage 如何驱动增删改查）

```
业务页面（如 views/system/user/index.vue）
  ├─ 定义 searchConfig / contentConfig / addModalConfig / editModalConfig（见 types.ts）
  ├─ 模板：
  │    <PageSearch ref="searchRef" :search-config="searchConfig" @query-click @reset-click />
  │    <PageContent ref="contentRef" :content-config="contentConfig" @add-click @operate-click ... />
  │    <PageModal ref="addModalRef"  :modal-config="addModalConfig"  @submit-click />
  │    <PageModal ref="editModalRef" :modal-config="editModalConfig" @submit-click />
  └─ setup：const { searchRef, contentRef, addModalRef, editModalRef, handleQueryClick, ... } = usePage()
      再把这批 handle* 接到组件事件上（或直接在模板中调用）

数据流：
  搜索    → handleQueryClick(params) → contentRef.fetchPageData({...params, ...filterParams}, true)（回第一页）
  重置    → handleResetClick(params) → 同上（PageSearch 内部先 resetFields）
  新增    → handleAddClick() → addModalRef.setModalVisible(true) + handleDisabled(false)
  编辑    → handleEditClick(row) → editModalRef.setModalVisible + setFormData(row)（cloneDeep 回填 + pk）
  查看    → handleViewClick(row) → setModalVisible + handleDisabled(true)（表单禁用）
  提交    → PageModal 内部 handleSubmit（节流 3s）→ 校验 → modalConfig.beforeSubmit(formData)
            → modalConfig.formAction(formData)（调 api 增/改）→ emit submitClick
            → usePage.handleSubmitClick() → 取 searchRef.getQueryParams() → contentRef.fetchPageData(params, true)
  删除    → PageContent 内部 ElMessageBox 确认 → contentConfig.deleteAction(ids) → 刷新
  行内修改 → switch/input templet → contentConfig.modifyAction({ pk, field, value })
  导出    → handleExportClick() → contentRef.exportPageData(searchParams)（后端）或 exports 弹窗前端 exceljs 导出
```

### 5.6 v-permission 指令实现

- `directives/index.ts` 只注册了 **`v-hasPerm`**（别名指令名 `hasPerm`，源码中调用处也写作 `v-hasPerm`）。
- `directives/permission/index.ts` 同时实现 `hasPerm` 与 `hasRole` 两个指令（`hasRole` 未注册，需要时可自行注册）。
- 行为：`mounted` 时读取 `binding.value`（string 或 string[]）；`useUserStore().userInfo` 的 `roles/perms`；`ROOT` 角色或含 `*:*:*` 直接放行；其余按 `some` 语义匹配；**不通过则从 DOM 移除元素**（`el.parentNode.removeChild(el)`）。
- 权限标识拼接：CURD 里按钮权限常用 `permPrefix + ":" + action`（如 `sys:user:create`）组成完整标识，配合后端菜单按钮权限（`MenuTypeEnum.BUTTON`）下发的 `perms` 数组做匹配；`utils/auth.ts` 的 `hasPerm()` 函数式版本供 JS 场景（如 `hasButtonPerm`）复用，逻辑一致。

---

## 6. 技术栈

| 类别 | 技术 | 版本 | 用途 |
|------|------|------|------|
| 框架 | Vue | 3.5 | Composition API + `<script setup>` |
| 语言 | TypeScript | 5.9 | 全量类型安全（vue-tsc 校验） |
| 构建 | Vite（Rolldown + Oxc + Lightning CSS） | 8.0 | 开发服务器 / 生产构建 |
| UI | Element Plus | 2.14 | 组件库 + 暗色主题 + 按需自动导入 |
| 路由 | Vue Router | 5.1 | 常量路由 + 后端动态路由 + 守卫 |
| 状态 | Pinia | 3.0 | 7 个 store（组合式写法） |
| HTTP | Axios + qs | 1.18 / 6.15 | 拦截器/令牌刷新/数组参数序列化 |
| 国际化 | vue-i18n | 11.4 | 中英文切换（EP locale 联动） |
| 样式 | SCSS + UnoCSS | — | 主题变量 + 原子化 CSS + 本地 SVG 图标 |
| 表格 | vxe-table（配置） / el-table（CURD 实际使用） | 4.6 / 2.14 | 全局表格配置 + 页面列表渲染 |
| 图表 | ECharts（按需引入） | 6.1 | 仪表盘/统计图表 |
| 富文本 | wangEditor | 5.7 | 公告/内容编辑 |
| Excel | exceljs | 4.4 | 前端导入导出（CURD 四件套内置） |
| 实时推送 | 自研 SSE（fetch + ReadableStream） | — | 字典失效同步 / 在线人数 |
| 工具 | VueUse / lodash-es / path-browserify / path-to-regexp / nprogress / sortablejs | — | 组合式函数 / 深拷贝 / 路径拼接 / 面包屑 / 进度条 / 拖拽 |
| 自动导入 | unplugin-auto-import / unplugin-vue-components | — | Vue/EP API 与组件按需自动导入 |
| Mock | vite-plugin-mock-dev-server | 2.4 | 本地联调（默认关闭） |
| 代码质量 | ESLint + Prettier + Stylelint + Husky + lint-staged + commitlint(cz-git) | — | 提交前校验与规范化提交 |