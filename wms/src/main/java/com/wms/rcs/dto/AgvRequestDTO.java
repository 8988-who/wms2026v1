package com.wms.rcs.dto;

import jakarta.validation.constraints.NotBlank;

import java.io.Serializable;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs.dto
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:36
 * @Description: AGV请求DTO
 * @Version: 1.0
 */
public class AgvRequestDTO implements Serializable {
    private static final long serialVersionUID = 1L;

    /**
    * 请求编号，每个请求都要一个唯一编号，同一个请求重复提交，使用同一编号
    */
    @NotBlank(message = "请求编号不能为空")
    private String reqCode;

}
