package com.wms.warehouse.controller;

import com.wms.warehouse.service.WmsLocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.dto.WmsLocationDTO;
import com.wms.warehouse.model.dto.WmsLocationQueryDTO;
import com.wms.warehouse.model.vo.WmsLocationVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
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
 * 库位/区域管理接口控制器
 * <p>
 * 提供库位/区域的增删改查、批量状态更新、级联筛选等 REST API。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Tag(name = "库位/区域接口")
@RestController
@RequestMapping("/api/v1/wms-location")
@RequiredArgsConstructor
public class WmsLocationController {

    private final WmsLocationService wmsLocationService;

    @Operation(summary = "库位/区域分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:list')")
    public PageResult<WmsLocationVO> getWmsLocationPage(WmsLocationQueryDTO queryParams) {
        IPage<WmsLocationVO> result = wmsLocationService.getWmsLocationPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增库位/区域")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:create')")
    public Result<Void> saveWmsLocation(@RequestBody @Valid WmsLocationDTO dto) {
        boolean result = wmsLocationService.saveWmsLocation(dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取库位/区域表单数据")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:update')")
    public Result<WmsLocationDTO> getWmsLocationForm(
            @Parameter(description = "库位/区域ID") @PathVariable Long id
    ) {
        WmsLocationDTO dto = wmsLocationService.getWmsLocationFormData(id);
        return Result.success(dto);
    }

    @Operation(summary = "修改库位/区域")
    @PutMapping(value = "/{id}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:update')")
    public Result<Void> updateWmsLocation(
            @Parameter(description = "库位/区域ID") @PathVariable Long id,
            @RequestBody @Validated WmsLocationDTO dto
    ) {
        boolean result = wmsLocationService.updateWmsLocation(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除库位/区域")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:delete')")
    public Result<Void> deleteWmsLocations(
            @Parameter(description = "库位/区域ID，多个以英文逗号(,)分割") @PathVariable String ids
    ) {
        boolean result = wmsLocationService.deleteWmsLocations(ids);
        return Result.judge(result);
    }

    @Operation(summary = "批量更新库位/区域状态（启用/停用）")
    @PutMapping("/status")
    @PreAuthorize("@ss.hasPerm('warehouse:wms-location:update')")
    public Result<Void> batchUpdateStatus(@RequestBody @Valid BatchStatusForm batchStatusForm) {
        boolean result = wmsLocationService.batchUpdateStatus(batchStatusForm);
        return Result.judge(result);
    }

    @Operation(summary = "获取搜索下拉选项（支持级联筛选：厂区→楼层→区域编码）")
    @GetMapping("/filter-options")
    public Result<java.util.Map<String, java.util.List<String>>> getFilterOptions(
            @Parameter(description = "厂区编码，传此参数后楼层和区域编码仅返回该厂区下的数据") @RequestParam(required = false) String plantCode,
            @Parameter(description = "楼层，传此参数后区域编码仅返回该楼层下的数据") @RequestParam(required = false) String floor
    ) {
        java.util.Map<String, java.util.List<String>> options = wmsLocationService.getFilterOptions(plantCode, floor);
        return Result.success(options);
    }
}