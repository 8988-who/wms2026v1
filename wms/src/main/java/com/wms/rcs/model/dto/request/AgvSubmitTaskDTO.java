package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

import java.util.List;
import java.util.Map;

/**
 * AGV 任务下发接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/task/submit}（ApiEnum.AGV_submitTask）。
 * 最核心的搬运任务下发接口，{@code taskType} 决定任务流程类型（潜伏车/叉车/CTU/滚筒车等）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 * <p>
 * 说明：{@code targetRoute}（对象数组）与 {@code extra}（JSON对象）结构随车型/场景变化，
 * 采用 {@code List<Map>}/{@code Map} 承接，仅对必填数组做非空校验。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV任务下发接口请求参数")
@Getter
@Setter
public class AgvSubmitTaskDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "任务类型。如 PF-LMR-COMMON(潜伏车)/PF-FMR-COMMON(叉车)/PF-CTU-COMMON(CTU)/PF-CMR-COMMON(滚筒车) 等",
            example = "PF-LMR-COMMON")
    @NotBlank(message = "任务类型不能为空")
    private String taskType;

    @Schema(description = "执行步骤集合。每个步骤含 type(目标类型)、code(目标编号)、operation(COLLECT取货/DELIVERY送货/ROTATE旋转)")
    @NotEmpty(message = "执行步骤集合不能为空")
    private List<Map<String, Object>> targetRoute;

    @Schema(description = "初始优先级(1~120)，数值越大优先级越高", example = "50")
    private Integer initPriority;

    @Schema(description = "任务截止时间，如 2021-04-04T12:23:55Z", example = "2026-08-10T12:00:00Z")
    private String deadline;

    @Schema(description = "机器人选择范围：GROUPS(资源组)/ROBOTS(指定车号)", example = "GROUPS")
    private String robotType;

    @Schema(description = "与 robotType 匹配的资源标识")
    private List<String> robotCode;

    @Schema(description = "能否打断：1=可打断，0=不可打断(默认)", example = "0")
    private Integer interrupt;

    @Schema(description = "外部任务唯一编号，为空则系统生成")
    private String robotTaskCode;

    @Schema(description = "任务组编号")
    private String groupCode;

    @Schema(description = "扩展字段，可含 angleInfo(角度)/carrierInfo(载具信息)/crossVisionDoor(视觉门)/pickStationCode(拣选站)")
    private Map<String, Object> extra;
}
