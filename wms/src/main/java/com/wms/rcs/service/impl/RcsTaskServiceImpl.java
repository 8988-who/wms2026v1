package com.wms.rcs.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.enums.ApiEnum;
import com.wms.common.exception.BusinessException;
import com.wms.common.result.Result;
import com.wms.common.result.ResultCode;
import com.wms.rcs.enums.RcsOperatorTypeEnum;
import com.wms.rcs.enums.RcsTaskPriorityEnum;
import com.wms.rcs.enums.RcsTaskStatusEnum;
import com.wms.rcs.enums.RcsTaskTypeEnum;
import com.wms.rcs.event.RcsTaskInventoryEvent;
import com.wms.rcs.mapper.RcsTaskLifecycleMapper;
import com.wms.rcs.mapper.RcsTaskMapper;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.dto.callback.RcsTaskReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskWarningDTO;
import com.wms.rcs.model.dto.request.AgvSubmitTaskDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.entity.RcsTaskLifecycleEntity;
import com.wms.rcs.model.vo.RcsTaskLifecycleVO;
import com.wms.rcs.model.vo.RcsTaskVO;
import com.wms.rcs.service.AgvService;
import com.wms.rcs.service.RcsTaskService;
import com.wms.rcs.utils.RcsTaskConverter;
import com.wms.system.service.ISysConfigService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
@Slf4j
public class RcsTaskServiceImpl extends ServiceImpl<RcsTaskMapper, RcsTaskEntity> implements RcsTaskService {

    @Autowired
    private RcsTaskConverter rcsTaskConverter;
    @Autowired
    private RcsTaskLifecycleMapper rcsTaskLifecycleMapper;
    @Autowired
    private AgvService agvService;
    @Autowired
    private ApplicationEventPublisher eventPublisher;
    @Autowired
    private ISysConfigService sysConfigService;

    /**
     * 自身代理引用：下发成功/失败后的库写操作需经代理触发 @Transactional(REQUIRES_NEW)，
     * 避免同类方法自调用导致事务注解失效。
     */
    @Autowired
    @Lazy
    private RcsTaskServiceImpl self;

    private static final DateTimeFormatter CODE_DATE_FMT = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");

    @Override
    public IPage<RcsTaskVO> getRcsTaskPage(RcsTaskQueryDTO queryParams) {
        Page<RcsTaskVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        IPage<RcsTaskVO> result = this.getBaseMapper().getRcsTaskPage(page, queryParams);
        // XML 分页查询未包含枚举描述字段，此处按枚举补齐（与 getRcsTaskDetail 的 converter 口径一致）
        result.getRecords().forEach(vo -> {
            vo.setStatusLabel(RcsTaskStatusEnum.getLabelByValue(vo.getStatus()));
            vo.setTaskTypeLabel(RcsTaskTypeEnum.getLabelByValue(vo.getTaskType()));
            vo.setPriorityLabel(RcsTaskPriorityEnum.getLabelByValue(vo.getPriority()));
        });
        return result;
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
    public Long saveRcsTask(RcsTaskDTO dto) {
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
        return entity.getId();
    }

    @Override
    public Long saveAndSubmitRcsTask(RcsTaskDTO dto) {
        // 先本地建单（独立事务提交，确保下发远程调用前任务已落库）
        Long taskId = self.saveRcsTask(dto);
        // 建单成功后立即下发；下发失败不影响已建的任务（任务会被置为异常，可经 submitRcsTask 重试下发或取消）
        submitRcsTask(taskId);
        return taskId;
    }

    /**
     * 下发任务给 RCS。远程调用在事务外进行，调用结果再经代理触发库写事务。
     */
    @Override
    public boolean submitRcsTask(Long id) {
        RcsTaskEntity task = this.getById(id);
        Assert.notNull(task, "任务不存在");
        // 待执行任务首次下发；异常任务允许重试下发（沿用原 taskCode 作 reqCode，RCS 侧幂等去重不会重复作业，
        // 成功后经 changeStatus 由 EXCEPTION→ASSIGNED，矩阵已放行）
        Integer submitStatus = task.getStatus();
        Assert.isTrue(RcsTaskStatusEnum.PENDING.getValue().equals(submitStatus)
                        || RcsTaskStatusEnum.EXCEPTION.getValue().equals(submitStatus),
                "仅待执行/异常状态的任务可下发，当前任务[" + task.getTaskCode() + "]状态不允许下发");

        Result<Object> result;
        try {
            result = agvService.commonRequest(ApiEnum.AGV_submitTask, buildSubmitParams(task));
        } catch (Exception e) {
            // 网络异常/RCS 抛错：置为异常态，记录错误信息，允许后续重试
            log.error("RCS任务下发异常, taskCode={}", task.getTaskCode(), e);
            self.applyException(id, "任务下发异常：" + e.getMessage());
            return false;
        }

        if (result != null && ResultCode.SUCCESS.getCode().equals(result.getCode())) {
            String rcsTaskId = extractRcsTaskId(result.getData());
            self.applyAssigned(id, rcsTaskId);
            return true;
        } else {
            String msg = result == null ? "RCS返回空结果" : result.getMsg();
            self.applyException(id, "任务下发失败：" + msg);
            return false;
        }
    }

    /**
     * 下发成功后的库写：回填外部任务号并流转为"已派发"（独立新事务）
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void applyAssigned(Long id, String rcsTaskId) {
        RcsTaskEntity task = this.getById(id);
        if (task == null) {
            return;
        }
        if (StrUtil.isNotBlank(rcsTaskId)) {
            task.setRcsTaskId(rcsTaskId);
        }
        changeStatus(task, RcsTaskStatusEnum.ASSIGNED.getValue(),
                RcsOperatorTypeEnum.SYSTEM, null, "任务已下发至RCS");
        // 库存闭环：下发成功 → 预占目标点位（事件在事务提交后由 inventory 监听执行）
        publishInventoryEvent(RcsTaskInventoryEvent.Action.PRE_BIND, task.getCartCode(), task.getToLocation());
    }

    /**
     * 下发失败后的库写：流转为"异常"并记录错误信息（独立新事务）
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void applyException(Long id, String errorMsg) {
        RcsTaskEntity task = this.getById(id);
        if (task == null) {
            return;
        }
        changeStatus(task, RcsTaskStatusEnum.EXCEPTION.getValue(),
                RcsOperatorTypeEnum.SYSTEM, null, errorMsg);
    }

    /**
     * 取消任务（联动 RCS）。已派发/执行中的任务远程取消调用在事务外进行，成功后再经代理触发库写事务。
     */
    @Override
    public boolean cancelRcsTask(Long id, String reason) {
        RcsTaskEntity task = this.getById(id);
        Assert.notNull(task, "任务不存在");
        Integer status = task.getStatus();

        // 仅已完成/已取消为不可逆终态；异常任务允许取消（EXCEPTION→CANCELLED，矩阵已放行）
        Assert.isTrue(!RcsTaskStatusEnum.FINISHED.getValue().equals(status)
                        && !RcsTaskStatusEnum.CANCELLED.getValue().equals(status),
                "任务[" + task.getTaskCode() + "]已处于终态，不能取消");

        String remark = StrUtil.isBlank(reason) ? "手动取消任务" : "手动取消任务：" + reason;

        // 从未到达 RCS 的任务（待执行，或下发失败无外部任务号的异常任务）：本地直接取消，无需远程调用
        boolean neverReachedRcs = RcsTaskStatusEnum.PENDING.getValue().equals(status)
                || (RcsTaskStatusEnum.EXCEPTION.getValue().equals(status) && StrUtil.isBlank(task.getRcsTaskId()));
        if (neverReachedRcs) {
            self.applyCancelled(id, remark);
            return true;
        }

        // 已派发/执行中、或已到达 RCS 后异常（有外部任务号）：先联动 RCS 取消，成功后再落库
        try {
            Result<Object> result = agvService.commonRequest(ApiEnum.AGV_cancelTask, buildCancelParams(task));
            if (result == null || !ResultCode.SUCCESS.getCode().equals(result.getCode())) {
                String msg = result == null ? "RCS返回空结果" : result.getMsg();
                throw new BusinessException("RCS任务取消失败：" + msg);
            }
        } catch (BusinessException be) {
            throw be;
        } catch (Exception e) {
            log.error("RCS任务取消异常, taskCode={}", task.getTaskCode(), e);
            throw new BusinessException("RCS任务取消异常：" + e.getMessage());
        }

        self.applyCancelled(id, remark);
        return true;
    }

    /**
     * 取消成功后的库写：流转为"已取消"（独立新事务）
     */
    @Transactional(propagation = Propagation.REQUIRES_NEW, rollbackFor = Exception.class)
    public void applyCancelled(Long id, String remark) {
        RcsTaskEntity task = this.getById(id);
        if (task == null) {
            return;
        }
        Integer fromStatus = task.getStatus();
        changeStatus(task, RcsTaskStatusEnum.CANCELLED.getValue(),
                RcsOperatorTypeEnum.ADMIN, null, remark);
        // 库存闭环：已下发/执行中（目标点位已预占）的任务取消后释放预占
        if (RcsTaskStatusEnum.ASSIGNED.getValue().equals(fromStatus)
                || RcsTaskStatusEnum.EXECUTING.getValue().equals(fromStatus)) {
            publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND, task.getCartCode(), task.getToLocation());
        }
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
     * 处理 RCS 任务执行过程回馈：反查本地任务并驱动状态流转。
     * <p>回调可能重复投递，changeStatus 内部对相同目标状态幂等（相等直接跳过）。</p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleTaskReport(RcsTaskReportDTO report) {
        if (report == null) {
            log.warn("RCS任务回馈：请求体为空，忽略");
            return false;
        }
        RcsTaskEntity task = findTask(report.getTaskCode(), report.getTaskId());
        if (task == null) {
            log.warn("RCS任务回馈：未匹配到本地任务，taskCode={}, taskId={}, method={}, status={}",
                    report.getTaskCode(), report.getTaskId(), report.getMethod(), report.getStatus());
            return false;
        }

        Integer targetStatus = mapReportToStatus(report.getMethod(), report.getStatus());
        if (targetStatus == null) {
            log.info("RCS任务回馈：无法映射到本地状态（仅记录），taskCode={}, method={}, status={}",
                    task.getTaskCode(), report.getMethod(), report.getStatus());
            return true;
        }

        // 【C-09 临时方案，待测试后调整】终态任务对迟到/乱序的执行回馈仅记录、不再流转。
        // 与 handleTaskWarning 保持一致：异常任务的恢复应由主动重试下发驱动，而非被动回馈激活。
        // 注：changeStatus 内已有 canTransfer 兜底，此处提前拦截可避免无意义的库写与日志噪音。
        if (RcsTaskStatusEnum.of(task.getStatus()) != null
                && RcsTaskStatusEnum.of(task.getStatus()).isFinal()) {
            log.info("RCS任务回馈：任务[{}]已处于终态status={}，仅记录回馈不流转：method={}, status={}",
                    task.getTaskCode(), task.getStatus(), report.getMethod(), report.getStatus());
            return true;
        }

        // 回填执行AGV编号（若回馈带上）
        if (StrUtil.isNotBlank(report.getAgvCode())) {
            task.setAgvCode(report.getAgvCode());
        }
        // 库存闭环（事件在事务提交后由 inventory 监听执行）：
        //   取货(PICK) → 解绑源点位；完成(FINISHED) → 确认目标点位到达
        if (RcsTaskStatusEnum.EXECUTING.getValue().equals(targetStatus)
                && StrUtil.isNotBlank(report.getMethod())
                && report.getMethod().toUpperCase().contains("PICK")) {
            publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND, task.getCartCode(), task.getFromLocation());
        } else if (RcsTaskStatusEnum.FINISHED.getValue().equals(targetStatus)) {
            publishInventoryEvent(RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE, task.getCartCode(), task.getToLocation());
        }
        String remark = buildReportRemark(report);
        changeStatus(task, targetStatus, RcsOperatorTypeEnum.EXTERNAL, report.getAgvCode(), remark);
        return true;
    }

    /**
     * 处理 RCS 任务异常告警：反查本地任务并流转为"异常"，写入告警信息。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean handleTaskWarning(RcsTaskWarningDTO warning) {
        if (warning == null) {
            log.warn("RCS任务告警：请求体为空，忽略");
            return false;
        }
        RcsTaskEntity task = findTask(warning.getTaskCode(), warning.getTaskId());
        if (task == null) {
            log.warn("RCS任务告警：未匹配到本地任务，taskCode={}, taskId={}, warningCode={}, warningMsg={}",
                    warning.getTaskCode(), warning.getTaskId(), warning.getWarningCode(), warning.getWarningMsg());
            return false;
        }
        // 终态任务不再变更，仅记录告警日志
        if (isFinalStatus(task.getStatus())) {
            log.info("RCS任务告警：任务[{}]已处于终态status={}，仅记录告警：{} {}",
                    task.getTaskCode(), task.getStatus(), warning.getWarningCode(), warning.getWarningMsg());
            return true;
        }
        if (StrUtil.isNotBlank(warning.getAgvCode())) {
            task.setAgvCode(warning.getAgvCode());
        }
        String remark = buildWarningRemark(warning);
        changeStatus(task, RcsTaskStatusEnum.EXCEPTION.getValue(),
                RcsOperatorTypeEnum.EXTERNAL, warning.getAgvCode(), remark);
        return true;
    }

    /**
     * 反查本地任务：优先按 taskCode（业务主键）匹配，取不到用 rcsTaskId（外部任务号）兜底。
     */
    private RcsTaskEntity findTask(String taskCode, String rcsTaskId) {
        if (StrUtil.isNotBlank(taskCode)) {
            RcsTaskEntity task = this.getOne(new LambdaQueryWrapper<RcsTaskEntity>()
                    .eq(RcsTaskEntity::getTaskCode, taskCode), false);
            if (task != null) {
                return task;
            }
        }
        if (StrUtil.isNotBlank(rcsTaskId)) {
            return this.getOne(new LambdaQueryWrapper<RcsTaskEntity>()
                    .eq(RcsTaskEntity::getRcsTaskId, rcsTaskId), false);
        }
        return null;
    }

    /**
     * 将 RCS 回馈的执行阶段/状态映射到本地任务状态。
     * <p>
     * 兼容两种来源：字符串 method（阶段语义）优先，其次数值 status。字段取值最终以对接文档为准，
     * 若约定不同仅需调整此映射；无法识别时返回 null（调用方仅记录不流转）。
     * </p>
     *
     * @param method RCS 回馈动作/阶段（大小写不敏感，含关键字即匹配）
     * @param status RCS 回馈数值状态
     * @return 本地状态值（{@link RcsTaskStatusEnum} 的 value），无法映射返回 null
     */
    private Integer mapReportToStatus(String method, Integer status) {
        if (StrUtil.isNotBlank(method)) {
            String m = method.trim().toUpperCase();
            // 完成：FINISH/END/COMPLETE/DONE
            if (m.contains("FINISH") || m.contains("END") || m.contains("COMPLETE") || m.contains("DONE")) {
                return RcsTaskStatusEnum.FINISHED.getValue();
            }
            // 执行中：START/EXECUT/ROBOT_APPLY/PICK/PUT/RUNNING/PROGRESS/MOVING
            if (m.contains("START") || m.contains("EXECUT") || m.contains("APPLY")
                    || m.contains("PICK") || m.contains("PUT") || m.contains("RUNNING")
                    || m.contains("PROGRESS") || m.contains("MOVING")) {
                return RcsTaskStatusEnum.EXECUTING.getValue();
            }
            // 取消：CANCEL/ABORT
            if (m.contains("CANCEL") || m.contains("ABORT")) {
                return RcsTaskStatusEnum.CANCELLED.getValue();
            }
            // 派发/接受：ASSIGN/ACCEPT/RECEIVE
            if (m.contains("ASSIGN") || m.contains("ACCEPT") || m.contains("RECEIVE")) {
                return RcsTaskStatusEnum.ASSIGNED.getValue();
            }
            // 异常/失败：ERROR/FAIL/EXCEPTION
            if (m.contains("ERROR") || m.contains("FAIL") || m.contains("EXCEPTION")) {
                return RcsTaskStatusEnum.EXCEPTION.getValue();
            }
        }
        // 数值状态兜底：直接采用与本地一致的 6 态编码（对接文档不同则在此调整）
        if (status != null && RcsTaskStatusEnum.getLabelByValue(status) != null) {
            return status;
        }
        return null;
    }

    /**
     * 是否终态（已完成/已取消/异常）。
     * <p>委托给 {@link RcsTaskStatusEnum#isFinal()}，保证终态定义单一来源（C-09）。</p>
     */
    private boolean isFinalStatus(Integer status) {
        RcsTaskStatusEnum e = RcsTaskStatusEnum.of(status);
        return e != null && e.isFinal();
    }

    /**
     * 组装执行回馈备注
     */
    private String buildReportRemark(RcsTaskReportDTO report) {
        StringBuilder sb = new StringBuilder("RCS回馈");
        if (StrUtil.isNotBlank(report.getMethod())) {
            sb.append("[").append(report.getMethod()).append("]");
        }
        if (StrUtil.isNotBlank(report.getAgvCode())) {
            sb.append(" AGV=").append(report.getAgvCode());
        }
        if (StrUtil.isNotBlank(report.getMessage())) {
            sb.append(" ").append(report.getMessage());
        }
        return sb.toString();
    }

    /**
     * 组装告警备注
     */
    private String buildWarningRemark(RcsTaskWarningDTO warning) {
        StringBuilder sb = new StringBuilder("RCS告警");
        if (StrUtil.isNotBlank(warning.getWarningCode())) {
            sb.append("[").append(warning.getWarningCode()).append("]");
        }
        if (StrUtil.isNotBlank(warning.getWarningMsg())) {
            sb.append(" ").append(warning.getWarningMsg());
        }
        if (StrUtil.isNotBlank(warning.getAgvCode())) {
            sb.append(" AGV=").append(warning.getAgvCode());
        }
        return sb.toString();
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
        // 【C-09 临时方案，待测试后调整】状态流转合法性校验：非法流转（如终态被回退、执行中打回已派发）
        // 记 warn 日志并跳过，不抛异常（适配 RCS 回调乱序/重复投递场景，避免回调接口报错）。
        // 流转白名单见 RcsTaskStatusEnum.TRANSITIONS，业务口径待联调测试后校准。
        if (!RcsTaskStatusEnum.canTransfer(statusFrom, toStatus)) {
            log.warn("RCS任务状态非法流转已拒绝：taskId={}, taskCode={}, from={}({}) -> to={}({}), opType={}, remark={}",
                    task.getId(), task.getTaskCode(),
                    statusFrom, RcsTaskStatusEnum.getLabelByValue(statusFrom),
                    toStatus, RcsTaskStatusEnum.getLabelByValue(toStatus),
                    opType, remark);
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
     * 发布库存闭环事件（携带编码，由 inventory 模块监听执行，保持 rcs 不反向依赖业务）。
     * 仅当关联料车与点位编码均存在时发布（有料车搬运才涉及绑定关系）。
     */
    private void publishInventoryEvent(RcsTaskInventoryEvent.Action action, String cartCode, String locationCode) {
        if (StrUtil.isBlank(cartCode) || StrUtil.isBlank(locationCode)) {
            return;
        }
        eventPublisher.publishEvent(RcsTaskInventoryEvent.of(action, cartCode, locationCode));
    }

    /**
     * 生成任务编号：RCS + 时间戳 + 4位随机，保证全局唯一
     */
    private String generateTaskCode() {
        return "RCS" + LocalDateTime.now().format(CODE_DATE_FMT)
                + IdUtil.fastSimpleUUID().substring(0, 4).toUpperCase();
    }

    /**
     * 组装下发给 RCS 的请求参数（DTO 形式，字段名编译期正确）。
     * <p>
     * reqCode 使用本地任务编号，保证同一任务重复下发时 RCS 侧可幂等去重；
     * targetRoute 按"源点位取车 → 目标点位放车"两步组装，与已验证的 RCS 下发格式对齐。
     * </p>
     */
    private AgvSubmitTaskDTO buildSubmitParams(RcsTaskEntity task) {
        AgvSubmitTaskDTO dto = new AgvSubmitTaskDTO();
        // 请求编号（唯一，重复提交沿用同一编号）
        dto.setReqCode(task.getTaskCode());
        // 任务类型：按本地类型枚举映射为 RCS 协议 taskType
        dto.setTaskType(mapTaskType(task.getTaskType()));
        // 执行步骤：源点位取车 → 目标点位放车（type=SITE 固定，code 为点位地图坐标）
        List<Map<String, Object>> route = new ArrayList<>();
        if (StrUtil.isNotBlank(task.getFromLocation())) {
            route.add(routeStep("SITE", toRcsSiteCode(task.getFromLocation())));
        }
        if (StrUtil.isNotBlank(task.getToLocation())) {
            route.add(routeStep("SITE", toRcsSiteCode(task.getToLocation())));
        }
        dto.setTargetRoute(route);
        // 初始优先级（1-低 2-中 3-高 4-紧急 → 30/50/80/120，与成功下发包一致基准）
        dto.setInitPriority(mapPriority(task.getPriority()));
        return dto;
    }

    /**
     * 点位编码 → RCS 站点编码（地图坐标）：下发 targetRoute.code 以 wms_point.coordinate 为准；
     * 查不到坐标时回退使用点位编码原值，避免历史数据/非点位编码导致下发中断。
     */
    private String toRcsSiteCode(String locationCode) {
        if (StrUtil.isBlank(locationCode)) {
            return locationCode;
        }
        String coordinate = this.getBaseMapper().selectCoordinateByPointCode(locationCode);
        if (StrUtil.isBlank(coordinate)) {
            log.warn("RCS下发：点位编码[{}]未匹配到地图坐标(wms_point.coordinate)，按原值下发", locationCode);
            return locationCode;
        }
        return coordinate;
    }

    /**
     * 组装单步执行步骤
     */
    private Map<String, Object> routeStep(String type, String code) {
        Map<String, Object> step = new HashMap<>();
        step.put("type", type);
        step.put("code", code);
        return step;
    }

    /**
     * 本地任务类型(1-搬运 2-充电 3-调度 4-巡检) → RCS 协议 taskType 字符串
     * <p>
     * 从系统配置表(sys_config)读取配置键 {@code wms.rcs.template.{taskType}}，如：
     * <ul>
     *     <li>wms.rcs.template.1 = PF-LMR-COMMON（搬运-潜伏车）</li>
     *     <li>wms.rcs.template.2 = PF-LMR-CHARGE（充电）</li>
     *     <li>wms.rcs.template.3 = PF-LMR-DISPATCH（调度）</li>
     *     <li>wms.rcs.template.4 = PF-LMR-INSPECT（巡检）</li>
     * </ul>
     * 未配置时统一兜底返回 {@code PF-LMR-COMMON}。
     * </p>
     */
    private String mapTaskType(Integer taskType) {
        if (taskType == null) {
            return "PF-LMR-COMMON";
        }
        String configKey = "wms.rcs.template." + taskType;
        String template = sysConfigService.selectConfigByKey(configKey);
        return StrUtil.isNotBlank(template) ? template : "PF-LMR-COMMON";
    }

    /**
     * 本地优先级(1-4) → RCS 初始优先级(1~120)，数值越大优先级越高
     */
    private Integer mapPriority(Integer priority) {
        if (priority == null) {
            return 50;
        }
        return switch (priority) {
            case 1 -> 30;   // 低
            case 3 -> 80;   // 高
            case 4 -> 120;  // 紧急
            default -> 50;  // 中（含默认）
        };
    }

    /**
     * 组装取消给 RCS 的请求参数。
     * <p>
     * reqCode 使用本地任务编号，与下发时保持一致，保证 RCS 侧能定位到同一请求；
     * taskCode 一并传递以便 RCS 明确取消的目标任务。若已回填外部任务号则附带 rcsTaskId。
     * </p>
     */
    private Map<String, Object> buildCancelParams(RcsTaskEntity task) {
        Map<String, Object> params = new HashMap<>();
        // 请求编号（唯一，与下发时同一编号，便于 RCS 幂等定位）
        params.put("reqCode", task.getTaskCode());
        params.put("taskCode", task.getTaskCode());
        // 外部任务号存在时一并传递，提升 RCS 侧匹配成功率
        if (StrUtil.isNotBlank(task.getRcsTaskId())) {
            params.put("rcsTaskId", task.getRcsTaskId());
        }
        return params;
    }

    /**
     * 从 RCS 返回的 data 中提取外部任务ID。
     * <p>RCS 不同接口返回结构可能不同，这里做兼容提取：优先取 taskId/reqCode，取不到则返回 null。</p>
     */
    @SuppressWarnings("unchecked")
    private String extractRcsTaskId(Object data) {
        if (data == null) {
            return null;
        }
        if (data instanceof Map<?, ?> map) {
            Object id = ((Map<String, Object>) map).get("taskId");
            if (id == null) {
                id = ((Map<String, Object>) map).get("reqCode");
            }
            return id == null ? null : id.toString();
        }
        // 非结构化返回，直接以字符串形式记录
        return data.toString();
    }
}
