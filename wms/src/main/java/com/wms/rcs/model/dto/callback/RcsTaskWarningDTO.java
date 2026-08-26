package com.wms.rcs.model.dto.callback;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 任务异常告警请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/task/warning}（RCS 侧接口 AGV_warningTask）。
 * 与执行回馈一致，任务标识优先 {@code taskCode}，取不到用 {@code taskId} 兜底；
 * 承接告警码/告警信息，用于将本地任务流转为「异常」并写入 errorMsg。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-07
 */
@Data
@Schema(description = "RCS任务异常告警请求体")
public class RcsTaskWarningDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 任务编号（首选反查键） */
    @Schema(description = "任务编号（首选反查键）")
    private String taskCode;

    /** RCS 系统任务ID（兜底反查键） */
    @Schema(description = "RCS系统任务ID（兜底反查键）")
    private String taskId;

    /** 告警编码 */
    @Schema(description = "告警编码")
    private String warningCode;

    /** 告警信息/描述 */
    @Schema(description = "告警信息")
    private String warningMsg;

    /** 关联的AGV编号 */
    @Schema(description = "AGV编号")
    private String agvCode;

    /** 其余扩展字段 */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
