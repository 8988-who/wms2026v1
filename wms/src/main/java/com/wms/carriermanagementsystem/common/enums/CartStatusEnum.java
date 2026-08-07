package com.wms.carriermanagementsystem.common.enums;

import com.wms.common.base.IBaseEnum;
import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 料车状态枚举
 * <p>
 * 定义料车的四种业务状态：空闲、使用中、已满载、维修。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Getter
@AllArgsConstructor
public enum CartStatusEnum implements IBaseEnum<Integer> {

    IDLE(1, "空闲"),
    IN_USE(2, "使用中"),
    FULL(3, "已满载"),
    MAINTENANCE(4, "维修");

    private final Integer value;
    private final String label;
}
