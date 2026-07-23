package com.wms.warehouse.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 点位视图对象
 * <p>
 * 用于向前端返回点位展示数据，包含关联的区域/巷道信息及创建/更新人名称。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@Schema(description = "点位视图对象")
@Data
public class WmsPointVO {

    @Schema(description = "点位ID")
    private Long id;

    @Schema(description = "厂区编码")
    private String plantCode;

    @Schema(description = "所属区域ID")
    private Long locationId;

    @Schema(description = "所属区域编码")
    private String locationCode;

    @Schema(description = "所属区域名称")
    private String locationName;

    @Schema(description = "所属巷道ID")
    private Long aisleId;

    @Schema(description = "所属巷道编码")
    private String aisleCode;

    @Schema(description = "所属巷道名称")
    private String aisleName;

    @Schema(description = "点位编码")
    private String pointCode;

    @Schema(description = "点位名称")
    private String pointName;

    @Schema(description = "点位条码")
    private String barcode;

    @Schema(description = "地图坐标")
    private String coordinate;

    @Schema(description = "物理楼层")
    private String floor;

    @Schema(description = "排序号")
    private Integer sortOrder;

    @Schema(description = "状态")
    private Integer status;

    @Schema(description = "备注")
    private String remark;

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