package com.wms.warehouse.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 库位/区域分页查询对象
 * <p>
 * 继承 BaseQuery，支持按关键字、厂区、区域编码、类型、楼层、更新人、状态等条件分页查询。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Schema(description = "库位/区域分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class WmsLocationQueryDTO extends BaseQuery {

    @Schema(description = "厂区编码")
    private String plantCode;

    @Schema(description = "区域编码")
    private String locationCode;

    @Schema(description = "区域名称")
    private String locationName;

    @Schema(description = "库位/区域类型")
    private String locationType;

    @Schema(description = "楼层（如：1F, B1）")
    private String floor;

    @Schema(description = "更新人（用户名模糊搜索）")
    private String updatedBy;

    @Schema(description = "状态(1->正常；0->禁用)")
    private Integer status;

}