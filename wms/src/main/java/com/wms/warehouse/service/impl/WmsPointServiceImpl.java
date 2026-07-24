package com.wms.warehouse.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.warehouse.utils.WmsPointConverter;
import com.wms.warehouse.mapper.WmsPointMapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.wms.warehouse.model.entity.WmsLocation;
import com.wms.warehouse.model.entity.WmsPoint;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.dto.WmsPointDTO;
import com.wms.warehouse.model.dto.WmsPointQueryDTO;
import com.wms.warehouse.model.vo.WmsPointVO;
import com.wms.warehouse.service.WmsAisleService;
import com.wms.warehouse.service.WmsLocationService;
import com.wms.warehouse.service.WmsPointService;
import com.wms.warehouse.utils.WmsCodeGeneratorService;
import com.wms.common.service.PlantCodeScopeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 点位业务服务实现
 * <p>
 * 实现点位的分页查询、新增（自动生成编码、校验巷道状态、同步更新巷道点位计数）、
 * 修改（巷道变更时重新生成编码并调整计数）、删除（同步扣减巷道点位计数）、
 * 批量状态更新及表单/筛选选项等功能。
 * </p>
 *
 * @author Yadmin
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
    private final PlantCodeScopeService plantCodeScopeService;

    @Override
    public IPage<WmsPointVO> getWmsPointPage(WmsPointQueryDTO queryParams) {
        Page<WmsPointVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        queryParams.setDataScopePlantCodes(plantCodeScopeService.getAccessiblePlantCodes());
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
    @CacheEvict(cacheNames = {"wms:point:formOptions", "wms:point:filterOptions"}, allEntries = true)
    public boolean saveWmsPoint(WmsPointDTO dto) {
        WmsAisle aisle = wmsAisleService.getById(dto.getAisleId());
        Assert.notNull(aisle, "所属巷道不存在");
        Assert.isTrue(aisle.getStatus() == 1, "所属巷道已停用，无法新增点位");
        WmsLocation location = wmsLocationService.getById(aisle.getLocationId());
        Assert.notNull(location, "所属区域不存在");

        dto.setFloor(location.getFloor());
        dto.setPlantCode(location.getPlantCode());
        dto.setLocationId(location.getId());

        String pointCode = wmsCodeGeneratorService.generatePointCode(aisle.getAisleCode(), () -> {
            WmsPoint max = this.getOne(new LambdaQueryWrapper<WmsPoint>()
                    .likeRight(WmsPoint::getPointCode, aisle.getAisleCode() + "-P")
                    .select(WmsPoint::getPointCode)
                    .orderByDesc(WmsPoint::getPointCode)
                    .last("LIMIT 1"));
            return max != null ? WmsCodeGeneratorService.extractSeq(max.getPointCode(), aisle.getAisleCode() + "-P") : 0;
        });
        dto.setPointCode(pointCode);

        WmsPoint entity = wmsPointConverter.toEntity(dto);
        boolean result = this.save(entity);

        if (result) {
            wmsAisleService.lambdaUpdate()
                    .eq(WmsAisle::getId, dto.getAisleId())
                    .setSql("point_count = point_count + 1")
                    .update();
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"wms:point:formOptions", "wms:point:filterOptions"}, allEntries = true)
    public boolean updateWmsPoint(Long id, WmsPointDTO dto) {
        WmsPoint existing = this.getById(id);
        Assert.notNull(existing, "点位不存在");

        Long oldAisleId = existing.getAisleId();

        if (!dto.getAisleId().equals(oldAisleId)) {
            WmsAisle aisle = wmsAisleService.getById(dto.getAisleId());
            Assert.notNull(aisle, "所属巷道不存在");
            Assert.isTrue(aisle.getStatus() == 1, "所属巷道已停用，无法将点位切换到该巷道");
            WmsLocation location = wmsLocationService.getById(aisle.getLocationId());
            Assert.notNull(location, "所属区域不存在");

            dto.setFloor(location.getFloor());
            dto.setPlantCode(location.getPlantCode());
            dto.setLocationId(location.getId());

            String pointCode = wmsCodeGeneratorService.generatePointCode(aisle.getAisleCode(), () -> {
                WmsPoint max = this.getOne(new LambdaQueryWrapper<WmsPoint>()
                        .likeRight(WmsPoint::getPointCode, aisle.getAisleCode() + "-P")
                        .select(WmsPoint::getPointCode)
                        .orderByDesc(WmsPoint::getPointCode)
                        .last("LIMIT 1"));
                return max != null ? WmsCodeGeneratorService.extractSeq(max.getPointCode(), aisle.getAisleCode() + "-P") : 0;
            });
            dto.setPointCode(pointCode);
        } else {
            dto.setFloor(existing.getFloor());
            dto.setPlantCode(existing.getPlantCode());
            dto.setLocationId(existing.getLocationId());
            dto.setPointCode(existing.getPointCode());
        }

        WmsPoint entity = wmsPointConverter.toEntity(dto);
        entity.setId(id);
        boolean result = this.updateById(entity);

        if (result && !dto.getAisleId().equals(oldAisleId)) {
            wmsAisleService.lambdaUpdate()
                    .eq(WmsAisle::getId, oldAisleId)
                    .setSql("point_count = GREATEST(point_count - 1, 0)")
                    .update();
            wmsAisleService.lambdaUpdate()
                    .eq(WmsAisle::getId, dto.getAisleId())
                    .setSql("point_count = point_count + 1")
                    .update();
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    @CacheEvict(cacheNames = {"wms:point:formOptions", "wms:point:filterOptions"}, allEntries = true)
    public boolean deleteWmsPoints(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String idStr : idArray) {
            Long pointId = Long.parseLong(idStr);
            WmsPoint entity = this.getById(pointId);
            Assert.notNull(entity, "点位不存在：" + pointId);
            this.removeById(pointId);

            wmsAisleService.lambdaUpdate()
                    .eq(WmsAisle::getId, entity.getAisleId())
                    .setSql("point_count = GREATEST(point_count - 1, 0)")
                    .update();
        }
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchUpdateStatus(BatchStatusForm batchStatusForm) {
        List<Long> ids = batchStatusForm.getIds();
        Integer status = batchStatusForm.getStatus();
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
    @Cacheable(cacheNames = "wms:point:formOptions")
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
    @Cacheable(cacheNames = "wms:point:filterOptions")
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