package com.youlai.boot.warehouse.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.youlai.boot.common.base.BaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 点位实体对象
 * <p>
 * 对应数据库表 wms_point，表示巷道下的具体作业点位（AGV停靠/操作点）。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
@TableName("wms_point")
@Data
@EqualsAndHashCode(callSuper = true)
public class WmsPoint extends BaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    private String plantCode;
    private Long locationId;
    private Long aisleId;
    private String floor;
    private String pointCode;
    private String pointName;
    private String barcode;
    private String coordinate;
    private Integer sortOrder;
    private Integer status;
    private String remark;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}