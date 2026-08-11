# 系统管理模块（system）

> 源码位置：[wmsui/src/views/system](../../wmsui/src/views/system)（页面）、[wmsui/src/api/system](../../wmsui/src/api/system)（接口）
> 本文档基于实际源码整理，所有链接可在 IDE 中 Ctrl+点击跳转。

## 1. 模块概述

系统管理模块是 WMS 后台的「组织与权限中枢」，解决**人员、组织、权限、字典、配置、审计、多租户**等基础治理问题。共包含 9 个页面（13 个 vue 文件）：

| 子模块 | 页面 | 解决的业务问题 |
|-------|------|--------------|
| 用户管理 | user | 平台/租户内人员账号的增删改查、启停、密码重置、Excel 导入导出、按部门过滤 |
| 角色管理 | role | 角色 CRUD、给角色分配菜单/按钮权限、数据权限（全部/部门/本人/自定义部门）控制 |
| 菜单管理 | menu | 目录/菜单/外链/按钮四类菜单的树形维护，菜单数据同时驱动前端动态路由与权限点 |
| 部门管理 | dept | 组织部门树（含厂区 plantCode 字段）维护，作为用户归属与数据权限的维度 |
| 字典管理 | dict + dict-item | 字典类型维护 + 字典项维护，前端全局字典缓存与标签样式（tagType） |
| 系统配置 | config | 全局 key-value 配置项维护与缓存刷新 |
| 操作日志 | log | 操作日志（请求/状态/IP/耗时）检索与详情查看；PV/UV 统计接口供仪表盘使用 |
| 租户管理 | tenant + plan | 多租户 CRUD、租户套餐（plan）管理、套餐内菜单功能范围配置、更换套餐 |
| 应用管理 | app | 三方应用（微信/支付宝/苹果/QQ）AppId/密钥维护与启停 |

模块整体特点（基于实际代码）：

- **表格**：本模块全部页面使用 Element Plus `el-table`（含树形表格），**未使用** vxe-table（vxe-table 仅作为全局插件配置在 [plugins/vxe-table.ts](../../wmsui/src/plugins/vxe-table.ts)，系统管理页面未引用）。
- **CURD 骨架**：不依赖 CURD 公共组件（PageContent 等），而是采用「`usePageTable` + `useTableSelection` 组合式函数 + 自动导入的 `pagination` 分页组件 + `el-card`/`el-table` 自绘」的结构，各页面代码高度同构。
- **组件自动导入**：`vite.config.ts` 配置了 `unplugin-vue-components`（`dirs: ["src/components", "src/**/components"]`），因此 `pagination`、`DictSelect`、`icon-select` 等无需显式 import。
- **权限点**：按钮级权限通过全局指令 `v-hasPerm`（如 `sys:user:create`）控制，指令在 [directives](../../wmsui/src/directives) 注册。
- **路由**：前端不写死业务路由，由 `stores/permission.ts` 调用 `MenuAPI.getRoutes()` 拉取菜单树动态生成，菜单「页面组件」字段（如 `system/user/index`）对应 `src/views` 下页面。

## 2. 页面与路由

路由路径由**后端菜单数据动态生成**（菜单表的 `routePath` + `component` 字段），下表「路由路径」为系统内置菜单的约定路径（如 `menu/index.vue` 中默认跳转示例 `/system/user`）。

| 路由路径（菜单数据） | 页面组件（链接） | 功能概述 |
|---------------------|-----------------|---------|
| `/system/user` | [user/index.vue](../../wmsui/src/views/system/user/index.vue) | 用户分页列表：关键字/状态/创建时间/部门树过滤，新增/编辑（抽屉表单）、批量删除（防删当前登录用户）、重置密码、导入导出、表格行勾选 |
| —（user 页内嵌） | [user/components/UserDeptTree.vue](../../wmsui/src/views/system/user/components/UserDeptTree.vue) | 用户页左侧部门树（搜索过滤 + 点击联动查询），`v-model` 绑定 `params.deptId` |
| —（user 页内嵌） | [user/components/UserImportDialog.vue](../../wmsui/src/views/system/user/components/UserImportDialog.vue) | 用户导入弹窗：模板下载、文件上传、导入结果（有效/无效条数 + 错误信息列表）回显 |
| `/system/role` | [role/index.vue](../../wmsui/src/views/system/role/index.vue) | 角色分页 CRUD；「分配权限」抽屉（菜单树勾选、父子联动开关）；数据权限 5 档选择（自定义档选部门树） |
| `/system/menu` | [menu/index.vue](../../wmsui/src/views/system/menu/index.vue) | 菜单树表（el-table tree-props）；四类菜单（目录/菜单/外链/按钮）新增/编辑/删除；表单按类型动态展示字段、切换类型保留草稿 |
| `/system/dept` | [dept/index.vue](../../wmsui/src/views/system/dept/index.vue) | 部门树表（默认全展开）；新增子部门/编辑/删除，`getOptions()` 结果复用于用户/角色表单的部门树选择 |
| `/system/dict` | [dict/index.vue](../../wmsui/src/views/system/dict/index.vue) | 字典类型分页 CRUD；「字典数据」按钮跳转字典项页（路由名 `DictItem`，query 传 `dictCode`/`title`） |
| 路由名 `DictItem` | [dict/dict-item.vue](../../wmsui/src/views/system/dict/dict-item.vue) | 字典项分页 CRUD（按路由 query 的 dictCode 限定），支持标签类型（tagType）选择 |
| `/system/config` | [config/index.vue](../../wmsui/src/views/system/config/index.vue) | 系统配置分页 CRUD + 「刷新缓存」按钮（防抖 1s） |
| `/system/log` | [log/index.vue](../../wmsui/src/views/system/log/index.vue) | 操作日志分页查询（关键字/时间区间）+ 详情弹窗（el-descriptions 全字段展示） |
| `/system/tenant` | [tenant/index.vue](../../wmsui/src/views/system/tenant/index.vue) | 租户分页 CRUD；更换套餐弹窗；套餐功能配置抽屉（按套餐范围勾选菜单）；平台租户保护（不可选/不可删） |
| `/system/tenant-plan` | [tenant/plan.vue](../../wmsui/src/views/system/tenant/plan.vue) | 租户套餐 CRUD + 「菜单配置」抽屉（按业务菜单范围勾选） |
| `/system/app` | [app/index.vue](../../wmsui/src/views/system/app/index.vue) | 三方应用分页 CRUD、平台（微信/支付宝/苹果/QQ）筛选、状态行内开关 |

## 3. 后端接口

> 所有接口统一走 [utils/request.ts](../../wmsui/src/utils/request.ts) 封装的 axios 实例，返回 `ApiResult<T>` 响应壳。

### 3.1 公共类型（[api/common.ts](../../wmsui/src/api/common.ts)）

| 类型 | 说明 |
|------|------|
| `ApiResult<T>` | 响应壳：`{ code, data, msg }` |
| `BaseQueryParams` | 分页基础参数：`pageNum`/`pageSize`/`sortBy`/`order` |
| `PageResult<T>` | 分页结果：`{ list: T[], total }` |
| `OptionItem` | 下拉/树选项：`{ value, label, children? }`（树形下拉通用结构） |
| `ExcelResult` | Excel 导入结果：`{ code, invalidCount, validCount, messageList: string[] }` |

### 3.2 用户（[api/system/user/index.ts](../../wmsui/src/api/system/user/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getInfo()` | GET `/api/v1/users/me` | 当前登录用户信息（含角色/权限） |
| `getPage(params)` | GET `/api/v1/users` | 用户分页（keywords/status/deptId/createTime） |
| `getFormData(userId)` | GET `/api/v1/users/{id}/form` | 编辑回显表单数据 |
| `create(data)` | POST `/api/v1/users` | 新增用户 |
| `update(id, data)` | PUT `/api/v1/users/{id}` | 修改用户 |
| `resetPassword(id, password)` | PUT `/api/v1/users/{id}/password/reset?password=` | 重置密码 |
| `deleteByIds(ids)` | DELETE `/api/v1/users/{ids}` | 批量删除（逗号分隔） |
| `downloadTemplate()` | GET `/api/v1/users/template`（blob） | 下载导入模板 |
| `export(params)` | GET `/api/v1/users/export`（blob） | 导出当前查询条件用户 |
| `import(file)` | POST `/api/v1/users/import`（multipart/form-data） | 导入用户，返回 `ExcelResult` |
| `getOptions()` | GET `/api/v1/users/options` | 用户下拉（页面未直接使用） |
| 个人中心相关 | GET/PUT `/api/v1/users/profile`、PUT `/api/v1/users/password`、`/mobile`、`/email`、GET `/api/v1/logs/login-records` | 个人中心/登录记录（非本页调用，随 UserAPI 一并导出） |

### 3.3 角色（[api/system/role/index.ts](../../wmsui/src/api/system/role/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/roles` | 角色分页 |
| `getOptions()` | GET `/api/v1/roles/options` | 角色下拉（用户表单「角色」多选用） |
| `getRoleMenuIds(roleId)` | GET `/api/v1/roles/{id}/menu-ids` | 已分配菜单 ID 集合（权限回显） |
| `updateRoleMenus(roleId, data)` | PUT `/api/v1/roles/{id}/menus` | 分配菜单权限（body 为 number[]） |
| `getFormData(id)` | GET `/api/v1/roles/{id}/form` | 编辑回显 |
| `getRoleDeptIds(roleId)` | GET `/api/v1/roles/{id}/dept-ids` | 自定义数据权限部门集合（页面未直接使用） |
| `create/update/deleteByIds` | POST/PUT/DELETE `/api/v1/roles(/{id})` | CRUD |

### 3.4 菜单（[api/system/menu/index.ts](../../wmsui/src/api/system/menu/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getRoutes()` | GET `/api/v1/menus/routes` | 当前用户动态路由（permission store 使用） |
| `getList(params)` | GET `/api/v1/menus` | 菜单树形列表（关键字过滤） |
| `getOptions(onlyParent?, scope?)` | GET `/api/v1/menus/options?onlyParent=&scope=` | 菜单下拉树（表单父级选择/权限树/租户功能树共用） |
| `getFormData(id)` | GET `/api/v1/menus/{id}/form` | 编辑回显 |
| `create/update` | POST/PUT `/api/v1/menus(/{id})` | 新增/修改 |
| `deleteById(id)` | DELETE `/api/v1/menus/{id}` | 删除菜单 |

### 3.5 部门（[api/system/dept/index.ts](../../wmsui/src/api/system/dept/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getList(params)` | GET `/api/v1/depts` | 部门树形列表 |
| `getOptions()` | GET `/api/v1/depts/options` | 部门下拉树（用户/角色表单、用户页部门树复用） |
| `getFormData(id)` | GET `/api/v1/depts/{id}/form` | 编辑回显 |
| `create/update/deleteByIds` | POST/PUT/DELETE `/api/v1/depts(/{id})` | CRUD |

### 3.6 字典（[api/system/dict/index.ts](../../wmsui/src/api/system/dict/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/dicts` | 字典类型分页 |
| `getList()` | GET `/api/v1/dicts/options` | 字典下拉（dict store 使用） |
| `getFormData(id)` | GET `/api/v1/dicts/{id}/form` | 字典类型编辑回显 |
| `create/update/deleteByIds` | POST/PUT/DELETE `/api/v1/dicts(/{id})` | 字典类型 CRUD |
| `getDictItemPage(dictCode, params)` | GET `/api/v1/dicts/{dictCode}/items` | 字典项分页（list 逐项做 tagType 解码） |
| `getDictItems(dictCode)` | GET `/api/v1/dicts/{dictCode}/items/options` | 字典项选项（DictSelect/DictTag 数据源） |
| `createDictItem(dictCode, data)` | POST `/api/v1/dicts/{dictCode}/items` | 新增字典项（tagType 编码为 P/S/W/I/D/N） |
| `getDictItemFormData(dictCode, id)` | GET `/api/v1/dicts/{dictCode}/items/{id}/form` | 字典项编辑回显 |
| `updateDictItem(dictCode, id, data)` | PUT `/api/v1/dicts/{dictCode}/items/{id}` | 修改字典项 |
| `deleteDictItems(dictCode, ids)` | DELETE `/api/v1/dicts/{dictCode}/items/{ids}` | 删除字典项 |

**关键点**：`tagType` 在 API 层统一转换 —— 后端码 `N/P/S/W/I/D`（无/主/成功/警告/信息/危险）⇄ 前端 Element Plus `""/primary/success/warning/info/danger`（`decodeDictTagType`/`encodeDictTagType`）。

### 3.7 系统配置（[api/system/config/index.ts](../../wmsui/src/api/system/config/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/configs` | 配置分页 |
| `getFormData(id)` | GET `/api/v1/configs/{id}/form` | 编辑回显 |
| `create/update/deleteById` | POST/PUT/DELETE `/api/v1/configs(/{id})` | CRUD |
| `refreshCache()` | PUT `/api/v1/configs/refresh` | 刷新配置缓存 |

### 3.8 操作日志（[api/system/log/index.ts](../../wmsui/src/api/system/log/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/logs` | 日志分页（keywords/createTime） |
| `getVisitTrend(params)` | GET `/api/v1/logs/analytics/trend` | 访问趋势（PV/UV 日期序列）—— 供 [dashboard/index.vue](../../wmsui/src/views/dashboard/index.vue) 使用 |
| `getVisitOverview()` | GET `/api/v1/logs/analytics/overview` | 访问概览（今日/累计 PV/UV 与增长率）—— 供仪表盘使用 |

> 说明：日志页本身只做操作日志查询；PV/UV 统计接口由 `LogAPI` 导出、在仪表盘页面消费。

### 3.9 租户（[api/system/tenant/index.ts](../../wmsui/src/api/system/tenant/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getTenantList()` | GET `/api/v1/tenants/options` | 当前用户可访问租户（切换器用） |
| `getCurrentTenant()` | GET `/api/v1/tenants/current` | 当前租户信息 |
| `switchTenant(tenantId)` | POST `/api/v1/tenants/{id}/switch` | 切换租户 |
| `getPage(params)` | GET `/api/v1/tenants` | 租户分页 |
| `getFormData(tenantId)` | GET `/api/v1/tenants/{id}/form` | 编辑回显 |
| `create(data)` | POST `/api/v1/tenants` | 新增租户（初始化默认数据，返回 `TenantCreateResult` 含管理员账号/初始密码） |
| `update(tenantId, data)` | PUT `/api/v1/tenants/{id}` | 修改租户（更换套餐也走此接口） |
| `deleteByIds(ids)` | DELETE `/api/v1/tenants/{ids}` | 批量删除 |
| `updateStatus(tenantId, status)` | PUT `/api/v1/tenants/{id}/status` | 修改状态 |
| `getTenantMenuIds(tenantId)` | GET `/api/v1/tenants/{id}/menuIds` | 租户已启用菜单 ID（功能配置回显） |
| `updateTenantMenus(tenantId, menuIds)` | PUT `/api/v1/tenants/{id}/menus` | 更新租户菜单（body 为 number[]） |

### 3.10 租户套餐（[api/system/tenant-plan/index.ts](../../wmsui/src/api/system/tenant-plan/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/tenant-plans` | 套餐分页 |
| `getFormData(planId)` | GET `/api/v1/tenant-plans/{id}/form` | 编辑回显 |
| `create/update/deleteByIds` | POST/PUT/DELETE `/api/v1/tenant-plans(/{id})` | CRUD |
| `getOptions()` | GET `/api/v1/tenant-plans/options` | 套餐下拉（租户表单/更换套餐弹窗用） |
| `getPlanMenuIds(planId)` | GET `/api/v1/tenant-plans/{id}/menuIds` | 套餐已配菜单 ID |
| `updatePlanMenus(planId, menuIds)` | PUT `/api/v1/tenant-plans/{id}/menus` | 更新套餐菜单 |

### 3.11 应用管理（[api/system/app/index.ts](../../wmsui/src/api/system/app/index.ts)）

| API 函数 | HTTP 方法与路径 | 说明 |
|----------|----------------|------|
| `getPage(params)` | GET `/api/v1/apps` | 应用分页（keywords/status/platform） |
| `getFormData(id)` | GET `/api/v1/apps/{id}/form` | 编辑回显 |
| `create/update/deleteByIds` | POST/PUT/DELETE `/api/v1/apps(/{id})` | CRUD |
| `updateStatus(id, status)` | PUT `/api/v1/apps/{id}/status` | 修改状态（行内开关调用） |

### 3.12 关键 types.ts 类型概述

| 类型文件 | 核心类型 | 要点 |
|---------|---------|------|
| [user/types.ts](../../wmsui/src/api/system/user/types.ts) | `UserInfo`/`UserQueryParams`/`UserItem`/`UserForm` | `roleNames` 逗号分隔；`UserQueryParams` 含 `deptId`、`createTime: [string, string]`；另含个人中心/改密/手机邮箱绑定等表单类型 |
| [role/types.ts](../../wmsui/src/api/system/role/types.ts) | `RoleItem`/`RoleForm` | `dataScope` 取值 1-5（1 全部/2 部门及子部门/3 本部门/4 本人/5 自定义），`dataScopeLabel` 为后端返回的标签文本；`deptIds` 仅在 dataScope=5 时有效 |
| [menu/types.ts](../../wmsui/src/api/system/menu/types.ts) | `MenuItem`/`MenuForm`/`RouteItem`/`Meta` | `type` 为字符串 `C/M/E/B`；`RouteItem`/`Meta` 是动态路由的数据结构（hidden/keepAlive/alwaysShow/params 等） |
| [dept/types.ts](../../wmsui/src/api/system/dept/types.ts) | `DeptItem`/`DeptForm` | 树形结构自带 `children`；含 `plantCode`（厂区编码）、`treePath`（父节点 ID 路径） |
| [dict/types.ts](../../wmsui/src/api/system/dict/types.ts) | `DictTypeItem`/`DictItem`/`DictItemForm`/`DictItemOption` | `tagType` 前端为 `"success"|"warning"|"info"|"primary"|"danger"|""` |
| [config/types.ts](../../wmsui/src/api/system/config/types.ts) | `ConfigItem`/`ConfigForm` | 简单 key-value 结构 |
| [log/types.ts](../../wmsui/src/api/system/log/types.ts) | `LogItem`/`LogQueryParams`/`VisitTrendDetail`/`VisitOverviewDetail` | `status` 0 失败 1 成功；PV/UV 相关类型供仪表盘使用 |
| [tenant/types.ts](../../wmsui/src/api/system/tenant/types.ts) | `TenantItem`/`TenantForm`/`TenantCreateForm`/`TenantCreateResult` | 新增与编辑表单拆分；`TenantCreateResult` 返回管理员账号/初始密码 |
| [tenant-plan/types.ts](../../wmsui/src/api/system/tenant-plan/types.ts) | `TenantPlanItem`/`TenantPlanForm` | 简单套餐结构 |
| [app/types.ts](../../wmsui/src/api/system/app/types.ts) | `AppPlatform`/`AppForm`/`AppItem` | `AppPlatform = "WECHAT_MP"|"WECHAT_MINI"|"ALIPAY"|"APPLE"|"QQ"` |

## 4. 文件清单

> 「引用的关键依赖」列只列 import 中真实出现的模块；`ref/reactive/computed/watch/watchEffect/nextTick` 等 Vue API 与 `useDebounceFn`（VueUse）、`useFullscreen`（@vueuse/core）、`useRoute/useRouter`（vue-router）均由 unplugin-auto-import 自动导入，不再逐一标注。

### 4.1 用户管理（user）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/user/index.vue) | 用户列表页：搜索/分页/CRUD/重置密码/导入导出/部门树联动 | `UserAPI`、`DeptAPI`、`RoleAPI`；`usePageTable`、`useTableSelection`；`useAppStore`、`useUserStore`；`CommonStatus`、`DeviceEnum`、`DialogMode`、`UserGender`；`downloadFile`；`UserDeptTree`、`UserImportDialog`；element-plus `ElMessage/ElMessageBox`、`FormInstance/FormRules` | 左侧 `<aside>` 放部门树（`v-model:params.deptId`）；`usePageTable` 管理分页，`useTableSelection` 管理勾选；新增/编辑用 `el-drawer` 抽屉表单（响应式宽度，桌面 600px）；编辑时 `username` 只读；提交走 `useDebounceFn(300)`；删除前二次确认并**拦截删除当前登录用户**；重置密码弹窗校验最小 6 位；导出 `UserAPI.export(params)` + `downloadFile(blob)`；`onMounted`/`onActivated` 均刷新列表 |
| [components/UserDeptTree.vue](../../wmsui/src/views/system/user/components/UserDeptTree.vue) | 用户页左侧部门树（搜索过滤 + 点击联动） | `DeptAPI`；`OptionItem`；element-plus tree 的 `TreeNodeData`；`useVModel`（auto-import） | `useVModel(props,"modelValue",emits)` 双向绑定 `deptId`；`watchEffect` 监听搜索词调用 `treeRef.filter()`；`default-expand-all` 全展开；点击节点写入 deptId 并 `emit("node-click")` 触发父页查询 |
| [components/UserImportDialog.vue](../../wmsui/src/views/system/user/components/UserImportDialog.vue) | 用户导入弹窗：模板下载 → 上传 → 结果回显 | `UserAPI`；`ApiCodeEnum`；`downloadFile`；element-plus `ElMessage`、`UploadUserFile`；`el-upload`/`el-dialog`/`el-table`/`el-alert`/`el-scrollbar` | `defineModel("modelValue")` 控制显隐；`el-upload` 单文件（xlsx/xls，≤1M，不自动上传）；「下载模板」调 `downloadTemplate()` 拿 blob；「确定」取 `files[0].raw` 调 `UserAPI.import()`（FormData 上传，**由后端解析**）；`code===SUCCESS && invalidCount===0` 提示成功并 `emit("import-success")`，否则弹「导入结果」对话框展示 `messageList` 逐条错误、`invalidCount/validCount` 统计 |

### 4.2 角色管理（role）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/role/index.vue) | 角色 CRUD + 权限分配 + 数据权限 | `RoleAPI`、`MenuAPI`、`DeptAPI`；`usePageTable`、`useTableSelection`；`useAppStore`；`CommonStatus`、`DeviceEnum`；element-plus `ElMessage/ElMessageBox`、`TreeInstance`、`TreeNodeData`；@element-plus/icons-vue `Search/Switch/QuestionFilled` | 表格列含 `dataScopeLabel`（后端返回的中文）；数据权限 `dataScopeOptions` 1-5 档，`DATA_SCOPE_CUSTOM=5` 时显示部门树多选（`el-tree-select` check-strictly），提交时非自定义档清除 `deptIds`；部门选项懒加载（首次打开弹窗才请求并缓存）；「分配权限」抽屉：并行请求 `MenuAPI.getOptions()` + `RoleAPI.getRoleMenuIds()`，`nextTick` 后 `setChecked` 回显，`check-strictly` 由「父子联动」开关控制，提交用 `getCheckedNodes(false,true)` 取半选父级 + 子级后 `updateRoleMenus`；展开/收缩遍历 `store.nodesMap` |

### 4.3 菜单管理（menu）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/menu/index.vue) | 菜单树表 + 四类型菜单表单 | `MenuAPI`；`useAppStore`；`CommonStatus`、`MenuScopeEnum`、`MenuTypeEnum`、`DeviceEnum`；`isTenantEnabled`（utils/tenant）、`isValidURL`；element-plus `ElMessage/ElMessageBox`、`FormInstance/FormRules`；@element-plus/icons-vue（Refresh/FullScreen/QuestionFilled 等）；`icon-select`（自动导入，[components/IconSelect](../../wmsui/src/components/IconSelect/index.vue)） | `el-table` 配 `tree-props`（children/hasChildren）渲染树；图标渲染支持 `el-icon-*` 前缀动态组件与 `i-svg:` 类名两种形式；行操作「新增」仅目录/菜单类型显示（继承父级 id）；表单按类型动态展示：目录（路由路径/默认跳转/单子级显示）、菜单（路由路径/组件/路由参数/页面缓存+页面标识）、外链（外链地址/打开方式：新标签页 or iframe 内嵌）、按钮（权限标识）；**类型切换草稿机制**：`menuTypeDrafts` 按类型保存已填字段，切换后恢复；提交前 `normalizeMenuPayload()` 按类型清理无关字段；多租户关闭时隐藏「菜单范围」字段（`isTenantEnabled()`）；路由参数 key=value 动态增删 |

### 4.4 部门管理（dept）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/dept/index.vue) | 部门树表 CRUD | `DeptAPI`；`useTableSelection`；`CommonStatus`；element-plus `ElMessage/ElMessageBox`、`FormInstance/FormRules` | `el-table` tree-props + `row-key="id"` + `default-expand-all` 渲染树表；`DeptAPI.getList()` 一次返回全量树；新增/编辑 `el-dialog`：先 `getOptions()` 拼上「顶级部门」根节点供 `el-tree-select` 选择父级；操作列「新增」传当前行 id 作为父级；删除单个/批量共用一个 `handleDelete(id?)`（勾选 id 逗号拼接） |

### 4.5 字典管理（dict）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/dict/index.vue) | 字典类型分页 CRUD | `DictAPI`；`usePageTable`、`useTableSelection`；`CommonStatus`；`router`（vue-router）；element-plus `ElMessage/ElMessageBox` | 标准分页 CRUD；「字典数据」按钮用 `router.resolve({ name:"DictItem", query:{ dictCode, title } })` 跳转，先校验 `route.matched.length` 判断路由是否注册，失败给出提示 |
| [dict-item.vue](../../wmsui/src/views/system/dict/dict-item.vue) | 字典项分页 CRUD | `DictAPI`；`usePageTable`、`useTableSelection`；`CommonStatus`；`useRoute`；element-plus `ElMessage/ElMessageBox` | `route.query.dictCode` 作为限定条件传给 `getDictItemPage`；新增/编辑提交前强制 `formData.dictCode = dictCode`；「标签类型」下拉将 `tagType` 直接渲染为 `el-tag` 颜色预览（options：primary/success/info/warning/danger），提交/回显由 API 层做编解码；删除走 `deleteDictItems(dictCode, ids)` |

### 4.6 系统配置（config）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/config/index.vue) | 配置分页 CRUD + 刷新缓存 | `ConfigAPI`；`usePageTable`；element-plus `ElMessage/ElMessageBox`、`FormInstance/FormRules` | 标准分页 CRUD（无行勾选，序号列）；「刷新缓存」按钮 `useDebounceFn(1000)` 调 `ConfigAPI.refreshCache()`；表单 4 字段（名称/键/值/描述，均限长度） |

### 4.7 操作日志（log）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/log/index.vue) | 操作日志分页查询 + 详情 | `LogAPI`；`usePageTable`；element-plus `FormInstance`、`TagProps`；@element-plus/icons-vue `Refresh/FullScreen` | 纯查询页（无增删改）；搜索仅关键字 + 时间区间；状态列 `LOG_STATUS_SUCCESS=1` 映射成功/失败 tag；请求方法 → tag 颜色映射 `getMethodTagType()`（GET 默认/POST 成功/PUT 警告/DELETE 危险/PATCH 信息）；详情弹窗用 `el-descriptions`（2 列）展示标题/状态/耗时/操作人/时间/IP/方法/路径/浏览器/系统/自定义内容/错误信息 |

### 4.8 租户管理（tenant）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/tenant/index.vue) | 租户 CRUD + 更换套餐 + 套餐功能配置 | `TenantAPI`、`TenantPlanAPI`、`MenuAPI`；`usePageTable`、`useTableSelection`；`CommonStatus`、`MenuScopeEnum`；`hasPerm`（utils/auth）、`isPlatformTenantId`（utils/tenant）；element-plus `ElMessage/ElMessageBox`、`ElTree`、`TreeInstance`、`TreeNodeData` | 列表 `request` 回调中把后端返回的 `planId` 统一转 number；平台租户保护：`isTenantSelectable` 使平台租户不可勾选、删除按钮隐藏、套餐操作隐藏；新增时可选套餐 + 管理员账号（为空系统生成），编辑时编码禁用、显示状态；**更换套餐弹窗**：展示升级/降级风险提示，`handlePlanChange` 拉取目标套餐菜单并 `filterMenuOptionsByIds` 只保留套餐允许节点、`updateCheckedMenus` 优先保留租户原勾选（套餐范围内）；确认后 `update` 租户 planId，再 `updateTenantMenus(keepMenuIds)` 同步菜单；**套餐功能配置抽屉**：`applyMenuOptionsDisabled` 锁定套餐外节点，勾选树提交时过滤套餐范围外 id；提交均 `useDebounceFn(300)` |
| [plan.vue](../../wmsui/src/views/system/tenant/plan.vue) | 租户套餐 CRUD + 菜单配置 | `TenantPlanAPI`、`MenuAPI`；`usePageTable`；`CommonStatus`、`MenuScopeEnum`；element-plus `ElMessage/ElMessageBox`、`TreeInstance`、`TreeNodeData` | 套餐标准分页 CRUD；「菜单配置」抽屉与 role 页权限分配同构：`getOptions(false, TENANT)` + `getPlanMenuIds` 并行加载、`setChecked` 回显、「父子联动」开关切 `check-strictly`、提交 `getCheckedNodes(false,true)` 取半选父级+子级 → `updatePlanMenus` |

### 4.9 应用管理（app）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [index.vue](../../wmsui/src/views/system/app/index.vue) | 三方应用分页 CRUD + 状态开关 | `AppAPI`；`usePageTable`、`useTableSelection`；`CommonStatus`；element-plus `ElMessage/ElMessageBox`、`FormInstance/FormRules` | 平台筛选（platformOptions：WECHAT_MP/WECHAT_MINI/ALIPAY/APPLE/QQ）；状态列行内 `el-switch`（权限 `sys:app:change-status`），`handleStatusChange` 失败时回滚开关状态；表单含 AppSecret/商户密钥（`show-password` 隐藏输入）；新增/编辑弹窗 `el-dialog`，提交校验 appName/appCode/platform/appId |

## 5. 核心实现逻辑

### 5.1 用户列表页完整链路（[user/index.vue](../../wmsui/src/views/system/user/index.vue)）

1. **分页查询**：`usePageTable<UserItem, UserQueryParams>({ initialParams:{pageNum:1,pageSize:10}, request: UserAPI.getPage })` 提供 `loading/list/total/params/fetchData/handleQuery/handleResetQuery`；`onMounted` + `onActivated`（keep-alive 恢复）触发 `handleQuery()`。
2. **搜索**：关键字（回车触发）/状态/创建时间区间绑定到 `params`，搜索按钮 → `handleQuery()`（回到第 1 页）；重置 → `queryFormRef.resetFields()` 后重新查询。
3. **部门树过滤**：左侧 `UserDeptTree` 通过 `v-model` 写 `params.deptId`，点击节点 emit 事件后父页重新查询。
4. **新增**：`handleCreateClick` → 并行 `loadFormOptions()`（`RoleAPI.getOptions()` + `DeptAPI.getOptions()`）→ 打开抽屉；表单校验规则含手机号正则 `^1[3-9]\d{9}$`、邮箱格式；「所属部门」用 `el-tree-select`（check-strictly 不联动子级）。
5. **编辑回显**：`handleEditClick(id)` → 同样先加载选项 → `UserAPI.getFormData(id)` → `Object.assign(formData, data)`（`username` 输入框 `:readonly="!!formData.id"`）。
6. **提交**：`useDebounceFn(300)` 内 `formRef.validate()` → 有 `id` 走 `update`，否则 `create` → 成功后关抽屉并 `handleQuery()`。
7. **删除确认**：`ElMessageBox.confirm` 二次确认；单删/批量删共用 `handleDelete(id?)`（不传则用 `selectedIds.join(",")`）；**安全检查**：命中当前登录用户（`userStore.userInfo.userId`）直接 `ElMessage.error("不能删除当前登录用户")` 拦截。
8. **重置密码**：单独弹窗（表单 min 6 位），`UserAPI.resetPassword(userId, password)`，`useDebounceFn` 防抖提交。
9. **导出**：`UserAPI.export(params)` 返回 blob → `downloadFile(response)`。

### 5.2 用户导入流程（[UserImportDialog.vue](../../wmsui/src/views/system/user/components/UserImportDialog.vue)）

1. **模板下载**：「下载模板」→ `UserAPI.downloadTemplate()`（`responseType:"blob"`）→ `downloadFile()` 保存 xlsx。
2. **文件选择**：`el-upload` 单文件（限 xlsx/xls、≤1M、`auto-upload:false`），超出个数 `handleFileExceed` 提示。
3. **提交**：「确定」取 `files[0].raw` 组 FormData 调 `UserAPI.import()`（POST multipart/form-data）。
4. **结果回显**：返回 `ExcelResult`；全部有效（`code===ApiCodeEnum.SUCCESS && invalidCount===0`）→ 成功提示并 `emit("import-success")` 让父页刷新；否则弹「导入结果」对话框，`el-alert` 显示「N 条无效数据，M 条有效数据」，`el-table` 逐条列出 `messageList` 错误。

> ⚠️ **与常见做法的差异**：本项目**未在前端使用 exceljs 解析**（package.json 虽含 exceljs 4.4，但本弹窗未引入），文件原始上传、由**后端**解析并返回逐行错误信息。

### 5.3 菜单树与部门树构建

- **菜单树表**（[menu/index.vue](../../wmsui/src/views/system/menu/index.vue)）：`MenuAPI.getList()` 一次返回全量树，`el-table` 用 `:tree-props="{children:'children',hasChildren:'hasChildren'}"` + `row-key="id"` 展开渲染；行内「新增」仅目录/菜单显示，`openDialog(parentId)` 通过 `getDefaultMenuType(parentId)` 推断新增类型（顶级→目录、父为菜单→按钮、否则→菜单）。
- **菜单下拉树**（表单「父级菜单」）：`MenuAPI.getOptions(true)`（onlyParent）拼「顶级菜单」根节点喂给 `el-tree-select`。
- **部门树**：`DeptAPI.getList()`（管理页树表）/ `DeptAPI.getOptions()`（树形下拉与用户页部门树）均返回带 `children` 的树；`UserDeptTree` 用 `el-tree` + `filter-node-method` 实现名称过滤（`watchEffect` 自动触发）。
- **权限/功能树复用**：role 页权限树、tenant 页功能树、plan 页菜单树均基于 `MenuAPI.getOptions()`（`scope` 区分平台/业务菜单），`el-tree` 统一 `node-key="value"`、`show-checkbox`。

### 5.4 角色权限分配交互（[role/index.vue](../../wmsui/src/views/system/role/index.vue)）

1. 点「分配权限」→ 抽屉标题 `【角色名】权限分配`；并行请求 `MenuAPI.getOptions()` 与 `RoleAPI.getRoleMenuIds(roleId)`。
2. `nextTick` 后遍历已分配 id 调 `permTreeRef.setChecked(id, true, false)` 回显。
3. 「父子联动」复选框控制 `:check-strictly="!parentChildLinked"` —— 开启时勾父自动带子（半选也计入），关闭时完全独立勾选（用于只给菜单不给按钮的场景）。
4. 关键字过滤 `watch(permKeywords)` 触发 `tree.filter()`；「展开/收缩」遍历 `store.nodesMap` 批量 expand/collapse。
5. 提交：`getCheckedNodes(false, true)`（含半选父级）映射为 number 数组 → `RoleAPI.updateRoleMenus(roleId, ids)` → 成功后重置查询。
6. 数据权限（表单）：`dataScope` 选择器 5 档，仅当 =5（自定义部门数据）时展示 `el-tree-select`（multiple + check-strictly）选择部门，提交时其他档位 `deptIds=undefined`。

### 5.5 字典页面与后端 SSE 的关系

字典页本身**不直接订阅 SSE**，但字典数据与 [stores/dict.ts](../../wmsui/src/stores/dict.ts)（全局字典缓存，供 `DictSelect`/`DictTag` 使用）关联；`setupSse()` 初始化 [composables/sse/useDictSync.ts](../../wmsui/src/composables/sse/useDictSync.ts) 单例，监听 SSE `dict` 频道消息（`{ dictCode, timestamp }`），收到变更即 `dictStore.removeDictItem(dictCode)` 清除本地缓存，使后续 `DictSelect`/`DictTag` 重新拉取最新字典项 —— 即「后端字典/字典项变更 → SSE 广播 → 前端清缓存自动刷新」。

## 6. 技术栈

| 分类 | 使用情况（基于本模块实际代码） |
|------|-------------------------------|
| 框架 | Vue 3.5 Composition API + `<script setup>` + `defineOptions({name})` |
| UI | Element Plus 2.x：`el-table`（树形/多选）、`el-dialog`、`el-drawer`、`el-tree-select`、`el-tree`、`el-upload`、`el-descriptions`、`ElMessage`、`ElMessageBox` |
| 组合式函数 | `usePageTable`（分页查询四件套）、`useTableSelection`（行勾选）、VueUse `useFullscreen`、`useDebounceFn` |
| 状态管理 | Pinia：`useAppStore`（设备/布局，控制抽屉宽度）、`useUserStore`（当前用户，删除安全检查）、dict store（SSE 联动） |
| 自动导入 | unplugin-auto-import（Vue API / VueUse / vue-router）、unplugin-vue-components（Element Plus 组件 + `src/components` 下 `pagination`/`DictSelect`/`icon-select`） |
| 枚举 | `CommonStatus`(0/1)、`UserGender`(0/1/2)、`DialogMode`、`MenuTypeEnum`(C/M/E/B)、`MenuScopeEnum`(1 平台/2 业务)、`DeviceEnum`(DESKTOP)、`ApiCodeEnum` |
| 工具 | `downloadFile`（blob 下载）、`isTenantEnabled`/`isPlatformTenantId`（utils/tenant）、`hasPerm`（utils/auth）、`isValidURL` |
| 指令 | `v-hasPerm`（按钮权限点，如 `sys:user:create`） |
| 网络 | axios 封装 `@/utils/request`；Excel 导入为 multipart 上传，导出/模板为 blob 下载 |
| 未使用 | 本模块页面全部使用 `el-table`，**未使用 vxe-table**；导入解析由后端完成，**未使用 exceljs** |
