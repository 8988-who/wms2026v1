package com.wms.rcs.model.dto;

import lombok.Data;

import java.io.Serializable;

/**
 * RCS点位引用（坐标反查结果）
 * <p>
 * 仅承载 wms_point 反查结果两个字段，供绑定回调 slotCode（地图坐标口径）→ 本地点位使用。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-01
 */
@Data
public class RcsPointRef implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 点位ID（wms_point.id） */
    private Long id;

    /** 点位编码（wms_point.point_code） */
    private String pointCode;
}
