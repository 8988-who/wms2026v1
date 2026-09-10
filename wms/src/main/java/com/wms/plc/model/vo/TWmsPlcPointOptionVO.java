package com.wms.plc.model.vo;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

/**
 * 储位（点位）下拉选项
 */
@Schema(description = "储位（点位）下拉选项")
@Data
public class TWmsPlcPointOptionVO {

    @Schema(description = "储位ID")
    private String id;

    @Schema(description = "储位名称")
    private String pointName;
}
