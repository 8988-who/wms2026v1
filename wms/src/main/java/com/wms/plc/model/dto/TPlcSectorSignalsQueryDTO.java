package com.wms.plc.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * PLC信号块读写信号配置分页查询对象
 */
@Schema(description = "PLC信号块读写信号配置分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TPlcSectorSignalsQueryDTO extends BaseQuery {

    @Schema(description = "id")
    private String id;

    @Schema(description = "信号类型: 1=货架号 2=产品条码 3=产品型号")
    private Integer signalType;

    @Schema(description = "信号地址")
    private String signalAddress;

    @Schema(description = "信号描述")
    private String signalDescription;

    @Schema(description = "信号ID")
    private String signalId;
}
