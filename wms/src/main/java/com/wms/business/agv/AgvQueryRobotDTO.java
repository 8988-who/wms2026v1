package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 查询机器人状态接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/robot/query}（ApiEnum.AGV_queryRobot）。
 * 根据机器人编号查询单台机器人当前状态（位置、电量、速度、状态等）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV查询机器人状态接口请求参数")
@Getter
@Setter
public class AgvQueryRobotDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "机器人编号")
    @NotBlank(message = "机器人编号不能为空")
    private String singleRobotCode;
}
