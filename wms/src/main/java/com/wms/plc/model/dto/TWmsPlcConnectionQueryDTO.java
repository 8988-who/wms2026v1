package com.wms.plc.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * PLC连接配置分页查询对象
 */
@Schema(description = "PLC连接配置分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TWmsPlcConnectionQueryDTO extends BaseQuery {

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

    @Schema(description = "心跳检测地址")
    private String heartbeatAddr;
}
