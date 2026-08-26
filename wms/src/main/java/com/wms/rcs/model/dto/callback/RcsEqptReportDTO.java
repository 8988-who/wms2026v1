package com.wms.rcs.model.dto.callback;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 请求外设控制请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/eqpt}（RCS 侧接口 AGV_eqptReporter）。
 * 典型场景：机器人需要使用电梯/门禁等外设，RCS 向 WMS（或 WCS）申请外设资源；
 * WMS 控制外设到位后，再通过出站「外设执行通知接口」告知 RCS。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Data
@Schema(description = "RCS请求外设控制请求体")
public class RcsEqptReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 设备编号 */
    @Schema(description = "设备编号")
    private String eqptCode;

    /** 设备名称 */
    @Schema(description = "设备名称")
    private String eqptName;

    /** 任务号 */
    @Schema(description = "任务号")
    private String taskCode;

    /**
     * 执行方法: CANCEL(取消)/APPLY_TO_AGV(接料)/APPLY_FROM_AGV(送料)/ARRIVED(到达)/RELEASE(离开)/
     * APPLY_LOCK(门开)/RELEASE_EQPT(释放门)/APPLY_RESOURCE(电梯申请)/EXECUTE_TASK(电梯执行)/RELEASE_RESOURCE(释放电梯)
     */
    @Schema(description = "执行方法: CANCEL/APPLY_TO_AGV/APPLY_FROM_AGV/ARRIVED/RELEASE/APPLY_LOCK/RELEASE_EQPT/APPLY_RESOURCE/EXECUTE_TASK/RELEASE_RESOURCE")
    private String method;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
