package com.wms.common.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.model.entity
 * @Author: 邵煜晨
 * @CreateTime: 2026-09-01 11:24
 * @Description: 点位表
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("wms_point")
public class WmsPoint implements Serializable {
    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;
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
    private Long createdBy;
    private Long updatedBy;


}
