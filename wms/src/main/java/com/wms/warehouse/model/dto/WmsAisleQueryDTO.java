package com.wms.warehouse.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 巷道分页查询对象
 * <p>
 * 继承 BaseQuery，支持按关键字、区域、厂区、巷道编码/名称、楼层、状态等条件分页查询。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Schema(description = "巷道分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class WmsAisleQueryDTO extends BaseQuery {

    @Schema(description = "关键字(巷道编码/名称)")
    private String keywords;

    @Schema(description = "区域ID")
    private Long locationId;

    @Schema(description = "厂区编码")
    private String plantCode;

    @Schema(description = "巷道编码")
    private String aisleCode;

    @Schema(description = "巷道名称")
    private String aisleName;

    @Schema(description = "楼层")
    private String floor;

    @Schema(description = "状态(1->正常；0->禁用)")
    private Integer status;

}