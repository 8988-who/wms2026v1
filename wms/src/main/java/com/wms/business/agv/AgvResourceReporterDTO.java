package com.wms.business.agv;

// ===== 已停用（SPI 回调 RCS→WMS 入站方向，非出站接口）=====
// 已从 ApiEnum 出站注册表移除，入站改由 RcsReporterController + com.wms.rcs.model.dto.Rcs*ReportDTO 承接。
// 保留整类内容（逐行注释）以备回溯；如需恢复，去掉每行行首 “// ” 并同步恢复 ApiEnum 对应枚举项。
// import com.wms.rcs.model.dto.AgvRequestDTO;
// import io.swagger.v3.oas.annotations.media.Schema;
// import jakarta.validation.constraints.NotBlank;
// import lombok.Getter;
// import lombok.Setter;
//
// /**
//  * AGV 请求资源接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/resource}（ApiEnum.AGV_resourceReporter）。
//  * RCS 向 WMS 请求资源分配（站点/仓位/分播位/载具），WMS 需在响应中返回分配的资源。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV请求资源接口参数（SPI）")
// @Getter
// @Setter
// public class AgvResourceReporterDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "任务号")
//     @NotBlank(message = "任务号不能为空")
//     private String robotTaskCode;
//
//     @Schema(description = "申请类型：APPLY_SITE/APPLY_BIN/APPLY_PTL_BIN/APPLY_CARRIER")
//     @NotBlank(message = "申请类型不能为空")
//     private String applyType;
//
//     @Schema(description = "资源类型：CARRIER/SITE/ZONE")
//     @NotBlank(message = "资源类型不能为空")
//     private String resourceType;
//
//     @Schema(description = "资源编号")
//     @NotBlank(message = "资源编号不能为空")
//     private String resourceCode;
// }
