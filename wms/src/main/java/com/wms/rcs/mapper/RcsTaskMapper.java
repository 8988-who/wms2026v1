package com.wms.rcs.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.dto.RcsPointRef;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.vo.RcsTaskVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * RCS任务持久层接口
 * <p>
 * 继承 MyBatis-Plus BaseMapper，提供任务分页查询（带创建人/更新人昵称）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Mapper
public interface RcsTaskMapper extends BaseMapper<RcsTaskEntity> {

    Page<RcsTaskVO> getRcsTaskPage(Page<RcsTaskVO> page, RcsTaskQueryDTO queryParams);

    /**
     * 按点位编码查询地图坐标（wms_point.coordinate），RCS 下发 targetRoute.code 以地图坐标为准
     */
    String selectCoordinateByPointCode(@Param("pointCode") String pointCode);

    /**
     * 按地图坐标反查点位（wms_point），RCS 绑定回调 slotCode（坐标口径）→ 本地点位。
     * 坐标正常应唯一，返回多条说明基础数据有重复，调用方取第一条并告警。
     */
    java.util.List<RcsPointRef> selectPointIdByCoordinate(@Param("coordinate") String coordinate);
}
