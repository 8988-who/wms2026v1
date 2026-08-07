package com.wms.carriermanagementsystem.common.enums;

import com.wms.common.base.IBaseEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 料车物品状态枚举
 * <p>
 * 定义装载明细的两种状态：在车、已取走。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Getter
@AllArgsConstructor
public enum CartItemStatusEnum implements IBaseEnum<Integer> {

    ON_CART(1, "在车"),
    TAKEN(2, "已取走");

    private final Integer value;
    private final String label;
}
