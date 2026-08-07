package com.wms.rcs.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RepeatSubmit;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.vo.RcsTaskVO;
import com.wms.rcs.service.RcsTaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

/**
 * RCS本地任务管理接口控制器
 * <p>
 * 提供 RCS 调度任务的分页查询、详情（含状态变更时间线）、新增、修改、删除。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Tag(name = "RCS本地任务接口")
@RestController
@RequestMapping("/api/v1/rcs-task")
@RequiredArgsConstructor
public class RcsTaskController {

    private final RcsTaskService rcsTaskService;

    @Operation(summary = "RCS任务分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('rcs:task:list')")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.LIST)
    public PageResult<RcsTaskVO> getRcsTaskPage(RcsTaskQueryDTO queryParams) {
        IPage<RcsTaskVO> result = rcsTaskService.getRcsTaskPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "获取RCS任务详情（含状态变更历史）")
    @GetMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('rcs:task:list')")
    public Result<RcsTaskVO> getRcsTaskDetail(
            @Parameter(description = "任务ID") @PathVariable Long id
    ) {
        return Result.success(rcsTaskService.getRcsTaskDetail(id));
    }

    @Operation(summary = "新增RCS任务")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('rcs:task:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.INSERT)
    public Result<Void> saveRcsTask(@RequestBody @Valid RcsTaskDTO dto) {
        return Result.judge(rcsTaskService.saveRcsTask(dto));
    }

    @Operation(summary = "修改RCS任务")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('rcs:task:update')")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateRcsTask(
            @Parameter(description = "任务ID") @PathVariable Long id,
            @RequestBody @Validated RcsTaskDTO dto
    ) {
        return Result.judge(rcsTaskService.updateRcsTask(id, dto));
    }

    @Operation(summary = "删除RCS任务")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('rcs:task:delete')")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteRcsTasks(
            @Parameter(description = "任务ID，多个以英文逗号(,)分割") @PathVariable String ids
    ) {
        return Result.judge(rcsTaskService.deleteRcsTasks(ids));
    }
}
