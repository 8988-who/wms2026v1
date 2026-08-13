package com.wms.carriermanagementsystem.cartmodel.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.carriermanagementsystem.cart.mapper.CartMapper;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cartmodel.CartModelConverter;
import com.wms.carriermanagementsystem.cartmodel.mapper.CartModelMapper;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import com.wms.carriermanagementsystem.cartmodel.service.CartModelService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 料车型号业务实现
 * <p>
 * 包含型号增删改查逻辑，事务注解作用于此层。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CartModelServiceImpl extends ServiceImpl<CartModelMapper, CartModel> implements CartModelService {

    private final CartModelMapper cartModelMapper;
    private final CartModelConverter cartModelConverter;
    private final CartMapper cartMapper;

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
        // 型号编码唯一性前置查重（DB 唯一索引 uk_model_code 兜底）
        checkModelCodeUnique(dto.getModelCode(), null);
        CartModel entity = cartModelConverter.toEntity(dto);
        if (entity.getLayerCount() == null) {
            entity.setLayerCount(1);
        }
        try {
            return save(entity);
        } catch (DuplicateKeyException e) {
            log.warn("并发新增型号编码冲突，modelCode={}", dto.getModelCode(), e);
            throw new RuntimeException("型号编码 " + dto.getModelCode() + " 已存在");
        }
    }

    @Override
    public CartModelDTO formCartModel(Long id) {
        CartModel entity = getById(id);
        return entity != null ? cartModelConverter.toDTO(entity) : null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateCartModel(Long id, CartModelDTO dto) {
        // 型号编码唯一性前置查重（修改时排除自身）
        checkModelCodeUnique(dto.getModelCode(), id);
        CartModel entity = cartModelConverter.toEntity(dto);
        entity.setId(id);
        if (entity.getLayerCount() == null) {
            entity.setLayerCount(1);
        }
        try {
            return updateById(entity);
        } catch (DuplicateKeyException e) {
            log.warn("并发修改型号编码冲突，modelCode={}", dto.getModelCode(), e);
            throw new RuntimeException("型号编码 " + dto.getModelCode() + " 已存在");
        }
    }

    /** 型号编码唯一性校验（新增传 excludeId=null；modelCode 为空时跳过，由 DB 非空约束兜底） */
    private void checkModelCodeUnique(String modelCode, Long excludeId) {
        if (modelCode == null) {
            return;
        }
        Long exist = cartModelMapper.selectCount(
                new LambdaQueryWrapper<CartModel>()
                        .eq(CartModel::getModelCode, modelCode)
                        .ne(excludeId != null, CartModel::getId, excludeId));
        if (exist != null && exist > 0) {
            throw new RuntimeException("型号编码 " + modelCode + " 已存在");
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteCartModel(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String id : idArray) {
            Long modelId = Long.parseLong(id);
            CartModel entity = this.getById(modelId);
            Assert.notNull(entity, "型号不存在");

            // 删除前校验：型号仍被料车引用时禁止删除（外键双保险，给出友好提示）
            Long cartCount = cartMapper.selectCount(
                    new LambdaQueryWrapper<Cart>()
                            .eq(Cart::getModelId, modelId));
            Assert.isTrue(cartCount == 0, "该型号下仍有 " + cartCount + " 台料车，请先处理后再删除");

            this.removeById(modelId);
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
}
