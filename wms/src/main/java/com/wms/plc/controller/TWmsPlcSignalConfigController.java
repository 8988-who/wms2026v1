package com.wms.plc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.plc.model.dto.TWmsPlcSignalConfigCreateDTO;
import com.wms.plc.model.dto.TWmsPlcSignalConfigQueryDTO;
import com.wms.plc.model.vo.TWmsPlcConnectionOptionVO;
import com.wms.plc.model.vo.TWmsPlcPointOptionVO;
import com.wms.plc.model.vo.TWmsPlcSignalConfigVO;
import com.wms.plc.service.TWmsPlcSignalConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * PLC信号块配置接口控制器
 */
@Tag(name = "PLC信号块配置接口")
@RestController
@RequestMapping("/api/v1/plc/board")
@RequiredArgsConstructor
public class TWmsPlcSignalConfigController {

    private final TWmsPlcSignalConfigService tWmsPlcSignalConfigService;

    @Operation(summary = "PLC信号块配置分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_CONFIG, value = ActionTypeEnum.LIST)
    public PageResult<TWmsPlcSignalConfigVO> getTWmsPlcSignalConfigPage(TWmsPlcSignalConfigQueryDTO queryParams) {
        IPage<TWmsPlcSignalConfigVO> result = tWmsPlcSignalConfigService.getTWmsPlcSignalConfigPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "PLC连接下拉选项")
    @GetMapping("/plc-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<TWmsPlcConnectionOptionVO>> getTWmsPlcConnectionOptions() {
        return Result.success(tWmsPlcSignalConfigService.getTWmsPlcConnectionOptions());
    }

    @Operation(summary = "储位（点位）下拉选项")
    @GetMapping("/point-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<TWmsPlcPointOptionVO>> getWmsPointOptions() {
        return Result.success(tWmsPlcSignalConfigService.getWmsPointOptions());
    }

    @Operation(summary = "新增PLC信号块配置")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_CONFIG, value = ActionTypeEnum.INSERT)
    public Result<Void> saveTWmsPlcSignalConfig(@RequestBody @Valid TWmsPlcSignalConfigCreateDTO dto) {
        boolean result = tWmsPlcSignalConfigService.saveTWmsPlcSignalConfig(dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除PLC信号块配置")
    @DeleteMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_CONFIG, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteTWmsPlcSignalConfig(
            @Parameter(description = "PLC信号块配置ID") @PathVariable String id
    ) {
        boolean result = tWmsPlcSignalConfigService.deleteTWmsPlcSignalConfig(id);
        return Result.judge(result);
    }

    @Operation(summary = "修改PLC信号块配置启用状态")
    @PutMapping("/{id}/enabled")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_CONFIG, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateTWmsPlcSignalConfigEnabled(
            @Parameter(description = "PLC信号块配置ID") @PathVariable String id,
            @Parameter(description = "启用状态，1=启用，0=禁用") @RequestParam Integer enabled
    ) {
        boolean result = tWmsPlcSignalConfigService.updateTWmsPlcSignalConfigEnabled(id, enabled);
        return Result.judge(result);
    }
}
