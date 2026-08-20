package com.wms.inventory.model.entity;

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
 * 料车库存（料车-点位绑定）实体
 * <p>
 * 对应数据库表 wms_cart_inventory，按「每个点位一条记录」建模：
 * cart_id 记录当前停靠的料车（NULL 表示空位），point_code/location_id/aisle_id 为冗余的点位属性（搬运不变）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@TableName("wms_cart_inventory")
@Data
@EqualsAndHashCode(callSuper = true)
public class CartInventory extends WmsBaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 点位ID，关联 wms_point.id（每个点位一条） */
    private Long pointId;

    /** 当前停靠料车ID，关联 wms_cart.id；NULL 表示空位 */
    private Long cartId;

    /** 冗余：点位编码（自 wms_point.point_code，点位属性，搬运不变） */
    private String pointCode;

    /** 冗余：点位所属区域ID（自 wms_point.location_id，点位属性，搬运不变） */
    private Long locationId;

    /** 冗余：点位所属巷道ID（自 wms_point.aisle_id，点位属性，搬运不变，按巷道筛选用） */
    private Long aisleId;

    /** 料车进入当前点位的时刻（cart_id 为空时为空） */
    private LocalDateTime arriveTime;

    /** 落位时装载量快照（绑定时刻 COUNT 在车货品，之后不维护） */
    private Integer arriveQuantity;

    /** 最近一次搬运任务编号（溯源用） */
    private String lastTaskCode;

    /** 库存锁定：0-正常 1-锁定（锁定期不参与任务分配/定时搬运） */
    private Integer lockStatus;

    /** 备注 */
    private String remark;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}
