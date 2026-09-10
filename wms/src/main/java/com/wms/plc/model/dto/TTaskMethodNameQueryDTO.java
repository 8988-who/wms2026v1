package com.wms.plc.model.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

/**
 * 方法名配置分页查询对象
 */
@Schema(description = "方法名配置分页查询对象")
@Data
@EqualsAndHashCode(callSuper = false)
public class TTaskMethodNameQueryDTO extends BaseQuery {

    @Schema(description = "id")
    private String id;

    @Schema(description = "方法名")
    private String methodName;

    @Schema(description = "方法描述")
    private String methodDescription;
}
