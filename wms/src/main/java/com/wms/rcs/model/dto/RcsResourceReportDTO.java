package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 请求资源分配请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/resource}（RCS 侧接口 AGV_resourceReporter）。
 * 典型场景：机器人需要搬运货架到目的地但目的地未指定，RCS 向 WMS 申请一个资源（站点/仓位/载具）。
 * WMS 需在响应 {@code data} 中返回分配的资源 {@code {"type":"SITE","code":"WS001"}}。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Data
@Schema(description = "RCS请求资源分配请求体")
public class RcsResourceReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 任务号 */
    @Schema(description = "任务号")
    private String robotTaskCode;

    /** 申请类型: APPLY_SITE(存储位置)/APPLY_BIN(仓位)/APPLY_PTL_BIN(分播位)/APPLY_CARRIER(载具) */
    @Schema(description = "申请类型: APPLY_SITE/APPLY_BIN/APPLY_PTL_BIN/APPLY_CARRIER")
    private String applyType;

    /** 资源类型: CARRIER/SITE/ZONE */
    @Schema(description = "资源类型: CARRIER/SITE/ZONE")
    private String resourceType;

    /** 资源编号 */
    @Schema(description = "资源编号")
    private String resourceCode;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
