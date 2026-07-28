package com.wms.carriermanagementsystem.cart.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 料车视图对象
 * <p>
 * 返回前端的展示字段，包含料车基本信息、型号信息（联表冗余）、有效容量、创建/更新人信息。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@Schema(description = "料车视图对象")
@Data
public class CartVO {

    @Schema(description = "料车ID")
    private Long id;

    @Schema(description = "料车编号")
    private String cartCode;

    @Schema(description = "型号ID")
    private Long modelId;

    @Schema(description = "型号代码")
    private String modelCode;

    @Schema(description = "型号名称")
    private String modelName;

    @Schema(description = "有效容量（实际容量或型号默认容量）")
    private Integer maxCapacity;

    @Schema(description = "当前装载数量")
    private Integer currentQuantity;

    @Schema(description = "状态：1-空闲 2-使用中 3-已满载 4-维修")
    private Integer status;

    @Schema(description = "所在区域")
    private String area;

    @Schema(description = "绑定操作工")
    private String bindWorker;

    @Schema(description = "实际容量（覆盖型号配置）")
    private Integer actualCapacity;

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
