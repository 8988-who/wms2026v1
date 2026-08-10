package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.Map;

/**
 * AGV 任务取消接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/cancel}（ApiEnum.AGV_cancelTask）。
 * 取消当前任务并返回结果，支持取消时同时下发新任务；支持按车号/载具号批量取消。
 * 取消类型：CANCEL(软取消，生成回库任务)/DROP(人工介入，硬取消)。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV任务取消接口请求参数")
@Getter
@Setter
public class AgvCancelTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "任务号（批量取消时可不传）")
    private String robotTaskCode;

    @Schema(description = "取消类型：CANCEL(软取消)/DROP(人工介入硬取消)", example = "CANCEL")
    @NotBlank(message = "取消类型不能为空")
    private String cancelType;

    @Schema(description = "回库载具编号")
    private String carrierCode;

    @Schema(description = "机器人编号（批量取消用）")
    private String robotCode;

    @Schema(description = "取消原因")
    private String reason;

    @Schema(description = "软取消回库任务类型，默认 PF-TASK-CANCEL-RETURN")
    private String returnTaskType;

    @Schema(description = "新任务目标位置")
    private Map<String, Object> targetRoute;
}
