package com.wms.warehouse.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

/**
 * 点位数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含点位的完整字段信息。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Schema(description = "点位数据传输对象")
@Getter
@Setter
public class WmsPointDTO {

    @Schema(description = "点位ID", example = "1")
    private Long id;

    @Schema(description = "厂区编码", example = "PLANT001")
    @NotBlank(message = "厂区编码不能为空")
    private String plantCode;

    @Schema(description = "所属区域ID", example = "1")
    @NotNull(message = "区域ID不能为空")
    private Long locationId;

    @Schema(description = "所属巷道ID", example = "1")
    @NotNull(message = "巷道ID不能为空")
    private Long aisleId;

    @Schema(description = "点位编码（系统自动生成）", example = "PLANT001-P001")
    private String pointCode;

    @Schema(description = "点位名称", example = "P001")
    @NotBlank(message = "点位名称不能为空")
    private String pointName;

    @Schema(description = "点位条码")
    private String barcode;

    @Schema(description = "坐标（AGV引擎定义格式）", example = "100,200,0")
    private String coordinate;

    @Schema(description = "物理楼层", example = "1F")
    private String floor;

    @Schema(description = "排序号", example = "1")
    private Integer sortOrder;

    @Schema(description = "状态(1:启用;0:禁用)", example = "1")
    @Range(min = 0, max = 1, message = "状态值不正确")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

}