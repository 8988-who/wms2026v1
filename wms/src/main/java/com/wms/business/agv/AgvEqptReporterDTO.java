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
//  * AGV 请求外设接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/eqpt}（ApiEnum.AGV_eqptReporter）。
//  * RCS 向 WCS/WMS 请求外设控制（如电梯、自动门等）。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV请求外设接口参数（SPI）")
// @Getter
// @Setter
// public class AgvEqptReporterDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "设备编号")
//     @NotBlank(message = "设备编号不能为空")
//     private String eqptCode;
//
//     @Schema(description = "设备名称")
//     @NotBlank(message = "设备名称不能为空")
//     private String eqptName;
//
//     @Schema(description = "任务号")
//     @NotBlank(message = "任务号不能为空")
//     private String taskCode;
//
//     @Schema(description = "执行方法：CANCEL/APPLY_TO_AGV/APPLY_FROM_AGV/ARRIVED/RELEASE/APPLY_LOCK/RELEASE_EQPT/APPLY_RESOURCE/EXECUTE_TASK/RELEASE_RESOURCE")
//     @NotBlank(message = "执行方法不能为空")
//     private String method;
// }
