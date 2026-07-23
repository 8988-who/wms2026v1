package com.wms.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.warehouse.model.dto.WmsAisleQueryDTO;
import com.wms.warehouse.model.vo.WmsAisleVO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 巷道持久层接口
 * <p>
 * 继承 MyBatis-Plus BaseMapper，提供巷道分页查询。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Mapper
public interface WmsAisleMapper extends BaseMapper<WmsAisle> {

    Page<WmsAisleVO> getWmsAislePage(Page<WmsAisleVO> page, WmsAisleQueryDTO queryParams);
}