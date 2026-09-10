package com.wms.plc.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 方法名配置新增对象
 */
@Schema(description = "方法名配置新增对象")
@Data
public class TTaskMethodNameCreateDTO {

    @Schema(description = "方法名")
    @NotBlank(message = "请输入方法名")
    private String methodName;

    @Schema(description = "方法描述")
    @NotBlank(message = "请输入方法描述")
    private String methodDescription;
}
