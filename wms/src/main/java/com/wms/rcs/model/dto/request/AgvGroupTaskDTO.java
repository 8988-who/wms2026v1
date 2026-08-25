package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

import java.util.List;
import java.util.Map;

/**
 * AGV 任务组接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/group}（ApiEnum.AGV_groupTask）。
 * 用于将多个机器人任务编组，按指定策略（顺序出库/按组分配/载具整理）统一调度。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键，重复提交沿用同一编号）。
 * </p>
 * <p>
 * 说明：{@code targetRoute}（JSON对象）与 {@code data}（JSON数组）结构随调度策略变化，
 * 采用 {@code Map}/{@code List<Map>} 承接，仅对数组整体做非空校验，元素内部字段由调用方保证。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV任务组接口请求参数")
@Getter
@Setter
public class AgvGroupTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "任务组编号，全局唯一", example = "GROUP20260810001")
    @NotBlank(message = "任务组编号不能为空")
    private String groupCode;

    @Schema(description = "执行策略：GROUP_SEQ(顺序出库)/GROUP_ASSIGN(按组分配)/GROUP_CARRIER_ADJUST(载具整理)",
            example = "GROUP_SEQ")
    @NotBlank(message = "执行策略不能为空")
    private String strategy;

    @Schema(description = "策略值。GROUP_SEQ 时：0=组间组内无序 1=组间组内有序 2=组间有序组内无序 3=组间无序组内有序",
            example = "1")
    private String strategyValue;

    @Schema(description = "组顺序号(1~9999999999)", example = "1")
    @Range(min = 1L, max = 9999999999L, message = "组顺序号取值范围为1~9999999999")
    private Long groupSeq;

    @Schema(description = "执行任务的下一个目标位置，控制同一工作台的顺序")
    private Map<String, Object> targetRoute;

    @Schema(description = "任务数据数组，元素包含 robotTaskCode(机器人任务编号) 和 sequence(组内顺序)")
    @NotEmpty(message = "任务数据数组不能为空")
    private List<Map<String, Object>> data;
}
