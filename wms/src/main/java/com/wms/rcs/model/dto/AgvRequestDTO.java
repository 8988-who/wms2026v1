package com.wms.rcs.model.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.io.Serializable;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs.model.dto
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:36
 * @Description: AGV请求DTO（所有 AGV 出站接口请求 DTO 的公共父类，承载幂等请求编号）
 * @Version: 1.0
 */
@Getter
@Setter
public class AgvRequestDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
    * 请求编号，每个请求都要一个唯一编号，同一个请求重复提交，使用同一编号
    */
    @Schema(description = "请求编号，全局唯一，重复提交沿用同一编号")
    @NotBlank(message = "请求编号不能为空")
    private String reqCode;

}
