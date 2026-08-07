package com.wms.rcs.enums;

import lombok.Getter;

/**
 * RCS任务操作者类型枚举
 * <p>对应 wms_rcs_task_lifecycle.operator_type，用于标识状态流转的触发方。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Getter
public enum RcsOperatorTypeEnum {

    SYSTEM("SYSTEM", "系统自动"),
    ADMIN("ADMIN", "管理员"),
    AGV("AGV", "AGV自主"),
    EXTERNAL("EXTERNAL", "外部系统");

    private final String value;
    private final String label;

    RcsOperatorTypeEnum(String value, String label) {
        this.value = value;
        this.label = label;
    }
}
