package com.wms.plc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.plc.model.dto.TWmsPlcConnectionCreateDTO;
import com.wms.plc.model.dto.TWmsPlcConnectionQueryDTO;
import com.wms.plc.model.vo.TWmsPlcConnectionLocationVO;
import com.wms.plc.model.vo.TWmsPlcConnectionVO;
import com.wms.plc.service.TWmsPlcConnectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import jakarta.validation.Valid;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * PLC连接配置接口控制器
 */
@Tag(name = "PLC连接配置接口")
@RestController
@RequestMapping("/api/v1/plc/task")
@RequiredArgsConstructor
public class TWmsPlcConnectionController {

    private final TWmsPlcConnectionService tWmsPlcConnectionService;

    @Operation(summary = "PLC连接配置分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('plc:task:list')")
    @Log(module = LogModuleEnum.PLC_CONNECTION, value = ActionTypeEnum.LIST)
    public PageResult<TWmsPlcConnectionVO> getTWmsPlcConnectionPage(TWmsPlcConnectionQueryDTO queryParams) {
        IPage<TWmsPlcConnectionVO> result = tWmsPlcConnectionService.getTWmsPlcConnectionPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "获取PLC区域选项")
    @GetMapping("/location-options")
    @PreAuthorize("@ss.hasPerm('plc:task:list')")
    public Result<List<TWmsPlcConnectionLocationVO>> getTWmsPlcConnectionLocationOptions() {
        return Result.success(tWmsPlcConnectionService.getTWmsPlcConnectionLocationOptions());
    }

    @Operation(summary = "新增PLC连接配置")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('plc:task:create')")
    @Log(module = LogModuleEnum.PLC_CONNECTION, value = ActionTypeEnum.INSERT)
    public Result<Void> saveTWmsPlcConnection(@RequestBody @Valid TWmsPlcConnectionCreateDTO dto) {
        boolean result = tWmsPlcConnectionService.saveTWmsPlcConnection(dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除PLC连接配置")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('plc:task:delete')")
    @Log(module = LogModuleEnum.PLC_CONNECTION, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteTWmsPlcConnections(
            @Parameter(description = "PLC配置ID，多个以英文逗号(,)分割") @PathVariable String ids
    ) {
        boolean result = tWmsPlcConnectionService.deleteTWmsPlcConnections(ids);
        return Result.judge(result);
    }

    @Operation(summary = "修改PLC连接启用状态")
    @PutMapping("/{id}/enabled")
    @PreAuthorize("@ss.hasPerm('plc:task:update')")
    @Log(module = LogModuleEnum.PLC_CONNECTION, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateTWmsPlcConnectionEnabled(
            @Parameter(description = "PLC配置ID") @PathVariable String id,
            @Parameter(description = "启用状态，1=启用，0=禁用") @RequestParam Integer enabled
    ) {
        boolean result = tWmsPlcConnectionService.updateTWmsPlcConnectionEnabled(id, enabled);
        return Result.judge(result);
    }

    @Operation(summary = "重新连接PLC")
    @PutMapping("/{id}/reconnect")
    @PreAuthorize("@ss.hasPerm('plc:task:update')")
    @Log(module = LogModuleEnum.PLC_CONNECTION, value = ActionTypeEnum.UPDATE)
    public Result<Void> reconnectTWmsPlcConnection(
            @Parameter(description = "PLC配置ID") @PathVariable String id
    ) {
        boolean result = tWmsPlcConnectionService.reconnectTWmsPlcConnection(id);
        return Result.judge(result);
    }
}
