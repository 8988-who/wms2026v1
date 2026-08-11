# WMS 前端（wmsui 工程）功能开发文档

> 本文档描述 `d:\workcoding\wms20260712\wmsui` 工程实现的功能。
> 按**功能模块**拆分文档，每个模块的 md 文件详细描述：页面怎么实现、每个文件（vue / ts）的作用与引用的依赖、对应的后端接口（来源 [wmsui/src/api](../../wmsui/src/api)）。

---

## 一、文档结构

| 模块文档 | 功能说明 | 状态 |
|---------|---------|------|
| [framework.md](./framework.md) | 工程基础设施：请求封装/路由守卫/状态管理/布局/公共组件 CURD | ✅ 已完成 |
| [auth.md](./auth.md) | 认证授权：登录/登出/令牌管理/用户状态 | ✅ 已完成 |
| [system.md](./system.md) | 系统管理：用户/角色/菜单/部门/字典/配置/日志/租户 | ✅ 已完成 |
| [warehouse.md](./warehouse.md) | 仓库管理：库位/巷道/点位三级页面 | ✅ 已完成 |
| [carriermanagementsystem.md](./carriermanagementsystem.md) | 载具管理：料车型号/料车/装载明细页面 | ✅ 已完成 |
| [file.md](./file.md) | 文件上传：上传组件与文件接口 | ✅ 已完成 |
| [message.md](./message.md) | 消息推送：SSE 实时推送（字典同步/在线数） | ✅ 已完成 |

---

## 二、工程技术栈总览

数据来源：[package.json](../../wmsui/package.json)

| 分类 | 技术选型 | 版本 | 用途 |
|------|---------|------|------|
| 语言 | TypeScript | 5.9 | 全量类型安全 |
| 框架 | Vue 3 | 3.5 | Composition API + `<script setup>` |
| 构建 | Vite | 8.0 | 开发服务器 / 打包 |
| UI | Element Plus | 2.14 | 基础组件库（含暗色主题） |
| 表格 | vxe-table | 4.6 | 高性能表格（CURD 页面核心） |
| 状态 | Pinia | 3.0 | 用户/权限/字典/设置等全局状态 |
| 路由 | Vue Router | 5.1 | 动态路由 + 权限守卫 |
| HTTP | Axios | 1.18 | 请求封装（拦截器/重试/SSE 兼容） |
| 国际化 | vue-i18n | 11.4 | 中英文切换 |
| 样式 | SCSS + UnoCSS | — | 原子化 CSS + 主题变量 |
| 图表 | ECharts | 6.1 | 仪表盘图表 |
| 富文本 | wangEditor | 5.7 | 公告/内容编辑 |
| Excel | exceljs | 4.4 | 前端导入导出 |
| 工具 | VueUse / lodash-es | — | 组合式函数 / 工具函数 |
| 代码质量 | ESLint + Prettier + Stylelint + Husky | — | lint-staged 提交前检查 |
| Mock | vite-plugin-mock-dev-server | 2.4 | 本地联调 Mock |
| 自动导入 | unplugin-auto-import / unplugin-vue-components | — | API 与组件按需自动导入 |

---

## 三、工程目录结构（src）

| 目录 | 职责 |
|------|------|
| `src/api` | 后端接口封装（按业务模块分目录，`index.ts` 请求 + `types.ts` 类型） |
| `src/views` | 页面组件（路由对应） |
| `src/components` | 公共组件（CURD 四件套、字典、上传、富文本等） |
| `src/composables` | 组合式函数（SSE、表格分页、多选） |
| `src/stores` | Pinia 状态（user/permission/dict/settings/tags-view/tenant/app） |
| `src/router` | 路由定义 + 权限守卫 |
| `src/utils` | 工具（request/auth/storage/theme/validate/format/download） |
| `src/directives` | 自定义指令（权限） |
| `src/enums` | 枚举（业务/API/通用/设置） |
| `src/constants` | 常量 |
| `src/lang` | 国际化（zh-cn/en） |
| `src/layouts` | 布局系统（左侧/顶部/双栏/混合四模式） |
| `src/styles` | 全局样式与主题变量 |
| `src/plugins` | 插件（vxe-table、nprogress） |
| `src/settings.ts` | 全局设置（标题/主题/布局偏好） |

---

## 四、如何阅读各模块文档

每个模块 md 统一按以下结构编写：

1. **模块概述** —— 页面解决什么业务问题，包含哪些页面与路由；
2. **页面与路由** —— 路由路径、页面组件对应关系；
3. **后端接口** —— 该模块调用的 API（路径/方法/参数），来源 `src/api`；
4. **文件清单** —— 每个文件：作用、引用的关键依赖、实现要点；
5. **核心实现逻辑** —— 关键交互流程（表单提交、数据回显、权限控制等）；
6. **技术栈** —— 该模块实际用到的技术。

> 文件链接均为相对路径（`../../wmsui/src/...`），IDE 中 Ctrl+点击可跳转源码。

### 前后端文档对应关系（数据交互）

前端**不直连数据库**，所有数据读写都通过 §3「后端接口」调用后端 API 完成——该章节即前端的数据交互部分，与后端文档的「数据库交互」章节对应：

| 前端文档 §3 后端接口 | 对应后端文档（§数据库交互） | 数据通道 |
|---------------------|--------------------------|---------|
| [auth.md](./auth.md) | [WMS后端/auth.md](../WMS后端/auth.md) §3 | `POST /api/v1/auth/login` 等 → sys_user + Redis |
| [system.md](./system.md) | [WMS后端/system.md](../WMS后端/system.md) §3 | `/api/v1/users`、`/roles`、`/dicts` 等 → sys_* 表 |
| [warehouse.md](./warehouse.md) | [WMS后端/warehouse.md](../WMS后端/warehouse.md) §3 | `/api/v1/wms-locations` 等 → wms_location/aisle/point |
| [carriermanagementsystem.md](./carriermanagementsystem.md) | [WMS后端/carriermanagementsystem.md](../WMS后端/carriermanagementsystem.md) §3 | `/api/v1/carts`、`/cart-items` 等 → wms_cart* 表 |
| [file.md](./file.md) | [WMS后端/file.md](../WMS后端/file.md) §3 | `/api/v1/files`（已下线）→ 对象存储，无 DB 表 |
| [message.md](./message.md) | [WMS后端/message.md](../WMS后端/message.md) §3 | `GET /api/v1/sse/connect` → 内存态，无 DB |
| [framework.md](./framework.md) §4 请求封装 | [WMS后端/framework.md](../WMS后端/framework.md) §3 | `utils/request.ts` → 拦截器/令牌/刷新 |

---

## 五、全局功能索引（功能 → 文档章节）

> 使用方式：想改某个页面功能 → 查下表 → 打开对应模块文档的章节 → 点击文档中的文件链接直达源码。

| 需求/功能 | 定位（文档 §章节） | 关键代码入口 |
|---------|------------------|-------------|
| 登录 / 登出 | [auth.md](./auth.md) §4 | `views/login/index.vue` / `stores/user.ts` |
| 请求封装（拦截器/令牌刷新） | [framework.md](./framework.md) §4 | `utils/request.ts` |
| 动态路由与权限守卫 | [framework.md](./framework.md) §4 | `router/guards/permission.ts` / `stores/permission.ts` |
| 用户管理页面 | [system.md](./system.md) §4 | `views/system/user/index.vue` |
| 角色/菜单/部门/字典/配置/日志页面 | [system.md](./system.md) §4 | `views/system/*/index.vue` |
| 库位/巷道/点位页面 | [warehouse.md](./warehouse.md) §4 | `views/warehouse/*/index.vue` |
| 料车型号/料车/装载明细页面 | [carriermanagementsystem.md](./carriermanagementsystem.md) §4 | `views/carriermanagementsystem/*/index.vue` |
| 文件上传组件 | [file.md](./file.md) §4 | `components/Upload/*.vue` |
| SSE 字典实时同步 | [message.md](./message.md) §4 | `composables/sse/useDictSync.ts` |
| SSE 在线人数 | [message.md](./message.md) §4 | `composables/sse/useOnlineCount.ts` |
