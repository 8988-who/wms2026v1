package com.wms.taskscheduling.enums;

import lombok.Getter;

/**
 * 编排步骤触发方式枚举（骨架预留）
 * <p>定义步骤之间如何衔接，字段设计待确认后补充到流程定义。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Getter
public enum ProcessStepTriggerEnum {

    /** 上一步任务完成回调触发（信号驱动，自动衔接） */
    STEP_FINISHED("STEP_FINISHED", "上一步完成回调触发"),
    /** 人工确认后触发 */
    MANUAL("MANUAL", "人工确认触发");

    private final String value;
    private final String label;

    ProcessStepTriggerEnum(String value, String label) {
        this.value = value;
        this.label = label;
    }
}
