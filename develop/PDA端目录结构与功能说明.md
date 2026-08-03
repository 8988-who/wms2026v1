# WMS PDA 端目录结构与功能说明

## 一、技术栈概览

| 技术 | 说明 |
|------|------|
| uni-app | 跨平台框架（H5/小程序/App） |
| Vue 3 | Composition API |
| TypeScript | 类型安全 |
| Vite | 构建工具 |
| Pinia | 状态管理 |
| uni-mini-router | 路由管理 |
| UnoCSS | 原子化 CSS |
| wot-ui | UI 组件库（Wot Design Uni） |
| ECharts/uCharts | 图表可视化 |

---

## 二、完整目录树与文件详情

```
wmspda
├── .cursorrules                               # AI 编码规则配置
├── .env.development                           # 开发环境变量
├── .env.production                            # 生产环境变量
├── eslint.config.mjs                          # ESLint 配置
├── uno.config.ts                              # UnoCSS 样式预设
├── vite.config.ts                             # Vite 构建配置
├── tsconfig.json                              # TypeScript 编译配置
├── pages.config.ts                            # 页面全局配置（tabBar/页面样式）
├── index.html                                 # HTML 入口（H5）
├── package.json                               # 项目依赖与 scripts
│
└── src
    ├── main.ts                                # 应用入口，初始化 Vue/Pinia/路由
    ├── App.vue                                # 根组件，初始化主题
    ├── manifest.json                          # uni-app 应用配置（名称/版本/权限）
    ├── pages.json                             # uni-app 页面路由配置
    ├── env.d.ts                               # 环境变量类型
    ├── shims-uni.d.ts                         # uni-app 类型声明
    ├── uni.scss                               # uni-app 全局样式变量
    │
    ├── api/                                   # API 接口模块
    │   ├── auth.ts                            # 认证 API：登录/登出/验证码
    │   ├── user.ts                            # 用户 API：信息获取/更新
    │   ├── role.ts                            # 角色 API：列表/分配权限
    │   ├── dept.ts                            # 部门 API：树形列表
    │   ├── menu.ts                            # 菜单 API：用户菜单权限
    │   ├── dict.ts                            # 字典 API：字典/字典项
    │   ├── config.ts                          # 系统配置 API
    │   ├── log.ts                             # 日志 API
    │   └── file.ts                            # 文件上传 API
    │
    ├── components/                            # 公共组件
    │   ├── custom-navbar/index.vue            # 自定义导航栏（标题/返回按钮）
    │   ├── custom-tree/index.vue              # 自定义树形组件（部门/菜单树）
    │   ├── cu-date-query/index.vue            # 日期查询组件（日期范围选择）
    │   ├── qiun-data-charts/                  # 跨端图表组件
    │   │   ├── qiun-data-charts.vue           # 图表主组件（ECharts/UCharts 双引擎）
    │   │   ├── qiun-error.vue                 # 图表错误提示
    │   │   └── qiun-loading/                  # 图表加载动画
    │   │       ├── qiun-loading.vue           # 加载组件入口
    │   │       └── loading1~5.vue             # 5 种加载动画样式
    │   └── u-charts/                          # UCharts 图表库
    │       ├── u-charts.js                    # UCharts 核心库
    │       ├── config-echarts.js              # ECharts 配置
    │       └── config-ucharts.js              # UCharts 配置
    │
    ├── composables/                           # 可组合函数
    │   ├── useTheme.ts                        # 主题管理（初始化/切换/持久化）
    │   ├── useLoading.ts                      # 加载状态控制
    │   ├── useCountdown.ts                    # 验证码倒计时
    │   ├── useNavbar.ts                       # 导航栏逻辑
    │   ├── useNavigation.ts                   # 页面导航封装
    │   ├── useRequest.ts                      # 网络请求封装
    │   ├── useSse.ts                          # SSE 实时推送
    │   ├── useTabbar.ts                       # TabBar 逻辑
    │   └── types/theme.ts                     # 主题类型定义
    │
    ├── config/                                # 配置
    │   ├── index.ts                           # 全局配置（API 地址等）
    │   └── menu.ts                            # 菜单配置
    │
    ├── constants/index.ts                     # 全局常量
    │
    ├── enums/
    │   └── api-code-enum.ts                   # API 状态码枚举
    │
    ├── layouts/                               # 布局
    │   ├── default.vue                        # 默认布局（内容容器+顶部栏）
    │   └── tabbar.vue                         # TabBar 底部导航布局
    │
    ├── pages/                                 # 页面
    │   ├── index/
    │   │   └── index.vue                      # 首页（数据概览+快捷入口）
    │   ├── login/
    │   │   └── index.vue                      # 登录页（账号密码登录）
    │   ├── webview/
    │   │   └── index.vue                      # 内嵌 WebView 页面
    │   ├── work/                              # 工作台模块
    │   │   ├── index.vue                      # 工作台首页（功能入口）
    │   │   ├── user/index.vue                 # 用户管理
    │   │   ├── role/
    │   │   │   ├── index.vue                  # 角色管理
    │   │   │   └── assign-perm.vue            # 分配权限
    │   │   ├── menu/index.vue                 # 菜单管理
    │   │   ├── dept/index.vue                 # 部门管理
    │   │   ├── dict/
    │   │   │   ├── index.vue                  # 字典管理
    │   │   │   └── item/index.vue             # 字典项管理
    │   │   ├── config/index.vue               # 系统配置
    │   │   ├── log/index.vue                  # 日志管理
    │   │   └── monitor/index.vue              # 系统监控
    │   └── mine/                              # 我的模块
    │       ├── index.vue                      # 个人中心首页
    │       ├── about/index.vue                # 关于页面
    │       ├── account/index.vue              # 账号管理
    │       ├── official/index.vue             # 关注公众号
    │       ├── profile/
    │       │   ├── index.vue                  # 个人资料
    │       │   └── complete-profile.vue       # 完善资料
    │       └── settings/                      # 设置
    │           ├── index.vue                  # 设置首页
    │           ├── theme/index.vue            # 主题设置
    │           ├── network/index.vue          # 网络设置
    │           ├── privacy/index.vue          # 隐私设置
    │           └── agreement/index.vue        # 用户协议
    │
    ├── router/
    │   └── index.ts                           # uni-mini-router 路由配置（路由表/守卫）
    │
    ├── store/                                 # Pinia 状态管理
    │   ├── index.ts                           # Store 入口
    │   └── modules/
    │       ├── user.ts                        # 用户状态（登录/登出/Token/用户信息）
    │       └── theme.ts                       # 主题状态（主题切换/持久化）
    │
    ├── styles/                                # 样式
    │   ├── index.scss                         # 全局样式入口
    │   └── theme.scss                         # 主题样式
    │
    ├── utils/                                 # 工具函数
    │   ├── request.ts                         # 网络请求封装（uni.request 拦截器/Token/错误处理）
    │   ├── auth.ts                            # Token 管理（uni.setStorageSync）
    │   ├── storage.ts                         # 本地存储封装
    │   ├── format.ts                          # 格式化工具（日期/数字）
    │   ├── form.ts                            # 表单工具（校验等）
    │   ├── permission.ts                      # 权限工具（按钮权限判断）
    │   └── index.ts                           # 通用工具函数
    │
    ├── static/                                # 静态资源
    │   ├── icons/                             # SVG 图标
    │   ├── images/                            # 图片资源
    │   ├── tabbar/                            # TabBar 图标
    │   └── logo.png                           # 应用 Logo
    │
    └── types/                                 # 类型定义
        ├── auto-imports.d.ts                  # 自动导入类型
        ├── env.d.ts                           # 环境变量类型
        ├── global.d.ts                        # 全局类型
        ├── uni-components.d.ts                # uni-app 组件类型
        ├── uni-mini-router.d.ts               # uni-mini-router 类型
        ├── uni-pages.d.ts                     # uni-app 页面类型
        └── wot-ui-component-shims.d.ts        # wot-ui 组件类型声明
│
├── components.d.ts                            # 组件自动导入类型
├── uni-pages.d.ts                             # uni-app 页面路由类型
└── theme.json                                 # uni-app 主题配置
```

---

## 三、页面路由总览

| 路由路径 | 页面 | TabBar | 说明 |
|---------|------|:---:|------|
| `/pages/index/index` | 首页 | ✅ | 数据概览+快捷入口 |
| `/pages/work/index` | 工作台 | ✅ | 业务功能入口 |
| `/pages/mine/index` | 我的 | ✅ | 个人中心 |
| `/pages/login/index` | 登录 | ❌ | 账号密码登录 |
| `/pages/webview/index` | WebView | ❌ | 内嵌网页 |
| `/pages/work/user/index` | 用户管理 | ❌ | 系统管理 |
| `/pages/work/role/index` | 角色管理 | ❌ | 系统管理 |
| `/pages/work/role/assign-perm` | 分配权限 | ❌ | 角色权限分配 |
| `/pages/work/menu/index` | 菜单管理 | ❌ | 系统管理 |
| `/pages/work/dept/index` | 部门管理 | ❌ | 系统管理 |
| `/pages/work/dict/index` | 字典管理 | ❌ | 系统管理 |
| `/pages/work/dict/item/index` | 字典项管理 | ❌ | 系统管理 |
| `/pages/work/config/index` | 系统配置 | ❌ | 系统管理 |
| `/pages/work/log/index` | 日志管理 | ❌ | 系统管理 |
| `/pages/work/monitor/index` | 系统监控 | ❌ | 系统管理 |
| `/pages/mine/profile/index` | 个人资料 | ❌ | 我的 |
| `/pages/mine/profile/complete-profile` | 完善资料 | ❌ | 我的 |
| `/pages/mine/account/index` | 账号管理 | ❌ | 我的 |
| `/pages/mine/about/index` | 关于 | ❌ | 我的 |
| `/pages/mine/official/index` | 关注公众号 | ❌ | 我的 |
| `/pages/mine/settings/index` | 设置 | ❌ | 我的 |
| `/pages/mine/settings/theme/index` | 主题设置 | ❌ | 设置 |
| `/pages/mine/settings/network/index` | 网络设置 | ❌ | 设置 |
| `/pages/mine/settings/privacy/index` | 隐私设置 | ❌ | 设置 |
| `/pages/mine/settings/agreement/index` | 用户协议 | ❌ | 设置 |

---

## 四、架构特点

1. **跨平台**: 基于 uni-app，支持 H5/微信小程序/App 多端编译
2. **Composition API**: 全量使用 Vue 3 Composition API + `<script setup>` 语法
3. **TypeScript**: 全量 TypeScript，类型安全
4. **TabBar 导航**: 三 Tab 设计（首页/工作台/我的），符合 PDA 操作习惯
5. **状态管理**: Pinia 模块化 Store（user/theme），支持持久化
6. **网络请求**: 基于 `uni.request` 封装，统一 Token 注入/错误处理/响应解构
7. **权限控制**: 路由守卫登录校验 + `permission.ts` 按钮权限
8. **主题切换**: 亮/暗主题，支持持久化存储
9. **图表可视化**: 集成 qiun-data-charts（ECharts + UCharts 双引擎），支持跨端渲染
10. **自定义导航栏**: `custom-navbar` 组件统一导航栏样式，支持自定义标题和返回行为
