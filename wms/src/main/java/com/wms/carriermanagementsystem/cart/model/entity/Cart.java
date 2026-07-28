package com.wms.carriermanagementsystem.cart.model.entity;

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
 * 料车实体
 * <p>
 * 对应数据库表 wms_cart，存储料车实例信息，通过 model_id 关联料车型号配置。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@TableName("wms_cart")
@Data
@EqualsAndHashCode(callSuper = true)
public class Cart extends BaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 料车编号 */
    private String cartCode;

    /** 型号ID */
    private Long modelId;

    /** 当前装载数量 */
    private Integer currentQuantity;

    /**
     * 状态
     * <ul>
     *   <li>1 - 空闲</li>
     *   <li>2 - 使用中</li>
     *   <li>3 - 已满载</li>
     *   <li>4 - 维修</li>
     * </ul>
     */
    private Integer status;

    /** 所在区域 */
    private String area;

    /** 绑定操作工 */
    private String bindWorker;

    /** 实际容量（覆盖型号配置） */
    private Integer actualCapacity;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}
