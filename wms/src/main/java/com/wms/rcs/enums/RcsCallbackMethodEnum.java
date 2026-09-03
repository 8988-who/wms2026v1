package com.wms.rcs.enums;

import lombok.Getter;

/**
 * RCS 任务执行过程回馈 method 字典（纯注册表）
 * <p>
 * 将 RCS 回调中 {@code extra.values.method} 的字符串值归一化为强类型枚举：忽略大小写、
 * 兼容"method + 尾部序号"的追加格式（剥离尾数后二次匹配）。
 * 具体"method 值 → 本地状态流转 + 库存联动事件"的业务编排见
 * {@code RcsTaskServiceImpl#handleTaskReport} 中的 switch：
 * 每个 case 自由组合状态与库存动作（如"到达 = 解绑源点 + 确认目标到达"），
 * 新增 method 只需"加一个枚举常量 + 加一个 case"。
 * </p>
 * <p>
 * 枚举未命中（{@link #UNKNOWN}）时回退到关键词模糊匹配（{@code mapReportToStatus}），
 * 保证未登记 method 不阻断任务流转，并输出告警便于补充登记。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-31
 */
@Getter
public enum RcsCallbackMethodEnum {

    /** 货架到达目标位 */
    NOTIFY_POD_ARR   ("notifyPodArr",   "货架到达目标位"),
    /** 货架离开源位 */
    NOTIFY_POD_LEAV  ("notifyPodLeav",  "货架离开源位"),
    /** 机器人取到载具（未离开起点，不解绑源位） */
    TAKE_SHELF_1     ("takeshelf1",     "机器人取到载具"),
    /** 机器人离开起点 */
    TAKE_SHELF_2     ("takeshelf2",     "机器人离开起点"),
    /** 机器人到达途经点 */
    NOTIFY_ROBOT_ARR ("notifyRobotArr", "机器人到达途经点"),
    /** 机器人离开途经点 */
    NOTIFY_ROBOT_LEAV("notifyRobotLeav","机器人离开途经点"),
    /** 机器人离开起点（料车随行）→ 锁定起点+终点（remark=1） */
    NOTIFY_ROBOT_LEAV_01("notifyRobotLeav01","机器人离开起点（预绑定起点与终点）"),
    /** 到达目标位 */
    ARRIVED_TARGET   ("arrivedTarget",  "到达目标位"),
    /** 任务开始 */
    START_TASK       ("startTask",      "任务开始"),
    /** 任务完成 */
    FINISH_TASK      ("finishTask",     "任务完成"),
    /** 任务完成（01 系列，终点终绑） */
    FINISH_TASK_01   ("finishTask01",   "任务完成（终点终绑）"),
    /** 任务取消（RCS 侧主动取消） */
    CANCEL_TASK      ("cancelTask",     "任务取消"),
    /** 任务异常 */
    ERROR_TASK       ("errorTask",      "任务异常"),
    /** 未匹配到任何已知 method */
    UNKNOWN          (null,             "未识别");

    /** RCS 回调 method 字符串（原值，匹配时忽略大小写） */
    private final String method;

    /** method 语义说明 */
    private final String description;

    RcsCallbackMethodEnum(String method, String description) {
        this.method = method;
        this.description = description;
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
        // 兼容 RCS 在 method 后追加序号（如 takeshelf1/takeshelf2 → takeshelf）：剥离尾部数字后再次精确匹配
        String base = m.replaceFirst("\\d+$", "");
        if (!base.isEmpty() && !base.equals(m)) {
            for (RcsCallbackMethodEnum e : values()) {
                if (e != UNKNOWN && e.method != null && e.method.equalsIgnoreCase(base)) {
                    return e;
                }
            }
        }
        return UNKNOWN;
    }
}
