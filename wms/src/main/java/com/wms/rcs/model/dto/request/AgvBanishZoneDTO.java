package com.wms.rcs.model.dto.request;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

/**
 * AGV 区域驱离接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/zone/banish}（ApiEnum.AGV_banishZone）。
 * 将区域内机器人驱离，并禁止其他机器人通过该区域；支持驱离后暂停、通知上层、指定目标区域。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV区域驱离接口请求参数")
@Getter
@Setter
public class AgvBanishZoneDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "需驱离的区域编号")
    private String zoneCode;

    @Schema(description = "区域集合")
    private List<String> zoneCodes;

    @Schema(description = "机器人前往的目标区域")
    private String targetZoneCode;

    @Schema(description = "控制模式：0=调度到区域外 1=暂驻区 2=指定区域")
    private String controlMode;

    @Schema(description = "完成后是否暂停：0=不暂停 1=暂停")
    private String pause;

    @Schema(description = "完成后是否通知：0=不通知 1=通知")
    private String report;

    @Schema(description = "调用类型：BANISH(驱离)/RUN(恢复)")
    private String invoke;
}
