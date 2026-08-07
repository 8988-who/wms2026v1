package com.wms.warehouse.utils;

import org.mapstruct.Mapper;
import com.wms.warehouse.model.entity.WmsLocation;
import com.wms.warehouse.model.dto.WmsLocationDTO;

/**
 * 库位/区域对象转换器
 * <p>
 * 基于 MapStruct 实现库位/区域实体(WmsLocation)与数据传输对象(WmsLocationDTO)之间的双向转换。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Mapper(componentModel = "spring")
public interface WmsLocationConverter {

    WmsLocationDTO toDTO(WmsLocation entity);

    WmsLocation toEntity(WmsLocationDTO dto);

}