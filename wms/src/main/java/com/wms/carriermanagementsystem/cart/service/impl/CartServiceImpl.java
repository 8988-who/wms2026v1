package com.wms.carriermanagementsystem.cart.service.impl;

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
import com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

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
public class CartServiceImpl extends ServiceImpl<CartMapper, Cart> implements CartService {

    private final CartMapper cartMapper;
    private final CartConverter cartConverter;
    private final CartModelMapper cartModelMapper;

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
        Cart entity = cartConverter.toEntity(dto);
        entity.setCurrentQuantity(0);
        entity.setStatus(1);
        return save(entity);
    }

    @Override
    public CartDTO formCart(Long id) {
        Cart entity = getById(id);
        return entity != null ? cartConverter.toDTO(entity) : null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCart(Long id, CartDTO dto) {
        Cart entity = cartConverter.toEntity(dto);
        entity.setId(id);
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCart(String ids) {
        List<Long> idList = Arrays.stream(ids.split(","))
                .map(Long::parseLong).collect(Collectors.toList());
        return removeByIds(idList);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean batchUpdateStatus(List<Long> ids, Integer status) {
        List<Cart> list = ids.stream().map(id -> {
            Cart cart = new Cart();
            cart.setId(id);
            cart.setStatus(status);
            return cart;
        }).collect(Collectors.toList());
        return updateBatchById(list);
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
        return list(new LambdaQueryWrapper<Cart>()
                .ne(Cart::getStatus, 4)
                .orderByAsc(Cart::getCartCode));
    }
}
