package com.wms.rcs.model.dto.callback;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 绑定解绑通知请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/v1/rcs/reporter/bind}（RCS 侧接口 AGV_bindReporter）。
 * RCS 执行绑定/解绑操作时通知 WMS，保持双方存储对象与搬运对象的绑定关系数据同步，需开启 BIND 业务通知。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-10
 */
@Data
@Schema(description = "RCS绑定解绑通知请求体")
public class RcsBindReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 侧唯一，重复回调沿用同一编号） */
    @Schema(description = "请求编号")
    private String reqCode;

    /** 存储对象类别: SITE(站点) / BIN(仓位) */
    @Schema(description = "存储对象类别: SITE(站点)/BIN(仓位)")
    private String slotCategory;

    /** 存储对象编号 */
    @Schema(description = "存储对象编号")
    private String slotCode;

    /** 搬运对象类别: POD(货架) / PALLET(托盘) / BOX(料箱) / MAT(物料) */
    @Schema(description = "搬运对象类别: POD(货架)/PALLET(托盘)/BOX(料箱)/MAT(物料)")
    private String carrierCategory;

    /** 载具编号 */
    @Schema(description = "载具编号")
    private String carrierCode;

    /** 操作类型: BIND(绑定) / UNBIND(解绑) */
    @Schema(description = "操作类型: BIND(绑定)/UNBIND(解绑)")
    private String invoke;

    /** 其余扩展字段（原样承接，便于排查与后续扩展） */
    @Schema(description = "扩展字段")
    private Map<String, Object> extra;
}
