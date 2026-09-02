package com.wms.taskscheduling.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 编排流程数据传输对象（骨架）
 * <p>字段设计待确认：流程编号/名称、步骤序号/总数、本步筛选条件 JSON、任务模板编号、下一步流程编号。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Schema(description = "编排流程数据传输对象")
@Data
public class DispatchProcessDTO {
}
