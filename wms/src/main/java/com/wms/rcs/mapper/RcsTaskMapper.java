package com.wms.rcs.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.vo.RcsTaskVO;
import org.apache.ibatis.annotations.Mapper;

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
}
