package com.wms.warehouse.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * 库位/区域视图对象
 * 用于向前端返回展示数据
 *
 * @author SenyangHe
 * @since 2026-07-20 12:44
 */
@Schema(description = "库位/区域视图对象")
@Data
public class WmsLocationVO {

    @Schema(description = "库位/区域ID")
    private Long id;

    @Schema(description = "厂区编码")
    private String plantCode;

    @Schema(description = "厂区名称（预留：分页SQL未映射，恒为null，前端未使用；如需展示需在 WmsLocationMapper.xml 补 sys_dept 按 plant_code 子查询）")
    private String plantName;

    @Schema(description = "库位/区域编码")
    private String locationCode;

    @Schema(description = "库位/区域名称")
    private String locationName;

    @Schema(description = "库位/区域类型")
    private String locationType;

    @Schema(description = "库位/区域类型描述（预留：分页SQL未映射，恒为null，前端未使用；如需展示需在 SQL 中 CASE WHEN 映射 湿坯下线/防干/干燥/立浇交接/检修/交接/成型/立浇交接/木板上线/木板下线/上线点/青坯上线/青坯下线/施釉上线/施釉下线）")
    private String locationTypeLabel;

    @Schema(description = "父节点ID")
    private Long parentId;

    @Schema(description = "物理楼层标识（如：1F, 2F, B1）")
    private String floor;

    @Schema(description = "排序号")
    private Integer sortOrder;

    @Schema(description = "状态(1:启用；0:禁用)")
    private Integer status;

    @Schema(description = "状态描述（预留：分页SQL未映射，恒为null，前端未使用；如需展示需在 SQL 中 CASE WHEN status 转换启用/停用）")
    private String statusLabel;

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