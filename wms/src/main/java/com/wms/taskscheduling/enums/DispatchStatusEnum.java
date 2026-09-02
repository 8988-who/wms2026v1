package com.wms.taskscheduling.enums;

import lombok.Getter;

/**
 * 调度会话状态枚举
 * <p>对应调度会话运行状态：0-停止 1-运行。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Getter
public enum DispatchStatusEnum {

    /** 停止 */
    STOPPED(0, "停止"),
    /** 运行 */
    RUNNING(1, "运行");

    private final Integer value;
    private final String label;

    DispatchStatusEnum(Integer value, String label) {
        this.value = value;
        this.label = label;
    }
}
