package com.wms.carriermanagementsystem.cart.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

/**
 * 料车数据传输对象
 * <p>
 * 用于前端表单提交和后端内部数据传递，包含料车完整字段信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Schema(description = "料车数据传输对象")
@Getter
@Setter
public class CartDTO {

    @Schema(description = "料车ID", example = "1")
    private Long id;

    @Schema(description = "料车编号", example = "CART-001")
    @NotBlank(message = "料车编号不能为空")
    private String cartCode;

    @Schema(description = "型号ID", example = "1")
    @NotNull(message = "型号不能为空")
    private Long modelId;

    @Schema(description = "所在区域", example = "A区")
    private String area;

    @Schema(description = "绑定操作工", example = "张三")
    private String bindWorker;

    @Schema(description = "实际容量（覆盖型号配置）", example = "100")
    private Integer actualCapacity;
}
