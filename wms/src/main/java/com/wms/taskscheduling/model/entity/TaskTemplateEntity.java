package com.wms.taskscheduling.model.entity;

import com.wms.common.base.WmsBaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 任务模板实体（骨架）
 * <p>
 * 对应任务模板表（表名待确认，@TableName 暂不落，确认后补充）。
 * 模板 = 预定义动作参数，字段设计待确认：
 * <ul>
 *     <li>模板编号/名称（templateCode/templateName）</li>
 *     <li>任务类型（taskType，对应 RCS 1-搬运 2-充电 3-调度 4-巡检）</li>
 *     <li>from/to 规则（固定点位 / 取筛选结果 / 取上一步回调结果）</li>
 *     <li>载荷（是否携带料车 cartCode）</li>
 *     <li>优先级、下一步模板编号（步骤链衔接）</li>
 * </ul>
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class TaskTemplateEntity extends WmsBaseEntity {
}
