package com.wms.plc.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * PLC连接配置新增对象
 */
@Schema(description = "PLC连接配置新增对象")
@Data
public class TWmsPlcConnectionCreateDTO {

    @Schema(description = "所属区域名称")
    @NotBlank(message = "请选择区域")
    private String name;

    @Schema(description = "PLC IP地址")
    @NotBlank(message = "请输入PLC IP地址")
    private String host;

    @Schema(description = "PLC类型")
    @NotBlank(message = "请选择PLC类型")
    private String plcType;

    @Schema(description = "心跳地址")
    private String heartbeatAddr;
}
