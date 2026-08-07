package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

import java.util.Map;

/**
 * RCS任务数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含任务的可编辑字段。
 * 任务编号（taskCode）由系统生成，状态/时间等由服务端流转，不在此接收。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Schema(description = "RCS任务数据传输对象")
@Getter
@Setter
public class RcsTaskDTO {

    @Schema(description = "任务ID", example = "1")
    private Long id;

    @Schema(description = "任务类型（1-搬运 2-充电 3-调度 4-巡检）", example = "1")
    @NotNull(message = "任务类型不能为空")
    @Range(min = 1, max = 4, message = "任务类型值不正确")
    private Integer taskType;

    @Schema(description = "任务标题", example = "A区搬运至B区")
    private String taskTitle;

    @Schema(description = "源位置编码", example = "P001")
    private String fromLocation;

    @Schema(description = "目标位置编码", example = "P002")
    private String toLocation;

    @Schema(description = "关联料车编码", example = "CART001")
    private String cartCode;

    @Schema(description = "任务扩展参数（JSON，如物料信息、路径约束等）")
    private Map<String, Object> payload;

    @Schema(description = "优先级（1-低 2-中 3-高 4-紧急）", example = "2")
    @Range(min = 1, max = 4, message = "优先级值不正确")
    private Integer priority;

    @Schema(description = "备注")
    private String remark;

}
