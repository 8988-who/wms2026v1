package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.Map;

/**
 * AGV 任务继续执行接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/extend/continue}（ApiEnum.AGV_continueTask）。
 * 多步骤任务中，每个步骤完成后由 WMS 通过此接口驱动下一阶段执行（第一个步骤也需由此启动，除非设置为自动开始）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV任务继续执行接口请求参数")
@Getter
@Setter
public class AgvContinueTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "触发类型：SITE(站点)/CARRIER(载具)/ROBOT(车号)/TASK(任务链编号)", example = "TASK")
    @NotBlank(message = "触发类型不能为空")
    private String triggerType;

    @Schema(description = "与 triggerType 对应的触发编号")
    @NotBlank(message = "触发编号不能为空")
    private String triggerCode;

    @Schema(description = "下一个目标位置（含 type、code、operation）")
    private Map<String, Object> targetRoute;

    @Schema(description = "扩展参数")
    private Map<String, Object> extra;
}
