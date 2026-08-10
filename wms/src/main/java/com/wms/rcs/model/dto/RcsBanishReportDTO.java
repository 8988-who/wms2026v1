package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * RCS 区域驱离完成回馈请求体（入站，国标）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/zone/banish}（RCS 侧接口 AGV_banishZoneReporter）。
 * 所有机器人全部驱离成功，或到达超时时间仍未全部完成时反馈给 WMS，需开启 ZONE_BANISH 业务通知。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Data
@Schema(description = "RCS区域驱离完成回馈请求体")
public class RcsBanishReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 驱离指令编号 */
    @Schema(description = "驱离指令编号")
    private String banishCode;

    /** 仍停留在区域内的机器人编号 */
    @Schema(description = "仍停留在区域内的机器人编号")
    private List<String> stayRobotCode;

    /** 驱离执行状态: SUCCESS(全部成功) / FAIL(超时未完成) */
    @Schema(description = "驱离执行状态: SUCCESS(全部成功)/FAIL(超时未完成)")
    private String status;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
