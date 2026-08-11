# 仓库管理模块（warehouse）

## 1. 模块概述

仓库基础数据模块，维护 **厂区 → 库位/区域 → 巷道 → 点位** 的仓储空间层级档案，是上架/出库作业与 AGV 调度（RCS 任务的起点/终点点位）的基础数据。包含三个页面（逐级递进）：

- **库位/区域（wms-location）**：区域档案，含厂区编码、区域类型（TURNOVER / DRY_ZONE / DRY_ROOM / BUFFER / PROD_LINE 等）、父级区域（`parentId` 树形结构，0 表示顶级）、楼层；
- **巷道（wms-aisle）**：挂在区域之下，编码由系统按「区域编码-A序号」自动生成（前端只读展示），含巷道用途（满架优先 FULL / 空架优先 EMPTY / 混合 MIXED）、是否交接点（`isHandoverPoint`）、关联点位数量（`pointCount`）等；
- **点位（wms-point）**：挂在巷道之下，编码由系统按「巷道编码-P序号」自动生成（前端只读展示），含点位条码（PDA/AGV 扫码识别用）、地图坐标（X/Y/Z），供 RCS 调度任务 `from_location / to_location` 引用。

后端对应 `WmsLocationController / WmsAisleController / WmsPointController`（`/api/v1/wms-location`、`/api/v1/wms-aisle`、`/api/v1/wms-point`），三张表通过 `locationId` / `aisleId` 逐级外键关联；权限标识分别为 `warehouse:wms-location:*`、`warehouse:wms-aisle:*`、`warehouse:wms-point:*`。

## 2. 页面与路由

页面路由为**动态路由**：后端菜单表下发菜单，`stores/permission.ts` 通过 `import.meta.glob("../views/**/*.vue")` 按菜单 `component` 字段映射到 views 下的组件文件。

| 路由路径 | 页面组件 | 功能概述 |
|---------|---------|---------|
| `/warehouse/wms-location` | [wms-location/index.vue](../../wmsui/src/views/warehouse/wms-location/index.vue) | 库位/区域管理：分页列表、厂区→楼层→区域编码三级级联筛选、新增/编辑/删除、批量启用/停用 |
| `/warehouse/wms-aisle` | [wms-aisle/index.vue](../../wmsui/src/views/warehouse/wms-aisle/index.vue) | 巷道管理：分页列表、按巷道/区域编码与巷道用途筛选、新增/编辑/删除、批量启用/停用 |
| `/warehouse/wms-point` | [wms-point/index.vue](../../wmsui/src/views/warehouse/wms-point/index.vue) | 点位管理：分页列表、按点位/区域/巷道编码与条码、坐标筛选、新增/编辑/删除、批量启用/停用 |

## 3. 后端接口

三个子模块接口形态完全一致（REST 资源式）：`GET /` 分页、`POST /` 新增、`GET /{id}/form` 回显、`PUT /{id}` 修改、`DELETE /{ids}` 批量删除、`PUT /status` 批量状态、`GET /form-options` 表单下拉、`GET /filter-options` 搜索下拉；仅 filter-options 的参数与返回结构不同。

### 3.1 wms-location（库位/区域）— [index.ts](../../wmsui/src/api/warehouse/wms-location/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/wms-location` | 分页列表，返回 `PageResult<WmsLocationItem>` |
| `getFormData` | GET `/api/v1/wms-location/{id}/form` | 编辑弹窗回显 |
| `create` | POST `/api/v1/wms-location` | 新增区域 |
| `update` | PUT `/api/v1/wms-location/{id}` | 修改区域 |
| `deleteByIds` | DELETE `/api/v1/wms-location/{ids}` | 批量删除，多个 ID 以英文逗号拼接 |
| `updateStatus` | PUT `/api/v1/wms-location/status` | 批量启用/停用，body `{ ids: number[]; status: number }` |
| `getFilterOptions` | GET `/api/v1/wms-location/filter-options?plantCode&floor` | 搜索下拉（厂区/楼层/区域编码/更新人），**支持厂区→楼层级联参数**，返回 `{ plantCodes, locationCodes, floors, updatedByNames, statuses }` |
| `getFormOptions` | GET `/api/v1/wms-location/form-options` | 表单下拉（厂区编码、区域类型），返回 `{ plantCodes, locationTypes }` |

### 3.2 wms-aisle（巷道）— [index.ts](../../wmsui/src/api/warehouse/wms-aisle/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/wms-aisle` | 分页列表，返回 `PageResult<WmsAisleItem>` |
| `getFormData` | GET `/api/v1/wms-aisle/{id}/form` | 编辑弹窗回显 |
| `create` | POST `/api/v1/wms-aisle` | 新增巷道 |
| `update` | PUT `/api/v1/wms-aisle/{id}` | 修改巷道 |
| `deleteByIds` | DELETE `/api/v1/wms-aisle/{ids}` | 批量删除 |
| `updateStatus` | PUT `/api/v1/wms-aisle/status` | 批量启用/停用 |
| `getFormOptions` | GET `/api/v1/wms-aisle/form-options` | 表单下拉（厂区编码、所属区域），返回 `WmsAisleFormOptions { plantCodes, locations }` |
| `getFilterOptions` | GET `/api/v1/wms-aisle/filter-options` | 搜索下拉（巷道编码/区域编码），返回 `Record<string, string[]>` |

### 3.3 wms-point（点位）— [index.ts](../../wmsui/src/api/warehouse/wms-point/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/wms-point` | 分页列表，返回 `PageResult<WmsPointItem>` |
| `getFormData` | GET `/api/v1/wms-point/{id}/form` | 编辑弹窗回显 |
| `create` | POST `/api/v1/wms-point` | 新增点位 |
| `update` | PUT `/api/v1/wms-point/{id}` | 修改点位 |
| `deleteByIds` | DELETE `/api/v1/wms-point/{ids}` | 批量删除 |
| `updateStatus` | PUT `/api/v1/wms-point/status` | 批量启用/停用，body 为 `WmsPointBatchStatusForm { ids, status }` |
| `getFormOptions` | GET `/api/v1/wms-point/form-options` | 表单下拉（厂区/区域/巷道三级），返回 `WmsPointFormOptions { plantCodes, locations, aisles }` |
| `getFilterOptions` | GET `/api/v1/wms-point/filter-options` | 搜索下拉（点位/区域/巷道编码），返回 `Record<string, string[]>` |

### 3.4 关键 types 概述（[types.ts](../../wmsui/src/api/warehouse/wms-point/types.ts) 等）

三个子模块类型结构同构，均继承 `@/api/common` 的 `BaseQueryParams`（`pageNum` / `pageSize` / 排序字段）：

| 类型 | 关键字段 | 说明 |
|------|---------|------|
| `WmsLocationQueryParams` | plantCode、locationCode、locationName、floor、updatedBy、status | 分页查询参数，含级联筛选字段 |
| `WmsLocationForm` | id、plantCode、locationCode、locationName、locationType、parentId、floor、sortOrder、status、remark | 表单对象；`locationCode` 由后端自动生成，前端禁用只读 |
| `WmsLocationItem` | Form 字段 + createdByName / createdTime / updatedByName / updatedTime | 列表项（含审计人名字段） |
| `WmsAisleQueryParams` | plantCode、aisleCode、aisleName、floor、locationCode、aislePurpose、status | 巷道查询参数 |
| `WmsAisleForm` | id、plantCode、locationId、aisleCode、aisleName、floor、sortOrder、status、remark、aislePurpose、isHandoverPoint | 巷道表单；`aisleCode` 自动生成、`floor` 由所选区域回填 |
| `WmsAisleItem` | Form 字段 + locationCode、pointCount、审计字段 | 列表项；`pointCount` 为关联点位数量 |
| `WmsAisleLocationOption` / `WmsAisleFormOptions` | `{ id, code, name, floor, label }[]` | 区域下拉选项及表单选项包 |
| `WmsPointQueryParams` | plantCode、pointCode、pointName、barcode、coordinate、floor、locationCode、aisleCode、status、aisleId | 点位查询参数 |
| `WmsPointForm` | id、plantCode、locationId、aisleId、pointCode、pointName、barcode、coordinate、floor、sortOrder、status、remark | 点位表单；`pointCode` 自动生成、`floor` 自动回填 |
| `WmsPointItem` | Form 字段 + locationCode、locationName、aisleCode、aisleName、审计字段 | 列表项（冗余区域/巷道编码名称便于展示） |
| `WmsPointLocationOption` / `WmsPointAisleOption` / `WmsPointFormOptions` | `{ id, code, name, floor, label }` / `{ id, code, name, locationId, label }` / 三者汇总 | 表单三级联动下拉选项 |
| `WmsPointBatchStatusForm` | ids、status | 批量状态更新请求体 |

## 4. 文件清单

### 4.1 库位/区域（wms-location）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [wms-location/index.vue](../../wmsui/src/views/warehouse/wms-location/index.vue) | 库位/区域分页管理页（搜索+表格+弹窗表单） | `@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh / ArrowDown）；`@/composables`（usePageTable / useTableSelection）；`@/api/warehouse/wms-location`（WmsLocationAPI + 类型） | ① 搜索区「厂区编码→楼层→区域编码」三级级联：`handlePlantCodeChange` / `handleFloorChange` 重置下级值并带参重调 `getFilterOptions(plantCode, floor)`；② 工具栏「批量操作」下拉（启用/停用/删除），按 `v-hasPerm` 控制；③ 表单中 `locationCode` 输入框 `readonly disabled`（系统自动生成）、`parentId` 数字输入（0 为顶级）；④ 状态列 `el-tag`（开启 success / 关闭 info）；⑤ 新增/编辑复用同一弹窗，提交按 `formData.id` 分流 create/update |
| [wms-location/index.ts](../../wmsui/src/api/warehouse/wms-location/index.ts) | 库位/区域接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 8 个接口函数；`deleteByIds` 把逗号拼接 ID 放入 URL 路径；`getFilterOptions` 带 plantCode/floor 可选参数；末尾 `export * from "./types"` 重导出 |
| [wms-location/types.ts](../../wmsui/src/api/warehouse/wms-location/types.ts) | 库位/区域类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Item / Detail 四类；`WmsLocationDetail = WmsLocationItem & WmsLocationForm` |

### 4.2 巷道（wms-aisle）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [wms-aisle/index.vue](../../wmsui/src/views/warehouse/wms-aisle/index.vue) | 巷道分页管理页 | `vue`（ref / reactive / onMounted）；`@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh / ArrowDown）；`@/composables`（usePageTable / useTableSelection）；`@/api/warehouse/wms-aisle`（WmsAisleAPI + 类型） | ① 搜索按巷道编码/区域编码（`getFilterOptions` 下拉）与巷道用途（FULL/EMPTY/MIXED 静态选项）筛选；② 表单「厂区编码→所属区域」级联：`handleFormPlantCodeChange` 按 `loc.code.startsWith(plantCode)` 过滤 `filteredLocations`，`handleFormLocationChange` 由所选区域回填 `floor`；③ `aisleCode` 只读（系统自动生成「区域编码-A序号」）、`floor` 只读自动获取；④ 「巷道用途」列三色 tag（FULL 红 / EMPTY 橙 / MIXED 绿）、交接点列 tag（是/否）、`pointCount` 点位数量列；⑤ `handleBatchClick` 在无选中时自动 `toggleAllSelection()` 全选当前页再展开批量操作 |
| [wms-aisle/index.ts](../../wmsui/src/api/warehouse/wms-aisle/index.ts) | 巷道接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 8 个接口函数，与 wms-location 同构；`getFormOptions` 返回 `WmsAisleFormOptions`；`getFilterOptions` 返回 `Record<string, string[]>`；重导出类型 |
| [wms-aisle/types.ts](../../wmsui/src/api/warehouse/wms-aisle/types.ts) | 巷道类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Item / LocationOption / FormOptions；`aislePurpose`（FULL/EMPTY/MIXED）、`isHandoverPoint`、`pointCount` 为巷道特有字段 |

### 4.3 点位（wms-point）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [wms-point/index.vue](../../wmsui/src/views/warehouse/wms-point/index.vue) | 点位分页管理页 | `vue`（ref / reactive / onMounted）；`@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh / ArrowDown）；`@/composables`（usePageTable / useTableSelection）；`@/api/warehouse/wms-point`（WmsPointAPI + 类型） | ① 搜索按点位/区域/巷道编码下拉与条码、地图坐标输入筛选；② 表单「厂区→区域→巷道」**三级联动**（详见 §5.3）；③ `pointCode` 只读（系统自动生成「巷道编码-P序号」）、`floor` 只读自动获取；④ 点位条码/地图坐标 placeholder 提示 PDA/AGV 扫码与 X/Y/Z 坐标格式；⑤ 列表展示区域/巷道冗余字段（locationName / aisleName），编辑时按回显值预过滤两级下拉 |
| [wms-point/index.ts](../../wmsui/src/api/warehouse/wms-point/index.ts) | 点位接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 8 个接口函数，与 wms-location 同构；`getFormOptions` 返回 `WmsPointFormOptions`（含 locations + aisles 供三级联动）；重导出类型（含 LocationOption / AisleOption） |
| [wms-point/types.ts](../../wmsui/src/api/warehouse/wms-point/types.ts) | 点位类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Item / LocationOption / AisleOption / FormOptions / BatchStatusForm；`WmsPointItem` 冗余 `locationCode/locationName/aisleCode/aisleName` 便于列表直接展示 |

## 5. 核心实现逻辑

### 5.1 列表分页 / 搜索 / 重置链路（三个页面共用模式）

所有页面统一使用 `@/composables` 的 `usePageTable<T, Q>` 与 `useTableSelection<T>`：

```
onMounted ──► loadFilterOptions()（搜索下拉）+ handleQuery()
handleQuery ──► params.pageNum = 1 ──► fetchData() ──► request(params) 请求 getPage
handleResetQuery ──► onBeforeReset()（queryFormRef.resetFields()）──► resetParams() 恢复 initialParams ──► fetchData()
pagination 组件 v-model:total/page/limit ──► @pagination="fetchData"
```

- `usePageTable` 只管理 loading / list / total / params 与请求回填，不碰勾选与弹窗；`fetchData` 返回 `data.list` / `data.total` 直接回填。
- `useTableSelection` 提供 `selectedIds` / `hasSelection` / `handleSelectionChange`；批量操作前校验 `hasSelection` 为空则 `ElMessage.warning` 提示。
- 全屏：`useFullscreen(tableWrapperRef)` 的 `toggle` 绑定工具栏 FullScreen 图标按钮。

### 5.2 新增 / 编辑 / 删除 / 批量状态链路（三个页面共用模式）

```
新增  handleCreateClick ──► dialog.title="新增…" ──► (可选) loadFormOptions() ──► openDialog()
编辑  handleEditClick(id) ──► await API.getFormData(id) ──► Object.assign(formData, data)（按回显值预过滤级联下拉）──► openDialog()
提交  handleSubmit ──► dataFormRef.validate() 通过后按 formData.id 分流：
        id 存在 → API.update(id, formData)  否则 → API.create(formData)
      ──► ElMessage.success ──► closeDialog() ──► handleQuery() 刷新
删除  handleDelete(id?) ──► ElMessageBox.confirm("警告") ──► API.deleteByIds(单条id或selectedIds.join(",")) ──► handleQuery()
批量  handleBatchCommand(command) 分派 enable/disable/delete：
        enable/disable → ElMessageBox.confirm ──► API.updateStatus({ ids, status }) ──► handleQuery()
```

- 编辑弹窗数据回填用 `getFormData`（`/{id}/form` 接口），而非直接用行数据，保证下拉选项上下文一致。
- 权限：新增/编辑/删除/批量按钮分别挂 `v-hasPerm` 指令（如 `warehouse:wms-location:create`）。
- 表单校验规则集中在 `rules: FormRules`（必填 + blur/change 触发），提交前统一 `validate()`。

### 5.3 特有交互

**① wms-location 搜索三级级联（厂区→楼层→区域编码）**
- `getFilterOptions(plantCode, floor)` 支持带参级联：不传参返回全部厂区+楼层，传厂区返回该厂区楼层+区域编码，再传楼层返回该楼层区域编码。
- `handlePlantCodeChange`：重置 `params.floor` 与 `params.locationCode`，以新厂区重载楼层/区域选项；
- `handleFloorChange`：重置 `params.locationCode`，以厂区+楼层重载区域选项；
- 厂区编码选项只在首次/重置时全量刷新，避免级联选择时被覆盖。

**② wms-aisle 表单厂区→区域联动 + 楼层自动回填**
- 选厂区：`filteredLocations = locations.filter(loc => loc.code?.startsWith(plantCode))`；
- 选区域：`formData.floor = selectedLoc.floor`（只读回填）；
- `handleBatchClick`：未勾选时先 `dataTableRef.toggleAllSelection()` 全选当前页，方便整页批量操作。

**③ wms-point 表单三级联动（厂区→区域→巷道）与编码联动展示**
- 选厂区：重置 `locationId`、`aisleId`，过滤区域列表；
- 选区域：重置 `aisleId`，过滤巷道列表（`aisle.locationId === selectedId`）并回填 `floor`；
- 选巷道：反查区域 `loc.id === selected.locationId` 回填 `floor`，并由区域编码 `loc.code.split('-')[0]` **反推厂区编码** `plantCode`（编码规则「厂区编码-…」的联动展示）；
- `pointCode` 输入框禁用只读，placeholder 提示「系统自动生成（巷道编码-P序号）」，与后端编码规则呼应。

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| Vue 3.5 + `<script setup>` + TypeScript | 页面组件与类型安全 |
| Element Plus | `el-table` / `el-form` / `el-dialog` / `el-select` / `el-tag` / `el-dropdown` / `el-button` / `ElMessage` / `ElMessageBox` |
| `@element-plus/icons-vue` | FullScreen / Refresh / ArrowDown 图标 |
| `@vueuse/core` `useFullscreen` | 表格卡片全屏切换 |
| `@/composables` `usePageTable` / `useTableSelection` | 分页查询状态与行多选状态复用 |
| `@/utils/request`（axios 封装） | 统一 HTTP 请求（baseURL `/api/v1` 前缀拼接） |
| 自定义指令 `v-hasPerm` | 按钮级权限控制（warehouse:wms-location / wms-aisle / wms-point 的 create/update/delete） |
| 动态路由 + `import.meta.glob` | 后端菜单表下发路由映射到 views 组件 |
| `pagination` 全局组件 | 分页条（v-model:total/page/limit + @pagination） |
