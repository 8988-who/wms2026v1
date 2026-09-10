package com.wms.plc.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

/**
 * 信号值方法配置新增对象
 */
@Schema(description = "信号值方法配置新增对象")
@Data
public class TSignalMethodConfigCreateDTO {

    @Schema(description = "信号块id(t_plc_signal_config.id)")
    @NotBlank(message = "请选择信号块地址")
    private String signalId;

    @Schema(description = "信号值")
    @NotBlank(message = "请输入信号值")
    private String signalCode;

    @Schema(description = "方法id(t_task_method_name.id)")
    @NotBlank(message = "请选择方法")
    private String methodId;
}
