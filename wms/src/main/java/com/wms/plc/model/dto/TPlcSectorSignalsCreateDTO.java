package com.wms.plc.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * PLC信号块读写信号配置新增对象
 */
@Schema(description = "PLC信号块读写信号配置新增对象")
@Data
public class TPlcSectorSignalsCreateDTO {

    @Schema(description = "信号类型: 1=货架号 2=产品条码 3=产品型号")
    @NotNull(message = "请选择信号类型")
    private Integer signalType;

    @Schema(description = "信号地址")
    @NotBlank(message = "请输入信号地址")
    private String signalAddress;

    @Schema(description = "信号描述")
    private String signalDescription;

    @Schema(description = "信号块配置ID(t_plc_signal_config.id)")
    @NotBlank(message = "请选择信号块")
    private String signalId;

    @Schema(description = "排序号，信号类型为1(货架号)时可空，其余类型必填")
    private Integer number;
}
