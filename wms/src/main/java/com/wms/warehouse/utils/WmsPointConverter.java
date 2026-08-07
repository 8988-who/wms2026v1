package com.wms.warehouse.utils;

import org.mapstruct.Mapper;
import com.wms.warehouse.model.entity.WmsPoint;
import com.wms.warehouse.model.dto.WmsPointDTO;

/**
 * 点位对象转换器
 * <p>
 * 基于 MapStruct 实现点位实体(WmsPoint)与数据传输对象(WmsPointDTO)之间的双向转换。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Mapper(componentModel = "spring")
public interface WmsPointConverter {

    WmsPointDTO toDTO(WmsPoint entity);

    WmsPoint toEntity(WmsPointDTO dto);

}