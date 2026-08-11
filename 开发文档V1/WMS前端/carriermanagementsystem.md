# 载具管理模块（carriermanagementsystem）

## 1. 模块概述

载具（料车）全生命周期管理模块，覆盖 **料车型号 → 料车 → 料车装载明细** 三层业务：

- **料车型号（cart-model）**：定义料车规格档案（型号代码、名称、最大装载数量、层数），型号被料车引用；列表展示关联料车数（`cartCount`）。
- **料车（cart）**：实物料车台账，绑定型号（继承 `maxCapacity` 有效容量），记录所在区域、绑定操作工、实际容量、装载状态（空闲/使用中/已满载/维修）；支持一键批量标记状态，并提供「可用料车列表」接口供装载页面下拉选用。
- **料车物品/装载明细（cart-item）**：料车装了什么货（条码、型号、批次号、层号、装货顺序），核心业务为 **装车（create）→ 取走（take/batchTake）** 流程闭环：装车后记录 `loadedAt` 与 `operator`，状态 1「在车」；取走后记录 `takenAt`，状态 2「已取走」；仅已取走记录允许删除。

后端对应 `CartModelController / CartController / CartItemController`（`/api/v1/cart-model`、`/api/v1/cart`、`/api/v1/cart-item`），料车与型号通过 `modelId` 关联，装载明细与料车通过 `cartId` 关联；权限标识分别为 `carriermanagementsystem:cart-model:*`、`carriermanagementsystem:cart:*`、`carriermanagementsystem:cart-item:*`。

## 2. 页面与路由

页面路由为**动态路由**：后端菜单表下发菜单，`stores/permission.ts` 通过 `import.meta.glob("../views/**/*.vue")` 按菜单 `component` 字段映射到 views 下的组件文件。

| 路由路径 | 页面组件 | 功能概述 |
|---------|---------|---------|
| `/carriermanagementsystem/cart-model` | [cart-model/index.vue](../../wmsui/src/views/carriermanagementsystem/cart-model/index.vue) | 料车型号配置：分页列表（含关联料车数）、新增/编辑/删除 |
| `/carriermanagementsystem/cart` | [cart/index.vue](../../wmsui/src/views/carriermanagementsystem/cart/index.vue) | 料车管理：分页列表、按关键词/状态/型号/区域筛选、新增/编辑/删除、批量标记状态（使用中/空闲/维修） |
| `/carriermanagementsystem/cart-item` | [cart-item/index.vue](../../wmsui/src/views/carriermanagementsystem/cart-item/index.vue) | 料车物品管理：装车/取走/批量取走/删除（仅已取走）、装车时间区间筛选、装货顺序展示 |

## 3. 后端接口

### 3.1 cart-model（料车型号）— [index.ts](../../wmsui/src/api/carriermanagementsystem/cart-model/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/cart-model` | 分页列表，返回 `PageResult<CartModelItem>` |
| `getFormData` | GET `/api/v1/cart-model/{id}/form` | 编辑弹窗回显 |
| `create` | POST `/api/v1/cart-model` | 新增型号 |
| `update` | PUT `/api/v1/cart-model/{id}` | 修改型号 |
| `deleteByIds` | DELETE `/api/v1/cart-model/{ids}` | 批量删除 |
| `getFormOptions` | GET `/api/v1/cart-model/form-options` | 表单下拉，返回 `CartModelItem[]` |
| `getFilterOptions` | GET `/api/v1/cart-model/filter-options` | 搜索下拉，返回 `CartModelItem[]` |

### 3.2 cart（料车）— [index.ts](../../wmsui/src/api/carriermanagementsystem/cart/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/cart` | 分页列表，返回 `PageResult<CartItem>` |
| `getFormData` | GET `/api/v1/cart/{id}/form` | 编辑弹窗回显 |
| `create` | POST `/api/v1/cart` | 新增料车 |
| `update` | PUT `/api/v1/cart/{id}` | 修改料车 |
| `deleteByIds` | DELETE `/api/v1/cart/{ids}` | 批量删除 |
| `batchUpdateStatus` | PUT `/api/v1/cart/batch-status?status={status}` | 批量修改料车状态，body 为 `number[]`（ids） |
| `getFormOptions` | GET `/api/v1/cart/form-options` | 表单下拉（型号列表），返回 `CartModelOption[]` |
| `getFilterOptions` | GET `/api/v1/cart/filter-options` | 搜索下拉（型号列表），返回 `CartModelOption[]` |
| `getAreas` | GET `/api/v1/cart/areas` | 区域列表（搜索筛选下拉），返回 `string[]` |
| `getAvailableCarts` | GET `/api/v1/cart/available` | 可用料车列表（供装载页/接口选用） |

### 3.3 cart-item（料车物品）— [index.ts](../../wmsui/src/api/carriermanagementsystem/cart-item/index.ts)

| API 函数名 | HTTP 方法与路径 | 说明 |
|-----------|----------------|------|
| `getPage` | GET `/api/v1/cart-item` | 分页列表，返回 `PageResult<CartItemRecord>` |
| `create` | POST `/api/v1/cart-item` | **装车**（新增明细），body `CartItemForm` |
| `update` | PUT `/api/v1/cart-item/{id}` | 修改明细（仅「在车」记录可编辑） |
| `getFormData` | GET `/api/v1/cart-item/{id}/form` | 编辑弹窗回显 |
| `deleteByIds` | DELETE `/api/v1/cart-item/{ids}` | 删除记录（仅「已取走」记录允许） |
| `take` | PUT `/api/v1/cart-item/{id}/take` | **取走单件物品** |
| `batchTake` | PUT `/api/v1/cart-item/batch-take` | **批量取走物品**，body `number[]`（ids） |
| `getByCartId` | GET `/api/v1/cart-item/by-cart/{cartId}` | 按料车 ID 查询明细，返回 `CartItemRecord[]` |
| `getFormOptions` | GET `/api/v1/cart-item/form-options` | 表单下拉（可用料车列表），返回 `AvailableCart[]` |
| `getFilterOptions` | GET `/api/v1/cart-item/filter-options` | 搜索下拉，返回 `string[]` |

### 3.4 关键 types 概述

| 类型 | 关键字段 | 说明 |
|------|---------|------|
| `CartModelQueryParams` | modelCode、modelName、keyword | 型号查询参数（均继承 `BaseQueryParams`） |
| `CartModelForm` | id、modelCode、modelName、maxCapacity、layerCount、remark | 型号表单 |
| `CartModelItem` | Form 字段 + **cartCount**（关联料车数）+ 审计字段 | 型号列表项 |
| `CartQueryParams` | keyword（料车编号/操作工）、status、modelId、area | 料车查询参数 |
| `CartForm` | id、cartCode、modelId、area、bindWorker、actualCapacity | 料车表单；`actualCapacity` 留空则用型号默认容量 |
| `CartItem` | Form 字段 + modelCode、modelName、maxCapacity、currentQuantity、status、审计字段 | 料车列表项；`status`：1 空闲 / 2 使用中 / 3 已满载 / 4 维修 |
| `CartModelOption` | id、modelCode、modelName、maxCapacity | 型号下拉选项（料车页复用） |
| `CartItemQueryParams` | cartId、cartCode、productCode、productModel、batchNo、status、layerNo、operator、**loadedAtStart / loadedAtEnd**、keyword | 装载明细查询参数，含装车时间区间 |
| `CartItemForm` | id、cartId、productCode、productModel、sortOrder、batchNo、layerNo、operator、remark | 装车表单；`sortOrder` 装货顺序 |
| `CartItemRecord` | Form 字段 + cartCode、cartStatus、status（1 在车 / 2 已取走）、loadedAt、takenAt、审计字段 | 明细列表项 |
| `AvailableCart` | id、cartCode、currentQuantity、status | 可用料车选项（装载页下拉） |

## 4. 文件清单

### 4.1 料车型号（cart-model）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [cart-model/index.vue](../../wmsui/src/views/carriermanagementsystem/cart-model/index.vue) | 料车型号分页管理页 | `vue`（ref / reactive / onMounted）；`@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh）；`@/composables`（usePageTable）；`@/api/carriermanagementsystem/cart-model`（CartModelAPI + 类型） | ① 搜索按型号代码/名称/关键词；② 列表含 `cartCount`「关联料车」列与 `remark` 溢出省略（show-overflow-tooltip）；③ 无批量操作（仅新增/编辑/删除），本页未用 useTableSelection；④ 表单 `maxCapacity` / `layerCount` 用 `el-input-number`（1–9999 / 1–99）；⑤ 提交按 `formData.id` 分流 create/update，成功后 `handleQuery()` 刷新 |
| [cart-model/index.ts](../../wmsui/src/api/carriermanagementsystem/cart-model/index.ts) | 料车型号接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 7 个接口函数；`getFormOptions` / `getFilterOptions` 均返回 `CartModelItem[]`；重导出类型 |
| [cart-model/types.ts](../../wmsui/src/api/carriermanagementsystem/cart-model/types.ts) | 料车型号类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Item 三类；`cartCount` 为列表聚合字段 |

### 4.2 料车（cart）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [cart/index.vue](../../wmsui/src/views/carriermanagementsystem/cart/index.vue) | 料车分页管理页 | `vue`（ref / reactive / onMounted）；`@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh）；`@/composables`（usePageTable）；`@/api/carriermanagementsystem/cart`（CartAPI + 类型） | ① 搜索：关键词（料车编号/操作工）、状态（1–4）、型号（下拉）、区域（`getAreas` 下拉）；② `loadOptions` 用 `Promise.all([getFormOptions(), getAreas()])` 并行加载型号与区域下拉；③ 工具栏为三个直接按钮「标记使用中/标记空闲/标记维修」，按 `selectedIds.length === 0` 禁用，`handleBatchStatus` 内部按 `statusMap` 拼确认文案后调 `batchUpdateStatus(ids, status)`；④ 表格状态列四色 tag（空闲 success / 使用中 primary / 已满载 warning / 维修 danger），并展示型号代码/名称、有效容量与当前装载数；⑤ 表单 `actualCapacity` 留空提示「使用型号默认容量」 |
| [cart/index.ts](../../wmsui/src/api/carriermanagementsystem/cart/index.ts) | 料车接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 10 个接口函数；`batchUpdateStatus` 状态放 query（`?status=`）、ids 数组放 body，与 warehouse 模块 `{ids, status}` 结构不同；`getAvailableCarts` 为装载场景预留；重导出类型 |
| [cart/types.ts](../../wmsui/src/api/carriermanagementsystem/cart/types.ts) | 料车类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Item / ModelOption 四类；`maxCapacity`（型号容量）与 `currentQuantity`（当前装载）并列展示 |

### 4.3 料车物品（cart-item）

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
|------|------|---------------|---------|
| [cart-item/index.vue](../../wmsui/src/views/carriermanagementsystem/cart-item/index.vue) | 料车物品（装车/取走）管理页 | `vue`（ref / reactive / onMounted / watch）；`@vueuse/core`（useFullscreen）；`element-plus`（ElMessage / ElMessageBox / FormInstance / FormRules）；`@element-plus/icons-vue`（FullScreen / Refresh）；`@/composables`（usePageTable）；`@/api/carriermanagementsystem/cart-item`（CartItemAPI + 类型） | ① 搜索：料车下拉（`getFormOptions` 可用料车）、批次号、状态（1 在车 / 2 已取走）、**装车时间区间** `el-date-picker datetimerange`，`watch(dateRange)` 实时映射 `loadedAtStart` / `loadedAtEnd` 到查询参数；② 工具栏「装车 / 批量取走 / 批量删除」；③ 行操作按状态分流：status=1 显示 编辑+取走，status=2 显示 删除；④ 装车弹窗：料车下拉、货品条码（「输入或扫描」）、型号、**装货顺序 `sortOrder`（el-input-number 1–99999）**、批次号、层号（1–20）、操作人、备注；⑤ 取走弹窗二次确认：展示条码、料车、层号后调 `take(id)`；⑥ `sortOrder` 为首列「装货顺序」宽 60 展示装载次序；⑦ 删除仅允许已取走记录（批量删除确认文案明确提示）；⑧ `layerNo` 默认 1 |
| [cart-item/index.ts](../../wmsui/src/api/carriermanagementsystem/cart-item/index.ts) | 料车物品接口封装 | `@/utils/request`；`./types`；`@/api/common`（PageResult） | 10 个接口函数；`take` / `batchTake` 为取走语义专用接口；`getByCartId` 按料车查明细；`getFilterOptions` 返回 `string[]`；重导出类型 |
| [cart-item/types.ts](../../wmsui/src/api/carriermanagementsystem/cart-item/types.ts) | 料车物品类型定义 | `@/api/common`（BaseQueryParams） | QueryParams / Form / Record / AvailableCart 四类；`loadedAt / takenAt` 记录装车/取走时间戳，`sortOrder` 装货顺序 |

## 5. 核心实现逻辑

### 5.1 列表分页 / 搜索 / 新增 / 编辑 / 删除链路（通用模式）

三个页面统一使用 `@/composables` 的 `usePageTable<T, Q>`（cart / cart-model / cart-item 均使用；仅 cart-model 因无批量操作未使用 `useTableSelection`）：

```
onMounted ──► (可选) loadOptions() 加载下拉 + handleQuery()
handleQuery ──► params.pageNum = 1 ──► fetchData() ──► CartXXXAPI.getPage(params) ──► 回填 list/total
handleResetQuery ──► onBeforeReset()（resetFields，cart-item 额外清空 dateRange）──► 恢复 initialParams ──► fetchData()
提交 handleSubmit ──► validate() 通过后按 formData.id 分流 update / create ──► ElMessage.success ──► closeDialog() ──► handleQuery()
删除 handleDelete ──► ElMessageBox.confirm ──► deleteByIds ──► handleQuery()
```

- 多选状态由行 `@selection-change` 直接映射 `selectedIds = rows.map(r => r.id!)`（cart 与 cart-item 页面内联实现，未走 useTableSelection 封装）。
- 编辑弹窗统一走 `getFormData({id}/form)` 接口回填，不直接用行数据。
- 权限：各按钮挂 `v-hasPerm`（如 `carriermanagementsystem:cart-item:create`）。

### 5.2 特有交互一：料车状态批量标记（cart 页）

工具栏直接提供「标记使用中 / 标记空闲 / 标记维修」三个按钮（无下拉），`handleBatchStatus(status)`：

```
selectedIds 为空 → return（按钮已禁用兜底）
ElMessageBox.confirm(`确认将选中的 N 辆料车标记为「${statusMap[status]}」？`)
──► CartAPI.batchUpdateStatus(selectedIds, status)  // 状态走 query 参数，ids 数组走 body
──► 成功：清空 selectedIds → handleQuery()
```

`statusMap = { 1: "空闲", 2: "使用中", 4: "维修" }`；列表状态列同时支持 3「已满载」（由装载数量驱动，不做手动标记）。

### 5.3 特有交互二：料车物品装车 / 取走闭环（cart-item 页）

```
装车 handleCreateClick ──► 装车弹窗（选料车 + 扫条码 + 装货顺序 sortOrder + 层号 layerNo）
   handleSubmit ──► CartItemAPI.create(formData) ──► "装车成功" ──► handleQuery()
编辑 仅 status === 1（在车）行显示 ──► getFormData 回填 ──► CartItemAPI.update
取走 handleTake(row) ──► 取走确认弹窗（条码/料车/层号）──► confirmTake ──► CartItemAPI.take(id) ──► "取走成功" ──► handleQuery()
批量取走 handleBatchTake ──► ElMessageBox.confirm ──► CartItemAPI.batchTake(selectedIds) ──► 清空选中 ──► handleQuery()
删除 仅 status === 2（已取走）行显示；批量删除确认文案注明「仅允许删除已取走的记录」
```

- **状态驱动 UI**：`status===1` 展示「编辑 / 取走」操作与 success 色「在车」tag；`status===2` 展示「删除」操作与 info 色「已取走」tag，`takenAt` 为空时展示占位符「—」。
- **装货顺序展示**：`sortOrder` 独立成首列「装货顺序」，装车时用 `el-input-number`（1–99999）输入，体现料车装载次序。
- **时间区间联动**：`el-date-picker datetimerange` 绑定 `dateRange`，`watch` 拆分为 `params.loadedAtStart` / `params.loadedAtEnd`（字符串 `YYYY-MM-DD HH:mm:ss`）提交查询。
- 取走/提交失败统一 `catch` 读取后端 `e.msg` 展示 `ElMessage.error`，避免页面假死。

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| Vue 3.5 + `<script setup>` + TypeScript | 页面组件与类型安全 |
| Element Plus | `el-table` / `el-form` / `el-dialog` / `el-select` / `el-tag` / `el-button` / `el-date-picker`（datetimerange）/ `el-input-number` / `ElMessage` / `ElMessageBox` |
| `@element-plus/icons-vue` | FullScreen / Refresh 图标 |
| `@vueuse/core` `useFullscreen` | 表格卡片全屏切换 |
| `@/composables` `usePageTable` | 分页查询状态复用（多选状态页内联实现） |
| `@/utils/request`（axios 封装） | 统一 HTTP 请求（baseURL `/api/v1` 前缀拼接） |
| 自定义指令 `v-hasPerm` | 按钮级权限控制（carriermanagementsystem:cart-model / cart / cart-item 的 create/update/delete） |
| 动态路由 + `import.meta.glob` | 后端菜单表下发路由映射到 views 组件 |
| `pagination` 全局组件 | 分页条（v-model:total/page/limit + @pagination） |
