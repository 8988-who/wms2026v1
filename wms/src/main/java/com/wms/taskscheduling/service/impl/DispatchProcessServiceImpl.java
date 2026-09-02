package com.wms.taskscheduling.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.taskscheduling.mapper.DispatchProcessMapper;
import com.wms.taskscheduling.model.entity.DispatchProcessEntity;
import com.wms.taskscheduling.service.DispatchProcessService;
import org.springframework.stereotype.Service;

/**
 * 编排流程业务服务实现（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Service
public class DispatchProcessServiceImpl
        extends ServiceImpl<DispatchProcessMapper, DispatchProcessEntity>
        implements DispatchProcessService {
}
