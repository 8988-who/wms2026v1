package com.wms.taskscheduling.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.taskscheduling.mapper.TaskTemplateMapper;
import com.wms.taskscheduling.model.entity.TaskTemplateEntity;
import com.wms.taskscheduling.service.TaskTemplateService;
import org.springframework.stereotype.Service;

/**
 * 任务模板业务服务实现（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Service
public class TaskTemplateServiceImpl
        extends ServiceImpl<TaskTemplateMapper, TaskTemplateEntity>
        implements TaskTemplateService {
}
