package com.wms.rcs.controller;

import com.wms.common.annotation.Log;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.rcs.model.dto.RcsTaskReportDTO;
import com.wms.rcs.model.dto.RcsTaskWarningDTO;
import com.wms.rcs.service.RcsTaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * RCS 回调入站接口控制器（反向链路）
 * <p>
 * 接收外部 RCS 系统主动回馈，反查本地任务并驱动状态流转（阶段五）：
 * <ul>
 *     <li>{@code POST /task}：任务执行过程回馈（对应 RCS 出站接口 AGV_taskReporter），按阶段/状态映射本地 6 态；</li>
 *     <li>{@code POST /task/warning}：任务异常告警（对应 AGV_warningTask），流转为"异常"并记录告警；</li>
 *     <li>{@code POST /robot/warning}：机器人告警（对应 AGV_warningRobot），当前仅落日志。</li>
 * </ul>
 * </p>
 * <p>
 * <b>鉴权说明</b>：本组接口由外部 RCS 调用，<b>暂不纳入前台 {@code @ss} 权限</b>。需在安全放行清单
 * （配置项 {@code security.ignore-urls} 或 {@code security.unsecured-urls}）中放行
 * {@code /api/v1/rcs/reporter/**}。后续接入生产时应改为独立 token / 来源 IP 白名单校验
 * （见下方 TODO），与前台鉴权隔离。
 * </p>
 * <p>
 * <b>响应约定</b>：返回 RCS 期望的成功结构 {@code {"code":"0","message":"success"}}，
 * 与 {@code ApiRequestUtils.handleByModule} 对 RCS 返回值按 {@code code=="0"} 判定成功保持一致。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-07
 */
@Tag(name = "RCS回调入站接口")
@RestController
@RequestMapping("/api/v1/rcs/reporter")
@RequiredArgsConstructor
@Slf4j
public class RcsReporterController {

    private final RcsTaskService rcsTaskService;

    // TODO 接入生产前补充回调鉴权：校验固定 token（请求头 X-lr-* 或独立密钥）或来源 IP 白名单

    @Operation(summary = "RCS任务执行过程回馈")
    @PostMapping("/task")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.OTHER)
    public Map<String, Object> taskReport(@RequestBody RcsTaskReportDTO report) {
        log.info("收到RCS任务执行回馈：{}", report);
        boolean matched = rcsTaskService.handleTaskReport(report);
        return reply(matched);
    }

    @Operation(summary = "RCS任务异常告警")
    @PostMapping("/task/warning")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.OTHER)
    public Map<String, Object> taskWarning(@RequestBody RcsTaskWarningDTO warning) {
        log.warn("收到RCS任务异常告警：{}", warning);
        boolean matched = rcsTaskService.handleTaskWarning(warning);
        return reply(matched);
    }

    @Operation(summary = "RCS机器人异常告警")
    @PostMapping("/robot/warning")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.OTHER)
    public Map<String, Object> robotWarning(@RequestBody Map<String, Object> body) {
        // 机器人告警与具体任务无强绑定，当前仅落日志（后续可扩展为设备告警台账/通知）
        log.warn("收到RCS机器人异常告警：{}", body);
        return reply(true);
    }

    /**
     * 构造 RCS 期望的回馈响应体。
     * <p>无论是否匹配到本地任务，均返回成功码，避免 RCS 侧重试风暴；未匹配情况已在 Service 层落日志。</p>
     */
    private Map<String, Object> reply(boolean matched) {
        Map<String, Object> resp = new HashMap<>(4);
        resp.put("code", "0");
        resp.put("message", matched ? "success" : "received");
        return resp;
    }
}
