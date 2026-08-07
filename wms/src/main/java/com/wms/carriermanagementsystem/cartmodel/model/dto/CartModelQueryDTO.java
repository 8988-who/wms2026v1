package com.wms.carriermanagementsystem.cartmodel.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 料车型号分页查询对象
 * <p>
 * 继承 BaseQuery，支持按型号代码、型号名称、通用关键词分页查询。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车型号分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class CartModelQueryDTO extends BaseQuery {

    @Schema(description = "型号代码")
    private String modelCode;

    @Schema(description = "型号名称")
    private String modelName;

    @Schema(description = "通用关键词（同时匹配型号代码/名称）")
    private String keyword;
}
