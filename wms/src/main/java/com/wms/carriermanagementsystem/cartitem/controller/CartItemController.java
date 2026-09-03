package com.wms.carriermanagementsystem.cartitem.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemDTO;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemQueryDTO;
import com.wms.carriermanagementsystem.cartitem.model.vo.CartItemVO;
import com.wms.carriermanagementsystem.cartitem.service.CartItemService;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RepeatSubmit;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 料车物品管理 REST 接口
 * <p>
 * 提供装载明细的增删改查、装车/取走核心业务、扫码专用端点（适配条码机/PDA）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Tag(name = "料车物品管理接口")
@RestController
@RequestMapping("/api/v1/cart-item")
@RequiredArgsConstructor
public class CartItemController {

    private final CartItemService cartItemService;

    /* ========== 标准 REST 端点 ========== */

    @Operation(summary = "分页查询装载明细")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:list')")
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.LIST)
    public PageResult<CartItemVO> getCartItemPage(CartItemQueryDTO queryParams) {
        IPage<CartItemVO> result = cartItemService.getCartItemPage(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "装车（新增明细）")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.INSERT)
    public Result<Void> saveCartItem(@RequestBody @Valid CartItemDTO dto) {
        boolean result = cartItemService.saveCartItem(dto);
        return Result.judge(result);
    }

    @Operation(summary = "修改装车明细")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateCartItem(
            @Parameter(description = "物品ID") @PathVariable Long id,
            @RequestBody @Valid CartItemDTO dto) {
        boolean result = cartItemService.updateCartItem(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取表单回显")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    public Result<CartItemDTO> getCartItemForm(
            @Parameter(description = "物品ID") @PathVariable Long id) {
        CartItemDTO dto = cartItemService.getCartItemFormData(id);
        return Result.success(dto);
    }

    @Operation(summary = "删除已取走的物品记录")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:delete')")
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteCartItems(
            @Parameter(description = "物品ID，多个以英文逗号(,)分割") @PathVariable String ids) {
        boolean result = cartItemService.deleteCartItems(ids);
        return Result.judge(result);
    }

    @Operation(summary = "取走单件物品")
    @PutMapping("/{id}/take")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.UPDATE)
    public Result<Void> takeCartItem(
            @Parameter(description = "物品ID") @PathVariable Long id) {
        boolean result = cartItemService.takeCartItem(id);
        return Result.judge(result);
    }

    @Operation(summary = "批量取走物品")
    @PutMapping("/batch-take")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.UPDATE)
    public Result<Void> batchTakeCartItems(
            @Parameter(description = "物品ID列表") @RequestBody List<Long> ids) {
        boolean result = cartItemService.batchTakeCartItems(ids);
        return Result.judge(result);
    }

    @Operation(summary = "查询指定料车的物品列表")
    @GetMapping("/by-cart/{cartId}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:list')")
    public Result<List<CartItemVO>> getCartItemsByCartId(
            @Parameter(description = "料车ID") @PathVariable Long cartId) {
        return Result.success(cartItemService.getCartItemsByCartId(cartId));
    }

    @Operation(summary = "获取表单下拉选项（可用料车列表）")
    @GetMapping("/form-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:list')")
    public Result<List<Cart>> getFormOptions() {
        return Result.success(cartItemService.getFormOptions());
    }

    @Operation(summary = "获取料车编号筛选下拉选项（有货料车列表）")
    @GetMapping("/filter-cart-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:list')")
    public Result<List<Cart>> getFilterCartOptions() {
        return Result.success(cartItemService.getFilterCartOptions());
    }

    @Operation(summary = "获取筛选下拉选项（货品型号列表）")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:list')")
    public Result<List<String>> getFilterOptions() {
        return Result.success(cartItemService.getFilterOptions());
    }

    /* ========== 扫码专用端点 ========== */

    @Operation(summary = "扫码装车（条码机/PDA 专用）")
    @PostMapping("/load-by-barcode")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.INSERT)
    public Result<Void> loadByBarcode(@RequestBody Map<String, String> params) {
        String cartCode = params.get("cartCode");
        String productCode = params.get("productCode");
        String productModel = params.get("productModel");
        boolean result = cartItemService.loadByBarcode(cartCode, productCode, productModel);
        return Result.judge(result);
    }

    @Operation(summary = "扫码取走单件（条码机/PDA 专用）")
    @PutMapping("/take-by-barcode/{productCode}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.UPDATE)
    public Result<Void> takeByBarcode(
            @Parameter(description = "货品条码") @PathVariable String productCode) {
        boolean result = cartItemService.takeByBarcode(productCode);
        return Result.judge(result);
    }

    @Operation(summary = "扫码批量取走（条码机/PDA 专用）")
    @PutMapping("/batch-take-by-barcodes")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-item:update')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_ITEM, value = ActionTypeEnum.UPDATE)
    public Result<Void> batchTakeByBarcodes(@RequestBody List<String> productCodes) {
        boolean result = cartItemService.batchTakeByBarcodes(productCodes);
        return Result.judge(result);
    }
}
