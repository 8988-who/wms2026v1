package com.wms.warehouse.enums;

import com.wms.common.base.IBaseEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 库位/区域类型枚举（预留，暂未启用）
 * <p>
 * 定义库位层级类型：厂区(0)、区域(1)、货架(2)、库位(3)。
 * 当前系统实际以 plant_code 作为厂区主维度、parent_id 表达归属树，
 * 本枚举暂未参与任何业务逻辑，仅作语义预留，后续如需层级建模再启用。
 * </p>
 *
 * @author SenyangHe
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