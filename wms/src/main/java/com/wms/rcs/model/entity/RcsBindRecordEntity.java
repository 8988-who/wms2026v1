package com.wms.rcs.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * RCS绑定解绑回调台账实体
 * <p>
 * 对应数据库表 wms_rcs_bind_record，记录 RCS 推送的每次绑定/解绑通知原文及处理结果。
 * req_code 唯一索引为幂等闸门，处理状态见 {@code HandleStatus} 常量。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-01
 */
@TableName("wms_rcs_bind_record")
@Data
public class RcsBindRecordEntity implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 处理状态：处理中 */
    public static final String STATUS_PROCESSING = "PROCESSING";
    /** 处理状态：成功 */
    public static final String STATUS_SUCCESS = "SUCCESS";
    /** 处理状态：点位未匹配（数据性问题，重试无意义） */
    public static final String STATUS_UNMATCHED_POINT = "UNMATCHED_POINT";
    /** 处理状态：料车未匹配（数据性问题，重试无意义） */
    public static final String STATUS_UNMATCHED_CART = "UNMATCHED_CART";
    /** 处理状态：非法报文（invoke 不合法等，不重试） */
    public static final String STATUS_REJECTED = "REJECTED";
    /** 处理状态：处理异常（可重试） */
    public static final String STATUS_FAILED = "FAILED";

    /** 主键ID（雪花算法生成，写入时回填） */
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    /** RCS侧请求编号（重复回调沿用同一编号），幂等键 */
    private String reqCode;

    /** 存储对象类别: SITE(站点)/BIN(仓位) */
    private String slotCategory;

    /** 存储对象编号（站点口径=wms_point.coordinate 地图坐标） */
    private String slotCode;

    /** 搬运对象类别: POD(货架)/PALLET(托盘)/BOX(料箱)/MAT(物料) */
    private String carrierCategory;

    /** 载具编号（对应 wms_cart.cart_code） */
    private String carrierCode;

    /** 操作类型: BIND(绑定)/UNBIND(解绑) */
    private String invoke;

    /** 处理状态 */
    private String handleStatus;

    /** 处理结果说明 */
    private String handleMsg;

    /** 回调报文原文（JSON） */
    private String rawParams;

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;
}
