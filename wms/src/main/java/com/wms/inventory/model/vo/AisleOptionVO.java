package com.wms.inventory.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 巷道筛选下拉项视图对象
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "巷道筛选下拉项")
@Data
public class AisleOptionVO {

    @Schema(description = "巷道ID")
    private Long id;

    @Schema(description = "巷道名称")
    private String aisleName;

    @Schema(description = "所属区域ID（级联过滤用）")
    private Long locationId;
}
