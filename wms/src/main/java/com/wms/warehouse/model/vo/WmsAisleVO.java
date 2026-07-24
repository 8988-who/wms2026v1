package com.wms.warehouse.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 巷道视图对象
 *
 * @author Yadmin
 * @since 2026-07-20 21:07
 */
@Schema(description = "巷道视图对象")
@Data
public class WmsAisleVO {

    @Schema(description = "巷道ID")
    private Long id;

    @Schema(description = "厂区编码")
    private String plantCode;

    @Schema(description = "所属区域ID")
    private Long locationId;

    @Schema(description = "所属区域编码")
    private String locationCode;

    @Schema(description = "巷道编码")
    private String aisleCode;

    @Schema(description = "巷道名称")
    private String aisleName;

    @Schema(description = "物理楼层")
    private String floor;

    @Schema(description = "排序号")
    private Integer sortOrder;

    @Schema(description = "状态")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "巷道用途(FULL/EMPTY/MIXED)")
    private String aislePurpose;

    @Schema(description = "是否交接点巷道(0:否;1:是)")
    private Integer isHandoverPoint;

    @Schema(description = "绑定的点位数量")
    private Integer pointCount;

    @Schema(description = "创建人")
    private String createdByName;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime createdTime;

    @Schema(description = "更新人")
    private String updatedByName;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm")
    private LocalDateTime updatedTime;
}
