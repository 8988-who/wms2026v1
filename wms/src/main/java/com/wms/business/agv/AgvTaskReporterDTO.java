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
// import java.util.Map;
//
// /**
//  * AGV 任务执行过程回馈接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/task}（ApiEnum.AGV_taskReporter）。
//  * RCS 将任务执行过程消息（start 任务开始/outbin 走出储位/end 任务完成）回馈给 WMS。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}（详见类库统一约定）。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV任务执行过程回馈接口参数（SPI）")
// @Getter
// @Setter
// public class AgvTaskReporterDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "任务号")
//     @NotBlank(message = "任务号不能为空")
//     private String robotTaskCode;
//
//     @Schema(description = "执行任务的机器人编号")
//     @NotBlank(message = "机器人编号不能为空")
//     private String singleRobotCode;
//
//     @Schema(description = "扩展信息，含 values.method(start/outbin/end)、values.carrierCode、values.slotCode 等")
//     private Map<String, Object> extra;
// }
