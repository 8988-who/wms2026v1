package com.wms.rcs.service;

import com.wms.rcs.model.dto.callback.RcsBindReportDTO;

/**
 * RCS绑定解绑回调同步业务接口
 * <p>
 * 处理 RCS /bind 回调：记台账（reqCode 幂等）→ 编码翻译（坐标→点位、料车编码→料车）
 * → 纯本地同步 cart_inventory（零回环调 RCS）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-01
 */
public interface RcsBindService {

    /**
     * 处理绑定/解绑通知
     *
     * @param report RCS 回调报文
     * @return 处理结果说明（成功/幂等跳过/未匹配原因），异常向上抛出由调用方回应失败码
     */
    String handleBindReport(RcsBindReportDTO report);
}
