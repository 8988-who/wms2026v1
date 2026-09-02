package com.wms.taskscheduling.model.entity;

import com.wms.common.base.WmsBaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 调度会话实体（骨架）
 * <p>
 * 对应调度会话表（表名待确认，@TableName 暂不落；方案 5.1 预留 wms_dispatch_session）。
 * 记录一次调度任务的运行态：
 * <ul>
 *     <li>筛选条件（locationId/loadType/aislePurpose/modelCode/pointType）</li>
 *     <li>最后目标点（targetPointCode，计划开始时确定，实际搬运才下发）</li>
 *     <li>当前编排进度（当前步骤 currentStepNo / 上一步回调结果）</li>
 *     <li>运行状态（running：0停止 1运行）</li>
 * </ul>
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class DispatchSessionEntity extends WmsBaseEntity {
}
