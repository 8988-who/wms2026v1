package com.wms.plc.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * PLC连接下拉选项
 */
@Schema(description = "PLC连接下拉选项")
@Data
public class TWmsPlcConnectionOptionVO {

    @Schema(description = "PLC ID")
    private String id;

    @Schema(description = "PLC地址")
    private String host;
}
