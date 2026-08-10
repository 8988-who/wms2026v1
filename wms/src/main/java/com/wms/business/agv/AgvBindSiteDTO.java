package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 存储对象与搬运对象绑定解绑接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/site/bind}（ApiEnum.AGV_bindSite）。
 * 存储对象（站点/仓位）与搬运对象（货架/托盘/料箱）的绑定与解绑，支持仓位绑定与堆叠场景。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV存储对象与搬运对象绑定解绑接口请求参数")
@Getter
@Setter
public class AgvBindSiteDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "存储对象种类：SITE(站点)/BIN(仓位)")
    private String slotCategory;

    @Schema(description = "存储对象编号")
    private String slotCode;

    @Schema(description = "搬运对象种类：POD(货架)/PALLET(托盘)/BOX(料箱)")
    private String carrierCategory;

    @Schema(description = "载具编号")
    private String carrierCode;

    @Schema(description = "货架方向：[0, 90, -90, 180, 360]")
    private Integer carrierDir;

    @Schema(description = "调用类型：BIND(绑定)/UNBIND(解绑)", example = "BIND")
    @NotBlank(message = "调用类型不能为空")
    private String invoke;

    @Schema(description = "堆叠层号")
    private Integer colCount;
}
