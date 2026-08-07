package com.wms.carriermanagementsystem.cartmodel.controller;

import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import com.wms.carriermanagementsystem.cartmodel.service.CartModelService;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RepeatSubmit;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.PageResult;
import com.wms.common.result.Result;
import com.baomidou.mybatisplus.core.metadata.IPage;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 料车型号配置 REST 接口
 * <p>
 * 提供型号配置的增删改查、分页列表及表单/筛选下拉选项接口。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Tag(name = "料车型号配置接口")
@RestController
@RequestMapping("/api/v1/cart-model")
@RequiredArgsConstructor
public class CartModelController {

    private final CartModelService cartModelService;

    @Operation(summary = "型号分页列表")
    @GetMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:list')")
    @Log(module = LogModuleEnum.CART_MODEL, value = ActionTypeEnum.LIST)
    public PageResult<CartModelVO> getCartModelPage(CartModelQueryDTO queryParams) {
        IPage<CartModelVO> result = cartModelService.listCartModel(queryParams);
        return PageResult.success(result);
    }

    @Operation(summary = "新增型号")
    @PostMapping
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:create')")
    @RepeatSubmit
    @Log(module = LogModuleEnum.CART_MODEL, value = ActionTypeEnum.INSERT)
    public Result<Void> saveCartModel(@RequestBody @Valid CartModelDTO dto) {
        boolean result = cartModelService.addCartModel(dto);
        return Result.judge(result);
    }

    @Operation(summary = "获取型号表单数据")
    @GetMapping("/{id}/form")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:update')")
    public Result<CartModelDTO> getCartModelForm(
            @Parameter(description = "型号ID") @PathVariable Long id) {
        CartModelDTO dto = cartModelService.formCartModel(id);
        return Result.success(dto);
    }

    @Operation(summary = "修改型号")
    @PutMapping("/{id}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:update')")
    @Log(module = LogModuleEnum.CART_MODEL, value = ActionTypeEnum.UPDATE)
    public Result<Void> updateCartModel(
            @Parameter(description = "型号ID") @PathVariable Long id,
            @RequestBody @Valid CartModelDTO dto) {
        boolean result = cartModelService.updateCartModel(id, dto);
        return Result.judge(result);
    }

    @Operation(summary = "删除型号")
    @DeleteMapping("/{ids}")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:delete')")
    @Log(module = LogModuleEnum.CART_MODEL, value = ActionTypeEnum.DELETE)
    public Result<Void> deleteCartModels(
            @Parameter(description = "型号ID，多个以英文逗号(,)分割") @PathVariable String ids) {
        boolean result = cartModelService.deleteCartModel(ids);
        return Result.judge(result);
    }

    @Operation(summary = "获取表单下拉选项")
    @GetMapping("/form-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:list')")
    public Result<List<CartModelVO>> getFormOptions() {
        return Result.success(cartModelService.formOptions());
    }

    @Operation(summary = "获取搜索筛选下拉选项")
    @GetMapping("/filter-options")
    @PreAuthorize("@ss.hasPerm('carriermanagementsystem:cart-model:list')")
    public Result<List<CartModelVO>> getFilterOptions() {
        return Result.success(cartModelService.filterOptions());
    }
}
