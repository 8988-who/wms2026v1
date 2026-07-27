package com.wms.warehouse.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.utils.WmsLocationConverter;
import com.wms.warehouse.mapper.WmsAisleMapper;
import com.wms.warehouse.mapper.WmsLocationMapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.wms.warehouse.model.entity.WmsLocation;
import com.wms.warehouse.model.dto.WmsLocationDTO;
import com.wms.warehouse.model.dto.WmsLocationQueryDTO;
import com.wms.warehouse.model.vo.WmsLocationVO;
import com.wms.warehouse.service.WmsCascadeService;
import com.wms.warehouse.service.WmsLocationService;
import com.wms.warehouse.utils.WmsCodeGeneratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 库位/区域业务服务实现
 * <p>
 * 实现库位/区域的分页查询、新增（自动生成编码）、修改（厂区变更时重新生成编码）、
 * 删除、批量状态更新（级联停用巷道和点位）及级联筛选选项等功能。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WmsLocationServiceImpl extends ServiceImpl<WmsLocationMapper, WmsLocation> implements WmsLocationService {

    private final WmsLocationConverter wmsLocationConverter;
    private final WmsCascadeService wmsCascadeService;
    private final WmsCodeGeneratorService wmsCodeGeneratorService;
    private final WmsAisleMapper wmsAisleMapper;

    @Override
    public IPage<WmsLocationVO> getWmsLocationPage(WmsLocationQueryDTO queryParams) {
        Page<WmsLocationVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.getBaseMapper().getWmsLocationPage(page, queryParams);
    }

    @Override
    public WmsLocationDTO getWmsLocationFormData(Long id) {
        WmsLocation entity = this.getById(id);
        Assert.notNull(entity, "库位/区域不存在");
        return wmsLocationConverter.toDTO(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveWmsLocation(WmsLocationDTO dto) {
        String plantCode = dto.getPlantCode();

        String locationCode = wmsCodeGeneratorService.generateLocationCode(plantCode, () -> {
            WmsLocation max = this.getOne(new LambdaQueryWrapper<WmsLocation>()
                    .eq(WmsLocation::getPlantCode, plantCode)
                    .select(WmsLocation::getLocationCode)
                    .orderByDesc(WmsLocation::getLocationCode)
                    .last("LIMIT 1"));
            return max != null ? WmsCodeGeneratorService.extractSeq(max.getLocationCode(), plantCode + "-") : 0;
        });
        dto.setLocationCode(locationCode);

        WmsLocation entity = wmsLocationConverter.toEntity(dto);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateWmsLocation(Long id, WmsLocationDTO dto) {
        WmsLocation existing = this.getById(id);
        Assert.notNull(existing, "库位/区域不存在");

        String newPlantCode = dto.getPlantCode();
        String oldPlantCode = existing.getPlantCode();

        if (!newPlantCode.equals(oldPlantCode)) {
            String locationCode = wmsCodeGeneratorService.generateLocationCode(newPlantCode, () -> {
                WmsLocation max = this.getOne(new LambdaQueryWrapper<WmsLocation>()
                        .eq(WmsLocation::getPlantCode, newPlantCode)
                        .select(WmsLocation::getLocationCode)
                        .orderByDesc(WmsLocation::getLocationCode)
                        .last("LIMIT 1"));
                return max != null ? WmsCodeGeneratorService.extractSeq(max.getLocationCode(), newPlantCode + "-") : 0;
            });
            dto.setLocationCode(locationCode);
        } else {
            dto.setLocationCode(existing.getLocationCode());
        }

        WmsLocation entity = wmsLocationConverter.toEntity(dto);
        entity.setId(id);
        boolean result = this.updateById(entity);

        if (result && dto.getStatus() != null && dto.getStatus() == 0) {
            wmsCascadeService.cascadeDisableLocations(List.of(id));
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteWmsLocations(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String id : idArray) {
            Long locationId = Long.parseLong(id);
            WmsLocation entity = this.getById(locationId);
            Assert.notNull(entity, "库位/区域不存在");

            Long childCount = this.count(new LambdaQueryWrapper<WmsLocation>()
                    .eq(WmsLocation::getParentId, locationId));
            Assert.isTrue(childCount == 0, "该区域下存在" + childCount + "个子区域，请先删除子区域后重试");

            Long aisleCount = wmsAisleMapper.selectCount(
                    new LambdaQueryWrapper<WmsAisle>()
                            .eq(WmsAisle::getLocationId, locationId));
            Assert.isTrue(aisleCount == 0, "该区域下存在" + aisleCount + "条巷道，请先删除巷道后重试");

            this.removeById(locationId);
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
        List<WmsLocation> list = this.listByIds(ids);
        for (WmsLocation location : list) {
            location.setStatus(status);
        }
        boolean result = this.updateBatchById(list);

        if (result && status == 0) {
            wmsCascadeService.cascadeDisableLocations(ids);
        }

        return result;
    }

    @Override
    public java.util.Map<String, java.util.List<?>> getFormOptions() {
        java.util.List<WmsLocation> list = this.list(new LambdaQueryWrapper<WmsLocation>()
                .select(WmsLocation::getPlantCode, WmsLocation::getLocationType));

        java.util.Set<String> plantCodes = new java.util.LinkedHashSet<>();
        java.util.Set<String> locationTypes = new java.util.LinkedHashSet<>();
        for (WmsLocation loc : list) {
            if (StrUtil.isNotBlank(loc.getPlantCode())) plantCodes.add(loc.getPlantCode());
            if (StrUtil.isNotBlank(loc.getLocationType())) locationTypes.add(loc.getLocationType());
        }

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodes));
        result.put("locationTypes", new java.util.ArrayList<>(locationTypes));
        return result;
    }

    @Override
    public java.util.Map<String, java.util.List<String>> getFilterOptions(String plantCode, String floor) {
        java.util.List<WmsLocation> allPlants = this.list(new LambdaQueryWrapper<WmsLocation>()
                .select(WmsLocation::getPlantCode));
        java.util.Set<String> plantCodes = new java.util.LinkedHashSet<>();
        for (WmsLocation loc : allPlants) {
            if (StrUtil.isNotBlank(loc.getPlantCode())) plantCodes.add(loc.getPlantCode());
        }

        LambdaQueryWrapper<WmsLocation> wrapper = new LambdaQueryWrapper<WmsLocation>()
                .select(WmsLocation::getLocationCode, WmsLocation::getFloor, WmsLocation::getUpdateBy);

        if (StrUtil.isNotBlank(plantCode)) {
            wrapper.eq(WmsLocation::getPlantCode, plantCode);
        }
        if (StrUtil.isNotBlank(floor)) {
            wrapper.eq(WmsLocation::getFloor, floor);
        }

        java.util.List<WmsLocation> list = this.list(wrapper);

        java.util.Set<String> locationCodes = new java.util.LinkedHashSet<>();
        java.util.Set<String> floors = new java.util.LinkedHashSet<>();
        java.util.Set<Long> updatedByIds = new java.util.LinkedHashSet<>();
        java.util.Set<String> statuses = new java.util.LinkedHashSet<>();
        for (WmsLocation loc : list) {
            if (StrUtil.isNotBlank(loc.getLocationCode())) locationCodes.add(loc.getLocationCode());
            if (StrUtil.isNotBlank(loc.getFloor())) floors.add(loc.getFloor());
            if (loc.getUpdateBy() != null) updatedByIds.add(loc.getUpdateBy());
            if (loc.getStatus() != null) statuses.add(String.valueOf(loc.getStatus()));
        }

        java.util.List<String> updatedByNames = new java.util.ArrayList<>();
        if (!updatedByIds.isEmpty()) {
            updatedByNames = this.getBaseMapper().getUpdatedByNames(new java.util.ArrayList<>(updatedByIds));
        }

        java.util.Map<String, java.util.List<String>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodes));
        result.put("locationCodes", new java.util.ArrayList<>(locationCodes));
        result.put("floors", new java.util.ArrayList<>(floors));
        result.put("updatedByNames", updatedByNames);
        result.put("statuses", new java.util.ArrayList<>(statuses));
        return result;
    }

}