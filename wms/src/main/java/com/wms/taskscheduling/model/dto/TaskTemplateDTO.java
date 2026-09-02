package com.wms.taskscheduling.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 任务模板数据传输对象（骨架）
 * <p>字段设计待确认：模板编号/名称、任务类型、from/to 规则、载荷、优先级、下一步模板编号。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Schema(description = "任务模板数据传输对象")
@Data
public class TaskTemplateDTO {
}
