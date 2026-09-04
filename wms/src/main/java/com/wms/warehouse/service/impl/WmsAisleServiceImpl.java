package com.wms.warehouse.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.carriermanagementsystem.cartmodel.service.CartModelService;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.utils.WmsAisleConverter;
import com.wms.warehouse.mapper.WmsAisleMapper;
import com.wms.warehouse.mapper.WmsPointMapper;
import com.wms.common.model.entity.WmsAisle;
import com.wms.common.model.entity.WmsLocation;
import com.wms.common.model.entity.WmsPoint;
import com.wms.warehouse.model.dto.WmsAisleDTO;
import com.wms.warehouse.model.dto.WmsAisleQueryDTO;
import com.wms.warehouse.model.vo.WmsAisleVO;
import com.wms.warehouse.service.WmsAisleService;
import com.wms.warehouse.service.WmsCascadeService;
import com.wms.warehouse.service.WmsLocationService;
import com.wms.warehouse.utils.WmsCodeGeneratorService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 巷道业务服务实现
 * <p>
 * 实现巷道的分页查询、新增（自动生成编码、校验区域状态）、修改（锁定所属区域、停用时级联停用点位）、
 * 删除、批量状态更新（级联停用点位）及表单/筛选选项等功能。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class WmsAisleServiceImpl extends ServiceImpl<WmsAisleMapper, WmsAisle> implements WmsAisleService {

    private final WmsAisleConverter wmsAisleConverter;
    private final WmsLocationService wmsLocationService;
    private final WmsCascadeService wmsCascadeService;
    private final WmsCodeGeneratorService wmsCodeGeneratorService;
    private final WmsPointMapper wmsPointMapper;
    private final CartModelService cartModelService;

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
    @Transactional(rollbackFor = Exception.class)
    public boolean saveWmsAisle(WmsAisleDTO dto) {
        WmsLocation location = wmsLocationService.getById(dto.getLocationId());
        Assert.notNull(location, "所属区域不存在");
        Assert.isTrue(location.getStatus() == 1, "所属区域已停用，无法新增巷道");

        // R-2 修复：巷道 plantCode 冗余字段从所属区域下推（与 saveWmsPoint 一致）
        dto.setPlantCode(location.getPlantCode());
        dto.setFloor(location.getFloor());

        String aisleCode = wmsCodeGeneratorService.generateAisleCode(location.getLocationCode(), "A", () -> {
            WmsAisle max = this.getOne(new LambdaQueryWrapper<WmsAisle>()
                    .likeRight(WmsAisle::getAisleCode, location.getLocationCode() + "-A")
                    .select(WmsAisle::getAisleCode)
                    .orderByDesc(WmsAisle::getAisleCode)
                    .last("LIMIT 1"));
            return max != null ? WmsCodeGeneratorService.extractSeq(max.getAisleCode(), location.getLocationCode() + "-A") : 0;
        });
        dto.setAisleCode(aisleCode);

        WmsAisle entity = wmsAisleConverter.toEntity(dto);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateWmsAisle(Long id, WmsAisleDTO dto) {
        WmsAisle existing = this.getById(id);
        Assert.notNull(existing, "巷道不存在");

        // P0-2 修复：禁止切换所属区域，防止下级点位编码链断裂与冗余字段失准
        Assert.isTrue(dto.getLocationId().equals(existing.getLocationId()),
                "所属区域不可变更，如需迁移请删除该巷道及下级后重建");

        // R-2 修复：plantCode 冗余字段从所属区域下推（与 saveWmsPoint 一致）
        WmsLocation location = wmsLocationService.getById(existing.getLocationId());
        Assert.notNull(location, "所属区域不存在");
        dto.setPlantCode(location.getPlantCode());

        dto.setAisleCode(existing.getAisleCode());
        dto.setFloor(existing.getFloor());

        WmsAisle entity = wmsAisleConverter.toEntity(dto);
        entity.setId(id);
        boolean result = this.updateById(entity);

        // R-3 修复：货架型号支持清空——updateById 默认忽略 null 字段，
        // 编辑时清空 modelCode 不会落库，需在保存后显式将该字段置 NULL
        if (result && StrUtil.isBlank(dto.getModelCode())) {
            this.lambdaUpdate()
                    .eq(WmsAisle::getId, id)
                    .set(WmsAisle::getModelCode, null)
                    .update();
        }

        // R-1 修复：单条编辑停用时级联停用其下点位（与 updateWmsLocation 行为对齐）
        if (result && dto.getStatus() != null && dto.getStatus() == 0) {
            wmsCascadeService.cascadeDisableAisles(List.of(id));
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteWmsAisles(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String id : idArray) {
            Long aisleId = Long.parseLong(id);
            WmsAisle entity = this.getById(aisleId);
            Assert.notNull(entity, "巷道不存在");

            Long pointCount = wmsPointMapper.selectCount(
                    new LambdaQueryWrapper<WmsPoint>()
                            .eq(WmsPoint::getAisleId, aisleId));
            Assert.isTrue(pointCount == 0, "该巷道下存在" + pointCount + "个点位，请先删除点位后重试");

            this.removeById(aisleId);
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
            item.put("plantCode", loc.getPlantCode());
            item.put("name", loc.getLocationName());
            item.put("floor", loc.getFloor());
            item.put("label", loc.getLocationCode() + " - " + loc.getLocationName());
            locationList.add(item);
        }

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("plantCodes", new java.util.ArrayList<>(plantCodeSet));
        result.put("locations", locationList);
        result.put("modelOptions", buildModelOptions());
        return result;
    }

    /** 构建货架型号下拉选项（来自料车型号配置 wms_cart_model） */
    private java.util.List<java.util.Map<String, Object>> buildModelOptions() {
        return cartModelService.formOptions().stream()
                .map(m -> {
                    java.util.Map<String, Object> item = new java.util.LinkedHashMap<>();
                    item.put("modelCode", m.getModelCode());
                    item.put("modelName", m.getModelName());
                    item.put("label", m.getModelCode() + " - " + m.getModelName());
                    return item;
                })
                .collect(java.util.stream.Collectors.toList());
    }

    @Override
    public java.util.Map<String, java.util.List<?>> getFilterOptions() {
        // 巷道编码
        java.util.List<String> aisleCodes = this.list(new LambdaQueryWrapper<WmsAisle>()
                .select(WmsAisle::getAisleCode))
                .stream().map(WmsAisle::getAisleCode).filter(StrUtil::isNotBlank).distinct().sorted()
                .collect(java.util.stream.Collectors.toList());

        // 区域编码
        java.util.List<String> locationCodes = wmsLocationService.list(
                new LambdaQueryWrapper<WmsLocation>()
                        .select(WmsLocation::getLocationCode))
                .stream().map(WmsLocation::getLocationCode).filter(StrUtil::isNotBlank).distinct().sorted()
                .collect(java.util.stream.Collectors.toList());

        java.util.Map<String, java.util.List<?>> result = new java.util.LinkedHashMap<>();
        result.put("aisleCodes", aisleCodes);
        result.put("locationCodes", locationCodes);
        result.put("modelOptions", buildModelOptions());
        return result;
    }
}