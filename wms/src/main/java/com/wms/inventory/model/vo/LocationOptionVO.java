package com.wms.inventory.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 区域筛选下拉项视图对象
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "区域筛选下拉项")
@Data
public class LocationOptionVO {

    @Schema(description = "区域ID")
    private Long id;

    @Schema(description = "区域名称")
    private String locationName;
}
