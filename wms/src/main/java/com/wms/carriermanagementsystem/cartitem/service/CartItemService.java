package com.wms.carriermanagementsystem.cartitem.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemDTO;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemQueryDTO;
import com.wms.carriermanagementsystem.cartitem.model.entity.CartItem;
import com.wms.carriermanagementsystem.cartitem.model.vo.CartItemVO;

import java.util.List;

/**
 * 料车物品业务接口
 * <p>
 * 定义装载明细的 CRUD、装车/取走核心业务、扫码专用方法。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
public interface CartItemService {

    /**
     * 分页查询装载明细
     */
    IPage<CartItemVO> getCartItemPage(CartItemQueryDTO queryParams);

    /**
     * 获取表单回显
     */
    CartItemDTO getCartItemFormData(Long id);

    /**
     * 修改装车明细
     */
    boolean updateCartItem(Long id, CartItemDTO dto);

    /**
     * 装车（核心业务：校验 cart 存在且可用、productCode 唯一性、sortOrder 同一车内唯一、未超过容量上限；
     * 成功后自动累加 cart.currentQuantity 并更新 cart.status）
     */
    boolean saveCartItem(CartItemDTO dto);

    /**
     * 取走单件物品（标记 status=2 + takenAt；更新 cart.currentQuantity；若原为满载则恢复为使用中）
     */
    boolean takeCartItem(Long id);

    /**
     * 批量取走物品
     */
    boolean batchTakeCartItems(List<Long> ids);

    /**
     * 批量删除（仅允许删除 status=2 已取走的记录）
     */
    boolean deleteCartItems(String ids);

    /**
     * 查询指定料车的所有物品（按 sortOrder DESC 排序）
     */
    List<CartItemVO> getCartItemsByCartId(Long cartId);

    /**
     * 表单选项（可用料车列表）
     */
    List<Cart> getFormOptions();

    /**
     * 筛选选项（货品型号、批次号）
     */
    List<String> getFilterOptions();

    /** ========== 扫码专用方法 ========== */

    /**
     * 扫码装车：cartCode → 查 cartId → 调 saveCartItem
     */
    boolean loadByBarcode(String cartCode, String productCode, String productModel);

    /**
     * 扫码取走单件：productCode → 查 itemId → 调 takeCartItem
     */
    boolean takeByBarcode(String productCode);

    /**
     * 扫码批量取走：productCodes 列表 → 逐个查 itemId → 调 batchTakeCartItems
     */
    boolean batchTakeByBarcodes(List<String> productCodes);

    /**
     * 定时同步所有料车的 current_quantity 和 status
     */
    void syncAllCartsStatus();
}
