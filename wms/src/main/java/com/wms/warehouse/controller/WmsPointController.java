package com.wms.warehouse.controller;

import com.wms.warehouse.service.WmsPointService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.dto.WmsPointDTO;
import com.wms.warehouse.model.dto.WmsPointQueryDTO;
import com.wms.warehouse.model.vo.WmsPointVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RepeatSubmit;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
import jakarta.validation.Valid;

/**
 * 点位管理接口控制器
 * <p>
 * 提供点位的增删改查、批量状态更新、表单下拉选项、搜索筛选等 REST API。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Tag(name = "点位接口")
@RestController
@RequestMapping("/api/v1/wms-point")
@RequiredArgsConstructor
public class WmsPointController {

    private final WmsPointService wmsPointService;

    @Operation(summary = "点位分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:list')")
    @Log(module = LogModuleEnum.WMS_POINT, value = ActionTypeEnum.LIST)
    public PageResult<WmsPointVO> getWmsPointPage(WmsPointQueryDTO queryParams) {
        IPage<WmsPointVO> result = wmsPointService.getWmsPointPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增点位")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.WMS_POINT, value = ActionTypeEnum.INSERT)
    public Result<Void> saveWmsPoint(@RequestBody @Valid WmsPointDTO dto) {
        boolean result = wmsPointService.saveWmsPoint(dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取点位表单数据")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:update')")
    public Result<WmsPointDTO> getWmsPointForm(
            @Parameter(description = "点位ID") @PathVariable Long id
    ) {
        WmsPointDTO dto = wmsPointService.getWmsPointFormData(id);
        return Result.success(dto);
    }

    @Operation(summary = "修改点位")
    @PutMapping(value = "/{id}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:update')")
    @Log(module = LogModuleEnum.WMS_POINT, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateWmsPoint(
            @Parameter(description = "点位ID") @PathVariable Long id,
            @RequestBody @Validated WmsPointDTO dto
    ) {
        boolean result = wmsPointService.updateWmsPoint(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除点位")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:delete')")
    @Log(module = LogModuleEnum.WMS_POINT, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteWmsPoints(
            @Parameter(description = "点位ID，多个以英文逗号(,)分割") @PathVariable String ids
    ) {
        boolean result = wmsPointService.deleteWmsPoints(ids);
        return Result.judge(result);
    }

    @Operation(summary = "批量更新点位状态（启用/停用）")
    @PutMapping("/status")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:update')")
    @Log(module = LogModuleEnum.WMS_POINT, value = ActionTypeEnum.OTHER)
    public Result<Void> batchUpdateStatus(@RequestBody @Valid BatchStatusForm batchStatusForm) {
        boolean result = wmsPointService.batchUpdateStatus(batchStatusForm);
        return Result.judge(result);
    }

    @Operation(summary = "获取表单下拉选项（厂区编码、所属区域、所属巷道）")
    @GetMapping("/form-options")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:list')")
    public Result<java.util.Map<String, java.util.List<?>>> getFormOptions() {
        java.util.Map<String, java.util.List<?>> options = wmsPointService.getFormOptions();
        return Result.success(options);
    }

    @Operation(summary = "获取搜索筛选下拉选项（点位编码、区域编码、巷道编码）")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-point:list')")
    public Result<java.util.Map<String, java.util.List<?>>> getFilterOptions() {
        java.util.Map<String, java.util.List<?>> options = wmsPointService.getFilterOptions();
        return Result.success(options);
    }
}