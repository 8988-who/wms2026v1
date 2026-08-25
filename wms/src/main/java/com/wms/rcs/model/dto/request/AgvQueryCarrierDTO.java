package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 查询载具状态接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/carrier/query}（ApiEnum.AGV_queryCarrier）。
 * 查询载具当前状态（绑定站点、任务编号、坐标、载具状态等）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV查询载具状态接口请求参数")
@Getter
@Setter
public class AgvQueryCarrierDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "载具编号")
    @NotBlank(message = "载具编号不能为空")
    private String carrierCode;
}
