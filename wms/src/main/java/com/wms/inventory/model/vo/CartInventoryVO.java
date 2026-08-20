package com.wms.inventory.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 料车库存视图对象
 * <p>
 * 返回库存列表展示字段：区域/巷道/点位/料车名称类字段 JOIN 主数据表实时取，装载量实时 COUNT。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Schema(description = "料车库存视图对象")
@Data
public class CartInventoryVO {

    @Schema(description = "点位ID")
    private Long pointId;

    @Schema(description = "料车ID（空位时为 null）")
    private Long cartId;

    @Schema(description = "点位编码")
    private String pointCode;

    @Schema(description = "点位名称")
    private String pointName;

    @Schema(description = "区域名称")
    private String locationName;

    @Schema(description = "巷道名称")
    private String aisleName;

    @Schema(description = "料车编号")
    private String cartCode;

    @Schema(description = "料车进入当前点位时刻")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime arriveTime;

    @Schema(description = "落位时装载量快照")
    private Integer arriveQuantity;

    @Schema(description = "实时装载量")
    private Integer currentQuantity;

    @Schema(description = "库存锁定：0-正常 1-锁定")
    private Integer lockStatus;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "最后更新者")
    private String updatedByName;

    @Schema(description = "最后更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime updatedTime;
}
