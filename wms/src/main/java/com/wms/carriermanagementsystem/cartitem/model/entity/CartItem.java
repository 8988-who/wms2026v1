package com.wms.carriermanagementsystem.cartitem.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.wms.common.base.WmsBaseEntity;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;

/**
 * 料车装载明细实体
 * <p>
 * 对应数据库表 wms_cart_item，存储料车中每个货品的装载记录。
 * 通过 cart_id 关联料车实例，支持装车和取走两个状态流转。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@TableName("wms_cart_item")
@Data
@EqualsAndHashCode(callSuper = true)
public class CartItem extends WmsBaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 料车ID */
    private Long cartId;

    /** 货品条码（唯一码，全局唯一防止重复装车） */
    private String productCode;

    /** 货品型号 */
    private String productModel;

    /** 装货顺序号（从1开始，越大越晚装，同一车内唯一） */
    private Integer sortOrder;

    /** 批次号/工单号 */
    private String batchNo;

    /** 层号（多层料车使用，默认 1） */
    private Integer layerNo;

    /** 装车操作人 */
    private String operator;

    /**
     * 状态
     * <ul>
     *   <li>1 - 在车</li>
     *   <li>2 - 已取走</li>
     * </ul>
     */
    private Integer status;

    /** 装车时间 */
    private LocalDateTime loadedAt;

    /** 取走时间（可空） */
    private LocalDateTime takenAt;

    /** 备注 */
    private String remark;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}
