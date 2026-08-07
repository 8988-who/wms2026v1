package com.wms.rcs.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * RCS任务分页查询对象
 * <p>
 * 继承 BaseQuery，支持按任务编号、类型、状态、AGV、料车、提交时间区间等条件分页查询。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Schema(description = "RCS任务分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class RcsTaskQueryDTO extends BaseQuery {

    @Schema(description = "任务编号")
    private String taskCode;

    @Schema(description = "任务类型（1-搬运 2-充电 3-调度 4-巡检）")
    private Integer taskType;

    @Schema(description = "任务状态（0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常）")
    private Integer status;

    @Schema(description = "优先级（1-低 2-中 3-高 4-紧急）")
    private Integer priority;

    @Schema(description = "执行AGV编号")
    private String agvCode;

    @Schema(description = "关联料车编码")
    private String cartCode;

    @Schema(description = "提交时间-起（yyyy-MM-dd HH:mm:ss）")
    private LocalDateTime submitTimeStart;

    @Schema(description = "提交时间-止（yyyy-MM-dd HH:mm:ss）")
    private LocalDateTime submitTimeEnd;

}
