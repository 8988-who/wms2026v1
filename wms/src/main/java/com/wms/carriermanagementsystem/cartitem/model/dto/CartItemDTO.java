package com.wms.carriermanagementsystem.cartitem.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * 料车物品传输对象
 * <p>
 * 用于前端装车表单提交和后端内部传递，status/loadedAt/takenAt 由业务逻辑自动维护。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车物品传输对象")
@Getter
@Setter
public class CartItemDTO {

    @Schema(description = "主键ID", example = "1")
    private Long id;

    @Schema(description = "料车ID", example = "1")
    @NotNull(message = "料车不能为空")
    private Long cartId;

    @Schema(description = "货品条码", example = "BAR-001")
    @NotBlank(message = "货品条码不能为空")
    private String productCode;

    @Schema(description = "货品型号", example = "M-100")
    @NotBlank(message = "货品型号不能为空")
    private String productModel;

    @Schema(description = "装货顺序号（留空则自动递增）", example = "1")
    private Integer sortOrder;

    @Schema(description = "批次号/工单号", example = "BATCH-01")
    private String batchNo;

    @Schema(description = "层号", example = "1")
    private Integer layerNo;

    @Schema(description = "装车操作人", example = "张三")
    private String operator;

    @Schema(description = "备注")
    private String remark;
}
