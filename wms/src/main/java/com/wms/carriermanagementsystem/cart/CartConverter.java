package com.wms.carriermanagementsystem.cart;

import com.wms.carriermanagementsystem.cart.model.dto.CartDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

/**
 * 料车对象转换器
 * <p>
 * 基于 MapStruct 实现料车实体(Cart)与数据传输对象(CartDTO)之间的双向转换。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Mapper(componentModel = "spring")
public interface CartConverter {

    CartDTO toDTO(Cart entity);

    Cart toEntity(CartDTO dto);

    void updateEntity(@MappingTarget Cart entity, CartDTO dto);
}
