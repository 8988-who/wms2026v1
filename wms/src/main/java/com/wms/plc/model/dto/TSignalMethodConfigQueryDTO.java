package com.wms.plc.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 信号值方法配置分页查询对象
 */
@Schema(description = "信号值方法配置分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TSignalMethodConfigQueryDTO extends BaseQuery {

    @Schema(description = "id")
    private String id;

    @Schema(description = "信号块id")
    private String signalId;

    @Schema(description = "信号值")
    private String signalCode;

    @Schema(description = "方法id")
    private String methodId;
}
