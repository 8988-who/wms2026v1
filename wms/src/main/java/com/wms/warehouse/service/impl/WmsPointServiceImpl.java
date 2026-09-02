package com.wms.warehouse.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.service.CartInventoryService;
import com.wms.warehouse.utils.WmsPointConverter;
import com.wms.warehouse.mapper.WmsPointMapper;
import com.wms.common.model.entity.WmsAisle;
import com.wms.common.model.entity.WmsLocation;
import com.wms.common.model.entity.WmsPoint;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.dto.WmsPointDTO;
import com.wms.warehouse.model.dto.WmsPointQueryDTO;
import com.wms.warehouse.model.vo.WmsPointVO;
import com.wms.warehouse.service.WmsAisleService;
import com.wms.warehouse.service.WmsLocationService;
import com.wms.warehouse.service.WmsPointService;
import com.wms.warehouse.utils.WmsCodeGeneratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

/**
 * 点位业务服务实现
 * <p>
 * 实现点位的分页查询、新增（自动生成编码、校验巷道/区域状态，支持不挂巷道的离散点位）、
 * 修改（巷道变更时重新生成编码）、删除、
 * 批量状态更新及表单/筛选选项等功能。
 * 点位数量采用 SQL 实时计算 + 手动维护双保险机制：
 * 查询时实时计算保证展示正确，写入时手动维护保证字段同步。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WmsPointServiceImpl extends ServiceImpl<WmsPointMapper, WmsPoint> implements WmsPointService {

    private final WmsPointConverter wmsPointConverter;
    private final WmsLocationService wmsLocationService;
    private final WmsAisleService wmsAisleService;
    private final WmsCodeGeneratorService wmsCodeGeneratorService;
    private final CartInventoryService cartInventoryService;

    @Override
    public IPage<WmsPointVO> getWmsPointPage(WmsPointQueryDTO queryParams) {
        Page<WmsPointVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.getBaseMapper().getWmsPointPage(page, queryParams);
    }

    @Override
    public WmsPointDTO getWmsPointFormData(Long id) {
        WmsPoint entity = this.getById(id);
        Assert.notNull(entity, "点位不存在");
        return wmsPointConverter.toDTO(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveWmsPoint(WmsPointDTO dto) {
        WmsAisle aisle = null;
        WmsLocation location;
        if (dto.getAisleId() != null) {
            aisle = wmsAisleService.getById(dto.getAisleId());
            Assert.notNull(aisle, "所属巷道不存在");
            Assert.isTrue(aisle.getStatus() == 1, "所属巷道已停用，无法新增点位");
            location = wmsLocationService.getById(aisle.getLocationId());
            Assert.notNull(location, "所属区域不存在");
            // P0-3 修复：补充校验所属区域启用状态，避免向停用区域下的巷道挂入点位
            Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法新增点位");
        } else {
            // 离散点位：不挂巷道（aisle_id=NULL），直接归属区域
            location = wmsLocationService.getById(dto.getLocationId());
            Assert.notNull(location, "所属区域不存在");
            Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法新增点位");
        }

        dto.setFloor(location.getFloor());
        dto.setPlantCode(location.getPlantCode());
        dto.setLocationId(location.getId());

        // P1-6 修复：barcode 厂区内唯一校验（空值跳过，DB 唯一索引兜底）
        if (StrUtil.isNotBlank(dto.getBarcode())) {
            long dupCount = this.count(new LambdaQueryWrapper<WmsPoint>()
                    .eq(WmsPoint::getPlantCode, dto.getPlantCode())
                    .eq(WmsPoint::getBarcode, dto.getBarcode()));
            Assert.isTrue(dupCount == 0, "该厂区下点位条码已存在：" + dto.getBarcode());
        }

        // 编码前缀：巷道点位用巷道编码，离散点位用区域编码
        String codePrefix = aisle != null ? aisle.getAisleCode() : location.getLocationCode();
        String pointCode = wmsCodeGeneratorService.generatePointCode(codePrefix, () -> {
            WmsPoint max = this.getOne(new LambdaQueryWrapper<WmsPoint>()
                    .likeRight(WmsPoint::getPointCode, codePrefix + "-P")
                    .select(WmsPoint::getPointCode)
                    .orderByDesc(WmsPoint::getPointCode)
                    .last("LIMIT 1"));
            return max != null ? WmsCodeGeneratorService.extractSeq(max.getPointCode(), codePrefix + "-P") : 0;
        });
        dto.setPointCode(pointCode);

        WmsPoint entity = wmsPointConverter.toEntity(dto);
        boolean result = this.save(entity);

        // 巷道点位维护巷道计数（离散点位无巷道计数可维护）
        if (result && aisle != null) {
            wmsAisleService.lambdaUpdate()
                    .eq(WmsAisle::getId, dto.getAisleId())
                    .setSql("point_count = point_count + 1")
                    .update();
        }

        // 库存联动：新增点位 → 占用表自动插入空位记录（cart_id=NULL），与点位新增同事务
        // 离散点位（aisleId=NULL）同样要生成空位记录，仅 aisle_id 冗余列为 NULL
        if (result) {
            CartInventory inventory = new CartInventory();
            inventory.setPointId(entity.getId());
            inventory.setPointCode(dto.getPointCode());
            inventory.setLocationId(dto.getLocationId());
            inventory.setAisleId(dto.getAisleId());
            inventory.setLockStatus(0);
            cartInventoryService.save(inventory);
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateWmsPoint(Long id, WmsPointDTO dto) {
        WmsPoint existing = this.getById(id);
        Assert.notNull(existing, "点位不存在");

        Long oldAisleId = existing.getAisleId();
        Long newAisleId = dto.getAisleId();
        boolean aisleChanged = !Objects.equals(newAisleId, oldAisleId);

        if (aisleChanged) {
            WmsAisle aisle = null;
            WmsLocation location;
            if (newAisleId != null) {
                aisle = wmsAisleService.getById(newAisleId);
                Assert.notNull(aisle, "所属巷道不存在");
                Assert.isTrue(aisle.getStatus() == 1, "所属巷道已停用，无法将点位切换到该巷道");
                location = wmsLocationService.getById(aisle.getLocationId());
                Assert.notNull(location, "所属区域不存在");
                // P0-3 修复：补充校验所属区域启用状态
                Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法将点位切换到该巷道");
            } else {
                // 切换为离散点位：不挂巷道（aisle_id=NULL），沿用原区域（编辑页区域不可改）
                location = wmsLocationService.getById(existing.getLocationId());
                Assert.notNull(location, "所属区域不存在");
                Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法修改点位");
            }

            dto.setFloor(location.getFloor());
            dto.setPlantCode(location.getPlantCode());
            dto.setLocationId(location.getId());

            // 编码前缀：巷道点位用巷道编码，离散点位用区域编码
            String codePrefix = aisle != null ? aisle.getAisleCode() : location.getLocationCode();
            String pointCode = wmsCodeGeneratorService.generatePointCode(codePrefix, () -> {
                WmsPoint max = this.getOne(new LambdaQueryWrapper<WmsPoint>()
                        .likeRight(WmsPoint::getPointCode, codePrefix + "-P")
                        .select(WmsPoint::getPointCode)
                        .orderByDesc(WmsPoint::getPointCode)
                        .last("LIMIT 1"));
                return max != null ? WmsCodeGeneratorService.extractSeq(max.getPointCode(), codePrefix + "-P") : 0;
            });
            dto.setPointCode(pointCode);
        } else {
            dto.setFloor(existing.getFloor());
            dto.setPlantCode(existing.getPlantCode());
            dto.setLocationId(existing.getLocationId());
            dto.setPointCode(existing.getPointCode());
        }

        // P1-6 修复：barcode 厂区内唯一校验（空值跳过，排除自身，DB 唯一索引兜底）
        if (StrUtil.isNotBlank(dto.getBarcode())) {
            long dupCount = this.count(new LambdaQueryWrapper<WmsPoint>()
                    .eq(WmsPoint::getPlantCode, dto.getPlantCode())
                    .eq(WmsPoint::getBarcode, dto.getBarcode())
                    .ne(WmsPoint::getId, id));
            Assert.isTrue(dupCount == 0, "该厂区下点位条码已存在：" + dto.getBarcode());
        }

        WmsPoint entity = wmsPointConverter.toEntity(dto);
        entity.setId(id);
        boolean result = this.updateById(entity);

        // updateById 的非空更新策略不会将 aisle_id 更新为 NULL，切换为离散点位时需显式置空
        if (result && newAisleId == null) {
            this.lambdaUpdate()
                    .eq(WmsPoint::getId, id)
                    .set(WmsPoint::getAisleId, null)
                    .update();
        }

        if (result && aisleChanged) {
            if (oldAisleId != null) {
                wmsAisleService.lambdaUpdate()
                        .eq(WmsAisle::getId, oldAisleId)
                        .setSql("point_count = GREATEST(point_count - 1, 0)")
                        .update();
            }
            if (newAisleId != null) {
                wmsAisleService.lambdaUpdate()
                        .eq(WmsAisle::getId, newAisleId)
                        .setSql("point_count = point_count + 1")
                        .update();
            }
        }

        // 库存联动：点位编辑后同步占用表冗余字段（point_code/location_id/aisle_id），与点位编辑同事务
        if (result) {
            cartInventoryService.lambdaUpdate()
                    .eq(CartInventory::getPointId, id)
                    .set(CartInventory::getPointCode, dto.getPointCode())
                    .set(CartInventory::getLocationId, dto.getLocationId())
                    .set(CartInventory::getAisleId, dto.getAisleId())
                    .update();
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteWmsPoints(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String idStr : idArray) {
            Long pointId = Long.parseLong(idStr);
            WmsPoint entity = this.getById(pointId);
            Assert.notNull(entity, "点位不存在：" + pointId);

            // 库存联动：点位下存在停靠料车时禁止删除
            CartInventory inventory = cartInventoryService.getOne(new LambdaQueryWrapper<CartInventory>()
                    .eq(CartInventory::getPointId, pointId));
            Assert.isTrue(inventory == null || inventory.getCartId() == null,
                    "点位下存在停靠料车，无法删除：" + entity.getPointCode());

            this.removeById(pointId);

            // 库存联动：同步删除该点位的占用记录（空位记录随点位一起清理）
            cartInventoryService.remove(new LambdaQueryWrapper<CartInventory>()
                    .eq(CartInventory::getPointId, pointId));

            // 离散点位（aisle_id=NULL）无巷道计数可维护
            if (entity.getAisleId() != null) {
                wmsAisleService.lambdaUpdate()
                        .eq(WmsAisle::getId, entity.getAisleId())
                        .setSql("point_count = GREATEST(point_count - 1, 0)")
                        .update();
            }
        }
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchUpdateStatus(BatchStatusForm batchStatusForm) {
        List<Long> ids = batchStatusForm.getIds();
        Integer status = batchStatusForm.getStatus();
        // P1-2 修复：防御 Service 层被内部调用时 status 为空（HTTP 入口已有 @NotNull + @Valid 拦截）
        Assert.notNull(status, "状态不能为空");
        if (ids == null || ids.isEmpty()) {
            return false;
        }
        List<WmsPoint> list = this.listByIds(ids);
        for (WmsPoint point : list) {
            point.setStatus(status);
        }
        return this.updateBatchById(list);
    }

    @Override
    public java.util.Map<String, java.util.List<?>> getFormOptions() {
        java.util.List<WmsLocation> locations = wmsLocationService.list(
                new LambdaQueryWrapper<WmsLocation>()
                        .eq(WmsLocation::getStatus, 1)
                        .select(WmsLocation::getId, WmsLocation::getPlantCode,
                                WmsLocation::getLocationCode, WmsLocation::getLocationName,
                                WmsLocation::getFloor)
        );

        java.util.Set<String> plantCodeSet = new java.util.LinkedHashSet<>();
        for (WmsLocation loc : locations) {
            if (StrUtil.isNotBlank(loc.getPlantCode())) {
                plantCodeSet.add(loc.getPlantCode());
            }
        }

        java.util.List<java.util.Map<String, Object>> locationList = new java.util.ArrayList<>();
        for (WmsLocation loc : locations) {
            java.util.Map<String, Object> item = new java.util.LinkedHashMap<>();
            item.put("id", loc.getId());
            item.put("code", loc.getLocationCode());
            item.put("plantCode", loc.getPlantCode());
            item.put("name", loc.getLocationName());
            item.put("floor", loc.getFloor());
            item.put("label", loc.getLocationCode() + " - " + loc.getLocationName());
            locationList.add(item);
        }

        java.util.List<WmsAisle> aisles = wmsAisleService.list(
                new LambdaQueryWrapper<WmsAisle>()
                        .eq(WmsAisle::getStatus, 1)
                        .select(WmsAisle::getId, WmsAisle::getAisleCode, WmsAisle::getAisleName,
                                WmsAisle::getLocationId)
        );

        java.util.List<java.util.Map<String, Object>> aisleList = new java.util.ArrayList<>();
        for (WmsAisle aisle : aisles) {
            java.util.Map<String, Object> item = new java.util.LinkedHashMap<>();
            item.put("id", aisle.getId());
            item.put("code", aisle.getAisleCode());
            item.put("name", aisle.getAisleName());
            item.put("locationId", aisle.getLocationId());
            item.put("label", aisle.getAisleCode() + " - " + aisle.getAisleName());
            aisleList.add(item);
        }

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodeSet));
        result.put("locations", locationList);
        result.put("aisles", aisleList);
        return result;
    }

    @Override
    public java.util.Map<String, java.util.List<?>> getFilterOptions() {
        // 点位编码
        java.util.List<String> pointCodes = this.list(new LambdaQueryWrapper<WmsPoint>()
                .select(WmsPoint::getPointCode))
                .stream().map(WmsPoint::getPointCode).filter(StrUtil::isNotBlank).distinct().sorted()
                .collect(java.util.stream.Collectors.toList());

        // 区域编码
        java.util.List<String> locationCodes = wmsLocationService.list(
                new LambdaQueryWrapper<WmsLocation>()
                        .select(WmsLocation::getLocationCode))
                .stream().map(WmsLocation::getLocationCode).filter(StrUtil::isNotBlank).distinct().sorted()
                .collect(java.util.stream.Collectors.toList());

        // 巷道编码
        java.util.List<String> aisleCodes = wmsAisleService.list(
                new LambdaQueryWrapper<WmsAisle>()
                        .select(WmsAisle::getAisleCode))
                .stream().map(WmsAisle::getAisleCode).filter(StrUtil::isNotBlank).distinct().sorted()
                .collect(java.util.stream.Collectors.toList());

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("pointCodes", pointCodes);
        result.put("locationCodes", locationCodes);
        result.put("aisleCodes", aisleCodes);
        return result;
    }
}