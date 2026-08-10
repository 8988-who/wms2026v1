# 仓库模块 Excel 导入导出方案

> 适用模块：`com.wms.warehouse`（库区/区域、巷道、点位）
> 创建时间：2026-08-05
> 状态：方案已确认，待实现

## 一、背景与目标

仓库模块包含三类基础数据对象：

| 对象 | 实体 | 数据表 | 层级关系 |
|---|---|---|---|
| 库区/区域 | WmsLocation | wms_location | 树形：厂区 → 区域 → 货架 → 库位（WmsLocationTypeEnum：PLANT/AREA/SHELF/LOCATION） |
| 巷道 | WmsAisle | wms_aisle | 挂在库区下（locationId） |
| 点位 | WmsPoint | wms_point | 挂在库区+巷道下（locationId / aisleId） |

目标：为三类对象提供 **Excel 模板下载、导入、导出** 功能，用于初始数据录入和批量维护。

## 二、总体设计（已确认决策）

1. **三个对象各自独立实现一套**（参考 system 模块 `UserImportForm + UserImportListener + ExcelUtils` 模式），互不冲突，不共享泛化逻辑。
2. **导入顺序**遵循层级关系：先库区 → 再巷道 → 后点位（巷道依赖库区 ID，点位依赖库区 + 巷道 ID）。
3. **模板下载采用动态生成**：`EasyExcel.write(outputStream).head(XxxImportForm.class).sheet().doWrite(空列表)`，不预置静态 xlsx 文件，列与校验类同步。
4. **导出复用导入表单类**：`EasyExcel.write(outputStream).head(XxxImportForm.class)`，导出列与导入列完全对应，可来回往返。若后续导出需要额外列（创建人、点位数等），再单独建 `XxxExportVO`。

## 三、目录与文件清单

```
warehouse/
├── model/form/                       # 新增目录
│   ├── WmsLocationImportForm.java    # 库区导入表单
│   ├── WmsAisleImportForm.java       # 巷道导入表单
│   └── WmsPointImportForm.java       # 点位导入表单
├── listener/                         # 新增目录
│   ├── WmsLocationImportListener.java
│   ├── WmsAisleImportListener.java
│   └── WmsPointImportListener.java
└── controller/                       # 修改，3 个 Controller 各加 3 个端点
    ├── WmsLocationController.java
    ├── WmsAisleController.java
    └── WmsPointController.java
```

不新增 Controller，不新增 Mapper/Service 接口方法（复用现有 `WmsLocationService` / `WmsAisleService` / `WmsPointService` 的 `IService.save()` / `list()`）。

## 四、核心难点：编码 ↔ ID 翻译

Excel 中不允许用户填自增 ID，导入表单的关联字段一律用**编码**，在 Listener 中翻译成 ID：

| 导入对象 | Excel 列（用户填） | 入库字段 | 翻译来源（预加载映射） |
|---|---|---|---|
| 库区 WmsLocation | 父级编码 parentCode | parentId | wms_location.locationCode → id |
| 巷道 WmsAisle | 所属库区编码 locationCode | locationId | wms_location.locationCode → id |
| 点位 WmsPoint | 所属库区编码 locationCode | locationId | wms_location.locationCode → id |
| 点位 WmsPoint | 所属巷道编码 aisleCode | aisleId | wms_aisle.aisleCode → id |

## 五、三个导入表单的 Excel 列设计

### 5.1 库区导入 WmsLocationImportForm

| Excel 列 | 字段 | 必填 | 校验规则 |
|---|---|---|---|
| 厂区编码 | plantCode | 是 | — |
| 库区编码 | locationCode | 是 | 全局唯一 |
| 库区名称 | locationName | 是 | — |
| 父级编码 | parentCode | 否 | 存在性校验；类型为厂区时禁止填父级 |
| 类型 | locationType | 是 | 支持中文标签（厂区/区域/货架/库位）或枚举值（0/1/2/3），翻译成枚举值 |
| 楼层 | floor | 否 | — |
| 排序号 | sortOrder | 否 | 默认 0 |
| 状态 | status | 否 | 默认 1（启用） |
| 备注 | remark | 否 | — |

### 5.2 巷道导入 WmsAisleImportForm

| Excel 列 | 字段 | 必填 | 校验规则 |
|---|---|---|---|
| 厂区编码 | plantCode | 是 | — |
| 所属库区编码 | locationCode | 是 | 对应库区必须存在 |
| 巷道编码 | aisleCode | 是 | 全局唯一 |
| 巷道名称 | aisleName | 是 | — |
| 楼层 | floor | 否 | — |
| 排序号 | sortOrder | 否 | 默认 0 |
| 状态 | status | 否 | 默认 1（启用） |
| 巷道用途 | aislePurpose | 否 | FULL/EMPTY/MIXED |
| 是否交接点 | isHandoverPoint | 否 | 支持填 是/否 或 1/0，默认 0 |
| 备注 | remark | 否 | — |

### 5.3 点位导入 WmsPointImportForm

| Excel 列 | 字段 | 必填 | 校验规则 |
|---|---|---|---|
| 厂区编码 | plantCode | 是 | — |
| 所属库区编码 | locationCode | 是 | 对应库区必须存在 |
| 所属巷道编码 | aisleCode | 是 | 对应巷道必须存在 |
| 点位编码 | pointCode | 是 | 全局唯一 |
| 点位名称 | pointName | 是 | — |
| 条码 | barcode | 否 | — |
| 坐标 | coordinate | 否 | — |
| 楼层 | floor | 否 | — |
| 排序号 | sortOrder | 否 | 默认 0 |
| 状态 | status | 否 | 默认 1（启用） |
| 备注 | remark | 否 | — |

## 六、Listener 处理逻辑与校验规则

三个 Listener 结构一致（参考 `UserImportListener`），以库区为例：

```
构造器：
  SpringUtil.getBean(WmsLocationService.class) 注入
  预加载已有 locationCode → id 映射（Map），避免逐行查库
  初始化 ExcelResult

invoke(逐行)：
  1. 必填项校验（plantCode / locationCode / locationName 等）
  2. 唯一性校验：locationCode 在库中不存在（count == 0）
  3. 关联校验：parentCode 必须存在于【预加载映射 + 本文件已处理行】中
  4. 类型翻译：中文标签或枚举值 → 枚举值
  5. 通过 → 组装 WmsLocation 实体，save() 落库，
     成功后把 (locationCode, id) 加入"本文件已处理"映射（支持文件内父子引用）
  6. 统计 ExcelResult：validCount / invalidCount / messageList
     失败行错误信息格式："第 N 行数据校验失败：xxx；yyy；"
  currentRow++

doAfterAllAnalysed：空实现
```

**校验规则摘要**

| 对象 | 必填 | 唯一性 | 关联存在性 |
|---|---|---|---|
| 库区 | plantCode / locationCode / locationName | locationCode | parentCode 存在（若有）；厂区类型不能有父级 |
| 巷道 | plantCode / locationCode / aisleCode / aisleName | aisleCode | locationCode 对应库区存在 |
| 点位 | plantCode / aisleCode / pointCode / pointName | pointCode | locationCode 库区 + aisleCode 巷道均存在 |

> 注意：库区父子引用要求 Excel 中**父级行在前**，若父级编码既不在库中也不在已处理行中，则该行报错"父级编码不存在"。

## 七、Controller 端点设计

三个 Controller 各加 3 个端点（路径前缀：`/api/v1/wms-location`、`/api/v1/wms-aisle`、`/api/v1/wms-point`）：

```
GET  {prefix}/template    # 下载导入模板（动态生成）
POST {prefix}/import      # 导入，返回 Result<ExcelResult>
GET  {prefix}/export      # 按现有 QueryDTO 查询导出
```

端点实现要点：

- `template`：
  ```java
  EasyExcel.write(response.getOutputStream(), WmsLocationImportForm.class)
          .sheet("库区导入模板").doWrite(Collections.emptyList());
  ```
- `import`：
  ```java
  WmsLocationImportListener listener = new WmsLocationImportListener();
  ExcelUtils.importExcel(file.getInputStream(), WmsLocationImportForm.class, listener);
  return Result.success(listener.getExcelResult());
  ```
- `export`：按现有 `XxxQueryDTO` 分页/全量查询后直接 `doWrite`。

权限与日志（与现有风格一致）：

```java
@PreAuthorize("@ss.hasPerm('warehouse:wms-location:import')")
@Log(module = LogModuleEnum.WMS_LOCATION, value = ActionTypeEnum.IMPORT)
```

权限标识：
- 库区：`warehouse:wms-location:import` / `warehouse:wms-location:export`
- 巷道：`warehouse:wms-aisle:import` / `warehouse:wms-aisle:export`
- 点位：`warehouse:wms-point:import` / `warehouse:wms-point:export`

## 八、实现步骤（后续实施计划）

1. 新建 `model/form/` 下 3 个 ImportForm 类（@ExcelProperty 标注列名，参考 UserImportForm）
2. 新建 `listener/` 下 3 个 ImportListener 类（参考 UserImportListener，预加载映射 + 逐行校验 + 落库）
3. 修改 3 个 Controller，追加 template / import / export 端点
4. 若导出需要额外列，再补 `XxxExportVO`
5. 编译验证（`mvn compile` 或 IDE 编译），联调模板下载 / 导入 / 导出
6. 前端对应页面加"下载模板 / 导入 / 导出"按钮（另行排期）

## 九、注意事项与风险

1. **复用现有 Service 接口**，不改 Mapper/Service 层接口签名，避免影响现有 CRUD。
2. **双保险机制不受影响**：库区/巷道/点位本身没有实时计算字段（点位数是查询时子查询计算，导入只写基础数据），导入不会破坏 `pointCount` / `currentQuantity` 等计算逻辑。
3. **编码 → ID 映射预加载**：大数据量时在构造器一次性查询，避免逐行查库；导入后如需刷新关联（如巷道导入后再补点位数），可在导出/查询时依赖现有 SQL 子查询机制。
4. **事务**：逐行 save 不做整体事务回滚（与 UserImportListener 一致），失败行记录到 messageList，成功行照常落库，便于用户按错误明细修正后重导。
5. **文档与代码同步**：若实体字段后续变更（如新增列），需同步更新本方案中的列设计表。
