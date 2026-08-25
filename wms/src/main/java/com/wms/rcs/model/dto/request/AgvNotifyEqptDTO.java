package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 外设执行通知接口请求 DTO（返回码 0 版本）
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/spi/wcs/robot/eqpt/notify}（ApiEnum.AGV_notifyEqpt）。
 * 外设执行完成后通知 RCS，用于电梯到位、自动门开关、装卸机取放货等外设协同场景。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV外设执行通知接口请求参数")
@Getter
@Setter
public class AgvNotifyEqptDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "设备编号")
    @NotBlank(message = "设备编号不能为空")
    private String eqptCode;

    @Schema(description = "任务号(UUID)")
    @NotBlank(message = "任务号不能为空")
    private String taskCode;

    @Schema(description = "执行状态：1自动门开门到位/2关门到位/3电梯开门到位/4物料到达楼层/5取货/6放货/7到达", example = "7")
    @NotBlank(message = "执行状态不能为空")
    private String actionStatus;

    @Schema(description = "分配的站点编号")
    @NotBlank(message = "站点编号不能为空")
    private String siteCode;
}
