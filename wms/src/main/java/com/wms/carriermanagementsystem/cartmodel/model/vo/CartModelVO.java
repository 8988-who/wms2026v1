package com.wms.carriermanagementsystem.cartmodel.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 料车型号视图对象
 * <p>
 * 返回前端的展示字段，包含型号基本信息、关联料车数和创建/更新人信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车型号视图对象")
@Data
public class CartModelVO {

    @Schema(description = "型号ID")
    private Long id;

    @Schema(description = "型号代码")
    private String modelCode;

    @Schema(description = "型号名称")
    private String modelName;

    @Schema(description = "最大装载数量")
    private Integer maxCapacity;

    @Schema(description = "层数")
    private Integer layerCount;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "关联料车数量")
    private Integer cartCount;

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
