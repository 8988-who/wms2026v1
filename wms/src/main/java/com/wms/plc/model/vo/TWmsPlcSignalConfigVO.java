package com.wms.plc.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * PLC信号块配置视图对象
 */
@Schema(description = "PLC信号块配置视图对象")
@Data
public class TWmsPlcSignalConfigVO {

    @Schema(description = "数据库ID")
    private String id;

    @Schema(description = "关联PLC ID")
    private String plcId;

    @Schema(description = "PLC信号地址")
    private String plcAddress;

    @Schema(description = "信号描述")
    private String description;

    @Schema(description = "储位id")
    private String pointId;

    @Schema(description = "启用状态: 1=启用 0=禁用")
    private Integer enabled;
}
