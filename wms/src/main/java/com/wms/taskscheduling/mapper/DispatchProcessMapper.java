package com.wms.taskscheduling.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.taskscheduling.model.entity.DispatchProcessEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 编排流程持久层接口（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Mapper
public interface DispatchProcessMapper extends BaseMapper<DispatchProcessEntity> {
}
