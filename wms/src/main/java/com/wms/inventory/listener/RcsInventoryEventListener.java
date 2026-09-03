package com.wms.inventory.listener;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.inventory.mapper.CartInventoryMapper;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.service.CartInventoryService;
import com.wms.rcs.event.RcsTaskInventoryEvent;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

/**
 * RCS 任务库存闭环监听器
 * <p>
 * 监听 {@link RcsTaskInventoryEvent}（RCS 模块在任务状态流转关键时点发布），驱动料车-点位绑定关系。
 * 库存表 remark 列作为"任务占用锁"：'1'=该点被任务锁定（如料车在途时锁起点/终点），'0'=默认。
 * <ul>
 *     <li>MARK_TASK：任务下发成功，把料车所在起点标记为所属任务（写 last_task_code）；</li>
 *     <li>PRE_BIND：任务锁定点位（remark='1'）；</li>
 *     <li>UNBIND：料车离开点位，清该点料车绑定（不动 remark）；</li>
 *     <li>RELEASE：任务终结解除点位占用锁（remark='0'，绝不动料车绑定）；</li>
 *     <li>CLEAR_TASK：任务终结清除该点预定任务编码（last_task_code=NULL）；</li>
 *     <li>CONFIRM_ARRIVE：任务完成确认目标点位到达，终绑料车。</li>
 * </ul>
 * <p>
 * 在发布方事务提交后（AFTER_COMMIT）同步执行。RCS 回调已代表 RCS 侧完成解绑/绑定，
 * 本监听器仅镜像本地（零 RCS 调用），避免回环与重复调用失败。
 * 回调线程无登录上下文，updateBy 为 null 属预期（系统驱动）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-26
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RcsInventoryEventListener {

    private final CartInventoryService cartInventoryService;
    private final CartInventoryMapper cartInventoryMapper;

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onRcsTaskInventoryEvent(RcsTaskInventoryEvent event) {
        if (event == null || event.getAction() == null) {
            return;
        }
        try {
            switch (event.getAction()) {
                case MARK_TASK -> handleMarkTask(event);
                case PRE_BIND -> handlePreBind(event);
                case UNBIND -> handleUnbind(event);
                case RELEASE -> handleRelease(event);
                case CLEAR_TASK -> handleClearTask(event);
                case CONFIRM_ARRIVE -> handleConfirmArrive(event);
            }
        } catch (Exception e) {
            log.error("RCS任务库存闭环执行失败：action={}, cartCode={}, locationCode={}",
                    event.getAction(), event.getCartCode(), event.getLocationCode(), e);
        }
    }

    /**
     * 任务下发成功：把料车所在起点标记为所属任务（写 last_task_code=taskCode）
     */
    private void handleMarkTask(RcsTaskInventoryEvent event) {
        if (StrUtil.isBlank(event.getTaskCode())) {
            log.warn("RCS任务预占标记跳过：缺少任务编码，locationCode={}", event.getLocationCode());
            return;
        }
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务预占标记失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.markPointTask(pointId, event.getTaskCode());
        log.info("RCS任务预占标记成功（last_task_code）：pointId={}, taskCode={}", pointId, event.getTaskCode());
    }

    /**
     * 任务终结：清除该点预定任务编码（last_task_code=NULL，按 taskCode 守卫幂等，绝不误清新任务的标记）
     */
    private void handleClearTask(RcsTaskInventoryEvent event) {
        if (StrUtil.isBlank(event.getTaskCode())) {
            return;
        }
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务预占清除失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.clearPointTask(pointId, event.getTaskCode());
        log.info("RCS任务预占清除成功（last_task_code=NULL）：pointId={}, taskCode={}", pointId, event.getTaskCode());
    }

    /**
     * 任务锁定点位（remark='1'，如机器人离开起点后锁起点/终点；仅空车未锁的点位可锁）
     */
    private void handlePreBind(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务锁定失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.reservePoint(pointId);
        log.info("RCS任务锁定成功（remark=1）：pointId={}, cartCode={}", pointId, event.getCartCode());
    }

    /**
     * 料车离开点位（AGV 取货/随行在途）：清该点料车绑定，不动 remark。
     * <p>幂等核对：仅当点位当前占用的是本事件料车时才清——已无车或点位被其他料车占有时跳过，避免误清。
     * 点位任务锁的解除走 RELEASE，不在此处理。</p>
     */
    private void handleUnbind(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务解绑失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        CartInventory inv = cartInventoryMapper.selectOne(
                new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, pointId));
        if (inv == null || inv.getCartId() == null) {
            // 点位已无料车占用（此前已解绑 / 料车从未停该点）：幂等跳过，不视为异常
            log.info("RCS任务解绑跳过：点位无料车占用，pointId={}", pointId);
            return;
        }
        String currentCartCode = cartInventoryMapper.selectCartCodeByCartId(inv.getCartId());
        if (event.getCartCode() != null && !event.getCartCode().equals(currentCartCode)) {
            // 点位当前被其他料车占用：绝不误解绑
            log.warn("RCS任务解绑跳过：点位被其他料车占用，pointId={}, currentCartCode={}, eventCartCode={}",
                    pointId, currentCartCode, event.getCartCode());
            return;
        }
        String result = cartInventoryService.syncExternalBind(pointId, inv.getCartId(), false);
        log.info("RCS任务解绑成功（本地镜像）：pointId={}, result={}", pointId, result);
    }

    /**
     * 解除点位任务占用锁（remark='0'，任务完成/取消/异常时释放；幂等，绝不动料车绑定）
     */
    private void handleRelease(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务解锁失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.releasePoint(pointId);
        log.info("RCS任务解锁成功（remark=0）：pointId={}, cartCode={}", pointId, event.getCartCode());
    }

    /**
     * 确认目标点位到达（本地镜像，零 RCS 调用）：终绑料车（写 cart_id/arrive_time）。
     * <p>料车到达前目标点可能仅带任务锁（remark=1）而无料车，此时按事件料车反查后直接绑定；
     * 若目标点已被其他料车占用则跳过（防错绑），绝不误解。</p>
     */
    private void handleConfirmArrive(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务确认到达失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        CartInventory inv = cartInventoryMapper.selectOne(
                new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, pointId));
        if (inv != null && inv.getCartId() != null) {
            String currentCartCode = cartInventoryMapper.selectCartCodeByCartId(inv.getCartId());
            if (event.getCartCode() != null && !event.getCartCode().equals(currentCartCode)) {
                // 目标点已被其他料车占用：绝不覆盖
                log.warn("RCS任务确认到达跳过：点位被其他料车占用，pointId={}, currentCartCode={}, eventCartCode={}",
                        pointId, currentCartCode, event.getCartCode());
                return;
            }
            // 目标点已是本车（如 RCS 回环先写入）：幂等补写到达时间
            String existed = cartInventoryService.syncExternalBind(pointId, inv.getCartId(), true);
            log.info("RCS任务确认到达幂等补写：pointId={}, result={}", pointId, existed);
            return;
        }
        // 目标点空位（可能带任务锁 remark=1）：按事件料车反查后终绑到达
        Long cartId = cartInventoryMapper.selectCartIdByCartCode(event.getCartCode());
        if (cartId == null) {
            log.warn("RCS任务确认到达失败：料车编码无法反查ID，cartCode={}", event.getCartCode());
            return;
        }
        String result = cartInventoryService.syncExternalBind(pointId, cartId, true);
        log.info("RCS任务确认到达成功（本地镜像）：pointId={}, result={}", pointId, result);
    }
}
