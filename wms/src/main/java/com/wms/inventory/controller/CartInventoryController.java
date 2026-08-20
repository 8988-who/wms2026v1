package com.wms.inventory.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RepeatSubmit;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.wms.inventory.model.dto.CartInventoryBindDTO;
import com.wms.inventory.model.dto.CartInventoryPointDTO;
import com.wms.inventory.model.dto.CartInventoryQueryDTO;
import com.wms.inventory.model.vo.AvailableCartVO;
import com.wms.inventory.model.vo.AvailablePointVO;
import com.wms.inventory.model.vo.CartInventoryVO;
import com.wms.inventory.service.CartInventoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 料车库存 REST 接口
 * <p>
 * 提供库存分页查询（库存显示/库存管理共用）、可用料车/点位下拉、绑定/解绑/锁定/解锁操作。
 * 锁定/解锁共用同一权限标识，available-* 下拉复用 list 权限。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Tag(name = "料车库存接口")
@RestController
@RequestMapping("/api/v1/cart-inventory")
@RequiredArgsConstructor
public class CartInventoryController {

    private final CartInventoryService cartInventoryService;

    @Operation(summary = "料车库存分页列表")
    @GetMapping("/page")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:list')")
    @Log(module = LogModuleEnum.CART_INVENTORY, value = ActionTypeEnum.LIST)
    public PageResult<CartInventoryVO> getCartInventoryPage(CartInventoryQueryDTO queryParams) {
        IPage<CartInventoryVO> result = cartInventoryService.page(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "可用料车下拉（不在任何点位且非维修）")
    @GetMapping("/available-carts")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:list')")
    public Result<List<AvailableCartVO>> getAvailableCarts() {
        return Result.success(cartInventoryService.availableCarts());
    }

    @Operation(summary = "可用点位下拉（空位且未锁定，可按区域/巷道联动筛选）")
    @GetMapping("/available-points")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:list')")
    public Result<List<AvailablePointVO>> getAvailablePoints(
            @RequestParam(required = false) Long locationId,
            @RequestParam(required = false) Long aisleId) {
        return Result.success(cartInventoryService.availablePoints(locationId, aisleId));
    }

    @Operation(summary = "搜索筛选下拉（区域列表 + 巷道列表）")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:list')")
    public Result<Map<String, List<?>>> getFilterOptions() {
        return Result.success(cartInventoryService.filterOptions());
    }

    @Operation(summary = "绑定（料车入位）")
    @PostMapping("/bind")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:bind')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_INVENTORY, value = ActionTypeEnum.INSERT)
    public Result<Void> bind(@RequestBody @Valid CartInventoryBindDTO dto) {
        cartInventoryService.bind(dto);
        return Result.success();
    }

    @Operation(summary = "解绑（料车离位）")
    @PostMapping("/unbind")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:unbind')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_INVENTORY, value = ActionTypeEnum.UPDATE)
    public Result<Void> unbind(@RequestBody @Valid CartInventoryPointDTO dto) {
        cartInventoryService.unbind(dto.getPointId());
        return Result.success();
    }

    @Operation(summary = "锁定库存")
    @PostMapping("/lock")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:lock')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_INVENTORY, value = ActionTypeEnum.OTHER)
    public Result<Void> lock(@RequestBody @Valid CartInventoryPointDTO dto) {
        cartInventoryService.lock(dto.getPointId());
        return Result.success();
    }

    @Operation(summary = "解锁库存")
    @PostMapping("/unlock")
    @PreAuthorize("@ss.hasPerm('inventory:cart-inventory:lock')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_INVENTORY, value = ActionTypeEnum.OTHER)
    public Result<Void> unlock(@RequestBody @Valid CartInventoryPointDTO dto) {
        cartInventoryService.unlock(dto.getPointId());
        return Result.success();
    }
  
}
