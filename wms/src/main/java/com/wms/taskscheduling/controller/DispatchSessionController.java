package com.wms.taskscheduling.controller;

import com.wms.taskscheduling.service.DispatchSessionService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 调度会话管理接口控制器（骨架）
 * <p>提供调度会话的启动/停止/状态查询；字段设计待确认后补充接口。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Tag(name = "调度会话接口")
@RestController
@RequestMapping("/api/v1/dispatch-session")
@RequiredArgsConstructor
public class DispatchSessionController {

    private final DispatchSessionService dispatchSessionService;
}
