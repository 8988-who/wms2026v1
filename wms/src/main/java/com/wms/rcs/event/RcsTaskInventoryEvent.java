package com.wms.rcs.event;

import lombok.Getter;

/**
 * RCS 任务库存闭环事件
 * <p>
 * RCS 模块在任务状态流转的关键时点发布，由业务模块（inventory）监听并驱动料车-点位绑定关系：
 * <ul>
 *     <li>{@link Action#PRE_BIND}：任务下发成功后预占目标点位（车未到，仅本地预占）；</li>
 *     <li>{@link Action#UNBIND}：AGV 取货（PICK）后解绑源点位，或任务取消/异常终结时释放目标点位预占；</li>
 *     <li>{@link Action#CONFIRM_ARRIVE}：任务完成（FINISHED）后确认目标点位到达（同步 RCS 绑定）。</li>
 * </ul>
 * 事件仅携带编码（cartCode/locationCode），ID 反查与库存操作由监听器在 inventory 模块内完成，
 * 保持 rcs 模块不反向依赖业务模块的分层约束。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-26
 */
@Getter
public class RcsTaskInventoryEvent {

    /** 库存联动动作 */
    public enum Action {
        /** 预占目标点位（任务下发成功） */
        PRE_BIND,
        /** 解绑点位（取货后的源点位，或取消时释放预占的目标点位） */
        UNBIND,
        /** 确认目标点位到达（任务完成） */
        CONFIRM_ARRIVE
    }

    /** 联动动作 */
    private final Action action;

    /** 关联料车编码（wms_cart.cart_code） */
    private final String cartCode;

    /** 关联点位编码（wms_cart_inventory.point_code；PRE_BIND/CONFIRM_ARRIVE 为目标点位，UNBIND 按发布方语义） */
    private final String locationCode;

    public RcsTaskInventoryEvent(Action action, String cartCode, String locationCode) {
        this.action = action;
        this.cartCode = cartCode;
        this.locationCode = locationCode;
    }

    public static RcsTaskInventoryEvent of(Action action, String cartCode, String locationCode) {
        return new RcsTaskInventoryEvent(action, cartCode, locationCode);
    }
}
