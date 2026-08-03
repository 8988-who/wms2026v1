package com.wms.business.log.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.business.log.domain.ApiRequestLog;
import com.wms.business.log.dto.ApiRequestLogQueryDTO;
import com.wms.business.log.service.IApiRequestLogService;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 接口请求日志Controller
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Tag(name = "接口请求日志")
@RestController
@RequestMapping("/api/v1/api-request-logs")
@RequiredArgsConstructor
public class ApiRequestLogController {

    private final IApiRequestLogService apiRequestLogService;

    /**
     * 分页查询接口请求日志列表
     */
    @Operation(summary = "接口请求日志分页列表")
    @GetMapping
    @Log(module = LogModuleEnum.API_REQUEST_LOG, value = ActionTypeEnum.LIST)
    public PageResult<ApiRequestLog> list(ApiRequestLogQueryDTO queryDTO) {
        IPage<ApiRequestLog> result = apiRequestLogService.findList(queryDTO);
        return PageResult.success(result);
    }

    /**
     * 获取接口请求日志详细信息
     */
    @Operation(summary = "获取接口请求日志详细信息")
    @GetMapping("/{id}")
    public Result<ApiRequestLog> getInfo(
            @Parameter(description = "主键ID") @PathVariable String id
    ) {
        return Result.success(apiRequestLogService.getById(id));
    }

}
