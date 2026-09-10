package com.wms.plc.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * PLC信号块配置分页查询对象
 */
@Schema(description = "PLC信号块配置分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TWmsPlcSignalConfigQueryDTO extends BaseQuery {

    @Schema(description = "数据库ID")
    private String id;

    @Schema(description = "关联PLC ID")
    private String plcId;

    @Schema(description = "PLC信号地址")
    private String plcAddress;

    @Schema(description = "信号描述")
    private String description;

    @Schema(description = "启用状态: 1=启用 0=禁用")
    private Integer enabled;
}
