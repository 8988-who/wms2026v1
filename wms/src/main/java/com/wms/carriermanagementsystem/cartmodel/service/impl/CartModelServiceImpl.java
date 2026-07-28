package com.wms.carriermanagementsystem.cartmodel.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.carriermanagementsystem.cartmodel.CartModelConverter;
import com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import com.wms.carriermanagementsystem.cartmodel.service.CartModelService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * 料车型号业务实现
 * <p>
 * 包含型号增删改查逻辑，事务注解作用于此层。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@Service
@RequiredArgsConstructor
public class CartModelServiceImpl extends ServiceImpl<CartModelMapper, CartModel> implements CartModelService {

    private final CartModelMapper cartModelMapper;
    private final CartModelConverter cartModelConverter;

    @Override
    public IPage<CartModelVO> listCartModel(CartModelQueryDTO queryParams) {
        Page<CartModelVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        List<CartModelVO> list = cartModelMapper.selectCartModelList(page, queryParams);
        page.setRecords(list);
        return page;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean addCartModel(CartModelDTO dto) {
        CartModel entity = cartModelConverter.toEntity(dto);
        if (entity.getLayerCount() == null) {
            entity.setLayerCount(1);
        }
        return save(entity);
    }

    @Override
    public CartModelDTO formCartModel(Long id) {
        CartModel entity = getById(id);
        return entity != null ? cartModelConverter.toDTO(entity) : null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCartModel(Long id, CartModelDTO dto) {
        CartModel entity = cartModelConverter.toEntity(dto);
        entity.setId(id);
        if (entity.getLayerCount() == null) {
            entity.setLayerCount(1);
        }
        return updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCartModel(String ids) {
        List<Long> idList = Arrays.stream(ids.split(","))
                .map(Long::parseLong).collect(Collectors.toList());
        return removeByIds(idList);
    }

    @Override
    public List<CartModelVO> formOptions() {
        return cartModelMapper.selectFormOptions();
    }

    @Override
    public List<CartModelVO> filterOptions() {
        return cartModelMapper.selectFormOptions();
    }
}
