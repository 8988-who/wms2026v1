package com.wms.system.model.vo;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 登录记录VO
 *
 * @author Ray.Hao
 * @since 4.3.3
 */
@Data
@Schema(description = "登录记录")
public class LoginRecordVO implements Serializable {

    @Schema(description = "设备")
    private String device;

    @Schema(description = "地区")
    private String region;

    @Schema(description = "IP 地址")
    private String ip;

    @Schema(description = "登录时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;
}
