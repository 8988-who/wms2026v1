package com.wms.common.model;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.util.List;

@Schema(description = "批量状态更新表单")
@Data
public class BatchStatusForm {

    @Schema(description = "ID列表")
    @NotEmpty(message = "ID列表不能为空")
    private List<Long> ids;

    @Schema(description = "状态(1:启用；0:停用)")
    @NotNull(message = "状态不能为空")
    private Integer status;
}
