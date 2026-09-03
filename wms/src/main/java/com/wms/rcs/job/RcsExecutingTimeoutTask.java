package com.wms.rcs.job;

import com.wms.rcs.service.RcsTaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 执行中超时兜底定时任务
 * <p>
 * RCS 失联、回调中断、AGV 卡死不完成也不取消时，"执行中"任务不会自行进入终态，
 * 预占（remark=1）与预定任务标记（last_task_code）将永久占用起/终点点位。
 * 本任务定时扫描进入"执行中"超过阈值（sys_config: wms.rcs.executing.timeout-minutes，默认 120 分钟）
 * 仍无终态回馈的任务置为"异常"，复用 changeStatus 的 EXCEPTION 分支释放预占并清除预定任务标记。
 * </p>
 * 默认启用，可配置 {@code rcs.executing-timeout.enabled=false} 关闭；扫描周期可配
 * {@code rcs.executing-timeout.fixed-rate}（毫秒，默认 60000）。
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Component
@Slf4j
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "rcs.executing-timeout", name = "enabled", havingValue = "true", matchIfMissing = true)
public class RcsExecutingTimeoutTask {

    private final RcsTaskService rcsTaskService;

    @Scheduled(fixedRateString = "${rcs.executing-timeout.fixed-rate:60000}")
    public void execute() {
        try {
            int count = rcsTaskService.timeoutExecutingRcsTasks();
            if (count > 0) {
                log.warn("RCS执行超时兜底扫描：本轮置异常 {} 个", count);
            }
        } catch (Exception e) {
            log.error("RCS执行超时兜底扫描异常", e);
        }
    }
}
