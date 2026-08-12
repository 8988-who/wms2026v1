package com.wms.rcs.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.baomidou.mybatisplus.extension.handlers.JacksonTypeHandler;
import com.wms.common.base.WmsBaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.time.LocalDateTime;
import java.util.Map;

/**
 * RCS任务实体
 * <p>
 * 对应数据库表 wms_rcs_task，存储AGV调度任务信息。
 * 审计字段映射到 created_time/updated_time/created_by/updated_by（复数形式，与 warehouse 模块一致），
 * 均由 AutoFillMetaObjectHandler 按属性名自动填充。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@TableName(value = "wms_rcs_task", autoResultMap = true)
@Data
@EqualsAndHashCode(callSuper = true)
public class RcsTaskEntity extends WmsBaseEntity {

    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    /** 任务编号（唯一，业务主键） */
    private String taskCode;

    /** 任务类型（1-搬运 2-充电 3-调度 4-巡检） */
    private Integer taskType;

    /** 任务标题 */
    private String taskTitle;

    /** 源位置编码 */
    private String fromLocation;

    /** 目标位置编码 */
    private String toLocation;

    /** 关联料车编码 */
    private String cartCode;

    /** 任务扩展参数（JSON格式，如物料信息、路径约束等） */
    @TableField(value = "payload", typeHandler = JacksonTypeHandler.class)
    private Map<String, Object> payload;

    /** 任务状态（0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常） */
    private Integer status;

    /** 优先级（1-低 2-中 3-高 4-紧急） */
    private Integer priority;

    /** 执行AGV编号 */
    private String agvCode;

    /** RCS系统任务ID */
    private String rcsTaskId;

    /** 提交时间 */
    private LocalDateTime submitTime;

    /** 派发时间（派发给AGV） */
    private LocalDateTime assignedAt;

    /** 开始执行时间 */
    private LocalDateTime startTime;

    /** 完成时间 */
    private LocalDateTime finishTime;

    /** 异常信息 */
    private String errorMsg;

    /** 备注 */
    private String remark;

    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;
}
