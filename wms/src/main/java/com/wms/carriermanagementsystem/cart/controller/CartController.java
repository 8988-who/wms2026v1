package com.wms.carriermanagementsystem.cart.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.carriermanagementsystem.cart.model.dto.CartDTO;
import com.wms.carriermanagementsystem.cart.model.dto.CartQueryDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cart.model.vo.CartVO;
import com.wms.carriermanagementsystem.cart.service.CartService;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
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

/**
 * 料车管理 REST 接口
 * <p>
 * 提供料车的增删改查、批量状态变更及可用料车列表接口。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@Tag(name = "料车管理接口")
@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;

    @Operation(summary = "料车分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:list')")
    @Log(module = LogModuleEnum.CART, value = ActionTypeEnum.LIST)
    public PageResult<CartVO> getCartPage(CartQueryDTO queryParams) {
        IPage<CartVO> result = cartService.listCart(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增料车")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART, value = ActionTypeEnum.INSERT)
    public Result<Void> saveCart(@RequestBody @Valid CartDTO dto) {
        boolean result = cartService.addCart(dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取料车表单数据")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:update')")
    public Result<CartDTO> getCartForm(
            @Parameter(description = "料车ID") @PathVariable Long id) {
        CartDTO dto = cartService.formCart(id);
        return Result.success(dto);
    }

    @Operation(summary = "修改料车")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:update')")
    @Log(module = LogModuleEnum.CART, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateCart(
            @Parameter(description = "料车ID") @PathVariable Long id,
            @RequestBody @Valid CartDTO dto) {
        boolean result = cartService.updateCart(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除料车")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:delete')")
    @Log(module = LogModuleEnum.CART, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteCarts(
            @Parameter(description = "料车ID，多个以英文逗号(,)分割") @PathVariable String ids) {
        boolean result = cartService.deleteCart(ids);
        return Result.judge(result);
    }

    @Operation(summary = "批量修改料车状态")
    @PutMapping("/batch-status")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:update')")
    @Log(module = LogModuleEnum.CART, value = ActionTypeEnum.UPDATE)
    public Result<Void> batchUpdateStatus(
            @Parameter(description = "料车ID列表") @RequestBody List<Long> ids,
            @Parameter(description = "目标状态") @RequestParam Integer status) {
        boolean result = cartService.batchUpdateStatus(ids, status);
        return Result.judge(result);
    }

    @Operation(summary = "获取表单下拉选项（型号列表）")
    @GetMapping("/form-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:list')")
    public Result<List<CartModelVO>> getFormOptions() {
        return Result.success(cartService.formOptions());
    }

    @Operation(summary = "获取筛选下拉选项（型号列表、区域列表）")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:list')")
    public Result<List<CartModelVO>> getFilterOptions() {
        return Result.success(cartService.filterOptions());
    }

    @Operation(summary = "获取区域列表（筛选下拉）")
    @GetMapping("/areas")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:list')")
    public Result<List<String>> getAreas() {
        return Result.success(cartService.listAreas());
    }

    @Operation(summary = "获取可用料车列表")
    @GetMapping("/available")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart:list')")
    public Result<List<Cart>> getAvailableCarts() {
        return Result.success(cartService.availableCarts());
    }
}
