package com.wms.carriermanagementsystem.cartitem;

import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemDTO;
import com.wms.carriermanagementsystem.cartitem.model.entity.CartItem;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

/**
 * 料车物品对象转换器
 * <p>
 * 基于 MapStruct 实现料车物品实体(CartItem)与数据传输对象(CartItemDTO)之间的双向转换。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@Mapper(componentModel = "spring")
public interface CartItemConverter {

    CartItemDTO toDTO(CartItem entity);

    CartItem toEntity(CartItemDTO dto);

    void updateEntity(@MappingTarget CartItem entity, CartItemDTO dto);
}
