package com.wms.plc.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * PLC区域选项
 */
@Schema(description = "PLC区域选项")
@Data
public class TWmsPlcConnectionLocationVO {

    @Schema(description = "区域名称")
    private String locationName;

    @Schema(description = "状态: 1=启用 0=禁用")
    private Integer status;
}
