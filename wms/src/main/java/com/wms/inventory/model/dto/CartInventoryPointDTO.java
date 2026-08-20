package com.wms.inventory.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * 料车库存操作请求对象（解绑/锁定/解锁）
 * <p>
 * 仅需点位ID即可定位占用表记录。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "料车库存操作请求对象")
@Data
public class CartInventoryPointDTO {

    @Schema(description = "点位ID")
    @NotNull(message = "点位ID不能为空")
    private Long pointId;
}
