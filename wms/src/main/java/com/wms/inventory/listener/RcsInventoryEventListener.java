package com.wms.inventory.listener;

import com.wms.inventory.mapper.CartInventoryMapper;
import com.wms.inventory.model.dto.CartInventoryBindDTO;
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
 * 监听 {@link RcsTaskInventoryEvent}（RCS 模块在任务状态流转关键时点发布），驱动料车-点位绑定关系：
 * <ul>
 *     <li>PRE_BIND：任务下发成功 → 预占目标点位（车未到）；</li>
 *     <li>UNBIND：AGV 取货后解绑源点位，或任务取消/异常终结时释放目标点位预占；</li>
 *     <li>CONFIRM_ARRIVE：任务完成 → 确认目标点位到达（内部同步 RCS 绑定）。</li>
 * </ul>
 * <p>
 * 在发布方事务提交后（AFTER_COMMIT）同步执行，保证 RCS 远程调用处于事务外；
 * 库存操作失败仅记录日志不向上抛出，避免影响 RCS 回调主链路（任务状态已正确流转，库存不一致靠日志/对账兜底）。
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
                case PRE_BIND -> handlePreBind(event);
                case UNBIND -> handleUnbind(event);
                case CONFIRM_ARRIVE -> handleConfirmArrive(event);
            }
        } catch (Exception e) {
            log.error("RCS任务库存闭环执行失败：action={}, cartCode={}, locationCode={}",
                    event.getAction(), event.getCartCode(), event.getLocationCode(), e);
        }
    }

    /**
     * 预占目标点位（需料车编码 + 点位编码均可反查）
     */
    private void handlePreBind(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        Long cartId = cartInventoryMapper.selectCartIdByCartCode(event.getCartCode());
        if (pointId == null || cartId == null) {
            log.warn("RCS任务预占失败：料车或点位编码无法反查ID，cartCode={}, locationCode={}",
                    event.getCartCode(), event.getLocationCode());
            return;
        }
        CartInventoryBindDTO dto = new CartInventoryBindDTO();
        dto.setPointId(pointId);
        dto.setCartId(cartId);
        cartInventoryService.preBind(dto);
        log.info("RCS任务预占成功：cartId={}, pointId={}", cartId, pointId);
    }

    /**
     * 解绑点位（源点位取货后 / 目标点位取消释放预占）
     */
    private void handleUnbind(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务解绑失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.unbind(pointId);
        log.info("RCS任务解绑成功：pointId={}", pointId);
    }

    /**
     * 确认目标点位到达（同步 RCS 绑定）
     */
    private void handleConfirmArrive(RcsTaskInventoryEvent event) {
        Long pointId = cartInventoryMapper.selectPointIdByPointCode(event.getLocationCode());
        if (pointId == null) {
            log.warn("RCS任务确认到达失败：点位编码无法反查ID，locationCode={}", event.getLocationCode());
            return;
        }
        cartInventoryService.confirmArrive(pointId);
        log.info("RCS任务确认到达成功：pointId={}", pointId);
    }
}
