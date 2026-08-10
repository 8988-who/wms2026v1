package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 查询任务状态接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/query}（ApiEnum.AGV_queryTask）。
 * 根据任务号查询单条任务当前执行状态。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV查询任务状态接口请求参数")
@Getter
@Setter
public class AgvQueryTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "任务号")
    @NotBlank(message = "任务号不能为空")
    private String robotTaskCode;
}
