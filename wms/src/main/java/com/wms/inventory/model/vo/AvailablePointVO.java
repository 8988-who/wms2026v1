package com.wms.inventory.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 可用点位下拉项视图对象
 * <p>
 * 绑定弹窗-可用点位下拉：仅返回空位（cart_id IS NULL）且未锁定（lock_status=0）的点位。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "可用点位下拉项")
@Data
public class AvailablePointVO {

    @Schema(description = "点位ID")
    private Long pointId;

    @Schema(description = "点位编码")
    private String pointCode;

    @Schema(description = "点位名称")
    private String pointName;

    @Schema(description = "区域名称")
    private String locationName;

    @Schema(description = "巷道名称")
    private String aisleName;
}
