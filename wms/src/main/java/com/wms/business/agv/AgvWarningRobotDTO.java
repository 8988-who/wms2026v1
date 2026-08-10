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
//  * AGV 机器人异常告警上报接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/robot/warning}（ApiEnum.AGV_warningRobot）。
//  * RCS 将导致机器人停止运行的严重告警推送给 WMS（只推送一次）。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV机器人异常告警上报接口参数（SPI）")
// @Getter
// @Setter
// public class AgvWarningRobotDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "异常机器人编号")
//     @NotBlank(message = "机器人编号不能为空")
//     private String singleRobotCode;
//
//     @Schema(description = "告警单号")
//     @NotBlank(message = "告警单号不能为空")
//     private String taskWarnCode;
//
//     @Schema(description = "初次出现故障时间")
//     @NotBlank(message = "故障时间不能为空")
//     private String startTime;
//
//     @Schema(description = "正在执行的任务编号")
//     private String robotTaskCode;
//
//     @Schema(description = "机器人位置 X 坐标")
//     @NotBlank(message = "位置X坐标不能为空")
//     private String x;
//
//     @Schema(description = "机器人位置 Y 坐标")
//     @NotBlank(message = "位置Y坐标不能为空")
//     private String y;
//
//     @Schema(description = "故障码")
//     @NotBlank(message = "故障码不能为空")
//     private String errorCode;
//
//     @Schema(description = "故障消息")
//     private String errorMsg;
// }
