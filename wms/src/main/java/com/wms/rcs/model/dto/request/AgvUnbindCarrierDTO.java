package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 载具与站点解绑接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/carrier/unbind}（ApiEnum.AGV_unbindCarrier）。
 * 将载具从站点解绑，代表载具离开该站点。与 {@link AgvBindCarrierDTO} 配对使用。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-26
 */
@Schema(description = "AGV载具与站点解绑接口请求参数")
@Getter
@Setter
public class AgvUnbindCarrierDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "载具编号/别名")
    @NotBlank(message = "载具编号不能为空")
    private String carrierCode;

    @Schema(description = "站点编号/别名")
    @NotBlank(message = "站点编号不能为空")
    private String siteCode;
}
