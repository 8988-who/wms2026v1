package com.wms.taskscheduling.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 调度会话数据传输对象（骨架）
 * <p>字段设计待确认：筛选条件（locationId/loadType/aislePurpose/modelCode/pointType）、目标点、当前步骤、运行状态。</p>
 *
 * @author SenyangHe
 * @since 2026-09-02
 */
@Schema(description = "调度会话数据传输对象")
@Data
public class DispatchSessionDTO {
}
