package com.wms.plc.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * PLC连接配置视图对象
 */
@Schema(description = "PLC连接配置视图对象")
@Data
public class TWmsPlcConnectionVO {

    @Schema(description = "数据库ID")
    private String id;

    @Schema(description = "所属区域")
    private String name;

    @Schema(description = "PLC地址")
    private String host;

    @Schema(description = "PLC型号")
    private String plcType;

    @Schema(description = "启用状态: 1=启用 0=禁用")
    private Integer enabled;

    @Schema(description = "PLC连接状态: true=连接中 false=未连接")
    private Boolean connected;

    @Schema(description = "心跳检测地址")
    private String heartbeatAddr;
}
