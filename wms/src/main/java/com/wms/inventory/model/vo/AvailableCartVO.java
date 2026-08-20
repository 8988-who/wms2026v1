package com.wms.inventory.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 可用料车下拉项视图对象
 * <p>
 * 绑定弹窗-可用料车下拉：仅返回当前不在任何点位且非维修状态的料车。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "可用料车下拉项")
@Data
public class AvailableCartVO {

    @Schema(description = "料车ID")
    private Long id;

    @Schema(description = "料车编号")
    private String cartCode;

    @Schema(description = "状态：1-空闲 2-使用中 3-已满载 4-维修")
    private Integer status;
}
