package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 任务执行过程回馈请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/task}（RCS 侧接口 AGV_taskReporter）。
 * 不同 RCS 版本字段命名存在差异，这里做兼容承接：
 * <ul>
 *     <li>任务标识：优先 {@code taskCode}（与我方下发时 reqCode 一致），取不到用 {@code taskId}（我方回填的 rcsTaskId）兜底；</li>
 *     <li>状态语义：兼容字符串 {@code method}（如 ROBOT_APPLY/START/FINISH）与数值 {@code status} 两种来源；</li>
 * </ul>
 * 最终字段名以对接文档为准，若不一致仅需调整此 DTO 与 Service 的映射逻辑。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-07
 */
@Data
@Schema(description = "RCS任务执行回馈请求体")
public class RcsTaskReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 任务编号（与我方下发时的 taskCode 一致，作为首选反查键） */
    @Schema(description = "任务编号（首选反查键）")
    private String taskCode;

    /** RCS 系统任务ID（我方回填的 rcs_task_id，taskCode 缺失时兜底反查键） */
    @Schema(description = "RCS系统任务ID（兜底反查键）")
    private String taskId;

    /** 回馈动作/阶段（字符串语义，如 ROBOT_APPLY/ROBOT_START/ROBOT_END/FINISH 等） */
    @Schema(description = "回馈动作/阶段")
    private String method;

    /** 回馈状态（数值语义，与 RCS 任务状态码约定一致） */
    @Schema(description = "回馈状态码")
    private Integer status;

    /** 执行的AGV编号 */
    @Schema(description = "执行AGV编号")
    private String agvCode;

    /** 附加信息/备注 */
    @Schema(description = "附加信息")
    private String message;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
