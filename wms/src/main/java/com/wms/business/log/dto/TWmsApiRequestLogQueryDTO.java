package com.wms.business.log.dto;

import com.wms.common.base.BaseQuery;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

/**
 * 查询接口请求日志DTO
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Data
@Schema(description = "查询接口请求日志DTO")
@EqualsAndHashCode(callSuper = true)
public class TWmsApiRequestLogQueryDTO extends BaseQuery implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "所属模块")
    private String module;

    @Schema(description = "接口编码")
    private String apiCode;

    @Schema(description = "接口地址")
    private String apiUrl;

    @Schema(description = "接口名称")
    private String apiName;

    @Schema(description = "是否成功")
    private String isSuccess;

    @Schema(description = "请求参数")
    private String reqParams;

}
