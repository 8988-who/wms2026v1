package com.wms.taskscheduling.controller;

import com.wms.taskscheduling.service.DispatchProcessService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 编排流程定义管理接口控制器（骨架）
 * <p>提供编排流程（步骤链：筛选条件 + 任务模板）的分页、详情、增删改；字段设计待确认后补充接口。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Tag(name = "编排流程定义接口")
@RestController
@RequestMapping("/api/v1/dispatch-process")
@RequiredArgsConstructor
public class DispatchProcessController {

    private final DispatchProcessService dispatchProcessService;
}
