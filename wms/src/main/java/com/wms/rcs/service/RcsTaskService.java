package com.wms.rcs.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.dto.callback.RcsTaskReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskWarningDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.vo.RcsTaskVO;

/**
 * RCS任务业务服务接口
 * <p>
 * 提供任务的分页查询、详情（含状态变更历史时间线）、新增、修改、删除。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
public interface RcsTaskService extends IService<RcsTaskEntity> {

    /**
     * 分页查询任务列表
     */
    IPage<RcsTaskVO> getRcsTaskPage(RcsTaskQueryDTO queryParams);

    /**
     * 获取任务详情（含状态变更历史）
     */
    RcsTaskVO getRcsTaskDetail(Long id);

    /**
     * 新增任务（状态默认待执行，自动生成任务编号）
     *
     * @return 新建任务的主键ID
     */
    Long saveRcsTask(RcsTaskDTO dto);

    /**
     * 新增任务并立即下发给 RCS（下发闭环）
     * <p>
     * 先本地建单（待执行），再调用 RCS 任务下发接口；下发成功回填外部任务号并流转为"已派发"，
     * 下发失败则流转为"异常"并记录错误信息。本地建单与远程下发不在同一事务，避免远程调用长时间占用数据库连接。
     * </p>
     *
     * @return 新建任务的主键ID
     */
    Long saveAndSubmitRcsTask(RcsTaskDTO dto);

    /**
     * 将"待执行"或"异常"任务下发给 RCS
     * <p>
     * 待执行任务首次下发；异常任务（含建单后下发失败者）可重试下发，沿用原任务编号作 reqCode，
     * RCS 侧按请求编号幂等去重，不会重复作业。下发成功流转为"已派发"，失败流转为"异常"。
     * </p>
     *
     * @return 下发是否成功
     */
    boolean submitRcsTask(Long id);

    /**
     * 取消任务（联动 RCS）
     * <p>
     * 未到达 RCS 的任务（待执行、或下发失败无外部任务号的异常任务）本地直接取消；
     * 已派发/执行中、或已到达 RCS 后异常（有外部任务号）的任务先调用 RCS 任务取消接口 AGV_cancelTask，
     * 成功后再流转为"已取消"。仅不可逆终态（已完成/已取消）不可取消。
     * </p>
     *
     * @param id     任务ID
     * @param reason 取消原因（可空）
     * @return 取消是否成功
     */
    boolean cancelRcsTask(Long id, String reason);

    /**
     * 修改任务（仅"待执行"状态可修改）
     */
    boolean updateRcsTask(Long id, RcsTaskDTO dto);

    /**
     * 删除任务（支持逗号分隔的多个ID，级联删除生命周期历史由外键保证）
     */
    boolean deleteRcsTasks(String ids);

    /**
     * 处理 RCS 任务执行过程回馈（入站回调）
     * <p>
     * 优先按 taskCode 反查本地任务，取不到用 rcsTaskId 兜底；将 RCS 的执行阶段/状态映射到本地 6 态，
     * 经统一状态流转 changeStatus 驱动（operatorType=EXTERNAL）。找不到本地任务时记录日志、不抛异常，
     * 保证回调幂等友好且不影响 RCS 侧流程。
     * </p>
     *
     * @param report 任务执行回馈请求体
     * @return 是否成功匹配并处理（未匹配到本地任务返回 false）
     */
    boolean handleTaskReport(RcsTaskReportDTO report);

    /**
     * 处理 RCS 任务异常告警（入站回调）
     * <p>
     * 反查规则同 {@link #handleTaskReport}；匹配到的任务流转为"异常"并写入告警信息。
     * </p>
     *
     * @param warning 任务异常告警请求体
     * @return 是否成功匹配并处理（未匹配到本地任务返回 false）
     */
    boolean handleTaskWarning(RcsTaskWarningDTO warning);

    /**
     * 执行超时兜底（定时任务驱动）：把进入"执行中"超过阈值仍无完成/取消回馈的任务置为"异常"。
     * <p>RCS 失联/回调中断/AGV 卡死时预占（remark=1）与预定任务标记会永久占用起/终点点位；
     * 置异常复用 changeStatus 的 EXCEPTION 分支，自动 RELEASE + CLEAR 起/终点。
     * 阈值读取 sys_config: wms.rcs.executing.timeout-minutes，默认 120 分钟。</p>
     *
     * @return 本轮置异常的任务数
     */
    int timeoutExecutingRcsTasks();
}
