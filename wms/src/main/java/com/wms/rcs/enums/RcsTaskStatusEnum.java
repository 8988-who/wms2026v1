package com.wms.rcs.enums;

import lombok.Getter;

import java.util.Collections;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.Map;
import java.util.Set;

/**
 * RCS任务状态枚举
 * <p>对应 wms_rcs_task.status：0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Getter
public enum RcsTaskStatusEnum {

    PENDING(0, "待执行"),
    ASSIGNED(1, "已派发"),
    EXECUTING(2, "执行中"),
    FINISHED(3, "已完成"),
    CANCELLED(4, "已取消"),
    EXCEPTION(5, "异常");

    private final Integer value;
    private final String label;

    RcsTaskStatusEnum(Integer value, String label) {
        this.value = value;
        this.label = label;
    }

    /**
     * 根据状态值获取描述，未匹配返回 null
     */
    public static String getLabelByValue(Integer value) {
        if (value == null) {
            return null;
        }
        for (RcsTaskStatusEnum e : values()) {
            if (e.value.equals(value)) {
                return e.label;
            }
        }
        return null;
    }

    /**
     * 根据状态值获取枚举，未匹配返回 null
     */
    public static RcsTaskStatusEnum of(Integer value) {
        if (value == null) {
            return null;
        }
        for (RcsTaskStatusEnum e : values()) {
            if (e.value.equals(value)) {
                return e;
            }
        }
        return null;
    }

    // ============================ 状态流转矩阵（C-09 临时方案，待测试后调整） ============================
    // ⚠️【临时方案】以下流转白名单为 C-09 整改的初版规则，用于阻止终态被回退/非法激活。
    //   业务口径（EXCEPTION 是否可重试恢复、PENDING 是否允许直接跳 EXECUTING 等）待联调测试后再校准，
    //   届时仅需调整此 TRANSITIONS 表，无需改动 changeStatus 校验逻辑。
    //
    // 当前口径：
    //   - FINISHED / CANCELLED 为锁死终态，不允许流向任何其他状态；
    //   - EXCEPTION 允许「重试恢复」到 ASSIGNED/EXECUTING，也允许被 CANCELLED，但不允许直接 FINISHED；
    //   - EXECUTING 不允许回退到 ASSIGNED（解决迟到回馈把执行中/已完成打回的问题）。
    private static final Map<RcsTaskStatusEnum, Set<RcsTaskStatusEnum>> TRANSITIONS;

    static {
        Map<RcsTaskStatusEnum, Set<RcsTaskStatusEnum>> map = new EnumMap<>(RcsTaskStatusEnum.class);
        map.put(PENDING, EnumSet.of(ASSIGNED, EXECUTING, CANCELLED, EXCEPTION));
        map.put(ASSIGNED, EnumSet.of(EXECUTING, FINISHED, CANCELLED, EXCEPTION));
        map.put(EXECUTING, EnumSet.of(FINISHED, CANCELLED, EXCEPTION));
        map.put(FINISHED, EnumSet.noneOf(RcsTaskStatusEnum.class));   // 终态锁死
        map.put(CANCELLED, EnumSet.noneOf(RcsTaskStatusEnum.class));  // 终态锁死
        map.put(EXCEPTION, EnumSet.of(ASSIGNED, EXECUTING, CANCELLED)); // 允许重试恢复/取消，不允许直接完成
        TRANSITIONS = Collections.unmodifiableMap(map);
    }

    /**
     * 是否为终态（已完成/已取消/异常）。
     * <p>注意：EXCEPTION 虽被业务上视为"终态展示"，但当前口径允许其重试恢复，
     * 具体能否流转以 {@link #canTransfer} 为准。</p>
     */
    public boolean isFinal() {
        return this == FINISHED || this == CANCELLED || this == EXCEPTION;
    }

    /**
     * 判断从当前状态流转到目标状态是否合法（C-09 临时方案，待测试后调整）。
     * <p>目标状态与当前状态相同时返回 true（交由调用方按幂等处理）。</p>
     *
     * @param from 当前状态值
     * @param to   目标状态值
     * @return true 合法（或相同）；false 非法流转
     */
    public static boolean canTransfer(Integer from, Integer to) {
        if (from == null || to == null) {
            return false;
        }
        if (from.equals(to)) {
            return true;
        }
        RcsTaskStatusEnum fromEnum = of(from);
        RcsTaskStatusEnum toEnum = of(to);
        if (fromEnum == null || toEnum == null) {
            return false;
        }
        return TRANSITIONS.getOrDefault(fromEnum, EnumSet.noneOf(RcsTaskStatusEnum.class)).contains(toEnum);
    }
}
