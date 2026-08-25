package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

/**
 * AGV 任务优先级设置接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/priority}（ApiEnum.AGV_priorityTask）。
 * 任务创建后、结束前随时调整任务优先级（初始优先级与截止时间）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV任务优先级设置接口请求参数")
@Getter
@Setter
public class AgvPriorityTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "任务号")
    @NotBlank(message = "任务号不能为空")
    private String robotTaskCode;

    @Schema(description = "优先级(1~120)", example = "60")
    @NotNull(message = "优先级不能为空")
    @Range(min = 1, max = 120, message = "优先级取值范围为1~120")
    private Integer initPriority;

    @Schema(description = "截止时间", example = "2026-08-10T12:00:00Z")
    private String deadline;
}
