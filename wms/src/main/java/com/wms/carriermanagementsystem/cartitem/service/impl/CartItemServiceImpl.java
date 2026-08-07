package com.wms.carriermanagementsystem.cartitem.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.carriermanagementsystem.cart.mapper.CartMapper;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cartitem.CartItemConverter;
import com.wms.carriermanagementsystem.cartitem.mapper.CartItemMapper;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemDTO;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemQueryDTO;
import com.wms.carriermanagementsystem.cartitem.model.entity.CartItem;
import com.wms.carriermanagementsystem.cartitem.model.vo.CartItemVO;
import com.wms.carriermanagementsystem.cartitem.service.CartItemService;
import com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 料车物品业务实现
 * <p>
 * 包含装载明细的 CRUD 操作、装车/取走核心业务逻辑（含容量校验、状态联动），
 * 以及扫码专用方法。所有写操作均添加事务管理。
 * 料车数量与状态采用 SQL 实时计算 + 手动维护双保险机制：
 * 查询时实时计算保证展示正确，写入时手动维护保证字段同步。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Service
@RequiredArgsConstructor
public class CartItemServiceImpl extends ServiceImpl<CartItemMapper, CartItem> implements CartItemService {

    private final CartItemMapper cartItemMapper;
    private final CartItemConverter cartItemConverter;
    private final CartMapper cartMapper;
    private final CartModelMapper cartModelMapper;

    @Override
    public IPage<CartItemVO> getCartItemPage(CartItemQueryDTO queryParams) {
        Page<CartItemVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        List<CartItemVO> list = cartItemMapper.getCartItemPage(page, queryParams);
        page.setRecords(list);
        return page;
    }

    @Override
    public CartItemDTO getCartItemFormData(Long id) {
        CartItem entity = getById(id);
        return entity != null ? cartItemConverter.toDTO(entity) : null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCartItem(Long id, CartItemDTO dto) {
        CartItem entity = getById(id);
        if (entity == null) {
            throw new RuntimeException("物品记录不存在");
        }

        // 如果修改了 productCode，检查唯一性
        if (dto.getProductCode() != null && !dto.getProductCode().equals(entity.getProductCode())) {
            Long conflictCount = cartItemMapper.selectCount(
                    new LambdaQueryWrapper<CartItem>()
                            .eq(CartItem::getProductCode, dto.getProductCode())
                            .ne(CartItem::getId, id));
            if (conflictCount != null && conflictCount > 0) {
                throw new RuntimeException("货品条码 " + dto.getProductCode() + " 已存在，不允许重复");
            }
        }

        // 如果修改了 sortOrder，检查是否与同车其他物品冲突
        if (dto.getSortOrder() != null && !dto.getSortOrder().equals(entity.getSortOrder())) {
            Long conflictCount = cartItemMapper.selectCount(
                    new LambdaQueryWrapper<CartItem>()
                            .eq(CartItem::getCartId, entity.getCartId())
                            .eq(CartItem::getSortOrder, dto.getSortOrder())
                            .ne(CartItem::getId, id));
            if (conflictCount != null && conflictCount > 0) {
                throw new RuntimeException("该料车已存在顺序号为 " + dto.getSortOrder() + " 的物品");
            }
        }

        // 使用 LambdaUpdateWrapper 显式指定需要更新的字段
        LambdaUpdateWrapper<CartItem> wrapper = new LambdaUpdateWrapper<>();
        wrapper.eq(CartItem::getId, id);

        // 只更新非 null 字段
        if (dto.getProductCode() != null) {
            wrapper.set(CartItem::getProductCode, dto.getProductCode());
        }
        if (dto.getProductModel() != null) {
            wrapper.set(CartItem::getProductModel, dto.getProductModel());
        }
        if (dto.getBatchNo() != null) {
            wrapper.set(CartItem::getBatchNo, dto.getBatchNo());
        }
        if (dto.getLayerNo() != null) {
            wrapper.set(CartItem::getLayerNo, dto.getLayerNo());
        }
        if (dto.getSortOrder() != null) {
            wrapper.set(CartItem::getSortOrder, dto.getSortOrder());
        }
        if (dto.getOperator() != null) {
            wrapper.set(CartItem::getOperator, dto.getOperator());
        }
        if (dto.getRemark() != null) {
            wrapper.set(CartItem::getRemark, dto.getRemark());
        }

        return update(wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveCartItem(CartItemDTO dto) {
        // ① 校验 cart 存在且不为维修
        Cart cart = cartMapper.selectById(dto.getCartId());
        if (cart == null) {
            throw new RuntimeException("料车不存在");
        }
        if (cart.getStatus() == null || cart.getStatus() == 4) {
            throw new RuntimeException("料车当前状态不可装车（维修中）");
        }

        // ② productCode 全局唯一校验（防止并发重复装车）
        Long existCount = cartItemMapper.selectCount(
                new LambdaQueryWrapper<CartItem>()
                        .eq(CartItem::getProductCode, dto.getProductCode()));
        if (existCount != null && existCount > 0) {
            throw new RuntimeException("货品条码已存在，不允许重复装车");
        }

        // ③ sortOrder 在同一车内唯一
        Integer maxSort = cartItemMapper.getMaxSortOrderByCartId(dto.getCartId());
        if (maxSort == null) maxSort = 0;
        if (dto.getSortOrder() == null || dto.getSortOrder() <= maxSort) {
            throw new RuntimeException("装货顺序号必须大于当前最大顺序号（当前最大：" + maxSort + "）");
        }

        // ④ 计算有效容量（COALESCE(actual_capacity, model.max_capacity)）
        int effectiveCapacity;
        if (cart.getActualCapacity() != null && cart.getActualCapacity() > 0) {
            effectiveCapacity = cart.getActualCapacity();
        } else {
            CartModel model = cartModelMapper.selectById(cart.getModelId());
            if (model == null) {
                throw new RuntimeException("料车型号配置不存在");
            }
            effectiveCapacity = model.getMaxCapacity();
        }

        // ⑤ 实时计算当前装载数量，判断是否超限
        Long currentCount = cartItemMapper.selectCount(
                new LambdaQueryWrapper<CartItem>()
                        .eq(CartItem::getCartId, dto.getCartId())
                        .eq(CartItem::getStatus, 1));
        if (currentCount != null && currentCount >= effectiveCapacity) {
            throw new RuntimeException("料车已满，无法继续装车（有效容量：" + effectiveCapacity + "）");
        }

        // 写入装载明细
        CartItem entity = cartItemConverter.toEntity(dto);
        entity.setStatus(1);
        entity.setLoadedAt(LocalDateTime.now());
        if (entity.getLayerNo() == null) {
            entity.setLayerNo(1);
        }
        
        boolean saved = save(entity);

        if (saved) {
            // 手动维护料车数量与状态（双保险：实时计算 + 手动维护）
            updateCartAfterChange(cart.getId());
        }

        return saved;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean takeCartItem(Long id) {
        CartItem item = getById(id);
        if (item == null) {
            throw new RuntimeException("物品记录不存在");
        }
        if (item.getStatus() == 2) {
            throw new RuntimeException("该物品已被取走，不允许重复操作");
        }

        Long cartId = item.getCartId();

        // 标记已取走
        item.setStatus(2);
        item.setTakenAt(LocalDateTime.now());
        boolean updated = updateById(item);

        if (updated) {
            // 手动维护料车数量与状态（双保险：实时计算 + 手动维护）
            updateCartAfterChange(cartId);
        }

        return updated;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchTakeCartItems(List<Long> ids) {
        for (Long id : ids) {
            boolean result = takeCartItem(id);
            if (!result) {
                throw new RuntimeException("批量取走失败，物品ID：" + id);
            }
        }
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCartItems(String ids) {
        List<Long> idList = Arrays.stream(ids.split(","))
                .map(Long::parseLong).collect(Collectors.toList());

        // 仅允许删除已取走的记录
        List<CartItem> items = listByIds(idList);
        Long cartId = null;
        for (CartItem item : items) {
            if (item.getStatus() != 2) {
                throw new RuntimeException("物品（条码：" + item.getProductCode() + "）尚未取走，不允许删除");
            }
            if (cartId == null) {
                cartId = item.getCartId();
            }
        }

        boolean removed = removeByIds(idList);

        if (removed && cartId != null) {
            // 手动维护料车数量与状态（双保险：实时计算 + 手动维护）
            updateCartAfterChange(cartId);
        }

        return removed;
    }

    @Override
    public List<CartItemVO> getCartItemsByCartId(Long cartId) {
        return cartItemMapper.getCartItemsByCartId(cartId);
    }

    @Override
    public List<Cart> getFormOptions() {
        return cartMapper.selectList(new LambdaQueryWrapper<Cart>()
                .ne(Cart::getStatus, 4)
                .orderByAsc(Cart::getCartCode));
    }

    @Override
    public List<String> getFilterOptions() {
        return cartItemMapper.selectList(
                new LambdaQueryWrapper<CartItem>()
                        .select(CartItem::getProductModel)
                        .isNotNull(CartItem::getProductModel)
                        .groupBy(CartItem::getProductModel)
        ).stream().map(CartItem::getProductModel).collect(Collectors.toList());
    }

    /* ========== 扫码专用方法 ========== */

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean loadByBarcode(String cartCode, String productCode, String productModel) {
        // cartCode → 查 cartId
        Cart cart = cartMapper.selectOne(
                new LambdaQueryWrapper<Cart>()
                        .eq(Cart::getCartCode, cartCode));
        if (cart == null) {
            throw new RuntimeException("料车编号不存在：" + cartCode);
        }

        // 自动计算 sortOrder
        Integer maxSort = cartItemMapper.getMaxSortOrderByCartId(cart.getId());
        int nextSort = (maxSort == null ? 0 : maxSort) + 1;

        CartItemDTO dto = new CartItemDTO();
        dto.setCartId(cart.getId());
        dto.setProductCode(productCode);
        dto.setProductModel(productModel);
        dto.setSortOrder(nextSort);
        return saveCartItem(dto);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean takeByBarcode(String productCode) {
        // productCode → 查 itemId
        CartItem item = cartItemMapper.selectOne(
                new LambdaQueryWrapper<CartItem>()
                        .eq(CartItem::getProductCode, productCode));
        if (item == null) {
            throw new RuntimeException("未找到该条码的物品记录：" + productCode);
        }
        return takeCartItem(item.getId());
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchTakeByBarcodes(List<String> productCodes) {
        List<Long> ids = cartItemMapper.selectList(
                new LambdaQueryWrapper<CartItem>()
                        .in(CartItem::getProductCode, productCodes)
        ).stream().map(CartItem::getId).collect(Collectors.toList());

        if (ids.isEmpty()) {
            throw new RuntimeException("未找到任何匹配的物品记录");
        }
        return batchTakeCartItems(ids);
    }

    /* ========== 内部辅助方法 ========== */

    /**
     * 物品变更后，手动维护料车的 current_quantity 和 status（双保险机制）
     */
    private void updateCartAfterChange(Long cartId) {
        Cart cart = cartMapper.selectById(cartId);
        if (cart == null || cart.getStatus() == 4) {
            return;
        }

        // 计算有效容量
        int effectiveCapacity;
        if (cart.getActualCapacity() != null && cart.getActualCapacity() > 0) {
            effectiveCapacity = cart.getActualCapacity();
        } else {
            CartModel model = cartModelMapper.selectById(cart.getModelId());
            effectiveCapacity = model != null ? model.getMaxCapacity() : 0;
        }

        // 实时计算当前装载数量
        Long currentCount = cartItemMapper.selectCount(
                new LambdaQueryWrapper<CartItem>()
                        .eq(CartItem::getCartId, cartId)
                        .eq(CartItem::getStatus, 1));
        int count = currentCount != null ? currentCount.intValue() : 0;

        // 更新料车
        cart.setCurrentQuantity(count);
        if (count == 0) {
            cart.setStatus(1);  // 空闲
        } else if (count >= effectiveCapacity) {
            cart.setStatus(3);  // 满载
        } else {
            cart.setStatus(2);  // 使用中
        }
        cartMapper.updateById(cart);
    }
}
