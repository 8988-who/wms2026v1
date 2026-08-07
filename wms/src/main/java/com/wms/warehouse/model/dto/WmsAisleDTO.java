package com.wms.warehouse.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

/**
 * 巷道数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含巷道的完整字段信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
@Schema(description = "巷道数据传输对象")
@Getter
@Setter
public class WmsAisleDTO {

    @Schema(description = "巷道ID", example = "1")
    private Long id;

    @Schema(description = "所属区域ID", example = "1")
    @NotNull(message = "区域ID不能为空")
    private Long locationId;

    @Schema(description = "巷道编码（系统自动生成）", example = "PLANT001-A001")
    private String aisleCode;

    @Schema(description = "巷道名称", example = "A001")
    @NotBlank(message = "巷道名称不能为空")
    private String aisleName;

    @Schema(description = "厂区编码", example = "PLANT001")
    private String plantCode;

    @Schema(description = "物理楼层", example = "1F")
    private String floor;

    @Schema(description = "排序号", example = "1")
    private Integer sortOrder;

    @Schema(description = "状态(1:启用;0:禁用)", example = "1")
    @Range(min = 0, max = 1, message = "状态值不正确")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "巷道用途(FULL/EMPTY/MIXED)")
    private String aislePurpose;

    @Schema(description = "是否交接点巷道(0:否;1:是)")
    private Integer isHandoverPoint;

}