package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 站点禁用与启用接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/site/lock}（ApiEnum.AGV_lockSite）。
 * 禁用站点后，该站点及站点载具不会被任务分配（已分配任务需执行完成）。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV站点禁用与启用接口请求参数")
@Getter
@Setter
public class AgvLockSiteDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "站点编号/别名")
    @NotBlank(message = "站点编号不能为空")
    private String siteCode;

    @Schema(description = "调用类型：LOCK(禁用)/UNLOCK(启用)", example = "LOCK")
    @NotBlank(message = "调用类型不能为空")
    private String invoke;
}
