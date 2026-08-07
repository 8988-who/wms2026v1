package com.wms.warehouse.utils;

import org.mapstruct.Mapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.wms.warehouse.model.dto.WmsAisleDTO;

/**
 * 巷道对象转换器
 * <p>
 * 基于 MapStruct 实现巷道实体(WmsAisle)与数据传输对象(WmsAisleDTO)之间的双向转换。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Mapper(componentModel = "spring")
public interface WmsAisleConverter {

    WmsAisleDTO toDTO(WmsAisle entity);

    WmsAisle toEntity(WmsAisleDTO dto);

}