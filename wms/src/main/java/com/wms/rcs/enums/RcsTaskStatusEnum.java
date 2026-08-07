package com.wms.rcs.enums;

import lombok.Getter;

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
}
