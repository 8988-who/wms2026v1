package com.wms.warehouse.controller;

import com.wms.warehouse.service.WmsAisleService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.dto.WmsAisleDTO;
import com.wms.warehouse.model.dto.WmsAisleQueryDTO;
import com.wms.warehouse.model.vo.WmsAisleVO;
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
 * 巷道管理接口控制器
 * <p>
 * 提供巷道的增删改查、批量状态更新、表单下拉选项、搜索筛选等 REST API。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Tag(name = "巷道接口")
@RestController
@RequestMapping("/api/v1/wms-aisle")
@RequiredArgsConstructor
public class WmsAisleController {

    private final WmsAisleService wmsAisleService;

    @Operation(summary = "巷道分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:list')")
    @Log(module = LogModuleEnum.WMS_AISLE, value = ActionTypeEnum.LIST)
    public PageResult<WmsAisleVO> getWmsAislePage(WmsAisleQueryDTO queryParams) {
        IPage<WmsAisleVO> result = wmsAisleService.getWmsAislePage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增巷道")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.WMS_AISLE, value = ActionTypeEnum.INSERT)
    public Result<Void> saveWmsAisle(@RequestBody @Valid WmsAisleDTO dto) {
        boolean result = wmsAisleService.saveWmsAisle(dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取巷道表单数据")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:update')")
    public Result<WmsAisleDTO> getWmsAisleForm(
            @Parameter(description = "巷道ID") @PathVariable Long id
    ) {
        WmsAisleDTO dto = wmsAisleService.getWmsAisleFormData(id);
        return Result.success(dto);
    }

    @Operation(summary = "修改巷道")
    @PutMapping(value = "/{id}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:update')")
    @Log(module = LogModuleEnum.WMS_AISLE, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateWmsAisle(
            @Parameter(description = "巷道ID") @PathVariable Long id,
            @RequestBody @Validated WmsAisleDTO dto
    ) {
        boolean result = wmsAisleService.updateWmsAisle(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除巷道")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:delete')")
    @Log(module = LogModuleEnum.WMS_AISLE, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteWmsAisles(
            @Parameter(description = "巷道ID，多个以英文逗号(,)分割") @PathVariable String ids
    ) {
        boolean result = wmsAisleService.deleteWmsAisles(ids);
        return Result.judge(result);
    }

    @Operation(summary = "批量更新巷道状态（启用/停用）")
    @PutMapping("/status")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:update')")
    @Log(module = LogModuleEnum.WMS_AISLE, value = ActionTypeEnum.OTHER)
    public Result<Void> batchUpdateStatus(@RequestBody @Valid BatchStatusForm batchStatusForm) {
        boolean result = wmsAisleService.batchUpdateStatus(batchStatusForm);
        return Result.judge(result);
    }

    @Operation(summary = "获取表单下拉选项（厂区编码、所属区域）")
    @GetMapping("/form-options")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:list')")
    public Result<java.util.Map<String, java.util.List<?>>> getFormOptions() {
        java.util.Map<String, java.util.List<?>> options = wmsAisleService.getFormOptions();
        return Result.success(options);
    }

    @Operation(summary = "获取搜索筛选下拉选项（巷道编码、区域编码）")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-aisle:list')")
    public Result<java.util.Map<String, java.util.List<?>>> getFilterOptions() {
        java.util.Map<String, java.util.List<?>> options = wmsAisleService.getFilterOptions();
        return Result.success(options);
    }
}