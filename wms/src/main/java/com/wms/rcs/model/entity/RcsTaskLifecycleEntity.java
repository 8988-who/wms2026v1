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
 * RCS任务状态变更历史实体
 * <p>
 * 对应数据库表 wms_rcs_task_lifecycle，记录任务状态全生命周期。
 * 该表仅有 create_time 一个审计字段（无 update_time/create_by/update_by），
 * 故不继承 {@link com.wms.common.base.BaseEntity}，独立声明。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@TableName("wms_rcs_task_lifecycle")
@Data
public class RcsTaskLifecycleEntity implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    /** 主键ID（雪花算法生成，写入时回填） */
    @TableId(type = IdType.ASSIGN_ID)
    private Long id;

    /** 关联 wms_rcs_task.id */
    private Long taskId;

    /** 变更前状态 */
    private Integer statusFrom;

    /** 变更后状态 */
    private Integer statusTo;

    /** 操作者类型：SYSTEM-系统自动 ADMIN-管理员 AGV-AGV自主 EXTERNAL-外部系统 */
    private String operatorType;

    /** 操作者标识（如AGV编号或用户ID） */
    private String operatorId;

    /** 变更备注 */
    private String remark;

    /** 状态变更时间 */
    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
