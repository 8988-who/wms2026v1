package com.wms.business.agv;

import com.wms.rcs.model.dto.AgvRequestDTO;
import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

/**
 * AGV 区域封锁与恢复接口请求 DTO
 * <p>
 * 对应 RCS 接口 {@code POST /rcs/rtas/api/robot/controller/zone/blockade}（ApiEnum.AGV_blockadeZone）。
 * 封锁指定区域，区域外机器人不能进入（区域内机器人无需离开）；解除封锁后限制取消。
 * 继承 {@link AgvRequestDTO} 复用请求编号 {@code reqCode}（幂等键）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Schema(description = "AGV区域封锁与恢复接口请求参数")
@Getter
@Setter
public class AgvBlockadeZoneDTO extends AgvRequestDTO {

    private static final long serialVersionUID = 1L;

    @Schema(description = "需封锁的区域编号")
    @NotBlank(message = "区域编号不能为空")
    private String zoneCode;

    @Schema(description = "调用类型：BLOCKADE(封锁)/OPENUP(解封)", example = "BLOCKADE")
    @NotBlank(message = "调用类型不能为空")
    private String invoke;

    @Schema(description = "封锁后是否暂停区域内机器人")
    private String pause;

    @Schema(description = "完成后是否上报")
    private String report;

    @Schema(description = "是否禁用点位：0=否 1=是(默认)")
    private Integer disableSite;

    @Schema(description = "是否启用点位：0=否 1=是(默认)")
    private Integer enableSite;
}
