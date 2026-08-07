package com.wms.rcs.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * RCS任务状态变更历史视图对象
 * <p>用于任务详情中展示状态流转时间线。</p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Schema(description = "RCS任务状态变更历史视图对象")
@Data
public class RcsTaskLifecycleVO {

    @Schema(description = "记录ID")
    private Long id;

    @Schema(description = "关联任务ID")
    private Long taskId;

    @Schema(description = "变更前状态")
    private Integer statusFrom;

    @Schema(description = "变更前状态描述")
    private String statusFromLabel;

    @Schema(description = "变更后状态")
    private Integer statusTo;

    @Schema(description = "变更后状态描述")
    private String statusToLabel;

    @Schema(description = "操作者类型（SYSTEM/ADMIN/AGV/EXTERNAL）")
    private String operatorType;

    @Schema(description = "操作者标识")
    private String operatorId;

    @Schema(description = "变更备注")
    private String remark;

    @Schema(description = "变更时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
