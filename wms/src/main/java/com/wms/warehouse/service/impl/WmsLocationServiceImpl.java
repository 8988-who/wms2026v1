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
import java.util.Objects;

/**
 * 库位/区域业务服务实现
 * <p>
 * 实现库位/区域的分页查询、新增（自动生成编码）、修改（厂区编码不可变更，P0-1 已锁定）、
 * 删除、批量状态更新（级联停用巷道和点位）及级联筛选选项等功能。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WmsLocationServiceImpl extends ServiceImpl<WmsLocationMapper, WmsLocation> implements WmsLocationService {

    /**
     * 区域用途类型枚举（现场固定值，与数据库存量数据一致）
     * 仅作下拉选项/语义固化，不参与业务逻辑。
     */
    private static final List<String> LOCATION_TYPES = List.of(
            "湿坯下线", "防干", "干燥", "立浇交接", "检修/交接", "成型/立浇交接",
            "木板上线", "木板下线", "上线点", "青坯上线", "青坯下线", "施釉上线", "施釉下线","周转","其他");

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

        // P0-1 修复：禁止修改厂区编码，防止下级巷道/点位编码链断裂与冗余字段失准
        Assert.isTrue(Objects.equals(dto.getPlantCode(), existing.getPlantCode()),
                "厂区编码不可修改，如需迁移请删除该区域及下级后重建");

        dto.setLocationCode(existing.getLocationCode());

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
        // P1-2 修复：防御 Service 层被内部调用时 status 为空（HTTP 入口已有 @NotNull + @Valid 拦截）
        Assert.notNull(status, "状态不能为空");
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
                .select(WmsLocation::getPlantCode));

        java.util.Set<String> plantCodes = new java.util.LinkedHashSet<>();
        for (WmsLocation loc : list) {
            if (StrUtil.isNotBlank(loc.getPlantCode())) plantCodes.add(loc.getPlantCode());
        }

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodes));
        result.put("locationTypes", new java.util.ArrayList<>(LOCATION_TYPES));
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
                .select(WmsLocation::getLocationCode, WmsLocation::getFloor, WmsLocation::getUpdateBy, WmsLocation::getStatus);

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