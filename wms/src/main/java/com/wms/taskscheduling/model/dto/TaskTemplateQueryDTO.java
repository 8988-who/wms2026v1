package com.wms.taskscheduling.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 任务模板分页查询对象（骨架）
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Schema(description = "任务模板分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TaskTemplateQueryDTO extends BaseQuery {
}
