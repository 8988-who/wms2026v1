package com.wms.taskscheduling.service.impl;

import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.taskscheduling.mapper.DispatchSessionMapper;
import com.wms.taskscheduling.model.entity.DispatchSessionEntity;
import com.wms.taskscheduling.service.DispatchSessionService;
import org.springframework.stereotype.Service;

/**
 * 调度会话业务服务实现（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Service
public class DispatchSessionServiceImpl
        extends ServiceImpl<DispatchSessionMapper, DispatchSessionEntity>
        implements DispatchSessionService {
}
