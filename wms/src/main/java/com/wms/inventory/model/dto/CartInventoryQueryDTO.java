package com.wms.inventory.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 料车库存分页查询对象
 * <p>
 * 继承 BaseQuery，支持按区域、巷道、点位编码、料车编号、锁定状态分页筛选（库存显示/库存管理共用）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "料车库存分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class CartInventoryQueryDTO extends BaseQuery {

    @Schema(description = "区域ID")
    private Long locationId;

    @Schema(description = "巷道ID")
    private Long aisleId;

    @Schema(description = "点位编码（模糊匹配）")
    private String pointCode;

    @Schema(description = "料车编号（模糊匹配）")
    private String cartCode;

    @Schema(description = "库存锁定：0-正常 1-锁定")
    private Integer lockStatus;
}
