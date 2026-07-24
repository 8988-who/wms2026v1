package com.wms.warehouse.enums;

import com.wms.common.base.IBaseEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 仓库通用状态枚举
 * <p>
 * 定义启用(1)/禁用(0)两种状态，用于库位/区域、巷道、点位等实体的状态字段。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Getter
@AllArgsConstructor
public enum WmsStatusEnum implements IBaseEnum<Integer> {

    DISABLED(0, "禁用"),
    ENABLED(1, "启用");

    private final Integer value;
    private final String label;

}