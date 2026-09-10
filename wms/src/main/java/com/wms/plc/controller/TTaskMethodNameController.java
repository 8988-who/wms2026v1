package com.wms.plc.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.model.entity.TTaskMethodName;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.plc.model.dto.TTaskMethodNameCreateDTO;
import com.wms.plc.model.dto.TTaskMethodNameQueryDTO;
import com.wms.plc.service.TTaskMethodNameService;
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

/**
 * 方法名配置接口控制器
 */
@Tag(name = "方法名配置接口")
@RestController
@RequestMapping("/api/v1/plc/taskname")
@RequiredArgsConstructor
public class TTaskMethodNameController {

    private final TTaskMethodNameService tTaskMethodNameService;

    @Operation(summary = "方法名配置分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    public PageResult<TTaskMethodName> getTTaskMethodNamePage(TTaskMethodNameQueryDTO queryParams) {
        IPage<TTaskMethodName> result = tTaskMethodNameService.getTTaskMethodNamePage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增方法名配置")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_TASK_METHOD_NAME, value = ActionTypeEnum.INSERT)
    public Result<Void> saveTTaskMethodName(@RequestBody @Valid TTaskMethodNameCreateDTO dto) {
        boolean result = tTaskMethodNameService.saveTTaskMethodName(dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除方法名配置")
    @DeleteMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('plc:board:list')")
    @Log(module = LogModuleEnum.PLC_TASK_METHOD_NAME, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteTTaskMethodName(
            @Parameter(description = "方法名配置ID") @PathVariable String id
    ) {
        boolean result = tTaskMethodNameService.deleteTTaskMethodName(id);
        return Result.judge(result);
    }
}
