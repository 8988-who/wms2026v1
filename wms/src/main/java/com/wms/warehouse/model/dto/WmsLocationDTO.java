package com.wms.warehouse.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.validator.constraints.Range;

/**
 * 库位/区域数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含库位/区域的完整字段信息。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Schema(description = "库位/区域数据传输对象")
@Getter
@Setter
public class WmsLocationDTO {

    @Schema(description = "库位/区域ID", example = "1")
    private Long id;

    @Schema(description = "厂区编码", example = "PLANT001")
    @NotBlank(message = "厂区编码不能为空")
    private String plantCode;

    @Schema(description = "库位/区域编码（系统自动生成）", example = "PLANT001-001")
    private String locationCode;

    @Schema(description = "库位/区域名称", example = "A区")
    @NotBlank(message = "库位/区域名称不能为空")
    private String locationName;

    @Schema(description = "库位/区域类型", example = "AREA")
    private String locationType;

    @Schema(description = "父节点ID", example = "0")
    private Long parentId;

    @Schema(description = "物理楼层标识（如：1F, 2F, B1）", example = "1F")
    private String floor;

    @Schema(description = "排序号", example = "1")
    private Integer sortOrder;

    @Schema(description = "状态(1:启用;0:禁用)", example = "1")
    @Range(min = 0, max = 1, message = "状态值不正确")
    private Integer status;

    @Schema(description = "备注", example = "A区存放原材料")
    private String remark;

}