package com.wms.carriermanagementsystem.cart;

import com.wms.carriermanagementsystem.cart.model.dto.CartDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;
import org.mapstruct.NullValuePropertyMappingStrategy;

/**
 * 料车对象转换器
 * <p>
 * 基于 MapStruct 实现料车实体(Cart)与数据传输对象(CartDTO)之间的双向转换。
 * 类级 nullValuePropertyMappingStrategy=IGNORE：增量映射（updateEntity）时 DTO 中为 null 的字段
 * 不覆盖目标实体原值，保证 status/currentQuantity 等 DTO 未携带的冗余状态字段被保留（M-1 加固）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Mapper(componentModel = "spring",
        nullValuePropertyMappingStrategy = NullValuePropertyMappingStrategy.IGNORE)
public interface CartConverter {

    CartDTO toDTO(Cart entity);

    Cart toEntity(CartDTO dto);

    void updateEntity(@MappingTarget Cart entity, CartDTO dto);
}
