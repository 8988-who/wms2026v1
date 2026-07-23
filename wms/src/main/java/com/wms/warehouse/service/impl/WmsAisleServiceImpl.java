package com.wms.warehouse.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.utils.WmsAisleConverter;
import com.wms.warehouse.mapper.WmsAisleMapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.wms.warehouse.model.entity.WmsLocation;
import com.wms.warehouse.model.dto.WmsAisleDTO;
import com.wms.warehouse.model.dto.WmsAisleQueryDTO;
import com.wms.warehouse.model.vo.WmsAisleVO;
import com.wms.warehouse.service.WmsAisleService;
import com.wms.warehouse.service.WmsCascadeService;
import com.wms.warehouse.service.WmsLocationService;
import com.wms.warehouse.utils.WmsCodeGeneratorUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 巷道业务服务实现
 * <p>
 * 实现巷道的分页查询、新增（自动生成编码、校验区域状态）、修改（区域变更时重新生成编码）、
 * 删除、批量状态更新（级联停用点位）及表单/筛选选项等功能。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WmsAisleServiceImpl extends ServiceImpl<WmsAisleMapper, WmsAisle> implements WmsAisleService {

    private final WmsAisleConverter wmsAisleConverter;
    private final WmsLocationService wmsLocationService;
    private final WmsCascadeService wmsCascadeService;

    @Override
    public IPage<WmsAisleVO> getWmsAislePage(WmsAisleQueryDTO queryParams) {
        Page<WmsAisleVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.getBaseMapper().getWmsAislePage(page, queryParams);
    }

    @Override
    public WmsAisleDTO getWmsAisleFormData(Long id) {
        WmsAisle entity = this.getById(id);
        Assert.notNull(entity, "巷道不存在");
        return wmsAisleConverter.toDTO(entity);
    }

    @Override
    public boolean saveWmsAisle(WmsAisleDTO dto) {
        WmsLocation location = wmsLocationService.getById(dto.getLocationId());
        Assert.notNull(location, "所属区域不存在");
        Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法新增巷道");

        dto.setFloor(location.getFloor());

        List<String> existingCodes = this.list(new LambdaQueryWrapper<WmsAisle>()
                .likeRight(WmsAisle::getAisleCode, location.getLocationCode() + "-A")
                .select(WmsAisle::getAisleCode))
                .stream()
                .map(WmsAisle::getAisleCode)
                .toList();

        String aisleCode = WmsCodeGeneratorUtil.generateAisleCode(location.getLocationCode(), "A", () -> existingCodes);
        dto.setAisleCode(aisleCode);

        WmsAisle entity = wmsAisleConverter.toEntity(dto);
        return this.save(entity);
    }

    @Override
    public boolean updateWmsAisle(Long id, WmsAisleDTO dto) {
        WmsAisle existing = this.getById(id);
        Assert.notNull(existing, "巷道不存在");

        if (!dto.getLocationId().equals(existing.getLocationId())) {
            WmsLocation location = wmsLocationService.getById(dto.getLocationId());
            Assert.notNull(location, "所属区域不存在");
            Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法将巷道切换到该区域");

            dto.setFloor(location.getFloor());

            List<String> existingCodes = this.list(new LambdaQueryWrapper<WmsAisle>()
                    .likeRight(WmsAisle::getAisleCode, location.getLocationCode() + "-A")
                    .select(WmsAisle::getAisleCode))
                    .stream()
                    .map(WmsAisle::getAisleCode)
                    .toList();

            String aisleCode = WmsCodeGeneratorUtil.generateAisleCode(location.getLocationCode(), "A", () -> existingCodes);
            dto.setAisleCode(aisleCode);
        } else {
            dto.setAisleCode(existing.getAisleCode());
            dto.setFloor(existing.getFloor());
        }

        WmsAisle entity = wmsAisleConverter.toEntity(dto);
        entity.setId(id);
        return this.updateById(entity);
    }

    @Override
    public boolean deleteWmsAisles(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String id : idArray) {
            WmsAisle entity = this.getById(Long.parseLong(id));
            Assert.notNull(entity, "巷道不存在");
            this.removeById(Long.parseLong(id));
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
        List<WmsAisle> list = this.listByIds(ids);
        for (WmsAisle aisle : list) {
            aisle.setStatus(status);
        }
        boolean result = this.updateBatchById(list);

        if (result && status == 0) {
            wmsCascadeService.cascadeDisableAisles(ids);
        }

        return result;
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
            item.put("name", loc.getLocationName());
            item.put("floor", loc.getFloor());
            item.put("label", loc.getLocationCode() + " - " + loc.getLocationName());
            locationList.add(item);
        }

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodeSet));
        result.put("locations", locationList);
        return result;
    }

    @Override
    public java.util.List<String> getFilterOptions() {
        java.util.List<WmsAisle> list = this.list(new LambdaQueryWrapper<WmsAisle>()
                .select(WmsAisle::getAisleCode));
        return list.stream()
                .map(WmsAisle::getAisleCode)
                .filter(StrUtil::isNotBlank)
                .distinct()
                .sorted()
                .collect(java.util.stream.Collectors.toList());
    }
}