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
// import java.util.List;
//
// /**
//  * AGV 区域驱离完成回馈接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/zone/banish}（ApiEnum.AGV_banishZoneReporter）。
//  * 所有机器人全部驱离成功，或到达超时时间仍未全部完成时反馈给 WMS。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV区域驱离完成回馈接口参数（SPI）")
// @Getter
// @Setter
// public class AgvBanishZoneReporterDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "驱离指令编号")
//     @NotBlank(message = "驱离指令编号不能为空")
//     private String banishCode;
//
//     @Schema(description = "仍停留在区域内的机器人编号")
//     private List<String> stayRobotCode;
//
//     @Schema(description = "执行状态：SUCCESS(全部成功)/FAIL(超时未完成)")
//     @NotBlank(message = "执行状态不能为空")
//     private String status;
// }
