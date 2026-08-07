package com.wms.carriermanagementsystem.cartitem.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 料车物品分页查询对象
 * <p>
 * 继承 BaseQuery，支持按料车、货品、批次、状态、时间范围等多维度筛选。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车物品分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class CartItemQueryDTO extends BaseQuery {

    @Schema(description = "料车ID（精确匹配）")
    private Long cartId;

    @Schema(description = "料车编号（跨表模糊匹配）")
    private String cartCode;

    @Schema(description = "货品条码（模糊匹配）")
    private String productCode;

    @Schema(description = "货品型号（模糊匹配）")
    private String productModel;

    @Schema(description = "批次号（模糊匹配）")
    private String batchNo;

    @Schema(description = "状态：1-在车 2-已取走（精确匹配）")
    private Integer status;

    @Schema(description = "层号（精确匹配）")
    private Integer layerNo;

    @Schema(description = "操作人（模糊匹配）")
    private String operator;

    @Schema(description = "装车开始时间")
    private String loadedAtStart;

    @Schema(description = "装车结束时间")
    private String loadedAtEnd;

    @Schema(description = "通用关键词（匹配 productCode/productModel/batchNo）")
    private String keyword;
}
