package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * RCS 机器人归巢完成回馈请求体（入站，国标）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/zone/homing}（RCS 侧接口 AGV_homingZoneReporter）。
 * 机器人归巢完成后反馈给 WMS，需在 RCS 系统设置中开启 ZONE_HOMING 业务通知。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Data
@Schema(description = "RCS机器人归巢完成回馈请求体")
public class RcsHomingReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 归巢指令编号 */
    @Schema(description = "归巢指令编号")
    private String homingCode;

    /** 仍在工作的机器人编号 */
    @Schema(description = "仍在工作的机器人编号")
    private List<String> workRobotCode;

    /** 归巢执行状态 */
    @Schema(description = "归巢执行状态")
    private String status;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
