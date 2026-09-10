package com.wms.plc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TSignalMethodConfig;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.plc.model.dto.TSignalMethodConfigCreateDTO;
import com.wms.plc.model.dto.TSignalMethodConfigQueryDTO;
import com.wms.plc.service.TSignalMethodConfigService;
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
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 信号值方法配置接口控制器
 */
@Tag(name = "信号值方法配置接口")
@RestController
@RequestMapping("/api/v1/plc/methodCode")
@RequiredArgsConstructor
public class TSignalMethodConfigController {

    private final TSignalMethodConfigService tSignalMethodConfigService;

    @Operation(summary = "信号值方法配置分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public PageResult<TSignalMethodConfig> getTSignalMethodConfigPage(TSignalMethodConfigQueryDTO queryParams) {
        IPage<TSignalMethodConfig> result = tSignalMethodConfigService.getTSignalMethodConfigPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "PLC连接下拉选项")
    @GetMapping("/plc-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<Option<String>>> getPlcOptions() {
        return Result.success(tSignalMethodConfigService.getPlcOptions());
    }

    @Operation(summary = "按PLC查询信号块下拉选项")
    @GetMapping("/signal-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<Option<String>>> getSignalConfigOptions(
            @Parameter(description = "PLC连接ID") @RequestParam(required = false) String plcId
    ) {
        return Result.success(tSignalMethodConfigService.getSignalConfigOptions(plcId));
    }

    @Operation(summary = "方法下拉选项")
    @GetMapping("/method-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<Option<String>>> getMethodOptions() {
        return Result.success(tSignalMethodConfigService.getMethodOptions());
    }

    @Operation(summary = "新增信号值方法配置")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_METHOD_CONFIG, value = ActionTypeEnum.INSERT)
    public Result<Void> saveTSignalMethodConfig(@RequestBody @Valid TSignalMethodConfigCreateDTO dto) {
        boolean result = tSignalMethodConfigService.saveTSignalMethodConfig(dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除信号值方法配置")
    @DeleteMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SIGNAL_METHOD_CONFIG, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteTSignalMethodConfig(
            @Parameter(description = "信号值方法配置ID") @PathVariable String id
    ) {
        boolean result = tSignalMethodConfigService.deleteTSignalMethodConfig(id);
        return Result.judge(result);
    }
}
