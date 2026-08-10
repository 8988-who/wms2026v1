package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

/**
 * AGV 预调度任务下发接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/pretask}（ApiEnum.AGV_preTask）。
 * 提前调度机器人到达指定位置待命，减少任务等待时间。nextTaskTime=0 时清空该点位所有预调度任务。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV预调度任务下发接口请求参数")
@Getter
@Setter
public class AgvPreTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "站点编号")
    @NotBlank(message = "站点编号不能为空")
    private String siteCode;

    @Schema(description = "预调度时间(0~3600秒)，0=清空预调度", example = "60")
    @NotBlank(message = "预调度时间不能为空")
    private String nextTaskTime;

    @Schema(description = "机器人类型")
    private String robotType;

    @Schema(description = "优先级(1~120)", example = "50")
    @Range(min = 1, max = 120, message = "优先级取值范围为1~120")
    private Integer priority;

    @Schema(description = "预调度任务数，默认1", example = "1")
    private Integer taskCount;
}
