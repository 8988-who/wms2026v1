package com.wms.rcs.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.rcs.model.entity.RcsTaskLifecycleEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * RCS任务状态变更历史持久层接口
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Mapper
public interface RcsTaskLifecycleMapper extends BaseMapper<RcsTaskLifecycleEntity> {
}
