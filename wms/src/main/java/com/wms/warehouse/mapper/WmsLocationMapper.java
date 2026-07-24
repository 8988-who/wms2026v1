package com.wms.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.warehouse.model.entity.WmsLocation;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.warehouse.model.dto.WmsLocationQueryDTO;
import com.wms.warehouse.model.vo.WmsLocationVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 库位/区域持久层接口
 * <p>
 * 继承 MyBatis-Plus BaseMapper，提供库位/区域分页查询和更新人名称查询。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Mapper
public interface WmsLocationMapper extends BaseMapper<WmsLocation> {

    Page<WmsLocationVO> getWmsLocationPage(Page<WmsLocationVO> page, WmsLocationQueryDTO queryParams);

    List<String> getUpdatedByNames(@Param("ids") List<Long> ids);

}