package com.wms.carriermanagementsystem.cartmodel;

import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import org.mapstruct.Mapper;

/**
 * 料车型号对象转换器
 * <p>
 * 基于 MapStruct 实现型号实体(CartModel)与数据传输对象(CartModelDTO)之间的双向转换。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Mapper(componentModel = "spring")
public interface CartModelConverter {

    CartModelDTO toDTO(CartModel entity);

    CartModel toEntity(CartModelDTO dto);
}
