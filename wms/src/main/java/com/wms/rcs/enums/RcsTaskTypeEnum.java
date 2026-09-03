package com.wms.rcs.enums;

import lombok.Getter;

/**
 * RCS任务类型枚举
 * <p>对应 wms_rcs_task.task_type：1-搬运 2-充电 3-调度 4-巡检。
 * {@code rcsTemplate} 为 RCS 平台任务模板编码（下发 taskType），与回调 method 一致走代码枚举，不再读 sys_config。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Getter
public enum RcsTaskTypeEnum {

    CARRY(1, "搬运", "PF-LMR-COMMON"),
    CHARGE(2, "充电", "PF-LMR-CHARGE"),
    DISPATCH(3, "调度", "PF-LMR-DISPATCH"),
    INSPECT(4, "巡检", "PF-LMR-INSPECT");

    private final Integer value;
    private final String label;
    /** RCS 协议任务模板编码（下发时作为 taskType） */
    private final String rcsTemplate;

    RcsTaskTypeEnum(Integer value, String label, String rcsTemplate) {
        this.value = value;
        this.label = label;
        this.rcsTemplate = rcsTemplate;
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

    /**
     * 根据类型值获取 RCS 任务模板编码，未匹配返回 null
     */
    public static String getRcsTemplateByValue(Integer value) {
        if (value == null) {
            return null;
        }
        for (RcsTaskTypeEnum e : values()) {
            if (e.value.equals(value)) {
                return e.rcsTemplate;
            }
        }
        return null;
    }
}
