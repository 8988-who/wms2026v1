package com.wms.plc.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * PLC信号块配置新增对象
 */
@Schema(description = "PLC信号块配置新增对象")
@Data
public class TWmsPlcSignalConfigCreateDTO {

    @Schema(description = "关联PLC ID")
    @NotBlank(message = "请选择PLC")
    private String plcId;

    @Schema(description = "PLC信号地址")
    @NotBlank(message = "请输入板块地址")
    private String plcAddress;

    @Schema(description = "信号描述")
    private String description;

    @Schema(description = "储位id")
    @NotBlank(message = "请选择储位")
    private String pointId;
}
