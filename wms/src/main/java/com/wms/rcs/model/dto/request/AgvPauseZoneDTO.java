package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 区域暂停与恢复接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/zone/pause}（ApiEnum.AGV_pauseZone）。
 * 让指定区域内的机器人暂停（FREEZE 运行急停）或恢复（RUN）运行。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV区域暂停与恢复接口请求参数")
@Getter
@Setter
public class AgvPauseZoneDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "调度管控区区域编号")
    @NotBlank(message = "区域编号不能为空")
    private String zoneCode;

    @Schema(description = "地图编号（临时区域时需要）")
    private String mapCode;

    @Schema(description = "调用类型：FREEZE(运行急停)/RUN(恢复)", example = "FREEZE")
    @NotBlank(message = "调用类型不能为空")
    private String invoke;
}
