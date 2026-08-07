package com.wms.carriermanagementsystem.cartitem.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 料车物品视图对象
 * <p>
 * 返回前端的展示字段，包含装载明细信息、料车冗余信息（联表）、创建/更新人信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车物品视图对象")
@Data
public class CartItemVO {

    @Schema(description = "主键ID")
    private Long id;

    @Schema(description = "料车ID")
    private Long cartId;

    @Schema(description = "料车编号（联表冗余）")
    private String cartCode;

    @Schema(description = "料车状态（联表冗余）")
    private Integer cartStatus;

    @Schema(description = "货品条码")
    private String productCode;

    @Schema(description = "货品型号")
    private String productModel;

    @Schema(description = "装货顺序号")
    private Integer sortOrder;

    @Schema(description = "批次号/工单号")
    private String batchNo;

    @Schema(description = "层号")
    private Integer layerNo;

    @Schema(description = "装车操作人")
    private String operator;

    @Schema(description = "状态：1-在车 2-已取走")
    private Integer status;

    @Schema(description = "装车时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime loadedAt;

    @Schema(description = "取走时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime takenAt;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String createdByName;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime createdTime;

    @Schema(description = "更新人")
    private String updatedByName;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime updatedTime;
}
