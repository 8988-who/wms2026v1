package com.wms.carriermanagementsystem.cart.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.carriermanagementsystem.cart.CartConverter;
import com.wms.carriermanagementsystem.cart.mapper.CartMapper;
import com.wms.carriermanagementsystem.cart.model.dto.CartDTO;
import com.wms.carriermanagementsystem.cart.model.dto.CartQueryDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cart.model.vo.CartVO;
import com.wms.carriermanagementsystem.cart.service.CartService;
import com.wms.carriermanagementsystem.cartitem.mapper.CartItemMapper;
import com.wms.carriermanagementsystem.cartitem.model.entity.CartItem;
import com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 料车业务实现
 * <p>
 * 包含料车的 CRUD、状态管理和可用料车查询逻辑，事务注解作用于此层。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CartServiceImpl extends ServiceImpl<CartMapper, Cart> implements CartService {

    private final CartMapper cartMapper;
    private final CartConverter cartConverter;
    private final CartModelMapper cartModelMapper;
    private final CartItemMapper cartItemMapper;

    @Override
    public IPage<CartVO> listCart(CartQueryDTO queryParams) {
        Page<CartVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        List<CartVO> list = cartMapper.selectCartList(page, queryParams);
        page.setRecords(list);
        return page;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addCart(CartDTO dto) {
        // 料车编号唯一性前置查重（DB 唯一约束 wms_cart_cart_code_key 兜底）
        checkCartCodeUnique(dto.getCartCode(), null);
        Cart entity = cartConverter.toEntity(dto);
        entity.setCurrentQuantity(0);
        entity.setStatus(1);
        try {
            return save(entity);
        } catch (DuplicateKeyException e) {
            log.warn("并发新增料车编号冲突，cartCode={}", dto.getCartCode(), e);
            throw new RuntimeException("料车编号 " + dto.getCartCode() + " 已存在");
        }
    }

    /** 料车编号唯一性校验（新增传 excludeId=null；cartCode 为空时跳过，由 DB 非空约束兜底） */
    private void checkCartCodeUnique(String cartCode, Long excludeId) {
        if (cartCode == null) {
            return;
        }
        Long exist = cartMapper.selectCount(
                new LambdaQueryWrapper<Cart>()
                        .eq(Cart::getCartCode, cartCode)
                        .ne(excludeId != null, Cart::getId, excludeId));
        if (exist != null && exist > 0) {
            throw new RuntimeException("料车编号 " + cartCode + " 已存在");
        }
    }

    @Override
    public CartDTO formCart(Long id) {
        Cart entity = getById(id);
        return entity != null ? cartConverter.toDTO(entity) : null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCart(Long id, CartDTO dto) {
        Cart current = this.getById(id);
        if (current == null) {
            throw new RuntimeException("料车不存在");
        }

        // 容量变更校验：改小容量/型号时，若当前装载数超出新有效容量则拦截（与装车容量口径一致）
        Long modelId = dto.getModelId() != null ? dto.getModelId() : current.getModelId();
        Integer actualCapacity = dto.getActualCapacity();
        if (modelId != null) {
            CartModel model = cartModelMapper.selectById(modelId);
            int effectiveCapacity = (actualCapacity != null && actualCapacity > 0)
                    ? actualCapacity
                    : (model != null && model.getMaxCapacity() != null ? model.getMaxCapacity() : 0);
            if (effectiveCapacity > 0) {
                // 只统计在车明细（status=1），与实时计算口径一致（Q-2 修复：原实现统计全部明细，含已取走历史记录）
                Long currentQuantity = cartItemMapper.selectCount(
                        new LambdaQueryWrapper<CartItem>()
                                .eq(CartItem::getCartId, id)
                                .eq(CartItem::getStatus, 1));
                if (currentQuantity > effectiveCapacity) {
                    throw new RuntimeException("当前车上有 " + currentQuantity + " 件货，超出新容量 " + effectiveCapacity + "，请先取走部分货物或调大容量");
                }
            }
        }

        // 料车编号唯一性前置查重（修改时排除自身）
        checkCartCodeUnique(dto.getCartCode(), id);

        Cart entity = cartConverter.toEntity(dto);
        entity.setId(id);
        try {
            return updateById(entity);
        } catch (DuplicateKeyException e) {
            log.warn("并发修改料车编号冲突，cartCode={}", dto.getCartCode(), e);
            throw new RuntimeException("料车编号 " + dto.getCartCode() + " 已存在");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCart(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String id : idArray) {
            Long cartId = Long.parseLong(id);
            Cart entity = this.getById(cartId);
            Assert.notNull(entity, "料车不存在");

            // 删除前校验：判断料车是否空闲（无在车货物 status=1，实时计算口径，Q-5 调整）。
            // 已取走的明细记录不阻止删除料车，随车一并清除；仅在车货物时禁止删除。
            Long inCartCount = cartItemMapper.selectCount(
                    new LambdaQueryWrapper<CartItem>()
                            .eq(CartItem::getCartId, cartId)
                            .eq(CartItem::getStatus, 1));
            Assert.isTrue(inCartCount == 0, "该料车上仍有" + inCartCount + "件在车货物，请先取走后再删除");

            // 删除该车全部装载明细（含已取走历史记录），否则外键 fk_item_cart_id (ON DELETE NO ACTION) 会拒绝删除料车
            cartItemMapper.delete(new LambdaQueryWrapper<CartItem>().eq(CartItem::getCartId, cartId));

            this.removeById(cartId);
        }
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchUpdateStatus(List<Long> ids, Integer status) {
        // 状态值白名单：仅约定 1=空闲 2=使用中 3=满载 4=维修，其余值拒绝
        if (status == null || status < 1 || status > 4) {
            throw new RuntimeException("非法的目标状态：" + status);
        }
        for (Long id : ids) {
            Cart cart = this.getById(id);
            Assert.notNull(cart, "料车不存在：" + id);
            if (status == 4) {
                // 进入维修：判断料车是否空闲（无在车货物 status=1，实时计算口径，Q-5 调整）。
                // 已取走的明细记录不影响送修（原实现统计全部明细，有历史记录即拦截，过于严格）。
                Long inCartCount = cartItemMapper.selectCount(
                        new LambdaQueryWrapper<CartItem>()
                                .eq(CartItem::getCartId, id)
                                .eq(CartItem::getStatus, 1));
                Assert.isTrue(inCartCount == 0,
                        "料车 " + cart.getCartCode() + " 上仍有 " + inCartCount + " 件在车货物，请先取走再标记维修");
            } else if (status != 1 && cart.getStatus() != null && cart.getStatus() == 4) {
                // 解除维修：维修(4) 仅可回到空闲(1)，禁止直接切到使用中(2)/满载(3)
                throw new RuntimeException("料车 " + cart.getCartCode() + " 维修中，请先标记为空闲后再使用");
            }

            Cart update = new Cart();
            update.setId(id);
            update.setStatus(status);
            updateById(update);
        }
        return true;
    }

    @Override
    public List<CartModelVO> formOptions() {
        return cartModelMapper.selectFormOptions();
    }

    @Override
    public List<CartModelVO> filterOptions() {
        return cartModelMapper.selectFormOptions();
    }

    @Override
    public List<String> listAreas() {
        return cartMapper.selectDistinctAreas();
    }

    @Override
    public List<Cart> availableCarts() {
        // 仅返回可装车候选：空闲(1)/使用中(2)；满载(3)/维修(4)不可装，从下拉源头过滤
        return list(new LambdaQueryWrapper<Cart>()
                .in(Cart::getStatus, 1, 2)
                .orderByAsc(Cart::getCartCode));
    }
}
