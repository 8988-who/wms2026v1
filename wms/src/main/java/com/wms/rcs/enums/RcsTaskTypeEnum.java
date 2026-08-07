package com.wms.rcs.enums;

import lombok.Getter;

/**
 * RCS任务类型枚举
 * <p>对应 wms_rcs_task.task_type：1-搬运 2-充电 3-调度 4-巡检。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Getter
public enum RcsTaskTypeEnum {

    CARRY(1, "搬运"),
    CHARGE(2, "充电"),
    DISPATCH(3, "调度"),
    INSPECT(4, "巡检");

    private final Integer value;
    private final String label;

    RcsTaskTypeEnum(Integer value, String label) {
        this.value = value;
        this.label = label;
    }

    /**
     * 根据类型值获取描述，未匹配返回 null
     */
    public static String getLabelByValue(Integer value) {
        if (value == null) {
            return null;
        }
        for (RcsTaskTypeEnum e : values()) {
            if (e.value.equals(value)) {
                return e.label;
            }
        }
        return null;
    }
}
