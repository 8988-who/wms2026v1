# 仓库管理模块（warehouse）

## 1. 模块概述

本模块管理仓库物理空间的三级层级结构，是 **AGV 路径规划与库存精细化管理** 的基础数据源：

- **wms_location（库位/区域）** → **wms_aisle（巷道）** → **wms_point（点位）** 三级层级；
- 区域通过 `parent_id` 支持树形归属（0 表示顶级），`floor` 管物理楼层；
- 巷道是区域的下一级物理划分，`aisle_purpose`（FULL/EMPTY/MIXED）用于周转区优先存放规则，`is_handover_point` 标记交接点巷道；
- 点位不承载库存信息，仅作为 **AGV 路径规划和人员导航的坐标点**（`coordinate` 格式由 AGV 引擎定义），`sort_order` 决定 AGV 经过顺序与作业推荐优先级。

核心业务能力：
- **自动编码**：基于 Redis INCR 原子自增生成区域/巷道/点位编码（`WmsCodeGeneratorService`），高并发不重复；
- **级联停用**：停用区域自动停用其下巷道与点位，停用巷道自动停用其下点位（`WmsCascadeService`），保证 AGV 路径规划避开停用点；
- **点位计数**：`wms_aisle.point_count` 采用「写入 setSql 维护 + 查询 SQL 实时计算」双保险机制；
- **删除保护**：区域下存在子区域/巷道、巷道下存在点位时禁止删除，防止悬挂数据。

```
wms_location（库位/区域，parent_id 树形）
    └── wms_aisle（巷道，location_id 归属，point_count 计数）
            └── wms_point（点位，aisle_id 归属，AGV 坐标点）
```

---

## 2. 数据表设计（来源 public.sql）

> 来源：[public.sql](../../wms/sql/public.sql)。三张表主键均为 int8 自增序列，均含 `created_by / created_time / updated_by / updated_time` 审计字段（默认 CURRENT_TIMESTAMP），此处合并说明。

### 2.1 `wms_location` —— 库位/区域主表

> 表注释：『库位/区域主表：多厂区隔离，parent_id 管归属，floor 管物理楼层』

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| plant_code | varchar(32) NOT NULL DEFAULT 'DEFAULT' | 厂区编码（关联 sys_dept.plant_code，数据权限隔离） |
| location_code | varchar(32) NOT NULL | 区域编码（厂区内唯一） |
| location_name | varchar(64) NOT NULL | 区域名称 |
| location_type | varchar(20) NOT NULL | 区域类型（对应枚举：厂区/区域/货架/库位） |
| parent_id | int8 NOT NULL DEFAULT 0 | 父级区域ID（0 表示顶级），管理归属/树形结构 |
| floor | varchar(20) DEFAULT '' | 物理楼层标识（如 1F/2F/B1），快速按楼层筛选和 AGV 路径规划 |
| sort_order | int4 NOT NULL DEFAULT 0 | 排序号 |
| status | int4 NOT NULL DEFAULT 1 | 状态：1 启用，0 停用 |
| remark | varchar(255) | 备注 |
| created_by / created_time / updated_by / updated_time | int8 / timestamp | 审计字段 |

**索引**：`idx_location_floor`、`idx_location_parent_id`、`idx_location_plant_code`、唯一索引 `uk_location_plant_code(plant_code, location_code)`。

### 2.2 `wms_aisle` —— 巷道/通道表

> 表注释：『巷道/通道表：区域下一级物理划分，用于AGV路径规划和库存精细化管理』

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| plant_code | varchar(32) NOT NULL | 厂区编码（**冗余字段，便于查询**） |
| location_id | int8 NOT NULL | 所属区域ID，关联 wms_location.id（外键 fk_aisle_location_id，RESTRICT） |
| aisle_code | varchar(32) NOT NULL | 巷道编码（厂区内唯一，如 A-01、B-02） |
| aisle_name | varchar(64) NOT NULL | 巷道名称（如：A区一号巷道） |
| floor | varchar(20) DEFAULT '' | 物理楼层（**冗余字段，便于按楼层筛选**） |
| sort_order | int4 NOT NULL DEFAULT 0 | 排序号，用于路径规划和界面展示 |
| status | int4 NOT NULL DEFAULT 1 | 状态：1 启用，0 停用 |
| remark | varchar(255) | 备注 |
| aisle_purpose | varchar(20) NOT NULL DEFAULT 'MIXED' | 巷道用途：FULL-满架优先，EMPTY-空架优先，MIXED-混合（周转区优先存放规则） |
| is_handover_point | int4 NOT NULL DEFAULT 0 | 是否交接点巷道：0-否，1-是 |
| point_count | int4 NOT NULL DEFAULT 0 | 绑定的点位数量（**冗余计数**，表注释标注"由触发器自动维护"，实际由业务代码 setSql 维护 + 查询 SQL 实时计算，见 5.3） |
| created_by / created_time / updated_by / updated_time | int8 / timestamp | 审计字段 |

**索引**：`idx_aisle_floor`、`idx_aisle_location_id`、`idx_aisle_plant_code`、`idx_aisle_status`、唯一索引 `uk_aisle_plant_code(plant_code, aisle_code)`。

### 2.3 `wms_point` —— 地标/点位表

> 表注释：『地标/点位表：仅作为AGV路径规划和人员导航的坐标点，不承载库存信息』

| 字段 | 类型 | 说明 |
|------|------|------|
| id | int8（自增序列） | 主键 |
| plant_code | varchar(32) NOT NULL | 厂区编码（**冗余，便于厂区隔离查询**） |
| location_id | int8 NOT NULL | 所属区域ID，关联 wms_location.id（外键 fk_point_location_id，RESTRICT） |
| aisle_id | int8 NOT NULL | 所属巷道ID，关联 wms_aisle.id（外键 fk_point_aisle_id，RESTRICT） |
| floor | varchar(20) NOT NULL DEFAULT '' | 物理楼层（**冗余，便于按楼层筛选点位**） |
| point_code | varchar(64) NOT NULL | 点位编码（厂区内唯一，如 P-A01-001） |
| point_name | varchar(100) NOT NULL | 点位名称（如：A区一号巷入口点） |
| barcode | varchar(64) | 点位条码（PDA/AGV 扫码识别用） |
| coordinate | varchar(100) NOT NULL DEFAULT '' | 地图坐标（AGV 引擎定义格式，如 "X=100,Y=200,Z=0"） |
| sort_order | int4 NOT NULL DEFAULT 0 | 巷道内优先级/顺序号（数字越小越优先）：①AGV 按此顺序经过各点位；②多可用点位时优先推荐（作业调度） |
| status | int4 NOT NULL DEFAULT 1 | 状态：1 启用，0 停用（停用后 AGV 路径规划避开该点） |
| remark | varchar(500) | 备注信息 |
| created_by / created_time / updated_by / updated_time | int8 / timestamp | 审计字段 |

**索引**：`idx_point_aisle_id`、`idx_point_aisle_sort(aisle_id, sort_order)`（支撑 AGV 按顺序取点）、`idx_point_floor`、`idx_point_location_id`、`idx_point_plant_code`、`idx_point_status`、唯一索引 `uk_point_plant_code(plant_code, point_code)`。

### 2.4 冗余与约束设计小结

- **冗余字段设计**：三张表均冗余 `plant_code`，巷道/点位还冗余 `floor`——由上层（区域）写入时下推赋值，避免逐级 JOIN 即可按厂区/楼层过滤，减少 AGV 路径规划与筛选查询的关联成本；
- **point_count 计数**：`wms_aisle.point_count` 为冗余计数列，用于列表快速展示点位数量；
- **外键约束**：`fk_aisle_location_id`、`fk_point_aisle_id`、`fk_point_location_id` 均为 **ON DELETE RESTRICT**，与业务侧「删除前校验下级为空」的双重保护一致；
- **唯一约束**：三张表编码均以 `(plant_code, 编码)` 组合唯一，保证"厂区内唯一"。

---

## 3. 数据库交互

本模块与数据库的交互全部集中在 `com.wms.warehouse` 包内，底层为 **MyBatis-Plus**（`BaseMapper` / `ServiceImpl` / `LambdaQueryWrapper` / `LambdaUpdateWrapper` / `Page`），自定义分页 SQL 位于 `resources/mapper/warehouse/` 下 3 个 XML。

### 3.1 数据访问方式总览

| 能力 | 实现方式 | 说明 |
|------|---------|------|
| 通用 CRUD | 继承 `BaseMapper` / `ServiceImpl` | 单表增删改查零 SQL，如 `getById` / `save` / `updateById` / `removeById` / `listByIds` / `count` |
| 条件查询 | `LambdaQueryWrapper` | 类型安全条件构造：`likeRight`（编码前缀查找）、`in`（级联）、`eq`、`orderByDesc` + `.last("LIMIT 1")` 取最大编码 |
| 条件更新 | `LambdaUpdateWrapper` | 级联停用时批量 `update(entity, wrapper)`；`setSql` 写原生 SQL 片段维护 point_count |
| 分页查询 | 自定义 XML SQL + `Page` 对象 | 分页由 MyBatis-Plus 分页插件拦截改写，SQL 只写业务查询与 JOIN |
| 编码序列 | Redis `StringRedisTemplate` | `opsForValue().increment(key)` 原子自增，`setIfAbsent` 初始化（见 5.1） |

### 3.2 与数据库交互点明细（按业务流程）

| 流程 | 数据库操作 | 说明 |
|------|-----------|------|
| 分页列表 `getWmsLocationPage / getWmsAislePage / getWmsPointPage` | 各 Mapper XML 分页 SQL | LEFT JOIN `sys_user` 取创建/更新人昵称；条件动态拼接（见 3.4）；`WmsAisleMapper.xml` 用子查询实时计算 point_count |
| 新增区域 `saveWmsLocation` | `getOne(LambdaQueryWrapper)` + `save(entity)` | 事务内先查最大编码（likeRight + orderByDesc + LIMIT 1）初始化 Redis 序列，再插入 |
| 新增巷道 `saveWmsAisle` | `getOne` + `save(entity)` | 同上前置校验区域存在且启用 |
| 新增点位 `saveWmsPoint` | `getById`（巷道/区域）+ `save(entity)` + `setSql` 更新 | 校验巷道/区域启用 → 冗余下推 floor/plantCode/locationId → 生成编码 → 插入后 `point_count = point_count + 1` |
| 修改 `updateWmsLocation / updateWmsAisle` | `getById` + `updateById(entity)` | 厂区/区域变更时重新生成编码；区域改为停用时触发级联停用 |
| 修改点位 `updateWmsPoint` | `getById` + `updateById(entity)` + `setSql` | 切换巷道时重新生成编码，并对旧巷道 `GREATEST(point_count - 1, 0)`、新巷道 +1 |
| 删除区域 `deleteWmsLocations` | `count`（子区域）+ `selectCount`（巷道）+ `removeById` | 存在子区域/巷道则 Assert 拒绝删除 |
| 删除巷道 `deleteWmsAisles` | `selectCount`（点位）+ `removeById` | 存在点位则 Assert 拒绝删除 |
| 删除点位 `deleteWmsPoints` | `getById` + `removeById` + `setSql` | 逐条删除并回减 point_count（GREATEST 防负数） |
| 批量停用区域/巷道 | `listByIds` + `updateBatchById` + 级联 Mapper update | 停用（status=0）后触发 `WmsCascadeService` 批量更新下级 |
| 下拉选项 `getFormOptions / getFilterOptions` | `list(LambdaQueryWrapper.select(...))` | 仅查启用数据、投影必要字段，前端拼 label；区域筛选支持 厂区→楼层 级联 |

### 3.3 审计字段自动填充

三个实体均继承 [BaseEntity](../../wms/src/main/java/com/wms/common/base/BaseEntity.java)，但在子类中**覆盖声明**审计字段（源码中表现为实体自行声明 `createTime/updateTime/createBy/updateBy` 并映射到数据库 `created_time/updated_time/created_by/updated_by`）：

- `@TableField(value = "created_time", fill = FieldFill.INSERT)`、`@TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)`、`created_by`/`updated_by` 同理；
- 由框架层 `AutoFillMetaObjectHandler` 在 insert/update 时按属性名自动填充。

### 3.4 分页 SQL 关键片段

三个 Mapper XML 均以 `resultMap` 映射 VO，主表 LEFT JOIN `sys_user`（`su1` 取创建人昵称、`su2` 取更新人昵称），条件 `<if>` 动态拼接，`ORDER BY {sort_order} ASC, id ASC`。

- [WmsLocationMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsLocationMapper.xml)：过滤 plantCode/locationCode/locationName/floor/updatedBy(nickname)/status；另有 `getUpdatedByNames` 用 `foreach` 批量查更新人昵称（供筛选下拉）。
- [WmsAisleMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsAisleMapper.xml)：过滤 status/plantCode/floor/aisleCode/aisleName/locationCode/aislePurpose（等值）；`point_count` 用**子查询实时计算**：

```xml
(SELECT COUNT(*) FROM wms_point WHERE wms_point.aisle_id = a.id) AS point_count
```

- [WmsPointMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsPointMapper.xml)：三表 JOIN（wms_point p LEFT JOIN wms_location l、LEFT JOIN wms_aisle a），可同时按区域/巷道编码过滤，点位字段多为 LIKE 模糊匹配。

### 3.5 事务边界总结

| 方法 | 事务 | 说明 |
|------|------|------|
| `WmsPointServiceImpl.saveWmsPoint / updateWmsPoint / deleteWmsPoints / batchUpdateStatus` | `@Transactional(rollbackFor = Exception.class)` | 点位写库与 point_count 维护原子提交 |
| `WmsAisleServiceImpl.saveWmsAisle / updateWmsAisle / deleteWmsAisles / batchUpdateStatus` | 同上 | 巷道写库 + 级联停用点位原子提交 |
| `WmsLocationServiceImpl.saveWmsLocation / updateWmsLocation / deleteWmsLocations / batchUpdateStatus` | 同上 | 区域写库 + 级联停用巷道/点位原子提交 |
| `WmsCascadeServiceImpl.cascadeDisableLocations / cascadeDisableAisles` | 同上 | 级联停用各步原子提交 |

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/warehouse/...`；以下"引用的包"为该文件 import 中的主要部分。模块共 **32 个 Java 文件 + 3 个 Mapper XML**。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationController.java](../../wms/src/main/java/com/wms/warehouse/controller/WmsLocationController.java) | 库位/区域 REST 接口：`/api/v1/wms-location` 分页/新增/表单/修改/删除/批量状态/下拉选项 | `com.wms.warehouse.service.WmsLocationService`、`com.wms.common.model.BatchStatusForm`、`com.wms.warehouse.model.dto/vo.*`、`com.baomidou.mybatisplus.core.metadata.IPage`、`com.wms.common.annotation.Log/RepeatSubmit`、`com.wms.common.enums.ActionTypeEnum/LogModuleEnum`、`com.wms.common.result.PageResult/Result`、`io.swagger.v3.oas.annotations.*`、`org.springframework.security.access.prepost.PreAuthorize`、`jakarta.validation.Valid` | 权限标识 `warehouse:wms-location:*`；新增加 `@RepeatSubmit`；筛选选项接口支持 plantCode/floor 级联参数；类注释留有 TODO（检查级联删除、id 改雪花生成） |
| [WmsAisleController.java](../../wms/src/main/java/com/wms/warehouse/controller/WmsAisleController.java) | 巷道 REST 接口：`/api/v1/wms-aisle`，功能同上 | 同 WmsLocationController（WmsAisleService/WmsAisleDTO/WmsAisleQueryDTO/WmsAisleVO，`LogModuleEnum.WMS_AISLE`） | 权限标识 `warehouse:wms-aisle:*`；新增加 `@RepeatSubmit` |
| [WmsPointController.java](../../wms/src/main/java/com/wms/warehouse/controller/WmsPointController.java) | 点位 REST 接口：`/api/v1/wms-point`，功能同上 | 同 WmsLocationController（WmsPointService/WmsPointDTO/WmsPointQueryDTO/WmsPointVO，`LogModuleEnum.WMS_POINT`） | 权限标识 `warehouse:wms-point:*`；新增加 `@RepeatSubmit`；表单选项含厂区/区域/巷道三级 |

### 4.2 服务层（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationService.java](../../wms/src/main/java/com/wms/warehouse/service/WmsLocationService.java) | 区域业务接口 | `com.baomidou.mybatisplus.extension.service.IService`、`com.wms.warehouse.model.entity.WmsLocation`、`com.wms.warehouse.model.dto/vo.*`、`com.wms.common.model.BatchStatusForm`、`com.baomidou.mybatisplus.core.metadata.IPage` | 继承 `IService<WmsLocation>`；分页/表单/增删改/批量状态/选项 |
| [WmsAisleService.java](../../wms/src/main/java/com/wms/warehouse/service/WmsAisleService.java) | 巷道业务接口 | 同 WmsLocationService（实体为 WmsAisle） | 继承 `IService<WmsAisle>`，方法同构 |
| [WmsPointService.java](../../wms/src/main/java/com/wms/warehouse/service/WmsPointService.java) | 点位业务接口 | 同 WmsLocationService（实体为 WmsPoint） | 继承 `IService<WmsPoint>`，方法同构 |
| [WmsCascadeService.java](../../wms/src/main/java/com/wms/warehouse/service/WmsCascadeService.java) | 级联操作接口 | `java.util.List` | 声明 `cascadeDisableLocations(List<Long>)` / `cascadeDisableAisles(List<Long>)` |
| [WmsLocationServiceImpl.java](../../wms/src/main/java/com/wms/warehouse/service/impl/WmsLocationServiceImpl.java) | 区域业务核心实现 | `cn.hutool.core.lang.Assert/StrUtil`、`com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.metadata.IPage`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.baomidou.mybatisplus.extension.service.impl.ServiceImpl`、`com.wms.warehouse.utils.WmsLocationConverter/WmsCodeGeneratorService`、`com.wms.warehouse.mapper.WmsAisleMapper`、`com.wms.warehouse.service.WmsCascadeService`、`org.springframework.transaction.annotation.Transactional` | 编码生成（plantCode-序号）；删除前校验子区域/巷道为空；批量停用触发 `cascadeDisableLocations`；筛选选项查更新人昵称（`getUpdatedByNames`） |
| [WmsAisleServiceImpl.java](../../wms/src/main/java/com/wms/warehouse/service/impl/WmsAisleServiceImpl.java) | 巷道业务核心实现 | 同 WmsLocationServiceImpl（Converter 为 WmsAisleConverter；额外注入 `com.wms.warehouse.mapper.WmsPointMapper`） | 编码生成（locationCode-A序号）；区域变更重新编码；删除前校验点位为空（`selectCount`）；批量停用触发 `cascadeDisableAisles` |
| [WmsPointServiceImpl.java](../../wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java) | 点位业务核心实现 | 同 WmsLocationServiceImpl（Converter 为 WmsPointConverter；额外注入 `com.wms.warehouse.service.WmsAisleService/WmsLocationService`） | 新增/改巷道时校验巷道启用并冗余下推区域信息；编码生成（aisleCode-P序号）；**point_count 的 setSql 维护**（+1 / GREATEST 回减）；删除保护由巷道侧负责 |
| [WmsCascadeServiceImpl.java](../../wms/src/main/java/com/wms/warehouse/service/impl/WmsCascadeServiceImpl.java) | 级联停用实现 | `com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper`、`com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper`、`com.wms.warehouse.mapper.WmsAisleMapper/WmsPointMapper`、`com.wms.warehouse.model.entity.WmsAisle/WmsPoint`、`org.springframework.transaction.annotation.Transactional` | **直接使用 Mapper 层操作数据库，避免 Service 层循环依赖**；区域→巷道→点位逐级批量 `status=0`（见 5.2） |

### 4.3 持久层（mapper）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationMapper.java](../../wms/src/main/java/com/wms/warehouse/mapper/WmsLocationMapper.java) | 区域持久层接口 | `com.baomidou.mybatisplus.core.mapper.BaseMapper`、`com.baomidou.mybatisplus.extension.plugins.pagination.Page`、`com.wms.warehouse.model.entity.WmsLocation`、`com.wms.warehouse.model.dto.WmsLocationQueryDTO`、`com.wms.warehouse.model.vo.WmsLocationVO`、`org.apache.ibatis.annotations.Mapper/Param`、`java.util.List` | 继承 BaseMapper；分页查询 `getWmsLocationPage(Page, QueryDTO)` + `getUpdatedByNames(@Param("ids") List<Long>)`，SQL 在 XML |
| [WmsAisleMapper.java](../../wms/src/main/java/com/wms/warehouse/mapper/WmsAisleMapper.java) | 巷道持久层接口 | 同 WmsLocationMapper（实体 WmsAisle） | 仅分页查询，SQL 在 XML |
| [WmsPointMapper.java](../../wms/src/main/java/com/wms/warehouse/mapper/WmsPointMapper.java) | 点位持久层接口 | 同 WmsLocationMapper（实体 WmsPoint） | 仅分页查询（三表 JOIN），SQL 在 XML |
| [WmsLocationMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsLocationMapper.xml) | 区域分页/更新人昵称 SQL | MyBatis XML（resultMap + 动态 where + foreach） | LEFT JOIN sys_user 取昵称；`getUpdatedByNames` 用 `<foreach>` 批量查昵称去重排序 |
| [WmsAisleMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsAisleMapper.xml) | 巷道分页 SQL | MyBatis XML | LEFT JOIN wms_location 取区域编码；`point_count` 用**子查询实时计算**（见 3.4）；aislePurpose 等值过滤 |
| [WmsPointMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsPointMapper.xml) | 点位分页 SQL | MyBatis XML | 三表 JOIN（wms_point/wms_location/wms_aisle + sys_user×2）；按区域/巷道编码、点位字段 LIKE 过滤 |

### 4.4 实体层（model/entity）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocation.java](../../wms/src/main/java/com/wms/warehouse/model/entity/WmsLocation.java) | 库位/区域实体 | `com.baomidou.mybatisplus.annotation.*`（TableName/TableField/FieldFill）、`com.wms.common.base.BaseEntity`、`com.fasterxml.jackson.annotation.*`（JsonFormat/JsonInclude）、`lombok.Data/EqualsAndHashCode`、`java.time.LocalDateTime` | `@TableName("wms_location")`；覆盖声明审计字段 createTime/updateTime/createBy/updateBy（`FieldFill.INSERT/INSERT_UPDATE`），其余字段与表一一对应 |
| [WmsAisle.java](../../wms/src/main/java/com/wms/warehouse/model/entity/WmsAisle.java) | 巷道实体 | 同 WmsLocation（`@TableName("wms_aisle")`） | 业务字段：plantCode/locationId/aisleCode/aisleName/floor/sortOrder/status/remark/aislePurpose/isHandoverPoint |
| [WmsPoint.java](../../wms/src/main/java/com/wms/warehouse/model/entity/WmsPoint.java) | 点位实体 | 同 WmsLocation（`@TableName("wms_point")`） | 业务字段：plantCode/locationId/aisleId/floor/pointCode/pointName/barcode/coordinate/sortOrder/status/remark |

### 4.5 传输对象（model/dto）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsLocationDTO.java) | 区域表单 DTO | `io.swagger.v3.oas.annotations.media.Schema`、`jakarta.validation.constraints.NotBlank`、`org.hibernate.validator.constraints.Range`、`lombok.Getter/Setter` | plantCode/locationName `@NotBlank`；status `@Range(0,1)`；locationCode 系统生成不校验 |
| [WmsAisleDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsAisleDTO.java) | 巷道表单 DTO | 同 WmsLocationDTO（另含 `jakarta.validation.constraints.NotNull`） | locationId `@NotNull`、aisleName `@NotBlank`；含 aislePurpose/isHandoverPoint |
| [WmsPointDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsPointDTO.java) | 点位表单 DTO | 同 WmsAisleDTO | locationId/aisleId `@NotNull`、pointName `@NotBlank`；含 barcode/coordinate |
| [WmsLocationQueryDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsLocationQueryDTO.java) | 区域分页查询条件 | `com.wms.common.base.BaseQuery`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data/EqualsAndHashCode` | 继承 BaseQuery（pageNum/pageSize/sortBy）；plantCode/locationCode/locationName/locationType/floor/updatedBy/status |
| [WmsAisleQueryDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsAisleQueryDTO.java) | 巷道分页查询条件 | 同 WmsLocationQueryDTO | locationId/plantCode/aisleCode/aisleName/floor/locationCode/aislePurpose/status |
| [WmsPointQueryDTO.java](../../wms/src/main/java/com/wms/warehouse/model/dto/WmsPointQueryDTO.java) | 点位分页查询条件 | 同 WmsLocationQueryDTO | plantCode/locationId/aisleId/pointCode/pointName/barcode/coordinate/locationCode/aisleCode/floor/status |

### 4.6 视图对象（model/vo）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationVO.java](../../wms/src/main/java/com/wms/warehouse/model/vo/WmsLocationVO.java) | 区域视图对象 | `com.fasterxml.jackson.annotation.JsonFormat`、`io.swagger.v3.oas.annotations.media.Schema`、`lombok.Data`、`java.time.LocalDateTime` | 增加 plantName/locationTypeLabel/statusLabel（预留字段，当前 XML 未回填）与 createdByName/updatedByName |
| [WmsAisleVO.java](../../wms/src/main/java/com/wms/warehouse/model/vo/WmsAisleVO.java) | 巷道视图对象 | 同 WmsLocationVO | 增加 locationCode/aislePurpose/isHandoverPoint/pointCount 与创建/更新人昵称 |
| [WmsPointVO.java](../../wms/src/main/java/com/wms/warehouse/model/vo/WmsPointVO.java) | 点位视图对象 | 同 WmsLocationVO | 增加 locationCode/locationName/aisleCode/aisleName（JOIN 回填）与创建/更新人昵称 |

### 4.7 枚举（enums）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsStatusEnum.java](../../wms/src/main/java/com/wms/warehouse/enums/WmsStatusEnum.java) | 通用状态枚举 | `com.wms.common.base.IBaseEnum`、`lombok.AllArgsConstructor/Getter` | DISABLED(0,禁用) / ENABLED(1,启用)，实现 `IBaseEnum<Integer>` |
| [WmsLocationTypeEnum.java](../../wms/src/main/java/com/wms/warehouse/enums/WmsLocationTypeEnum.java) | 区域类型枚举 | 同 WmsStatusEnum | PLANT(0,厂区) / AREA(1,区域) / SHELF(2,货架) / LOCATION(3,库位) |

### 4.8 转换器与工具（utils）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [WmsLocationConverter.java](../../wms/src/main/java/com/wms/warehouse/utils/WmsLocationConverter.java) | 区域对象转换器 | `org.mapstruct.Mapper`、`com.wms.warehouse.model.entity.WmsLocation`、`com.wms.warehouse.model.dto.WmsLocationDTO` | `@Mapper(componentModel="spring")`，`toDTO`/`toEntity` 双向转换，编译期生成实现 |
| [WmsAisleConverter.java](../../wms/src/main/java/com/wms/warehouse/utils/WmsAisleConverter.java) | 巷道对象转换器 | 同 WmsLocationConverter（WmsAisle/WmsAisleDTO） | 同上 |
| [WmsPointConverter.java](../../wms/src/main/java/com/wms/warehouse/utils/WmsPointConverter.java) | 点位对象转换器 | 同 WmsLocationConverter（WmsPoint/WmsPointDTO） | 同上 |
| [WmsCodeGeneratorService.java](../../wms/src/main/java/com/wms/warehouse/utils/WmsCodeGeneratorService.java) | 编码生成服务（Redis INCR） | `cn.hutool.core.util.StrUtil`、`jakarta.annotation.Resource`、`org.springframework.data.redis.core.StringRedisTemplate`、`org.springframework.stereotype.Service`、`lombok.extern.slf4j.Slf4j`、`java.util.function.Supplier` | 三个生成方法共用 `initSeqIfAbsent`（`setIfAbsent` 原子初始化，并发安全）；静态 `extractSeq` 从编码提取序号；`deleteSeqCache` 清理序列缓存（修改厂区编码时用） |

---

## 5. 核心实现逻辑

### 5.1 自动编码规则（WmsCodeGeneratorService + Redis INCR）

三种编码均为「前缀-序号」结构，序号 3 位补零：

| 类型 | 格式 | 示例 | Redis Key | 初始化依据 |
|------|------|------|-----------|-----------|
| 区域编码 | `{plantCode}-{3位序号}` | `PLANT001-001` | `code:seq:location:{plantCode}` | 按 plantCode 查最大 locationCode |
| 巷道编码 | `{locationCode}-A{3位序号}` | `PLANT001-001-A001` | `code:seq:aisle:{locationCode}:A` | 按 locationCode 前缀查最大 aisleCode |
| 点位编码 | `{aisleCode}-P{3位序号}` | `PLANT001-001-A001-P001` | `code:seq:point:{aisleCode}` | 按 aisleCode 前缀查最大 pointCode |

**流程**：
1. `initSeqIfAbsent(key, maxSeqSupplier)`：`setIfAbsent(key, "0")` 原子尝试；仅当 key 不存在且当前线程初始化成功时，才调用 `maxSeqSupplier.get()`（数据库 `likeRight(前缀)` + `orderByDesc` + `LIMIT 1` + `extractSeq` 取最大已有序号）回填；
2. `opsForValue().increment(key)` 原子 +1 并返回；
3. 拼接前缀 + 序号返回。

**要点**：首次生成后 Redis 自增与库内已有数据衔接；`setIfAbsent` 保证多线程/多实例并发时只有一次 DB 初始化；编码「厂区内唯一」同时由数据库唯一索引 `uk_*_plant_code` 兜底。

### 5.2 级联停用流程（WmsCascadeService）

```
停用区域(WmsLocationServiceImpl.batchUpdateStatus / updateWmsLocation)
    └─ wmsCascadeService.cascadeDisableLocations(locationIds)
         ├─ 查区域下巷道ID：wmsAisleMapper.selectList(LambdaQueryWrapper.in(locationId))
         ├─ wmsAisleMapper.update(aisleUpdate(status=0), LambdaUpdateWrapper.in(id))
         └─ 递归 cascadeDisablePoints(aisleIds)
              └─ wmsPointMapper.update(pointUpdate(status=0), LambdaUpdateWrapper.in(aisleId))
停用巷道(WmsAisleServiceImpl.batchUpdateStatus)
    └─ wmsCascadeService.cascadeDisableAisles(aisleIds)
         └─ cascadeDisablePoints(aisleIds)
```

**要点**：
- **直接注入 Mapper 而非 Service**，避免 `WmsLocationService ↔ WmsAisleService ↔ WmsPointService` 的循环依赖；
- 整体在同一 `@Transactional(rollbackFor = Exception.class)` 事务内，任一步失败整体回滚；
- 批量更新采用「新实体 + LambdaUpdateWrapper」方式，不触发 MyBatis-Plus 全字段更新，仅更新 status 字段；
- 只停用不下发，恢复启用（status=1）时不自动恢复下级，由人工逐级启用。

### 5.3 point_count 双保险机制

`wms_aisle.point_count` 虽为冗余列（表注释原意"由触发器自动维护"，但**实际代码未使用触发器**，而是以下双保险）：

| 侧 | 实现 | 位置 |
|----|------|------|
| **写入侧（手动维护）** | 新增点位后 `setSql("point_count = point_count + 1")`；删除/换巷道时 `setSql("point_count = GREATEST(point_count - 1, 0)")`（GREATEST 防负数），同事务执行 | [WmsPointServiceImpl.java](../../wms/src/main/java/com/wms/warehouse/service/impl/WmsPointServiceImpl.java) |
| **查询侧（实时计算）** | 巷道分页 SQL 中用子查询 `(SELECT COUNT(*) FROM wms_point WHERE wms_point.aisle_id = a.id) AS point_count` 覆盖列值 | [WmsAisleMapper.xml](../../wms/src/main/resources/mapper/warehouse/WmsAisleMapper.xml) |

**设计意图**：写入侧保证冗余列与明细同步（供列表快速展示）；查询侧以实时 COUNT 兜底，即使冗余列因历史数据/异常发生偏差，列表展示仍正确——两套机制互备。

**相关校验**：巷道删除前 `selectCount` 校验点位数为 0，区域删除前校验子区域与巷道数为 0，与数据库外键 `ON DELETE RESTRICT` 形成双重保护。

### 5.4 新增/修改时的冗余字段下推

点位新增或切换巷道时，服务端自动完成「区域信息冗余下推」，前端无需提交：

```
巷道 → 区域 反查(wmsAisleService.getById → wmsLocationService.getById)
  ├─ 校验：巷道/区域存在且 status=1（停用不可挂点位/切巷道）
  └─ 下推：dto.floor = location.floor
           dto.plantCode = location.plantCode
           dto.locationId = location.id
```

同时校验所属巷道启用，避免向停用巷道写入点位导致 AGV 规划数据不生效。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| MyBatis-Plus | BaseMapper/ServiceImpl 通用 CRUD、LambdaQueryWrapper 条件查询、LambdaUpdateWrapper 条件更新 + setSql、Page 分页（分页插件拦截改写） |
| Redis（StringRedisTemplate） | 编码序列 `code:seq:*` 原子自增（INCR）与初始化（setIfAbsent），保证高并发编码唯一 |
| Spring `@Transactional` | 增删改与 point_count 维护、级联停用原子提交（rollbackFor = Exception.class） |
| MapStruct | DTO/Entity 编译期双向转换（WmsLocation/Aisle/PointConverter） |
| Hutool | Assert 断言（存在性/状态/计数校验）、StrUtil（字符串判空/拼接） |
| PostgreSQL 14+ | wms_location/wms_aisle/wms_point 三表；组合唯一索引保证"厂区内编码唯一"；外键 RESTRICT 防误删 |
| Spring Security `@PreAuthorize` | 接口级权限（warehouse:wms-location:* / wms-aisle:* / wms-point:*） |
| `@RepeatSubmit`（Redisson） | 新增接口防重复提交 |
| `@Log` AOP | 操作日志埋点（LogModuleEnum.WMS_LOCATION/WMS_AISLE/WMS_POINT） |
| Knife4j / Swagger（io.swagger.v3） | 接口文档注解 |
| Lombok | @Data/@Getter/@Setter/@RequiredArgsConstructor/@Slf4j |
