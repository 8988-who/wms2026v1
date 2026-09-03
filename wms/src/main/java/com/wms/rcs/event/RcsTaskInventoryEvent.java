package com.wms.rcs.event;

import lombok.Getter;

/**
 * RCS 任务库存闭环事件
 * <p>
 * RCS 模块在任务状态流转的关键时点发布，由业务模块（inventory）监听并驱动料车-点位绑定关系。
 * 库存表以 remark 列作为"任务占用锁"（'1'=该点被某任务锁定/预占，'0'=默认），料车到达后才写 cart_id。
 * <ul>
 *     <li>{@link Action#MARK_TASK}：任务下发成功（ASSIGNED），把料车所在起点标记为所属任务（写 last_task_code）；</li>
 *     <li>{@link Action#PRE_BIND}：任务锁定某点位（remark='1'），如机器人离开起点后锁起点/终点；</li>
 *     <li>{@link Action#UNBIND}：料车离开某点位（AGV 取货/随行在途），清该点料车绑定，不动 remark；</li>
 *     <li>{@link Action#RELEASE}：任务终结（完成/取消/异常）解除某点位占用锁（remark='0'），绝不动料车绑定；</li>
 *     <li>{@link Action#CLEAR_TASK}：任务终结（完成/取消/异常）清除该点预定任务编码（last_task_code=NULL），随 RELEASE 一并发布；</li>
 *     <li>{@link Action#CONFIRM_ARRIVE}：任务完成（FINISHED）后确认目标点位到达，终绑料车（写 cart_id/arrive_time）。</li>
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
        /** 任务下发成功：预占记录料车所在起点所属任务（写 last_task_code），料车仍停在起点 */
        MARK_TASK,
        /** 任务锁定点位（remark='1'，要求空车未锁） */
        PRE_BIND,
        /** 料车离开点位（清该点 cart_id/arrive_time，不动 remark） */
        UNBIND,
        /** 解除点位任务占用锁（remark='0'，绝不动料车绑定） */
        RELEASE,
        /** 任务终结：清除该点预定任务编码（last_task_code=NULL，按 taskCode 守卫幂等） */
        CLEAR_TASK,
        /** 确认目标点位到达（任务完成，终绑料车） */
        CONFIRM_ARRIVE
    }

    /** 联动动作 */
    private final Action action;

    /** 关联料车编码（wms_cart.cart_code） */
    private final String cartCode;

    /** 关联点位编码（wms_cart_inventory.point_code；MARK_TASK/PRE_BIND/CONFIRM_ARRIVE 按发布方语义，UNBIND/RELEASE/CLEAR_TASK 按发布方语义） */
    private final String locationCode;

    /** 关联任务编码（wms_rcs_task.task_code；MARK_TASK 写入 / CLEAR_TASK 守卫清除，可为空） */
    private final String taskCode;

    public RcsTaskInventoryEvent(Action action, String cartCode, String locationCode) {
        this(action, cartCode, locationCode, null);
    }

    public RcsTaskInventoryEvent(Action action, String cartCode, String locationCode, String taskCode) {
        this.action = action;
        this.cartCode = cartCode;
        this.locationCode = locationCode;
        this.taskCode = taskCode;
    }

    public static RcsTaskInventoryEvent of(Action action, String cartCode, String locationCode) {
        return new RcsTaskInventoryEvent(action, cartCode, locationCode, null);
    }

    public static RcsTaskInventoryEvent of(Action action, String cartCode, String locationCode, String taskCode) {
        return new RcsTaskInventoryEvent(action, cartCode, locationCode, taskCode);
    }
}
