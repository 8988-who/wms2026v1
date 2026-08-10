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
//  * AGV 绑定解绑通知接口 DTO（SPI，RCS→WMS）
//  * <p>
//  * 对应接口 {@code POST /api/robot/reporter/bind}（ApiEnum.AGV_bindReporter）。
//  * RCS 执行绑定/解绑操作时通知 WMS，保持双方数据同步。
//  * 本类为让 ApiEnum 参数校验统一而建，继承 {@link AgvRequestDTO}。
//  * </p>
//  *
//  * @author SenyangHe
//  * @since 2026-08-10
//  */
// @Schema(description = "AGV绑定解绑通知接口参数（SPI）")
// @Getter
// @Setter
// public class AgvBindReporterDTO extends AgvRequestDTO {
//
//     private static final long serialVersionUID = 1L;
//
//     @Schema(description = "存储对象种类：SITE(站点)/BIN(仓位)")
//     @NotBlank(message = "存储对象种类不能为空")
//     private String slotCategory;
//
//     @Schema(description = "存储对象编号")
//     @NotBlank(message = "存储对象编号不能为空")
//     private String slotCode;
//
//     @Schema(description = "搬运对象种类：POD(货架)/PALLET(托盘)/BOX(料箱)/MAT(物料)")
//     @NotBlank(message = "搬运对象种类不能为空")
//     private String carrierCategory;
//
//     @Schema(description = "载具编号")
//     private String carrierCode;
//
//     @Schema(description = "调用类型：BIND(绑定)/UNBIND(解绑)")
//     @NotBlank(message = "调用类型不能为空")
//     private String invoke;
// }
