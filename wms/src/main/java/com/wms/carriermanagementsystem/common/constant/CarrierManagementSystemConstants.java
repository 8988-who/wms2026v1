package com.wms.carriermanagementsystem.common.constant;

/**
 * 载具管理系统公共常量
 * <p>
 * 存放 CMS 模块共享的缓存 Key、业务阈值等常量。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
public final class CarrierManagementSystemConstants {

    private CarrierManagementSystemConstants() {
    }

    /**
     * 料车型号缓存前缀
     */
    public static final String CART_MODEL_CACHE_PREFIX = "cart:model:";

    /**
     * 料车缓存前缀
     */
    public static final String CART_CACHE_PREFIX = "cart:";

    /**
     * 默认料车层数
     */
    public static final int DEFAULT_LAYER_COUNT = 1;

    /**
     * 默认料车状态（空闲）
     */
    public static final int DEFAULT_CART_STATUS = 1;
}
