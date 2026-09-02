package com.wms.taskscheduling.model.entity;

import com.wms.common.base.WmsBaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 编排流程实体（骨架）
 * <p>
 * 对应编排流程定义表（表名待确认，@TableName 暂不落）。
 * 流程 = 步骤链，每条记录一个流程节点：
 * <ul>
 *     <li>流程编号/名称（processCode/processName）</li>
 *     <li>步骤序号（stepNo）与步骤总数（stepTotal）</li>
 *     <li>本步筛选条件（filterJson，区域/满空/巷道/型号等维度）</li>
 *     <li>本步任务模板编号（templateId）</li>
 *     <li>下一步模板编号/下一节点（nextProcessId，信号驱动衔接）</li>
 * </ul>
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Data
@EqualsAndHashCode(callSuper = true)
public class DispatchProcessEntity extends WmsBaseEntity {
}
