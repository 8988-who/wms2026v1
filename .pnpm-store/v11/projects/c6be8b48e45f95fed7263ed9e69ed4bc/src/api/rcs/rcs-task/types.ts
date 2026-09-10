/**
 * RCS 任务类型定义
 *
 * 字段严格对齐后端 RcsTaskDTO / RcsTaskVO / RcsTaskQueryDTO / RcsTaskLifecycleVO。
 * 雪花 ID 一律为 string（后端全局 Long→String 序列化），前端禁止对 id 做 Number 转换。
 */

import type { BaseQueryParams } from "@/api/common";

/** RCS 任务查询参数 */
export interface RcsTaskQueryParams extends BaseQueryParams {
  /** 任务编号 */
  taskCode?: string;
  /** 任务类型（1-搬运 2-充电 3-调度 4-巡检） */
  taskType?: number;
  /** 任务状态（0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常） */
  status?: number;
  /** 优先级（1-低 2-中 3-高 4-紧急） */
  priority?: number;
  /** 执行 AGV 编号 */
  agvCode?: string;
  /** 关联料车编码 */
  cartCode?: string;
  /** 提交时间-起（yyyy-MM-dd HH:mm:ss） */
  submitTimeStart?: string;
  /** 提交时间-止（yyyy-MM-dd HH:mm:ss） */
  submitTimeEnd?: string;
}

/** RCS 任务表单对象（taskCode/状态/时间由服务端生成，不在表单） */
export interface RcsTaskForm {
  /** 任务ID（雪花，字符串） */
  id?: string;
  /** 任务类型（必填，1-搬运 2-充电 3-调度 4-巡检） */
  taskType?: number;
  /** 任务标题 */
  taskTitle?: string;
  /** 源位置编码 */
  fromLocation?: string;
  /** 目标位置编码 */
  toLocation?: string;
  /** 关联料车编码 */
  cartCode?: string;
  /** 任务扩展参数（JSON） */
  payload?: Record<string, unknown>;
  /** 优先级（1-低 2-中 3-高 4-紧急） */
  priority?: number;
  /** 备注 */
  remark?: string;
}

/** RCS 任务状态变更记录（详情时间线） */
export interface RcsTaskLifecycle {
  /** 记录ID */
  id?: string;
  /** 关联任务ID */
  taskId?: string;
  /** 变更前状态 */
  statusFrom?: number;
  /** 变更前状态描述 */
  statusFromLabel?: string;
  /** 变更后状态 */
  statusTo?: number;
  /** 变更后状态描述 */
  statusToLabel?: string;
  /** 操作者类型（SYSTEM/ADMIN/AGV/EXTERNAL） */
  operatorType?: string;
  /** 操作者标识 */
  operatorId?: string;
  /** 变更备注 */
  remark?: string;
  /** 变更时间 */
  createTime?: string;
}

/** RCS 任务列表项 / 详情项（详情额外带 lifecycles 时间线） */
export interface RcsTaskItem {
  /** 任务ID（雪花，字符串） */
  id?: string;
  /** 任务编号 */
  taskCode?: string;
  /** 任务类型 */
  taskType?: number;
  /** 任务类型描述 */
  taskTypeLabel?: string;
  /** 任务标题 */
  taskTitle?: string;
  /** 源位置编码 */
  fromLocation?: string;
  /** 目标位置编码 */
  toLocation?: string;
  /** 关联料车编码 */
  cartCode?: string;
  /** 任务扩展参数（JSON） */
  payload?: Record<string, unknown>;
  /** 任务状态 */
  status?: number;
  /** 任务状态描述 */
  statusLabel?: string;
  /** 优先级 */
  priority?: number;
  /** 优先级描述 */
  priorityLabel?: string;
  /** 执行 AGV 编号 */
  agvCode?: string;
  /** RCS 系统任务ID */
  rcsTaskId?: string;
  /** 提交时间 */
  submitTime?: string;
  /** 派发时间 */
  assignedAt?: string;
  /** 开始执行时间 */
  startTime?: string;
  /** 完成时间 */
  finishTime?: string;
  /** 异常信息 */
  errorMsg?: string;
  /** 备注 */
  remark?: string;
  /** 创建人 */
  createdByName?: string;
  /** 创建时间 */
  createdTime?: string;
  /** 更新人 */
  updatedByName?: string;
  /** 更新时间 */
  updatedTime?: string;
  /** 状态变更历史（时间线，详情专用，按变更时间升序） */
  lifecycles?: RcsTaskLifecycle[];
}
