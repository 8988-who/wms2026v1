package com.wms.warehouse.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wms.common.base.WmsBaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 库位/区域实体对象
 * 对应数据库表 wms_location
 *
 * @author SenyangHe
 * @since 2026-07-20 12:44
 */
@TableName("wms_location")
@Data
@EqualsAndHashCode(callSuper = true)
public class WmsLocation extends WmsBaseEntity {

    /**
     * 创建时间（覆盖父类，映射数据库 created_time）
     */
    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    /**
     * 更新时间（覆盖父类，映射数据库 updated_time）
     */
    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /**
     * 厂区编码，关联 sys_dept.plant_code，用于数据权限隔离
     */
    private String plantCode;

    /**
     * 库位/区域编码
     */
    private String locationCode;

    /**
     * 库位/区域名称
     */
    private String locationName;

    /**
     * 区域用途类型（预留，如 TURNOVER/DRY_ZONE/DRY_ROOM/BUFFER/PROD_LINE，当前不参与业务逻辑）
     */
    private String locationType;

    /**
     * 父节点ID
     */
    private Long parentId;

    /**
     * 物理楼层标识（如：1F, 2F, B1）
     */
    private String floor;

    /**
     * 排序号
     */
    private Integer sortOrder;

    /**
     * 状态(1-正常 0-禁用)
     */
    private Integer status;

    /**
     * 备注
     */
    private String remark;

    /**
     * 创建人ID
     */
    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    /**
     * 更新人ID
     */
    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;

}