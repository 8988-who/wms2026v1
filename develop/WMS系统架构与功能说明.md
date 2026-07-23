# WMS 仓储管理系统 - 系统架构与功能说明

> 文档版本：v1.0
> 最后更新：2026-07-21

---

## 一、系统概述

WMS（Warehouse Management System）仓储管理系统，基于 Youlai Boot 框架构建，实现了仓库空间结构的层级化管理（库区 → 巷道 → 点位），以及完整的 RBAC 权限控制系统。系统采用前后端分离架构，支持多厂区、多楼层、多区域的仓库管理场景。

### 1.1 核心业务价值

- **仓库空间数字化**：将物理仓库抽象为 库区(Location) → 巷道(Aisle) → 点位(Point) 三级空间结构
- **状态管控**：支持各级空间的独立启用/停用，以及级联状态变更
- **权限隔离**：基于厂区编码(plantCode)的数据权限隔离，确保不同厂区数据互不可见
- **编码自动化**：厂区编码+流水号的自动编码生成策略，无需人工维护

---

## 二、技术栈

### 2.1 后端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Java | 17 | 运行时环境 |
| Spring Boot | 4.0.5 | 应用框架 |
| Spring Security | 6.x (与 Boot 4 配套) | 认证与授权 |
| MyBatis-Plus | 3.5.15 | ORM 框架 |
| PostgreSQL | 15+ | 数据库 |
| Druid | 1.2.24 | 数据库连接池 |
| MapStruct | 1.6.3 | 对象映射 |
| Hutool | 5.8.41 | 工具库 |
| Knife4j | 4.5.0 | API 文档 |
| Redis | - | 缓存 |
| Redisson | 4.1.0 | 分布式锁 |
| Caffeine | 2.9.3 | 本地缓存 |
| MinIO / OSS | - | 对象存储 |
| XXL-Job | 3.2.0 | 分布式定时任务 |

### 2.2 前端技术栈

| 技术 | 版本 | 用途 |
|------|------|------|
| Vue | 3.5.38 | UI 框架 |
| TypeScript | - | 类型系统 |
| Vite | 6.x | 构建工具 |
| Element Plus | 2.14.2 | UI 组件库 |
| Pinia | 3.x | 状态管理 |
| Vue Router | 5.x | 路由管理 |
| Axios | 1.18.0 | HTTP 请求 |
| ECharts | 6.x | 图表可视化 |
| Vxe-Table | 4.6 | 表格增强组件 |

---

## 三、项目结构

### 3.1 整体结构

```
e:\wms20260712/
├── develop/                          # 开发文档与工具（当前文档所在目录）
│   ├── WMS系统架构与功能说明.md
│   ├── postgresql-migration-db-only-scripts.sql
│   └── ...
├── wms/                              # 后端项目 (Spring Boot)
│   └── youlai-boot/
│       └── src/main/java/com/youlai/boot/
│           ├── YouLaiBootApplication.java  # 启动类
│           ├── auth/                  # 认证模块
│           ├── system/                # 系统管理模块
│           ├── warehouse/             # 仓储管理模块（核心业务）
│           ├── codegen/               # 代码生成模块
│           ├── common/                # 公共基础设施
│           ├── framework/             # 框架基础设施
│           ├── file/                  # 文件服务
│           └── message/               # 消息推送
└── wmsui/                            # 前端项目 (Vue 3)
    └── vue3-element-admin/
        └── src/
            ├── api/                   # API 接口层
            ├── views/                 # 页面组件
            ├── router/                # 路由配置
            ├── stores/                # 状态管理
            ├── components/            # 公共组件
            ├── composables/           # 组合式函数
            ├── layouts/               # 布局组件
            └── utils/                 # 工具函数
```

### 3.2 后端模块说明

| 模块包 | 说明 | 核心职责 |
|--------|------|----------|
| `auth` | 认证中心 | 登录认证、Token 签发、OAuth2、微信小程序认证 |
| `system` | 系统管理 | 用户、角色、菜单、部门、字典、配置、日志、通知公告、租户管理 |
| `warehouse` | **仓储管理（核心）** | 库区/区域 → 巷道 → 点位 三级仓库空间管理 |
| `codegen` | 代码生成 | 基于数据库表结构自动生成 CRUD 代码 |
| `framework` | 基础设施 | 安全框架、缓存、验证码、短信/邮件、文件存储、数据权限 |
| `file` | 文件服务 | 本地存储 / MinIO / 阿里云 OSS 三种存储模式 |
| `message` | 消息推送 | SSE 服务端推送，用于在线用户数统计等 |

### 3.3 前端模块说明

| 目录 | 说明 |
|------|------|
| `api/` | 按业务模块划分的 API 封装，每个模块包含 `index.ts`（接口）+ `types.ts`（类型） |
| `views/` | 页面组件，与 api 目录结构对应 |
| `views/system/` | 系统管理页面（用户、角色、菜单、部门、字典、配置、日志、租户等） |
| `views/warehouse/` | **仓储管理页面（核心）**：库区管理、巷道管理、点位管理 |
| `views/dashboard/` | 仪表盘首页 |
| `views/codegen/` | 代码生成器页面 |
| `views/login/` | 登录页面 |
| `stores/permission.ts` | 动态路由生成（从后端菜单数据生成前端路由） |

---

## 四、核心业务模块：仓储管理 (WMS)

### 4.1 仓库空间结构

```
厂区 (Plant)
  └── 库区/区域 (WmsLocation)    → 物理仓库区域划分
        ├── 巷道 (WmsAisle)      → 货架之间的通道
        │     └── 点位 (WmsPoint)  → 具体的存储位置（库位号）
        ├── 巷道 (WmsAisle)
        └── ...
```

### 4.2 数据表结构

| 表名 | 实体 | 说明 | 核心字段 |
|------|------|------|----------|
| `wms_location` | WmsLocation | 库区/区域 | plant_code, location_code, location_name, location_type, floor, parent_id |
| `wms_aisle` | WmsAisle | 巷道 | plant_code, location_id, aisle_code, aisle_name, floor, point_count(冗余) |
| `wms_point` | WmsPoint | 点位 | plant_code, location_id, aisle_id, point_code, point_name |

### 4.3 编码规则

```
区域编码 : {plantCode}-{3位序号}     例: PLANT001-001
巷道编码 : {locationCode}-A{2位序号} 例: PLANT001-001-A01
点位编码 : {aisleCode}-P{3位序号}    例: PLANT001-001-A01-P001
```

编码生成策略采用**填补空号**算法：新增时从 1 开始查找未使用的序号，删除后空出的序号可被复用。

### 4.4 级联状态管理

```
停用 库区/区域 (WmsLocation)
  └── 自动停用 所有巷道 (WmsAisle)（通过 WmsCascadeService）
        └── 自动停用 所有点位 (WmsPoint)

新增巷道时校验：所属区域必须为启用状态
新增点位时校验：所属巷道必须为启用状态
修改上级时校验：目标上级必须为启用状态
```

级联逻辑通过独立的 `WmsCascadeService` 实现，直接操作 Mapper 层（而非 Service 层），避免了 Service 层循环依赖。

### 4.5 点位数量冗余

`wms_aisle.point_count` 字段维护每个巷道绑定的点位数量：
- 列表查询通过 SQL 子查询实时计算（始终准确）
- 点位新增/删除/更换巷道时通过 Java 代码同步更新存储值
- 双机制保证数据一致性

---

## 五、系统管理模块

### 5.1 RBAC 权限体系

```
用户 (User) ─── 角色 (Role) ─── 菜单 (Menu) ─── API/页面权限
```

| 模块 | 说明 |
|------|------|
| **用户管理** | 系统用户管理，支持导入、部门归属 |
| **角色管理** | 角色定义及权限分配 |
| **菜单管理** | 菜单树管理，支持按钮级权限标识 |
| **部门管理** | 组织架构管理 |
| **字典管理** | 系统字典项维护 |
| **参数配置** | 系统配置参数管理 |
| **操作日志** | 用户操作日志记录与查询 |
| **通知公告** | 系统通知公告发布 |

### 5.2 权限标识规则

```
{模块}:{资源}:{操作}
     │       │      │
  warehouse  wms-location  list / create / update / delete
  warehouse  wms-aisle     list / create / update / delete
  warehouse  wms-point     list / create / update / delete
  sys        user          list / create / update / delete
  sys        role          list / create / update / delete
```

### 5.3 数据权限隔离

基于厂区编码 (`plantCode`) 的数据权限：
- 通过 MyBatis 拦截器注入数据权限 SQL
- 仓储模块的所有实体均包含 `plantCode` 字段
- 不同厂区用户仅能看到本厂区数据

---

## 六、认证与安全

### 6.1 认证流程

```
用户登录 → AuthController → 校验账号密码 → 签发 JWT Token → 前端存储 Token
  → 后续请求携带 Token → Security 过滤器链验证 → 获取用户身份与权限
```

### 6.2 安全特性

- **JWT Token 认证**：无状态认证，支持 Token 过期与刷新
- **RBAC 权限控制**：方法级 `@PreAuthorize` 注解 + 前端 `v-hasPerm` 指令
- **验证码支持**：登录验证码保护
- **防重复提交**：`@RepeatSubmit` 注解
- **接口限流**：`@RateLimit` 注解
- **操作日志记录**：`@Log` 注解
- **数据权限过滤**：MyBatis 拦截器自动注入数据权限条件

---

## 七、前端架构

### 7.1 路由机制

```
静态路由 → 登录 → 从后端获取菜单数据 → 解析为 Vue Router 路由 → 动态注册
```

- 静态路由（`router/index.ts`）：登录页、仪表盘、错误页面等基础路由
- 动态路由（`stores/permission.ts`）：业务页面路由全部由后端菜单表管理
- 组件解析（`resolveComponent`）：通过 `import.meta.glob` 动态扫描 `views/` 下的 `.vue` 文件

### 7.2 页面模板

标准 CRUD 页面结构：

```
┌─────────────────────────────────────────────────┐
│  搜索条件栏（状态/厂区/关键字等）                  │
├─────────────────────────────────────────────────┤
│  工具栏（新增 | 批量操作 ▼ | 刷新 | 全屏）        │
├─────────────────────────────────────────────────┤
│  ┌───────────────────────────────────────────┐ │
│  │  表格数据（列表展示 + 分页）              │ │
│  └───────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### 7.3 通用功能

| 功能 | 实现方式 |
|------|----------|
| `usePageTable` | 组合式函数，提供分页查询、搜索、重置能力 |
| `useTableSelection` | 组合式函数，提供表格多选能力 |
| `v-hasPerm` | 自定义指令，按钮级权限控制 |
| `el-dropdown` | 批量操作下拉菜单（启用/停用/删除） |
| 动态路由生成 | 后端菜单管理 → 前端自动注册路由和菜单树 |

---

## 八、API 接口清单

### 8.1 仓储管理接口

| 模块 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 库区 | GET | `/api/v1/wms-location` | 库区分页列表 |
| 库区 | POST | `/api/v1/wms-location` | 新增库区 |
| 库区 | PUT | `/api/v1/wms-location/{id}` | 修改库区 |
| 库区 | DELETE | `/api/v1/wms-location/{ids}` | 删除库区 |
| 库区 | PUT | `/api/v1/wms-location/status` | 批量更新库区状态 |
| 库区 | GET | `/api/v1/wms-location/{id}/form` | 获取库区表单数据 |
| 库区 | GET | `/api/v1/wms-location/filter-options` | 获取搜索下拉选项 |
| 巷道 | GET | `/api/v1/wms-aisle` | 巷道分页列表 |
| 巷道 | POST | `/api/v1/wms-aisle` | 新增巷道 |
| 巷道 | PUT | `/api/v1/wms-aisle/{id}` | 修改巷道 |
| 巷道 | DELETE | `/api/v1/wms-aisle/{ids}` | 删除巷道 |
| 巷道 | PUT | `/api/v1/wms-aisle/status` | 批量更新巷道状态 |
| 巷道 | GET | `/api/v1/wms-aisle/{id}/form` | 获取巷道表单数据 |
| 巷道 | GET | `/api/v1/wms-aisle/form-options` | 获取表单下拉选项 |
| 点位 | GET | `/api/v1/wms-point` | 点位分页列表 |
| 点位 | POST | `/api/v1/wms-point` | 新增点位 |
| 点位 | PUT | `/api/v1/wms-point/{id}` | 修改点位 |
| 点位 | DELETE | `/api/v1/wms-point/{ids}` | 删除点位 |
| 点位 | PUT | `/api/v1/wms-point/status` | 批量更新点位状态 |
| 点位 | GET | `/api/v1/wms-point/{id}/form` | 获取点位表单数据 |
| 点位 | GET | `/api/v1/wms-point/form-options` | 获取表单下拉选项 |
| 点位 | GET | `/api/v1/wms-point/filter-options` | 获取搜索筛选选项 |

### 8.2 系统管理接口

| 模块 | 路径前缀 | 说明 |
|------|----------|------|
| 认证 | `/api/v1/auth` | 登录、登出、Token 刷新 |
| 用户 | `/api/v1/users` | 用户 CRUD + 导入导出 |
| 角色 | `/api/v1/roles` | 角色 CRUD + 权限分配 |
| 菜单 | `/api/v1/menus` | 菜单 CRUD + 路由获取 |
| 部门 | `/api/v1/depts` | 部门 CRUD |
| 字典 | `/api/v1/dicts` | 字典 CRUD |
| 配置 | `/api/v1/configs` | 系统配置 CRUD |
| 通知 | `/api/v1/notices` | 通知公告 CRUD |
| 日志 | `/api/v1/logs` | 操作日志查询 |
| 文件 | `/api/v1/files` | 文件上传/下载 |

---

## 九、部署说明

### 9.1 环境要求

| 组件 | 版本要求 |
|------|----------|
| JDK | 17+ |
| Node.js | 18+ |
| PostgreSQL | 15+ |
| Redis | 6+ |
| MinIO (可选) | - |

### 9.2 启动方式

**后端启动：**

```bash
cd wms/youlai-boot
mvn clean compile -DskipTests   # 编译
mvn spring-boot:run              # 启动开发服务器
```

**前端启动：**

```bash
cd wmsui/vue3-element-admin
pnpm install                     # 安装依赖
pnpm run dev                     # 启动开发服务器
```

### 9.3 配置文件

- 后端配置：`application.yml` + `application-dev.yml` / `application-prod.yml`
- 数据库连接、Redis 配置、文件存储配置等均在对应 profile 配置文件中

---

## 十、数据库实体关系

```
wms_location (库区/区域)
├── id (PK)
├── plant_code (厂区编码，数据权限隔离字段)
├── location_code (区域编码，自动生成)
├── location_name (区域名称)
├── location_type (区域类型: TURNOVER/DRY_ZONE/DRY_ROOM/BUFFER/PROD_LINE)
├── parent_id (父级区域ID)
├── floor (楼层)
├── sort_order (排序号)
├── status (状态: 0-停用, 1-启用)
└── ...

wms_aisle (巷道)
├── id (PK)
├── plant_code (厂区编码)
├── location_id (FK → wms_location.id)
├── aisle_code (巷道编码，自动生成)
├── aisle_name (巷道名称)
├── floor (楼层)
├── point_count (冗余字段，点位数量)
├── status (状态)
└── ...

wms_point (点位)
├── id (PK)
├── plant_code (厂区编码)
├── location_id (FK → wms_location.id)
├── aisle_id (FK → wms_aisle.id)
├── point_code (点位编码，自动生成)
├── point_name (点位名称)
├── point_type (点位类型)
├── status (状态)
└── ...
```

---

## 十一、常见问题 FAQ

**Q: 为什么 wms-location 的 后端 API 路径是 `/api/v1/wms-location`，但前端文件放在了 `warehouse/` 目录？**

A: 后端严格按照业务模块组织，`WmsLocationController` 属于 `warehouse` 包。前端最初将其放在了 `system/` 目录下，现已统一迁移到 `warehouse/` 目录，与巷道、点位管理保持一致。

**Q: 级联停用是如何实现的？**

A: 通过独立的 `WmsCascadeService` 实现。该服务直接注入 `WmsAisleMapper` 和 `WmsPointMapper`（底层 Mapper），使用 SQL UPDATE 进行批量状态更新，不经过 Service 层，避免了循环依赖。

**Q: 计算点位数量的机制是什么？**

A: 双机制：1）列表查询时通过 `(SELECT COUNT(*) FROM wms_point WHERE aisle_id = a.id)` 子查询实时计算，保证数据准确性；2）点位新增/删除/更换巷道时，通过 Java 代码同步更新 `wms_aisle.point_count` 字段，保证冗余字段值及时更新。
