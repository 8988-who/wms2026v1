package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 物料解绑接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/matlabel/unbind}（ApiEnum.AGV_unbindMatlabel）。
 * 将载具上的物料解绑。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV物料解绑接口请求参数")
@Getter
@Setter
public class AgvUnbindMatlabelDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "载具编号")
    @NotBlank(message = "载具编号不能为空")
    private String carrierCode;

    @Schema(description = "物料标签")
    @NotBlank(message = "物料标签不能为空")
    private String matLabel;
}
