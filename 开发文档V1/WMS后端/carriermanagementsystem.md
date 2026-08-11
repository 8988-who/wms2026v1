# 载具管理模块（carriermanagementsystem）

## 1. 模块概述

本模块负责料车（载具）的全生命周期管理，采用**三级结构**：

```
wms_cart_model（料车型号配置，如 TC-100，定义最大装载数量/层数）
        │ 1:N（model_id 外键）
        ▼
wms_cart（料车实例，绑定型号、区域、操作工，冗余 current_quantity/status）
        │ 1:N（cart_id 外键）
        ▼
wms_cart_item（装载明细，每个货品一条记录，含条码/顺序号/批次/装车与取走时间）
```

核心业务能力：

- **装车 / 取走**：`CartItemServiceImpl.saveCartItem`（5 重校验：料车可用 → 条码全局唯一 → 顺序号同车唯一 → 有效容量 → 实时装载数不超限）、`takeCartItem`（标记已取走）；
- **扫码装车 / 取走**（条码机 / PDA 专用）：按 `cartCode` 反查料车自动计算顺序号装车、按 `productCode` 反查明细取走、条码列表批量取走；
- **料车状态维护**：`batchUpdateStatus` 批量变更（维修/恢复等）+ 装载变更后自动联动重算 `current_quantity/status`；
- **容量校验**：有效容量 = `COALESCE(actual_capacity, model.max_capacity)`（料车实际容量优先，缺省回落型号最大容量），查询与写入两侧一致。

---

## 2. 数据表设计（来源 [public.sql](../../wms/sql/public.sql)）

三张表均位于 `public` schema，主键均为 int8 自增（分别使用序列 `wms_cart_model_id_seq` / `wms_cart_id_seq` / `wms_cart_item_id_seq`）。

### 2.1 `wms_cart_model` —— 料车型号配置表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| model_code | varchar(20) NOT NULL | 型号代码，如 TC-100（**全局唯一** `wms_cart_model_model_code_key`） |
| model_name | varchar(50) | 型号名称 |
| max_capacity | int4 NOT NULL | 最大装载数量 |
| layer_count | int2 DEFAULT 1 | 层数 |
| remark | varchar(255) | 备注 |
| created_time / updated_time | timestamp | 创建/更新时间（默认 CURRENT_TIMESTAMP） |
| created_by / updated_by | int8 | 审计字段 |

**约束**：主键 `wms_cart_model_pkey`；唯一约束 `model_code`。

### 2.2 `wms_cart` —— 料车实例表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| cart_code | varchar(50) NOT NULL | 料车编号（**全局唯一** `wms_cart_cart_code_key`） |
| model_id | int4 NOT NULL | 型号ID（外键 `fk_cart_model_id` → wms_cart_model.id） |
| current_quantity | int4 DEFAULT 0 | 当前装载数量（**手动维护 + SQL 实时计算双保险**） |
| status | int2 DEFAULT 1 | 状态：1-空闲 2-使用中 3-已满载 4-维修 |
| area | varchar(50) | 所在区域 |
| bind_worker | varchar(20) | 绑定操作工 |
| actual_capacity | int4 | 实际容量（覆盖型号配置，为空时回落型号 max_capacity） |
| created_time / updated_time | timestamp | 审计字段（默认 CURRENT_TIMESTAMP） |
| created_by / updated_by | int8 | 审计字段 |

**索引**：`idx_cart_cart_code`、`idx_wms_cart_area`、`idx_wms_cart_status`。
**约束**：主键 `wms_cart_pkey`；唯一约束 `cart_code`；外键 `fk_cart_model_id`（model_id → wms_cart_model.id，NO ACTION）。

### 2.3 `wms_cart_item` —— 料车装载明细表

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| cart_id | int8 NOT NULL | 料车ID（外键 `fk_item_cart_id` → wms_cart.id） |
| product_code | varchar(255) NOT NULL | 货品条码（唯一码，**全局唯一** `uk_item_product_code`，防重复装车） |
| product_model | varchar(255) NOT NULL | 货品型号 |
| sort_order | int4 NOT NULL | 装货顺序号（从 1 开始，越大越晚装；**同一车内唯一** `uk_item_cart_sort`） |
| batch_no | varchar(50) | 批次号/工单号 |
| layer_no | int2 DEFAULT 1 | 层号（多层料车使用） |
| operator | varchar(20) | 装车操作人 |
| status | int2 DEFAULT 1 | 状态：1-在车 2-已取走 |
| loaded_at | timestamp DEFAULT CURRENT_TIMESTAMP | 装车时间 |
| taken_at | timestamp | 取走时间（可空） |
| remark | varchar(255) | 备注 |
| created_by / updated_by / created_time / updated_time | int8 / timestamp | 审计字段 |

**索引**：`idx_cart_item_cart_status`（cart_id, status）、`idx_cart_item_product_code`、`idx_item_batch_no`、`idx_item_cart_status_order`（cart_id, status, sort_order DESC）、`idx_item_loaded_at`。
**约束**：主键 `wms_cart_item_pkey`；唯一约束 `uk_item_cart_sort`（cart_id, sort_order）、`uk_item_product_code`（product_code）；外键 `fk_item_cart_id`（cart_id → wms_cart.id，NO ACTION）。

> 外键均无级联，删除料车/型号不会自动删除关联明细，需业务层先行处理。

---

## 3. 数据库交互

本模块数据库交互分布在三个 Service 实现（[CartItemServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java)、[CartServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/service/impl/CartServiceImpl.java)、[CartModelServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/service/impl/CartModelServiceImpl.java)）与其对应 Mapper/XML 中，底层为 **MyBatis-Plus**。

### 3.1 数据访问方式总览

| 能力 | 实现方式 | 说明 |
|------|---------|------|
| 通用 CRUD | 继承 `BaseMapper` / `ServiceImpl` | 单表增删改查零 SQL，如 `getById` / `save` / `updateById` / `removeByIds` / `listByIds` / `updateBatchById` |
| 条件构造 | `LambdaQueryWrapper` / `LambdaUpdateWrapper` | 类型安全条件查询/更新，如按 cartCode 反查料车、productCode 唯一性校验、按 status=1 实时计数 |
| 分页查询 | 自定义 XML SQL + `Page` 对象 | 分页由 MyBatis-Plus 分页插件拦截改写，SQL 只写业务查询与 JOIN |

### 3.2 关键交互点：装车时料车 current_quantity / status 双保险维护

- **写入侧（手动维护）**：装车/取走/删除明细后调用私有方法 `updateCartAfterChange(cartId)`，用 SQL 实时 `COUNT(cart_id AND status=1)` 重算装载数，并按下述规则更新料车：
  - `count == 0` → status = 1（空闲）；
  - `count >= 有效容量` → status = 3（已满载）；
  - 其余 → status = 2（使用中）；
  - **料车本身 status = 4（维修）时不参与重算**（直接 return，保留人工维修标记）。
- **查询侧（实时计算）**：`CartMapper.selectCartList` 在 SQL 中用**子查询**实时计算 `current_quantity` 与 `status`，保证列表展示永远正确（详见 3.4）。

### 3.3 容量计算（COALESCE 规则）

有效容量在**两处**以同一规则实现，保证写入校验与展示一致：

- SQL 侧：`COALESCE(c.actual_capacity, m.max_capacity)`（[CartMapper.xml](../../wms/src/main/resources/mapper/carriermanagementsystem/CartMapper.xml) 中 SELECT 与状态 CASE 均使用）；
- Java 侧：`actualCapacity != null && actualCapacity > 0` 取实际容量，否则查 `wms_cart_model` 取 `maxCapacity`（[CartItemServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java) `saveCartItem` 第④步与 `updateCartAfterChange` 中实现）。

### 3.4 分页 SQL 关键片段（CartMapper.xml）

```sql
SELECT c.id, c.cart_code, m.model_code, m.model_name,
       COALESCE(c.actual_capacity, m.max_capacity) AS max_capacity,
       -- 实时计算 current_quantity（在车状态的物品数量）
       (SELECT COUNT(*) FROM wms_cart_item WHERE cart_id = c.id AND status = 1) AS current_quantity,
       -- 实时计算 status（维修状态保持数据库值，其他状态实时计算）
       CASE
           WHEN c.status = 4 THEN 4
           WHEN (SELECT COUNT(*) FROM wms_cart_item WHERE cart_id = c.id AND status = 1) = 0 THEN 1
           WHEN (SELECT COUNT(*) FROM wms_cart_item WHERE cart_id = c.id AND status = 1)
                >= COALESCE(c.actual_capacity, m.max_capacity) THEN 3
           ELSE 2
       END AS status,
       c.area, c.bind_worker, c.actual_capacity,
       su1.nickname AS created_by_name, c.created_time,
       su2.nickname AS updated_by_name, c.updated_time
FROM wms_cart c
LEFT JOIN wms_cart_model m ON c.model_id = m.id
LEFT JOIN sys_user su1 ON c.created_by = su1.id
LEFT JOIN sys_user su2 ON c.updated_by = su2.id
```

筛选状态时：`status=4` 直接匹配数据库值 `c.status = 4`；其他状态用同一段 CASE 实时计算值匹配（`<choose>` 分支），避免库中冗余状态滞后导致筛选错位。

### 3.5 审计字段自动填充

- 三张表 `created_by / created_time / updated_by / updated_time`：实体继承 `BaseEntity` 并重声明 `createTime/updateTime/createBy/updateBy`，加 `@TableField(fill = FieldFill.INSERT / INSERT_UPDATE)`，由框架层 [AutoFillMetaObjectHandler](../../wms/src/main/java/com/wms/framework/mybatis/handler/AutoFillMetaObjectHandler.java) 按属性名自动填充；
- 明细表 `loaded_at`（装车时间）由业务层 `LocalDateTime.now()` 显式写入，`taken_at`（取走时间）在取走时写入。

### 3.6 事务边界总结

| 方法 | 事务 | 说明 |
|------|------|------|
| `saveCartItem` / `loadByBarcode` | `@Transactional(rollbackFor = Exception.class)` | 5 重校验 + 写明细 + 联动料车状态原子提交 |
| `takeCartItem` / `batchTakeCartItems` / `takeByBarcode` / `batchTakeByBarcodes` | `@Transactional` | 标记取走 + 联动料车状态原子提交 |
| `deleteCartItems` | `@Transactional` | 删除已取走记录 + 联动料车状态 |
| `updateCartItem` | `@Transactional` | 字段级更新（productCode/sortOrder 冲突校验） |
| `addCart` / `updateCart` / `deleteCart` / `batchUpdateStatus`（CartServiceImpl） | `@Transactional` | 料车 CRUD 与批量状态 |
| `addCartModel` / `updateCartModel` / `deleteCartModel`（CartModelServiceImpl） | `@Transactional` | 型号 CRUD |

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/carriermanagementsystem/...`；以下"引用的包"为该文件 import 中的主要部分。共 30 个 Java 文件 + 3 个 Mapper XML。

### 4.1 子模块 cart（料车实例）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [CartController.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/controller/CartController.java) | 料车 REST 接口：分页/新增/编辑/删除/批量状态/下拉选项/区域/可用料车 | `com.wms.carriermanagementsystem.cart.service.CartService`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`com.baomidou.mybatisplus.core.metadata.IPage`、`io.swagger.v3.oas.annotations.*`、`jakarta.validation.Valid`、`org.springframework.security.access.prepost.PreAuthorize`、`org.springframework.web.bind.annotation.*` | 前缀 `/api/v1/cart`；权限标识 `carriermanagementsystem:cart:*`；新增加 `@RepeatSubmit`；批量状态 `PUT /batch-status`（ids + status）；`GET /available` 返回未维修料车供装车选择 |
| [CartService.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/service/CartService.java) | 料车业务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.carriermanagementsystem.cart.model.dto/vo/entity.*`、`com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO`、`java.util.List` | 声明分页/新增/表单回显/编辑/批量删除/批量改状态/型号下拉/区域列表/可用料车 9 个方法 |
| [CartServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/service/impl/CartServiceImpl.java) | 料车业务实现（批量状态、下拉选项、可用料车） | `com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.carriermanagementsystem.cart.CartConverter`、`com.wms.carriermanagementsystem.cart.mapper.CartMapper`、`com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper`、`lombok.RequiredArgsConstructor`、`org.springframework.transaction.annotation.Transactional` | `addCart` 初始化 `currentQuantity=0/status=1`；`batchUpdateStatus` 用 `updateBatchById` 批量改状态；`availableCarts` 用 `LambdaQueryWrapper.ne(status, 4)` + 按 cartCode 升序；`listCart` 走 `selectCartList` 实时计算 |
| [CartMapper.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/mapper/CartMapper.java) | 料车持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.carriermanagementsystem.cart.model.dto.CartQueryDTO`、`com.wms.carriermanagementsystem.cart.model.entity.Cart`、`com.wms.carriermanagementsystem.cart.model.vo.CartVO`、`org.apache.ibatis.annotations.Mapper/Param` | 继承 BaseMapper；自定义 `selectCartList(Page, Query)`（XML 实时计算）、`selectDistinctAreas()` |
| [CartMapper.xml](../../wms/src/main/resources/mapper/carriermanagementsystem/CartMapper.xml) | 料车列表 SQL | MyBatis XML | LEFT JOIN wms_cart_model 取型号冗余、LEFT JOIN sys_user 取创建/更新人昵称；`current_quantity` 与 `status` 用子查询/CASE 实时计算（见 3.4）；筛选：keyword（cart_code/bind_worker LIKE）、status（4 直配库值、其余实时 CASE 匹配）、modelId、area；`ORDER BY cart_code` |
| [CartConverter.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/CartConverter.java) | 料车对象转换器 | `org.mapstruct.Mapper/MappingTarget`、`com.wms.carriermanagementsystem.cart.model.dto.CartDTO`、`com.wms.carriermanagementsystem.cart.model.entity.Cart` | `@Mapper(componentModel="spring")` 编译期生成；`toDTO` / `toEntity` / `updateEntity(@MappingTarget)` |
| [Cart.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/model/entity/Cart.java) | 料车实体 | `com.baomidou.mybatisplus.annotation.*`（TableName/TableField/FieldFill）、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.*`、`lombok.Data/EqualsAndHashCode`、`java.time.LocalDateTime` | `@TableName("wms_cart")`，继承 BaseEntity；字段 cartCode/modelId/currentQuantity/status/area/bindWorker/actualCapacity；审计字段 createTime/updateTime/createBy/updateBy 自动填充 |
| [CartDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/model/dto/CartDTO.java) | 料车表单 DTO | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank/NotNull`、`lombok.Getter/Setter` | 接收可编辑字段（cartCode 非空、modelId 非空、area/bindWorker/actualCapacity）；currentQuantity/status 由服务端控制 |
| [CartQueryDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/model/dto/CartQueryDTO.java) | 料车分页查询条件 | `com.wms.common.base.BaseQuery`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode` | 继承 BaseQuery（pageNum/pageSize）；筛选：keyword/status/modelId/area |
| [CartVO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cart/model/vo/CartVO.java) | 料车视图对象 | `com.fasterxml.jackson.annotation.JsonFormat`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.time.LocalDateTime` | 在实体字段上增加 modelCode/modelName（联表冗余）、maxCapacity（有效容量）、createdByName/updatedByName |

### 4.2 子模块 cartitem（装载明细，核心）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [CartItemController.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/controller/CartItemController.java) | 装载明细 REST 接口 + 扫码专用端点 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.carriermanagementsystem.cartitem.model.dto/vo/entity.*`、`com.wms.carriermanagementsystem.cartitem.service.CartItemService`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`io.swagger.v3.oas.annotations.*`、`jakarta.validation.Valid`、`org.springframework.security.access.prepost.PreAuthorize`、`org.springframework.web.bind.annotation.*`、`java.util.Map/List` | 前缀 `/api/v1/cart-item`；标准端点：分页/装车 POST/修改/表单/删除/`PUT {id}/take` 取走/`PUT batch-take` 批量取走/`GET by-cart/{cartId}`/下拉选项；扫码端点：`POST load-by-barcode`（Map 参数）、`PUT take-by-barcode/{productCode}`、`PUT batch-take-by-barcodes`；写操作均加 `@RepeatSubmit` 与 `@Log` |
| [CartItemService.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/CartItemService.java) | 装载明细业务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.carriermanagementsystem.cart.model.entity.Cart`、`com.wms.carriermanagementsystem.cartitem.model.dto/vo/entity.*`、`java.util.List` | 声明 CRUD + 装车/取走/批量取走/删除 + 按车查询 + 下拉选项 + 3 个扫码方法 |
| [CartItemServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/service/impl/CartItemServiceImpl.java) | **装载明细核心实现**（装车 5 重校验、取走/删除规则、扫码、双保险联动） | `com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper`、`com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.carriermanagementsystem.cart.mapper.CartMapper`、`com.wms.carriermanagementsystem.cart.model.entity.Cart`、`com.wms.carriermanagementsystem.cartitem.CartItemConverter`、`com.wms.carriermanagementsystem.cartitem.mapper.CartItemMapper`、`com.wms.carriermanagementsystem.cartitem.model.dto/vo/entity.*`、`com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper`、`com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel`、`lombok.RequiredArgsConstructor`、`org.springframework.transaction.annotation.Transactional`、`java.time.LocalDateTime` | 详见 [5. 核心实现逻辑](#5-核心实现逻辑) |
| [CartItemMapper.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/mapper/CartItemMapper.java) | 装载明细持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.carriermanagementsystem.cartitem.model.dto.CartItemQueryDTO`、`com.wms.carriermanagementsystem.cartitem.model.entity.CartItem`、`com.wms.carriermanagementsystem.cartitem.model.vo.CartItemVO`、`org.apache.ibatis.annotations.Mapper/Param`、`java.util.List` | 继承 BaseMapper；自定义 `getCartItemPage(Page, Query)`、`getCartItemsByCartId`、`getMaxSortOrderByCartId`（取当前最大顺序号，无则 0） |
| [CartItemMapper.xml](../../wms/src/main/resources/mapper/carriermanagementsystem/CartItemMapper.xml) | 明细列表 SQL | MyBatis XML | LEFT JOIN wms_cart 取 cart_code/cart_status、LEFT JOIN sys_user 取人名；分页筛选：cartId/cartCode/productCode/productModel/batchNo/status/layerNo/operator/loadedAt 区间/keyword；`ORDER BY loaded_at DESC, sort_order DESC`；`getCartItemsByCartId` 按 sort_order DESC；`getMaxSortOrderByCartId` 用 `COALESCE(MAX(sort_order),0)` |
| [CartItemConverter.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/CartItemConverter.java) | 明细对象转换器 | `org.mapstruct.Mapper/MappingTarget`、`com.wms.carriermanagementsystem.cartitem.model.dto.CartItemDTO`、`com.wms.carriermanagementsystem.cartitem.model.entity.CartItem` | `@Mapper(componentModel="spring")`；`toDTO` / `toEntity` / `updateEntity(@MappingTarget)` |
| [CartItem.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/model/entity/CartItem.java) | 明细实体 | `com.baomidou.mybatisplus.annotation.*`、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.*`、`lombok.Data/EqualsAndHashCode`、`java.time.LocalDateTime` | `@TableName("wms_cart_item")`；字段 cartId/productCode/productModel/sortOrder/batchNo/layerNo/operator/status/loadedAt/takenAt/remark；status 注释 1-在车 2-已取走 |
| [CartItemDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/model/dto/CartItemDTO.java) | 装车表单 DTO | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank/NotNull`、`lombok.Getter/Setter` | cartId/productCode/productModel/sortOrder 必填；status/loadedAt/takenAt 由业务自动维护不接收 |
| [CartItemQueryDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/model/dto/CartItemQueryDTO.java) | 明细分页查询条件 | `com.wms.common.base.BaseQuery`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode` | 多维度筛选：cartId/cartCode/productCode/productModel/batchNo/status/layerNo/operator/loadedAtStart/loadedAtEnd/keyword |
| [CartItemVO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartitem/model/vo/CartItemVO.java) | 明细视图对象 | `com.fasterxml.jackson.annotation.JsonFormat`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.time.LocalDateTime` | 增加 cartCode/cartStatus（联表冗余）与 createdByName/updatedByName |

### 4.3 子模块 cartmodel（料车型号配置）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [CartModelController.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/controller/CartModelController.java) | 型号配置 REST 接口 | `com.wms.carriermanagementsystem.cartmodel.model.dto/vo.*`、`com.wms.carriermanagementsystem.cartmodel.service.CartModelService`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`com.baomidou.mybatisplus.core.metadata.IPage`、`io.swagger.v3.oas.annotations.*`、`jakarta.validation.Valid`、`org.springframework.security.access.prepost.PreAuthorize`、`org.springframework.web.bind.annotation.*` | 前缀 `/api/v1/cart-model`；权限 `carriermanagementsystem:cart-model:*`；新增 `@RepeatSubmit`；`GET form-options` / `GET filter-options` 返回可用型号下拉 |
| [CartModelService.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/service/CartModelService.java) | 型号业务接口 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.carriermanagementsystem.cartmodel.model.dto/vo.*`、`java.util.List` | 声明分页/新增/表单/编辑/删除/两类下拉选项 7 个方法 |
| [CartModelServiceImpl.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/service/impl/CartModelServiceImpl.java) | 型号业务实现 | `com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.carriermanagementsystem.cartmodel.CartModelConverter`、`com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper`、`com.wms.carriermanagementsystem.cartmodel.model.dto/vo/entity.*`、`lombok.RequiredArgsConstructor`、`org.springframework.transaction.annotation.Transactional`、`java.util.Arrays/List/stream.Collectors` | `addCartModel`/`updateCartModel` 默认 layerCount=1；`deleteCartModel` 按逗号拆分 ID 批量删除；分页走 `selectCartModelList`（左联统计料车数）；form/filter 下拉走 `selectFormOptions` |
| [CartModelMapper.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/mapper/CartModelMapper.java) | 型号持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO`、`com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel`、`com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO`、`org.apache.ibatis.annotations.Mapper/Param`、`java.util.List` | 继承 BaseMapper；自定义 `selectCartModelList(Page, Query)`、`selectFormOptions()` |
| [CartModelMapper.xml](../../wms/src/main/resources/mapper/carriermanagementsystem/CartModelMapper.xml) | 型号列表 SQL | MyBatis XML | `selectCartModelList`：LEFT JOIN 子查询按 model_id 统计料车数（`COALESCE(cart_count,0)`），筛选 modelCode/modelName/keyword（LIKE）；`selectFormOptions` 取 id/model_code/model_name/max_capacity/layer_count；均按 model_code 升序 |
| [CartModelConverter.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/CartModelConverter.java) | 型号对象转换器 | `org.mapstruct.Mapper`、`com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO`、`com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel` | `@Mapper(componentModel="spring")`；`toDTO` / `toEntity` |
| [CartModel.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/model/entity/CartModel.java) | 型号实体 | `com.baomidou.mybatisplus.annotation.*`、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.*`、`lombok.Data/EqualsAndHashCode`、`java.time.LocalDateTime` | `@TableName("wms_cart_model")`；字段 modelCode/modelName/maxCapacity/layerCount/remark |
| [CartModelDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/model/dto/CartModelDTO.java) | 型号表单 DTO | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank/NotNull`、`lombok.Getter/Setter` | modelCode 非空、maxCapacity 非空；layerCount 可空（默认 1） |
| [CartModelQueryDTO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/model/dto/CartModelQueryDTO.java) | 型号分页查询条件 | `com.wms.common.base.BaseQuery`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode` | 筛选：modelCode/modelName/keyword |
| [CartModelVO.java](../../wms/src/main/java/com/wms/carriermanagementsystem/cartmodel/model/vo/CartModelVO.java) | 型号视图对象 | `com.fasterxml.jackson.annotation.JsonFormat`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.time.LocalDateTime` | 在实体字段上增加 cartCount（关联料车数）、createdByName/updatedByName |

### 4.4 公共层（common）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [CartStatusEnum.java](../../wms/src/main/java/com/wms/carriermanagementsystem/common/enums/CartStatusEnum.java) | 料车状态枚举 | `com.wms.common.base.IBaseEnum`、`lombok.AllArgsConstructor/Getter` | 实现 `IBaseEnum<Integer>`：IDLE(1,空闲)、IN_USE(2,使用中)、FULL(3,已满载)、MAINTENANCE(4,维修) |
| [CartItemStatusEnum.java](../../wms/src/main/java/com/wms/carriermanagementsystem/common/enums/CartItemStatusEnum.java) | 明细状态枚举 | `com.wms.common.base.IBaseEnum`、`lombok.AllArgsConstructor/Getter` | 实现 `IBaseEnum<Integer>`：ON_CART(1,在车)、TAKEN(2,已取走) |
| [CarrierManagementSystemConstants.java](../../wms/src/main/java/com/wms/carriermanagementsystem/common/constant/CarrierManagementSystemConstants.java) | 模块公共常量 | 无（纯常量类，私有构造器） | 缓存前缀 `CART_MODEL_CACHE_PREFIX="cart:model:"` / `CART_CACHE_PREFIX="cart:"`；`DEFAULT_LAYER_COUNT=1`、`DEFAULT_CART_STATUS=1` |

---

## 5. 核心实现逻辑

### 5.1 装车流程（CartItemServiceImpl.saveCartItem，5 重校验顺序）

```
saveCartItem(dto)
  ├─ ① 料车存在且可装车：cartMapper.selectById(cartId)；null 抛"料车不存在"；
  │     status==null 或 status==4 抛"料车当前状态不可装车（维修中）"
  ├─ ② 条码全局唯一：selectCount(eq productCode)；>0 抛"货品条码已存在，不允许重复装车"（防并发重复装车）
  ├─ ③ 顺序号同车唯一：getMaxSortOrderByCartId(cartId) 取当前最大（null 视为 0）；
  │     dto.sortOrder 为空或 <= maxSort 抛"装货顺序号必须大于当前最大顺序号"
  ├─ ④ 有效容量：actualCapacity>0 用之，否则查 CartModel 取 maxCapacity（model 缺失抛异常）
  ├─ ⑤ 实时装载数不超限：selectCount(eq cartId, eq status=1)；>= 有效容量抛"料车已满"
  │
  ├─ 写入明细：toEntity(dto) → status=1、loadedAt=now、layerNo 默认 1 → save(entity)
  └─ 成功 → updateCartAfterChange(cartId) 手动维护料车 current_quantity/status
```

### 5.2 取走流程（takeCartItem / batchTakeCartItems / deleteCartItems）

```
takeCartItem(id)
  ├─ 校验：记录存在；status==2 抛"已被取走，不允许重复操作"
  ├─ 标记：status=2、takenAt=now → updateById
  └─ 成功 → updateCartAfterChange(cartId)（满载料车取走后自动回落为使用中/空闲）

batchTakeCartItems(ids)：逐条调 takeCartItem，任一失败抛"批量取走失败，物品ID：x"（整体回滚）

deleteCartItems(ids)
  ├─ 按逗号拆分 idList → listByIds
  ├─ 规则：仅允许删除 status==2 已取走记录，否则抛"尚未取走，不允许删除"
  ├─ removeByIds 物理删除
  └─ 成功 → updateCartAfterChange(cartId)
```

### 5.3 扫码装车/取走（按条码反查）

| 方法 | 流程 |
|------|------|
| `loadByBarcode(cartCode, productCode, productModel)` | cartCode → `selectOne(eq cartCode)` 反查料车（不存在抛错）→ `getMaxSortOrderByCartId` 自动计算 `nextSort = maxSort+1` → 组装 CartItemDTO（productModel 传入）→ 复用 `saveCartItem`（自动按上述 5 重校验） |
| `takeByBarcode(productCode)` | productCode → `selectOne(eq productCode)` 反查明细（不存在抛"未找到该条码的物品记录"）→ 调 `takeCartItem(itemId)` |
| `batchTakeByBarcodes(productCodes)` | productCodes 列表 → `selectList(in productCode)` 映射出 id 列表（为空抛错）→ 调 `batchTakeCartItems(ids)` |

### 5.4 状态机

**料车状态（wms_cart.status，CartStatusEnum）**：

```
1-空闲 ──装车──► 2-使用中 ──装至满载──► 3-已满载
  ▲                 │                     │
  └──全部取走────────┘◄────取走───────┘
  4-维修（人工批量状态维护，不参与自动联动：装车校验拒绝、updateCartAfterChange 跳过）
```

自动联动规则（`updateCartAfterChange`，装车/取走/删除后触发）：
- `count(status=1) == 0` → 1-空闲；
- `count >= 有效容量` → 3-已满载；
- 其余 → 2-使用中；
- 料车 status=4（维修）→ 直接 return，不重算。

**明细状态（wms_cart_item.status，CartItemStatusEnum）**：

```
1-在车 ──取走──► 2-已取走 ──删除（仅此状态允许物理删除）──► 记录消失
```

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MyBatis-Plus | 通用 BaseMapper/ServiceImpl、LambdaQueryWrapper/LambdaUpdateWrapper 条件构造、Page 分页插件、FieldFill 审计字段自动填充 |
| PostgreSQL | wms_cart_model / wms_cart / wms_cart_item 三表、序列自增主键、唯一约束与索引保证条码/顺序号唯一 |
| Spring `@Transactional(rollbackFor = Exception.class)` | 装车/取走/删除与料车状态联动原子提交 |
| MapStruct | DTO/Entity 编译期转换（CartConverter/CartItemConverter/CartModelConverter，`componentModel="spring"`） |
| Spring Security `@PreAuthorize` | 接口级权限（`carriermanagementsystem:cart:*` / `cart-item:*` / `cart-model:*`） |
| `@RepeatSubmit`（Redisson） | 新增/装车/取走/扫码等写接口防重复提交 |
| `@Log` AOP | 操作日志埋点（LogModuleEnum.CART / CART_ITEM / CART_MODEL） |
| Knife4j（springdoc `@Tag`/`@Operation`/`@Schema`） | 接口文档与参数说明 |
| Lombok（`@Data`/`@Getter`/`@Setter`/`@RequiredArgsConstructor`） | 消除样板代码，构造器注入 |
