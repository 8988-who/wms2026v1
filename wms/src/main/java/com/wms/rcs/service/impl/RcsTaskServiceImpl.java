package com.wms.rcs.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.rcs.enums.RcsApiEnum;
import com.wms.common.exception.BusinessException;
import com.wms.common.result.Result;
import com.wms.common.result.ResultCode;
import com.wms.rcs.enums.RcsCallbackMethodEnum;
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
import com.wms.rcs.model.dto.request.AgvCancelTaskDTO;
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

    /** 执行中任务超时兜底默认阈值（分钟），可用 sys_config: wms.rcs.executing.timeout-minutes 覆盖 */
    private static final int DEFAULT_EXECUTING_TIMEOUT_MINUTES = 120;

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
            result = agvService.commonRequest(RcsApiEnum.SUBMIT_TASK, buildSubmitParams(task));
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
        // 下发成功仅流转"已下发"，不做点位预占（remark 锁）：
        // 料车保持绑定在起点，待 RCS 回馈 notifyRobotLeav01（料车随 AGV 离开）时再锁定起点/终点（remark=1）
        changeStatus(task, RcsTaskStatusEnum.ASSIGNED.getValue(),
                RcsOperatorTypeEnum.SYSTEM, null, "任务已下发至RCS");
        // 库存闭环：任务下发即把料车所在起点标记为该任务的"预定任务"（写 last_task_code，供库存页展示）
        publishInventoryEvent(RcsTaskInventoryEvent.Action.MARK_TASK,
                task.getCartCode(), task.getFromLocation(), task.getTaskCode());
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
     * 执行超时兜底：把进入"执行中"超过阈值仍无完成/取消回馈的任务置为"异常"（定时任务驱动）。
     * <p>RCS 失联、回调中断、AGV 卡死不完成也不取消时，任务不会自行进入终态，
     * 预占（remark=1）与预定任务标记（last_task_code）将永久占用起/终点点位；
     * 本方法逐任务经 {@link #applyException} 置异常——复用 changeStatus 的 EXCEPTION 分支，
     * 自动对起/终点 RELEASE + CLEAR（幂等）。阈值取自 sys_config: wms.rcs.executing.timeout-minutes，默认 120 分钟。</p>
     *
     * @return 本轮置异常的任务数
     */
    @Override
    public int timeoutExecutingRcsTasks() {
        int timeoutMinutes = resolveExecutingTimeoutMinutes();
        LocalDateTime cutoff = LocalDateTime.now().minusMinutes(timeoutMinutes);
        List<RcsTaskEntity> timeoutTasks = this.list(new LambdaQueryWrapper<RcsTaskEntity>()
                .eq(RcsTaskEntity::getStatus, RcsTaskStatusEnum.EXECUTING.getValue())
                .isNotNull(RcsTaskEntity::getStartTime)
                .lt(RcsTaskEntity::getStartTime, cutoff));
        int count = 0;
        for (RcsTaskEntity task : timeoutTasks) {
            self.applyException(task.getId(),
                    String.format("执行超时自动置异常：进入执行中已超过 %d 分钟仍无完成/取消回馈（定时兜底）", timeoutMinutes));
            count++;
        }
        if (count > 0) {
            log.warn("RCS执行超时兜底：{} 个执行中任务超过 {} 分钟无终态回馈，已置异常并释放点位预占", count, timeoutMinutes);
        }
        return count;
    }

    /**
     * 解析执行超时阈值（分钟）：优先 sys_config: wms.rcs.executing.timeout-minutes，非法/缺失回退默认 120
     */
    private int resolveExecutingTimeoutMinutes() {
        String value = sysConfigService.selectConfigByKey("wms.rcs.executing.timeout-minutes");
        if (StrUtil.isNotBlank(value)) {
            try {
                int minutes = Integer.parseInt(value.trim());
                if (minutes > 0) {
                    return minutes;
                }
            } catch (NumberFormatException ignored) {
                log.warn("RCS执行超时阈值配置非法，回退默认 {} 分钟：{}", DEFAULT_EXECUTING_TIMEOUT_MINUTES, value);
            }
        }
        return DEFAULT_EXECUTING_TIMEOUT_MINUTES;
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
            Result<Object> result = agvService.commonRequest(RcsApiEnum.CANCEL_TASK,
                    buildCancelParams(task, reason));
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
        changeStatus(task, RcsTaskStatusEnum.CANCELLED.getValue(),
                RcsOperatorTypeEnum.ADMIN, null, remark);
        // 库存闭环：解除本任务起点与终点的占用锁 remark=1 并清除预定任务标记 last_task_code
        //（幂等——未锁/未标记的点 no-op；仅动 remark 与预定标记，绝不动料车绑定：任务若未出发，料车仍正确停在起点）
        publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                task.getCartCode(), task.getFromLocation());
        publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                task.getCartCode(), task.getToLocation());
        publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                task.getCartCode(), task.getFromLocation(), task.getTaskCode());
        publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                task.getCartCode(), task.getToLocation(), task.getTaskCode());
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
     * 处理 RCS 任务执行过程回馈：反查本地任务，按 {@code extra.values.method} 分发驱动状态流转。
     * <p>
     * 分发采用"枚举字典 + switch"：每个 case 自由编排状态流转与库存联动事件
     * （如"到达 = 解绑源点 + 确认目标到达"）。新增 method 只需在
     * {@code RcsCallbackMethodEnum} 加常量并在下方 switch 加对应 case；
     * 未登记的 method 走 {@link #fallbackKeyword} 关键词兜底。
     * </p>
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
        String method = report.resolveMethod();
        if (task == null) {
            log.warn("RCS任务回馈：未匹配到本地任务，taskCode={}, taskId={}, method={}, status={}",
                    report.getTaskCode(), report.getTaskId(), method, report.getStatus());
            return false;
        }

        // 【C-09 临时方案，待测试后调整】终态任务对迟到/乱序的执行回馈仅记录、不再流转。
        if (isFinalStatus(task.getStatus())) {
            log.info("RCS任务回馈：任务[{}]已处于终态status={}，仅记录回馈不流转：method={}, status={}",
                    task.getTaskCode(), task.getStatus(), method, report.getStatus());
            return true;
        }
        // 回填执行AGV编号（若回馈带上）
        if (StrUtil.isNotBlank(report.getAgvCode())) {
            task.setAgvCode(report.getAgvCode());
        }

        // 库存闭环：事件在事务提交后由 inventory 监听执行——
        //   UNBIND(fromLocation) 解绑源点位；CONFIRM_ARRIVE(toLocation) 确认目标点位到达绑定终点
        RcsCallbackMethodEnum callback = RcsCallbackMethodEnum.fromMethod(method);
        switch (callback) {
            // 货架到达目标位/任务完成：转已完成；先解绑当前源点位（幂等——监听器核对料车，未占用或非本车则跳过），再确认目标到达
            case NOTIFY_POD_ARR, ARRIVED_TARGET, FINISH_TASK -> {
                transitTo(task, report, RcsTaskStatusEnum.FINISHED, method);
                publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND,
                        task.getCartCode(), task.getFromLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE,
                        task.getCartCode(), task.getToLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getFromLocation(), task.getTaskCode());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getToLocation(), task.getTaskCode());
            }
            // 货架离开源位/机器人离开起点：转执行中 + 解绑源点位
            case NOTIFY_POD_LEAV, TAKE_SHELF_2 -> {
                transitTo(task, report, RcsTaskStatusEnum.EXECUTING, method);
                publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND,
                        task.getCartCode(), task.getFromLocation());
            }
            // 取到载具/任务开始/途经点到达离开：仅推进执行中状态，无库存联动
            case TAKE_SHELF_1, START_TASK, NOTIFY_ROBOT_ARR, NOTIFY_ROBOT_LEAV ->
                    transitTo(task, report, RcsTaskStatusEnum.EXECUTING, method);
            // 机器人离开起点（料车随行，01 系列）：执行中；起点料车解绑（随车在途），起点与终点打任务占用锁 remark=1
            case NOTIFY_ROBOT_LEAV_01 -> {
                transitTo(task, report, RcsTaskStatusEnum.EXECUTING, method);
                publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND,
                        task.getCartCode(), task.getFromLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.PRE_BIND,
                        task.getCartCode(), task.getFromLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.PRE_BIND,
                        task.getCartCode(), task.getToLocation());
            }
            // 任务完成（01 系列）：已完成；终点终绑料车到达，解除起点占用锁并清除起/终点预定任务标记
            case FINISH_TASK_01 -> {
                transitTo(task, report, RcsTaskStatusEnum.FINISHED, method);
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE,
                        task.getCartCode(), task.getToLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                        task.getCartCode(), task.getFromLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getFromLocation(), task.getTaskCode());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getToLocation(), task.getTaskCode());
            }
            // RCS 侧主动取消：转已取消；解除本任务起点与终点的占用锁（幂等，绝不动料车绑定），并清除预定任务标记
            case CANCEL_TASK -> {
                transitTo(task, report, RcsTaskStatusEnum.CANCELLED, method);
                publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                        task.getCartCode(), task.getFromLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                        task.getCartCode(), task.getToLocation());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getFromLocation(), task.getTaskCode());
                publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                        task.getCartCode(), task.getToLocation(), task.getTaskCode());
            }
            // RCS 侧主动异常：转异常（释放目标点位预占在 changeStatus 内统一处理）
            case ERROR_TASK -> transitTo(task, report, RcsTaskStatusEnum.EXCEPTION, method);
            // 未登记 method：关键词兜底映射，无法识别仅记录
            default -> fallbackKeyword(task, report, method);
        }
        return true;
    }

    /**
     * 按 RCS 外部回馈统一流转本地状态：拼接回馈备注并写状态/生命周期。
     * <p>流转合法性/幂等（同状态跳过）在 {@link #changeStatus} 内部处理，不抛异常。</p>
     */
    private void transitTo(RcsTaskEntity task, RcsTaskReportDTO report,
                           RcsTaskStatusEnum toStatus, String method) {
        String remark = buildReportRemark(report, method);
        changeStatus(task, toStatus.getValue(), RcsOperatorTypeEnum.EXTERNAL,
                report.getAgvCode(), remark);
    }

    /**
     * 未在方法表登记的 method 兜底处理（历史关键词兼容逻辑）：
     * 按 method/status 关键词映射本地状态与库存动作，仍无法识别时仅记录不流转。
     */
    private void fallbackKeyword(RcsTaskEntity task, RcsTaskReportDTO report, String method) {
        Integer targetStatus = mapReportToStatus(method, report.getStatus());
        if (targetStatus == null) {
            log.info("RCS任务回馈：method[{}] 无法映射到本地状态（仅记录），taskCode={}, status={}",
                    method, task.getTaskCode(), report.getStatus());
            return;
        }
        log.warn("RCS任务回馈：method[{}] 未在方法表登记，按关键词兜底流转为状态[{}]，taskCode={}",
                method, targetStatus, task.getTaskCode());
        RcsTaskInventoryEvent.Action inventoryAction = resolveInventoryAction(targetStatus, method);
        if (inventoryAction != null) {
            if (RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE.equals(inventoryAction)) {
                publishInventoryEvent(RcsTaskInventoryEvent.Action.UNBIND,
                        task.getCartCode(), task.getFromLocation());
            }
            publishInventoryEvent(inventoryAction, task.getCartCode(),
                    RcsTaskInventoryEvent.Action.UNBIND.equals(inventoryAction)
                            ? task.getFromLocation() : task.getToLocation());
        }
        String remark = buildReportRemark(report, method);
        changeStatus(task, targetStatus, RcsOperatorTypeEnum.EXTERNAL, report.getAgvCode(), remark);
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
            // 完成：notifyPodArr(货架到达目标位) / arrivedTarget / FINISH / END / COMPLETE / DONE
            if (m.contains("PODARR") || m.contains("ARRIVEDTARGET") || m.contains("FINISH")
                    || m.contains("END") || m.contains("COMPLETE") || m.contains("DONE")) {
                return RcsTaskStatusEnum.FINISHED.getValue();
            }
            // 取货/执行中：notifyPodLeav(货架离开源位) / notifyRobotArr/notifyRobotLeav(机器人到达/离开途经点)
            //   / START / EXECUT / PICK / PUT / RUNNING / PROGRESS / MOVING
            if (m.contains("PODLEAV") || m.contains("ROBOTARR") || m.contains("ROBOTLEAV")
                    || m.contains("START") || m.contains("EXECUT") || m.contains("APPLY")
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
     * 关键词兜底：根据目标状态和 method 推导库存联动动作。
     * <p>仅在枚举未命中时使用。UNBIND 需额外匹配 PICK/PODLEAV 关键词，
     * CONFIRM_ARRIVE 直接绑定 FINISHED 状态。</p>
     */
    private RcsTaskInventoryEvent.Action resolveInventoryAction(Integer targetStatus, String method) {
        if (targetStatus == null) {
            return null;
        }
        if (RcsTaskStatusEnum.EXECUTING.getValue().equals(targetStatus)
                && StrUtil.isNotBlank(method)
                && (method.toUpperCase().contains("PICK") || method.toUpperCase().contains("PODLEAV"))) {
            return RcsTaskInventoryEvent.Action.UNBIND;
        }
        if (RcsTaskStatusEnum.FINISHED.getValue().equals(targetStatus)) {
            return RcsTaskInventoryEvent.Action.CONFIRM_ARRIVE;
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
    private String buildReportRemark(RcsTaskReportDTO report, String resolvedMethod) {
        StringBuilder sb = new StringBuilder("RCS回馈");
        if (StrUtil.isNotBlank(resolvedMethod)) {
            sb.append("[").append(resolvedMethod).append("]");
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
        // 库存闭环：已下发/执行中的任务流转为"异常"时解除起点与终点的占用锁 remark=1 并清除预定任务标记
        //（异常任务不会送达目标，锁不释放会永久占用点位；覆盖告警异常与 errorTask 回调异常两条路径。
        //  仅动 remark 与预定标记，绝不动料车绑定）
        if (RcsTaskStatusEnum.EXCEPTION.getValue().equals(toStatus)
                && (RcsTaskStatusEnum.ASSIGNED.getValue().equals(statusFrom)
                    || RcsTaskStatusEnum.EXECUTING.getValue().equals(statusFrom))) {
            publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                    task.getCartCode(), task.getFromLocation());
            publishInventoryEvent(RcsTaskInventoryEvent.Action.RELEASE,
                    task.getCartCode(), task.getToLocation());
            publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                    task.getCartCode(), task.getFromLocation(), task.getTaskCode());
            publishInventoryEvent(RcsTaskInventoryEvent.Action.CLEAR_TASK,
                    task.getCartCode(), task.getToLocation(), task.getTaskCode());
        }
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
        publishInventoryEvent(action, cartCode, locationCode, null);
    }

    private void publishInventoryEvent(RcsTaskInventoryEvent.Action action, String cartCode, String locationCode,
                                       String taskCode) {
        if (StrUtil.isBlank(cartCode) || StrUtil.isBlank(locationCode)) {
            return;
        }
        eventPublisher.publishEvent(RcsTaskInventoryEvent.of(action, cartCode, locationCode, taskCode));
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
     * 本地任务类型(1-搬运 2-充电 3-调度 4-巡检) → RCS 协议 taskType（任务模板编码）
     * <p>模板编码与任务类型一一对应且跨环境固定，与回调 method 一致走代码枚举
     * {@link RcsTaskTypeEnum#rcsTemplate}，不再读 sys_config；未知类型统一兜底返回 {@code PF-LMR-COMMON}。</p>
     */
    private String mapTaskType(Integer taskType) {
        String rcsTemplate = RcsTaskTypeEnum.getRcsTemplateByValue(taskType);
        return StrUtil.isNotBlank(rcsTemplate) ? rcsTemplate : "PF-LMR-COMMON";
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
     * 组装取消给 RCS 的请求参数（强类型 DTO，与 RCS 任务取消接口契约对齐）。
     * <p>
     * 业务约定「统一 DROP 硬取消」：RCS 侧直接终止任务、机器人原地待命，不安排料车回库，
     * 故不携带 targetRoute/returnTaskType/extra 等回库相关字段。
     * reqCode 沿用本地任务编号（与下发一致，RCS 按请求号幂等定位）；
     * robotTaskCode 用 RCS 外部任务号（下发返回、上报回调同名，本地以 rcs_task_id 冗余存储），
     * 不能误用本地 taskCode——它是 WMS 业务单号，RCS 侧匹配不上。
     * </p>
     */
    private AgvCancelTaskDTO buildCancelParams(RcsTaskEntity task, String reason) {
        AgvCancelTaskDTO dto = new AgvCancelTaskDTO();
        // 请求编号（唯一，与下发时同一 reqCode，便于 RCS 幂等定位）
        dto.setReqCode(task.getTaskCode());
        // RCS 外部任务号（下发成功时回填；为空时本方法不应被调用——cancelRcsTask 已分流本地取消）
        dto.setRobotTaskCode(task.getRcsTaskId());
        // 取消类型：统一 DROP（硬取消，RCS 不生成回库任务）；如后续需软取消回库可传 CANCEL 并补 targetRoute/returnTaskType
        dto.setCancelType("DROP");
        dto.setReason(reason);
        return dto;
    }

    /**
     * 从 RCS 返回的 data 中提取外部任务ID（RCS 生成的 robotTaskCode）。
     * <p>回调(AGV_taskReporter)用同名 {@code robotTaskCode} 反查本地 rcs_task_id，
     * 入库值必须与回调一致才能匹配上。按常见字段名依次探测：robotTaskCode → taskId → robotTaskId → taskCode。
     * 注意：不能用 reqCode 兜底——它是 WMS 自己 taskCode 的回显，拿来做反查键永远匹配不上。</p>
     */
    @SuppressWarnings("unchecked")
    private String extractRcsTaskId(Object data) {
        if (data == null) {
            return null;
        }
        if (data instanceof Map<?, ?> map) {
            Map<String, Object> m = (Map<String, Object>) map;
            for (String key : new String[]{"robotTaskCode", "taskId", "robotTaskId", "taskCode"}) {
                Object id = m.get(key);
                if (id != null && StrUtil.isNotBlank(id.toString())) {
                    return id.toString();
                }
            }
            return null;
        }
        // 非结构化返回，直接以字符串形式记录
        return data.toString();
    }
}
