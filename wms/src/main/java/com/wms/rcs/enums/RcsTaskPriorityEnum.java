package com.wms.rcs.enums;

import lombok.Getter;

/**
 * RCS任务优先级枚举
 * <p>对应 wms_rcs_task.priority：1-低 2-中 3-高 4-紧急。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Getter
public enum RcsTaskPriorityEnum {

    LOW(1, "低"),
    MEDIUM(2, "中"),
    HIGH(3, "高"),
    URGENT(4, "紧急");

    private final Integer value;
    private final String label;

    RcsTaskPriorityEnum(Integer value, String label) {
        this.value = value;
        this.label = label;
    }

    /**
     * 根据优先级值获取描述，未匹配返回 null
     */
    public static String getLabelByValue(Integer value) {
        if (value == null) {
            return null;
        }
        for (RcsTaskPriorityEnum e : values()) {
            if (e.value.equals(value)) {
                return e.label;
            }
        }
        return null;
    }
}
