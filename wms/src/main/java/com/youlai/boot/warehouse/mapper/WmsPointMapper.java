package com.youlai.boot.warehouse.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.youlai.boot.warehouse.model.entity.WmsPoint;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.youlai.boot.warehouse.model.dto.WmsPointQueryDTO;
import com.youlai.boot.warehouse.model.vo.WmsPointVO;
import org.apache.ibatis.annotations.Mapper;

/**
 * 点位持久层接口
 * <p>
 * 继承 MyBatis-Plus BaseMapper，提供点位分页查询。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Mapper
public interface WmsPointMapper extends BaseMapper<WmsPoint> {

    Page<WmsPointVO> getWmsPointPage(Page<WmsPointVO> page, WmsPointQueryDTO queryParams);
}