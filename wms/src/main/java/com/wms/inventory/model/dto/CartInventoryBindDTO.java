package com.wms.inventory.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 料车库存绑定请求对象
 * <p>
 * 绑定操作：将料车绑到目标空位点位。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "料车库存绑定请求对象")
@Data
public class CartInventoryBindDTO {

    @Schema(description = "目标点位ID")
    @NotNull(message = "点位ID不能为空")
    private Long pointId;

    @Schema(description = "料车ID")
    @NotNull(message = "料车ID不能为空")
    private Long cartId;
}
