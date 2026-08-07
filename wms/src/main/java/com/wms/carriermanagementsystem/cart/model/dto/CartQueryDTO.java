package com.wms.carriermanagementsystem.cart.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 料车分页查询对象
 * <p>
 * 继承 BaseQuery，支持按料车编号/操作工关键词、状态、型号、区域分页筛选。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class CartQueryDTO extends BaseQuery {

    @Schema(description = "通用关键词（同时匹配料车编号/操作工）")
    private String keyword;

    @Schema(description = "状态：1-空闲 2-使用中 3-已满载 4-维修")
    private Integer status;

    @Schema(description = "型号ID")
    private Long modelId;

    @Schema(description = "所在区域")
    private String area;
}
