package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 外设执行通知接口请求 DTO（V4.2.8 返回 SUCCESS 版本）
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/spi/wcs/robot/eqpt/notifyGbt}（ApiEnum.AGV_notifyGbtEqpt）。
 * 功能与 {@link AgvNotifyEqptDTO} 相同，字段一致，仅返回码由 "0" 改为 "SUCCESS"。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV外设执行通知接口请求参数（notifyGbt 版本）")
@Getter
@Setter
public class AgvNotifyGbtEqptDTO extends AgvRequestDTO {

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
