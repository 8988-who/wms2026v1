package com.wms.rcs.service.impl;

import cn.hutool.core.util.StrUtil;
import com.alibaba.fastjson2.JSON;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.wms.inventory.mapper.CartInventoryMapper;
import com.wms.rcs.mapper.RcsBindRecordMapper;
import com.wms.rcs.mapper.RcsTaskMapper;
import com.wms.rcs.model.dto.RcsPointRef;
import com.wms.rcs.model.dto.callback.RcsBindReportDTO;
import com.wms.rcs.model.entity.RcsBindRecordEntity;
import com.wms.rcs.service.RcsBindService;
import com.wms.inventory.service.CartInventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

/**
 * RCS绑定解绑回调同步业务实现
 * <p>
 * 流程：记台账（reqCode 唯一索引幂等闸门）→ 编码翻译（slotCode 坐标→点位、carrierCode→料车）
 * → 调用 {@link CartInventoryService#syncExternalBind} 纯本地同步绑定状态（零回环调 RCS）。
 * </p>
 * <p>
 * 失败策略与 task 回调刻意不同：task 回调"总是回成功"防重试风暴；bind 是数据修正，
 * 程序异常时回失败码让 RCS 重试（FAILED 记录可重处理），避免库存悄悄错位。
 * 数据性问题（点位/料车翻译不到）重试也不会好，落 UNMATCHED 台账并回成功，供人工补数。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-09-01
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class RcsBindServiceImpl implements RcsBindService {

    private final RcsBindRecordMapper rcsBindRecordMapper;
    private final RcsTaskMapper rcsTaskMapper;
    private final CartInventoryMapper cartInventoryMapper;
    private final CartInventoryService cartInventoryService;

    /** 终态：重复推送直接按原结果回应，不再重处理 */
    private static final Set<String> TERMINAL_STATUSES = Set.of(
            RcsBindRecordEntity.STATUS_SUCCESS,
            RcsBindRecordEntity.STATUS_UNMATCHED_POINT,
            RcsBindRecordEntity.STATUS_UNMATCHED_CART,
            RcsBindRecordEntity.STATUS_REJECTED);

    @Override
    public String handleBindReport(RcsBindReportDTO report) {
        // 1. 台账闸门：插入即占位（reqCode 唯一索引），重复推送按已处理状态分流。
        //    本方法不加事务：台账记录需在处理失败时保留 FAILED 状态供 RCS 重试，
        //    库存同步自带独立事务（syncExternalBind）。
        RcsBindRecordEntity record = buildRecord(report);
        try {
            rcsBindRecordMapper.insert(record);
        } catch (DuplicateKeyException e) {
            RcsBindRecordEntity existing = rcsBindRecordMapper.selectOne(
                    new LambdaQueryWrapper<RcsBindRecordEntity>()
                            .eq(RcsBindRecordEntity::getReqCode, report.getReqCode()));
            if (existing == null) {
                // 唯一索引冲突却查不到记录（极端并发窗口），按新记录继续处理
                log.warn("RCS绑定回调台账冲突但记录不存在，按新记录处理：reqCode={}", report.getReqCode());
            } else if (TERMINAL_STATUSES.contains(existing.getHandleStatus())) {
                log.info("RCS绑定回调重复推送，按原结果回应：reqCode={}, status={}",
                        report.getReqCode(), existing.getHandleStatus());
                return "重复推送，原处理结果：" + existing.getHandleStatus();
            } else {
                // FAILED/PROCESSING：复用原记录重处理
                record = existing;
            }
        }

        try {
            HandleResult result = doHandle(report);
            updateRecordStatus(record, result);
            return result.message();
        } catch (Exception e) {
            updateRecordStatus(record,
                    new HandleResult(RcsBindRecordEntity.STATUS_FAILED, "处理异常：" + e.getMessage()));
            throw e;
        }
    }

    /**
     * 编码翻译 + 库存同步
     *
     * @return 处理结果（状态+说明）
     */
    private HandleResult doHandle(RcsBindReportDTO report) {
        boolean bind = "BIND".equalsIgnoreCase(report.getInvoke());
        if (!bind && !"UNBIND".equalsIgnoreCase(report.getInvoke())) {
            log.warn("RCS绑定回调操作类型非法，已拒绝：reqCode={}, invoke={}", report.getReqCode(), report.getInvoke());
            return new HandleResult(RcsBindRecordEntity.STATUS_REJECTED,
                    "非法操作类型：" + report.getInvoke());
        }

        // BIN/仓位类别暂不支持，落台账待后续扩展
        if (!"SITE".equalsIgnoreCase(report.getSlotCategory())) {
            log.info("RCS绑定回调存储对象类别暂不支持：reqCode={}, slotCategory={}",
                    report.getReqCode(), report.getSlotCategory());
            return new HandleResult(RcsBindRecordEntity.STATUS_UNMATCHED_POINT,
                    "存储对象类别暂不支持：" + report.getSlotCategory());
        }
        if (StrUtil.isBlank(report.getSlotCode())) {
            return new HandleResult(RcsBindRecordEntity.STATUS_UNMATCHED_POINT, "站点编码为空");
        }
        if (StrUtil.isBlank(report.getCarrierCode())) {
            return new HandleResult(RcsBindRecordEntity.STATUS_UNMATCHED_CART, "载具编码为空");
        }

        // slotCode（坐标口径）→ 本地点位
        List<RcsPointRef> points = rcsTaskMapper.selectPointIdByCoordinate(report.getSlotCode());
        if (points.isEmpty()) {
            log.warn("RCS绑定回调坐标未匹配到点位：reqCode={}, slotCode={}", report.getReqCode(), report.getSlotCode());
            return new HandleResult(RcsBindRecordEntity.STATUS_UNMATCHED_POINT,
                    "坐标未匹配到点位：" + report.getSlotCode());
        }
        if (points.size() > 1) {
            log.warn("RCS绑定回调坐标匹配到多个点位，取第一条：slotCode={}, count={}, 取用点位={}",
                    report.getSlotCode(), points.size(), points.get(0).getPointCode());
        }
        RcsPointRef point = points.get(0);

        // carrierCode → 料车（复用任务闭环的反查，口径与 wms_cart.cart_code 一致）
        Long cartId = cartInventoryMapper.selectCartIdByCartCode(report.getCarrierCode());
        if (cartId == null) {
            log.warn("RCS绑定回调载具未匹配到料车：reqCode={}, carrierCode={}",
                    report.getReqCode(), report.getCarrierCode());
            return new HandleResult(RcsBindRecordEntity.STATUS_UNMATCHED_CART,
                    "载具未匹配到料车：" + report.getCarrierCode());
        }

        // 纯本地同步（不回环调 RCS）
        String msg = cartInventoryService.syncExternalBind(point.getId(), cartId, bind);
        log.info("RCS绑定回调同步完成：reqCode={}, invoke={}, point={}, cart={}, result={}",
                report.getReqCode(), report.getInvoke(), point.getPointCode(), report.getCarrierCode(), msg);
        return new HandleResult(RcsBindRecordEntity.STATUS_SUCCESS,
                point.getPointCode() + " / " + report.getCarrierCode() + "：" + msg);
    }

    private RcsBindRecordEntity buildRecord(RcsBindReportDTO report) {
        RcsBindRecordEntity record = new RcsBindRecordEntity();
        record.setReqCode(report.getReqCode());
        record.setSlotCategory(report.getSlotCategory());
        record.setSlotCode(report.getSlotCode());
        record.setCarrierCategory(report.getCarrierCategory());
        record.setCarrierCode(report.getCarrierCode());
        record.setInvoke(report.getInvoke());
        record.setHandleStatus(RcsBindRecordEntity.STATUS_PROCESSING);
        record.setRawParams(JSON.toJSONString(report));
        return record;
    }

    /**
     * 更新台账处理状态（独立于库存同步事务，失败仅记日志——台账写不进去不影响同步结果）
     */
    private void updateRecordStatus(RcsBindRecordEntity record, HandleResult result) {
        try {
            rcsBindRecordMapper.update(null,
                    new LambdaUpdateWrapper<RcsBindRecordEntity>()
                            .set(RcsBindRecordEntity::getHandleStatus, result.status())
                            .set(RcsBindRecordEntity::getHandleMsg, StrUtil.subPre(result.message(), 500))
                            .set(RcsBindRecordEntity::getUpdateTime, LocalDateTime.now())
                            .eq(RcsBindRecordEntity::getId, record.getId()));
        } catch (Exception e) {
            log.error("RCS绑定回调台账状态更新失败：reqCode={}, status={}", record.getReqCode(), result.status(), e);
        }
    }

    /**
     * 处理结果（状态 + 说明），仅作内部传递
     */
    private record HandleResult(String status, String message) {
    }
}
