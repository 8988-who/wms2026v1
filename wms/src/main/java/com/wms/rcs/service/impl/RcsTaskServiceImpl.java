package com.wms.rcs.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.rcs.enums.RcsOperatorTypeEnum;
import com.wms.rcs.enums.RcsTaskStatusEnum;
import com.wms.rcs.mapper.RcsTaskLifecycleMapper;
import com.wms.rcs.mapper.RcsTaskMapper;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.entity.RcsTaskLifecycleEntity;
import com.wms.rcs.model.vo.RcsTaskLifecycleVO;
import com.wms.rcs.model.vo.RcsTaskVO;
import com.wms.rcs.service.RcsTaskService;
import com.wms.rcs.utils.RcsTaskConverter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * RCS任务业务服务实现
 * <p>
 * 实现任务的分页查询、详情、新增、修改、删除。状态流转统一经 {@link #changeStatus} 处理，
 * 在同一事务内更新主表状态/时间戳并写入一条状态变更历史（wms_rcs_task_lifecycle）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RcsTaskServiceImpl extends ServiceImpl<RcsTaskMapper, RcsTaskEntity> implements RcsTaskService {

    private final RcsTaskConverter rcsTaskConverter;
    private final RcsTaskLifecycleMapper rcsTaskLifecycleMapper;

    private static final DateTimeFormatter CODE_DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Override
    public IPage<RcsTaskVO> getRcsTaskPage(RcsTaskQueryDTO queryParams) {
        Page<RcsTaskVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.getBaseMapper().getRcsTaskPage(page, queryParams);
    }

    @Override
    public RcsTaskVO getRcsTaskDetail(Long id) {
        RcsTaskEntity entity = this.getById(id);
        Assert.notNull(entity, "任务不存在");
        RcsTaskVO vo = rcsTaskConverter.toVO(entity);

        List<RcsTaskLifecycleEntity> lifecycleList = rcsTaskLifecycleMapper.selectList(
                new LambdaQueryWrapper<RcsTaskLifecycleEntity>()
                        .eq(RcsTaskLifecycleEntity::getTaskId, id)
                        .orderByAsc(RcsTaskLifecycleEntity::getCreateTime)
                        .orderByAsc(RcsTaskLifecycleEntity::getId));
        List<RcsTaskLifecycleVO> lifecycleVOs = lifecycleList.stream()
                .map(rcsTaskConverter::toLifecycleVO)
                .toList();
        vo.setLifecycles(lifecycleVOs);
        return vo;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveRcsTask(RcsTaskDTO dto) {
        RcsTaskEntity entity = rcsTaskConverter.toEntity(dto);
        entity.setId(null);
        entity.setTaskCode(generateTaskCode());
        entity.setStatus(RcsTaskStatusEnum.PENDING.getValue());
        entity.setSubmitTime(LocalDateTime.now());
        if (entity.getPriority() == null) {
            entity.setPriority(2);
        }
        boolean saved = this.save(entity);
        Assert.isTrue(saved, "任务创建失败");

        // 记录初始状态（null -> 待执行），满足生命周期从建单起可追溯
        writeLifecycle(entity.getId(), null, entity.getStatus(),
                RcsOperatorTypeEnum.ADMIN, null, "创建任务");
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateRcsTask(Long id, RcsTaskDTO dto) {
        RcsTaskEntity existing = this.getById(id);
        Assert.notNull(existing, "任务不存在");
        Assert.isTrue(RcsTaskStatusEnum.PENDING.getValue().equals(existing.getStatus()),
                "仅待执行状态的任务可修改");

        RcsTaskEntity entity = rcsTaskConverter.toEntity(dto);
        entity.setId(id);
        // 业务主键与状态/时间等由服务端管理，禁止随表单覆盖
        entity.setTaskCode(existing.getTaskCode());
        entity.setStatus(existing.getStatus());
        entity.setSubmitTime(existing.getSubmitTime());
        return this.updateById(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteRcsTasks(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }
        String[] idArray = ids.split(",");
        for (String idStr : idArray) {
            Long taskId = Long.parseLong(idStr.trim());
            RcsTaskEntity entity = this.getById(taskId);
            Assert.notNull(entity, "任务不存在");
            Integer status = entity.getStatus();
            // 执行中/已派发的任务不允许直接删除，避免与 RCS 侧状态失配
            Assert.isTrue(!RcsTaskStatusEnum.ASSIGNED.getValue().equals(status)
                            && !RcsTaskStatusEnum.EXECUTING.getValue().equals(status),
                    "任务[" + entity.getTaskCode() + "]处于进行中，不能删除");
            this.removeById(taskId);
        }
        return true;
    }

    /**
     * 统一状态流转入口：更新主表状态与关键时间戳，并在同一事务写入一条状态变更历史。
     * <p>后续阶段（下发/取消/回调）均应经此方法改变状态，禁止直接 setStatus。</p>
     *
     * @param task      任务实体（会被就地更新并持久化）
     * @param toStatus  目标状态（{@link RcsTaskStatusEnum} 的 value）
     * @param opType    操作者类型
     * @param opId      操作者标识（如AGV编号/用户ID，可空）
     * @param remark    变更备注
     */
    @Transactional(rollbackFor = Exception.class)
    public void changeStatus(RcsTaskEntity task, Integer toStatus,
                             RcsOperatorTypeEnum opType, String opId, String remark) {
        Integer statusFrom = task.getStatus();
        if (toStatus.equals(statusFrom)) {
            return;
        }
        LocalDateTime now = LocalDateTime.now();
        task.setStatus(toStatus);
        if (RcsTaskStatusEnum.ASSIGNED.getValue().equals(toStatus)) {
            task.setAssignedAt(now);
        } else if (RcsTaskStatusEnum.EXECUTING.getValue().equals(toStatus)) {
            if (task.getStartTime() == null) {
                task.setStartTime(now);
            }
        } else if (RcsTaskStatusEnum.FINISHED.getValue().equals(toStatus)
                || RcsTaskStatusEnum.CANCELLED.getValue().equals(toStatus)) {
            task.setFinishTime(now);
        } else if (RcsTaskStatusEnum.EXCEPTION.getValue().equals(toStatus)) {
            task.setErrorMsg(remark);
        }
        this.updateById(task);
        writeLifecycle(task.getId(), statusFrom, toStatus, opType, opId, remark);
    }

    /**
     * 写入一条状态变更历史
     */
    private void writeLifecycle(Long taskId, Integer statusFrom, Integer statusTo,
                                RcsOperatorTypeEnum opType, String opId, String remark) {
        RcsTaskLifecycleEntity lifecycle = new RcsTaskLifecycleEntity();
        lifecycle.setTaskId(taskId);
        lifecycle.setStatusFrom(statusFrom);
        lifecycle.setStatusTo(statusTo);
        lifecycle.setOperatorType(opType == null ? null : opType.getValue());
        lifecycle.setOperatorId(opId);
        lifecycle.setRemark(remark);
        rcsTaskLifecycleMapper.insert(lifecycle);
    }

    /**
     * 生成任务编号：RCS + 时间戳 + 4位随机，保证全局唯一
     */
    private String generateTaskCode() {
        return "RCS" + LocalDateTime.now().format(CODE_DATE_FMT)
                + IdUtil.fastSimpleUUID().substring(0, 4).toUpperCase();
    }
}
