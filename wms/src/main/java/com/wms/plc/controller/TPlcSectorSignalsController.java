package com.wms.plc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TPlcSectorSignals;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.plc.model.dto.TPlcSectorSignalsCreateDTO;
import com.wms.plc.model.dto.TPlcSectorSignalsQueryDTO;
import com.wms.plc.service.TPlcSectorSignalsService;
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
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * PLC信号块读写信号配置接口控制器
 */
@Tag(name = "PLC信号块读写信号配置接口")
@RestController
@RequestMapping("/api/v1/plc/sector")
@RequiredArgsConstructor
public class TPlcSectorSignalsController {

    private final TPlcSectorSignalsService tPlcSectorSignalsService;

    @Operation(summary = "PLC信号块读写信号配置分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public PageResult<TPlcSectorSignals> getTPlcSectorSignalsPage(TPlcSectorSignalsQueryDTO queryParams) {
        IPage<TPlcSectorSignals> result = tPlcSectorSignalsService.getTPlcSectorSignalsPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "信号块下拉选项")
    @GetMapping("/signal-block-options")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public Result<List<Option<String>>> getSignalBlockOptions() {
        return Result.success(tPlcSectorSignalsService.getSignalConfigOptions());
    }

    @Operation(summary = "新增PLC信号块读写信号配置")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SECTOR_SIGNALS, value = ActionTypeEnum.INSERT)
    public Result<Void> saveTPlcSectorSignal(@RequestBody @Valid TPlcSectorSignalsCreateDTO dto) {
        boolean result = tPlcSectorSignalsService.saveTPlcSectorSignal(dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除PLC信号块读写信号配置")
    @DeleteMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_SECTOR_SIGNALS, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteTPlcSectorSignals(
            @Parameter(description = "PLC信号块读写信号配置ID") @PathVariable String id
    ) {
        boolean result = tPlcSectorSignalsService.deleteTPlcSectorSignals(id);
        return Result.judge(result);
    }
}
