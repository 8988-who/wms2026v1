package com.wms.carriermanagementsystem.cartmodel.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wms.common.base.BaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 料车型号配置实体
 * <p>
 * 对应数据库表 wms_cart_model，存储料车的型号规格配置信息。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@TableName("wms_cart_model")
@Data
@EqualsAndHashCode(callSuper = true)
public class CartModel extends BaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /**
     * 型号代码，如 TC-100
     */
    private String modelCode;

    /**
     * 型号名称
     */
    private String modelName;

    /**
     * 最大装载数量
     */
    private Integer maxCapacity;

    /**
     * 层数
     */
    private Integer layerCount;

    /**
     * 备注
     */
    private String remark;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}
