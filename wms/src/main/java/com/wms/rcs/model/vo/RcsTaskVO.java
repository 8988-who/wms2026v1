package com.wms.rcs.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * RCS任务视图对象
 * 用于向前端返回展示数据
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Schema(description = "RCS任务视图对象")
@Data
public class RcsTaskVO {

    @Schema(description = "任务ID")
    private Long id;

    @Schema(description = "任务编号")
    private String taskCode;

    @Schema(description = "任务类型")
    private Integer taskType;

    @Schema(description = "任务类型描述")
    private String taskTypeLabel;

    @Schema(description = "任务标题")
    private String taskTitle;

    @Schema(description = "源位置编码")
    private String fromLocation;

    @Schema(description = "目标位置编码")
    private String toLocation;

    @Schema(description = "关联料车编码")
    private String cartCode;

    @Schema(description = "任务扩展参数（JSON）")
    private Map<String, Object> payload;

    @Schema(description = "任务状态")
    private Integer status;

    @Schema(description = "任务状态描述")
    private String statusLabel;

    @Schema(description = "优先级")
    private Integer priority;

    @Schema(description = "优先级描述")
    private String priorityLabel;

    @Schema(description = "执行AGV编号")
    private String agvCode;

    @Schema(description = "RCS系统任务ID")
    private String rcsTaskId;

    @Schema(description = "提交时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime submitTime;

    @Schema(description = "派发时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime assignedAt;

    @Schema(description = "开始执行时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime startTime;

    @Schema(description = "完成时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime finishTime;

    @Schema(description = "异常信息")
    private String errorMsg;

    @Schema(description = "备注")
    private String remark;

    @Schema(description = "创建人")
    private String createdByName;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdTime;

    @Schema(description = "更新人")
    private String updatedByName;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedTime;

    @Schema(description = "状态变更历史（时间线，按变更时间升序）")
    private List<RcsTaskLifecycleVO> lifecycles;
}
