package com.wms.carriermanagementsystem.cartmodel.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * 料车型号数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含型号的完整字段信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车型号数据传输对象")
@Getter
@Setter
public class CartModelDTO {

    @Schema(description = "型号ID", example = "1")
    private Long id;

    @Schema(description = "型号代码", example = "TC-100")
    @NotBlank(message = "型号代码不能为空")
    private String modelCode;

    @Schema(description = "型号名称", example = "标准料车")
    private String modelName;

    @Schema(description = "最大装载数量", example = "50")
    @NotNull(message = "最大装载数量不能为空")
    private Integer maxCapacity;

    @Schema(description = "层数", example = "1")
    private Integer layerCount;

    @Schema(description = "备注")
    private String remark;
}
