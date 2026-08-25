package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * AGV 区域归巢接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/zone/homing}（ApiEnum.AGV_homingZone）。
 * 让指定区域内的机器人前往预定停放区域，支持归巢后自动关机并预设开机时间。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV区域归巢接口请求参数")
@Getter
@Setter
public class AgvHomingZoneDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "地图编号（只传地图则整个地图的车归巢）")
    private String mapCode;

    @Schema(description = "需归巢的区域编号")
    private String zoneCode;

    @Schema(description = "区域编号集合（须同一地图）")
    private List<String> zoneCodes;

    @Schema(description = "归巢后是否自动关机：YES(关机)/NO(不关机)", example = "NO")
    @NotBlank(message = "自动关机标识不能为空")
    private String autoShutdown;

    @Schema(description = "预设开机时间（分钟精度），autoShutdown=YES 时生效")
    private String bootTime;

    @Schema(description = "归巢超时时间（秒精度），默认10分钟")
    private String expireTime;
}
