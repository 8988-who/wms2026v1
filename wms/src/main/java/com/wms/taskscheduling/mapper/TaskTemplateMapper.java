package com.wms.taskscheduling.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.taskscheduling.model.entity.TaskTemplateEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * 任务模板持久层接口（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Mapper
public interface TaskTemplateMapper extends BaseMapper<TaskTemplateEntity> {
}
