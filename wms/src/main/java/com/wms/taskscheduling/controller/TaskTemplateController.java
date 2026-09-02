package com.wms.taskscheduling.controller;

import com.wms.taskscheduling.service.TaskTemplateService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 任务模板管理接口控制器（骨架）
 * <p>提供任务模板的分页、详情、增删改；字段设计待确认后补充接口。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Tag(name = "任务模板接口")
@RestController
@RequestMapping("/api/v1/task-template")
@RequiredArgsConstructor
public class TaskTemplateController {

    private final TaskTemplateService taskTemplateService;
}
