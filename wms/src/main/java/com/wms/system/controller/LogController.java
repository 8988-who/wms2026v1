package com.wms.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.system.model.query.LogQuery;
import com.wms.system.model.vo.LogPageVO;
import com.wms.system.model.vo.VisitOverviewVO;
import com.wms.system.model.vo.VisitTrendVO;
import com.wms.system.service.LogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;

/**
 * 日志控制层
 *
 * @author Ray.Hao
 * @since 2.10.0
 */
@Tag(name = "09.日志接口")
@RestController
@RequestMapping("/api/v1/logs")
@RequiredArgsConstructor
public class LogController {

    private final LogService logService;

    @Operation(summary = "日志分页列表")
    @GetMapping
    @Log(module = LogModuleEnum.LOG, value = ActionTypeEnum.LIST)
    public PageResult<LogPageVO> getLogPage(
             LogQuery queryParams
    ) {
        Page<LogPageVO> result = logService.getLogPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "访问趋势统计")
    @GetMapping("/analytics/trend")
    public Result<VisitTrendVO> getVisitTrend(
            @Parameter(description = "开始时间", example = "2024-01-01") @RequestParam String startDate,
            @Parameter(description = "结束时间", example = "2024-12-31") @RequestParam String endDate
    ) {
        LocalDate start = LocalDate.parse(startDate);
        LocalDate end = LocalDate.parse(endDate);
        VisitTrendVO data = logService.getVisitTrend(start, end);
        return Result.success(data);
    }

    @Operation(summary = "访问统计概览")
    @GetMapping("/analytics/overview")
    public Result<VisitOverviewVO> getVisitOverview() {
        VisitOverviewVO result = logService.getVisitStats();
        return Result.success(result);
    }

}
