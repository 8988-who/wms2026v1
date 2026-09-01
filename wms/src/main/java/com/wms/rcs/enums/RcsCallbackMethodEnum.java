package com.wms.rcs.enums;

import com.wms.rcs.event.RcsTaskInventoryEvent;
import lombok.Getter;

/**
 * RCS 任务执行过程回馈动作枚举
 * <p>
 * 将 RCS 回调中 {@code extra.values.method} 的字符串值映射为强类型枚举，
 * 绑定对应的本地任务状态与库存联动动作。精确匹配优先于关键词模糊匹配，
 * 避免误命中（如 {@code notifyPodArrange} 不会被误判为"货架到达"）。
 * </p>
 * <p>
 * 枚举未命中时回退到 {@link RcsTaskServiceImpl#mapReportToStatus} 的关键词模糊匹配。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-31
 */
@Getter
public enum RcsCallbackMethodEnum {

    /** 货架到达目标位 → 任务完成 + 确认目标到达 */
    NOTIFY_POD_ARR   ("notifyPodArr",    RcsTaskStatusEnum.FINISHED,   RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE),
    /** 货架离开源位 → 执行中 + 解绑源点位 */
    NOTIFY_POD_LEAV  ("notifyPodLeav",   RcsTaskStatusEnum.EXECUTING,  RcsTaskInventoryEvent.Action.UNBIND),
    /** 机器人到达途经点 → 执行中 */
    NOTIFY_ROBOT_ARR ("notifyRobotArr",  RcsTaskStatusEnum.EXECUTING,  null),
    /** 机器人离开途经点 → 执行中 */
    NOTIFY_ROBOT_LEAV("notifyRobotLeav", RcsTaskStatusEnum.EXECUTING,  null),
    /** 到达目标位 → 任务完成 + 确认目标到达 */
    ARRIVED_TARGET   ("arrivedTarget",   RcsTaskStatusEnum.FINISHED,   RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE),
    /** 任务开始 → 执行中 */
    START_TASK       ("startTask",       RcsTaskStatusEnum.EXECUTING,  null),
    /** 任务完成 → 已完成 + 确认目标到达 */
    FINISH_TASK      ("finishTask",      RcsTaskStatusEnum.FINISHED,   RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE),
    /** 任务取消 → 已取消 */
    CANCEL_TASK      ("cancelTask",      RcsTaskStatusEnum.CANCELLED,  null),
    /** 任务异常 → 异常 */
    ERROR_TASK       ("errorTask",       RcsTaskStatusEnum.EXCEPTION,  null),
    /** 未匹配到任何已知 method */
    UNKNOWN          (null,              null,                          null);

    /** RCS 回调 method 字符串（原值，匹配时忽略大小写） */
    private final String method;

    /** 映射的本地任务状态 */
    private final RcsTaskStatusEnum targetStatus;

    /** 库存联动动作（null 表示不需要库存联动） */
    private final RcsTaskInventoryEvent.Action inventoryAction;

    RcsCallbackMethodEnum(String method, RcsTaskStatusEnum targetStatus, RcsTaskInventoryEvent.Action inventoryAction) {
        this.method = method;
        this.targetStatus = targetStatus;
        this.inventoryAction = inventoryAction;
    }

    /**
     * 根据 RCS 回调 method 字符串精确匹配枚举（忽略大小写）。
     *
     * @param method RCS 回调中的 method 值（如 "notifyPodArr"）
     * @return 匹配到的枚举，未匹配返回 {@link #UNKNOWN}
     */
    public static RcsCallbackMethodEnum fromMethod(String method) {
        if (method == null || method.isBlank()) {
            return UNKNOWN;
        }
        String m = method.trim();
        for (RcsCallbackMethodEnum e : values()) {
            if (e != UNKNOWN && e.method != null && e.method.equalsIgnoreCase(m)) {
                return e;
            }
        }
        return UNKNOWN;
    }
}
