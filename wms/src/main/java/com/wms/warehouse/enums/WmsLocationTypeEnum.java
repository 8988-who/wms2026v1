package com.wms.warehouse.enums;

import com.wms.common.base.IBaseEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 库位/区域类型枚举
 * <p>
 * 定义库位层级类型：厂区(0)、区域(1)、货架(2)、库位(3)。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Getter
@AllArgsConstructor
public enum WmsLocationTypeEnum implements IBaseEnum<Integer> {

    PLANT(0, "厂区"),
    AREA(1, "区域"),
    SHELF(2, "货架"),
    LOCATION(3, "库位");

    private final Integer value;
    private final String label;

}