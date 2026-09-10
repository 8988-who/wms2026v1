/**
 * RCS 任务创建表单相关常量
 *
 * 设计依据：开发文档V1/新增功能文档/RCS任务创建表单优化设计.md（v3，搬运主场景）
 * 只服务「搬运货物」主场景，只依赖 AGV_submitTask 一个接口。
 */

/** 任务类型（1-搬运 2-充电 3-调度 4-巡检） */
export const TASK_TYPE_OPTIONS = [
  { value: 1, label: "搬运" },
  { value: 2, label: "充电" },
  { value: 3, label: "调度" },
  { value: 4, label: "巡检" },
];

/** 任务状态（0-待执行 1-已派发 2-执行中 3-已完成 4-已取消 5-异常） */
export const STATUS_OPTIONS = [
  { value: 0, label: "待执行" },
  { value: 1, label: "已派发" },
  { value: 2, label: "执行中" },
  { value: 3, label: "已完成" },
  { value: 4, label: "已取消" },
  { value: 5, label: "异常" },
];

/** 优先级（1-低 2-中 3-高 4-紧急） */
export const PRIORITY_OPTIONS = [
  { value: 1, label: "低" },
  { value: 2, label: "中" },
  { value: 3, label: "高" },
  { value: 4, label: "紧急" },
];

/**
 * targetRoute 步骤目标类型枚举
 *
 * ⚠️ TODO（待确认项 1）：PICK_SITE / DELIVERY_SITE 为占位值，落地前须按 RCS 对接文档
 * 校正为真实枚举。映射逻辑集中在本文件，改此处即改全局。
 */
export const ROUTE_SITE_TYPE = {
  /** 取货点位类型 */
  PICK: "PICK_SITE",
  /** 送货点位类型 */
  DELIVERY: "DELIVERY_SITE",
} as const;

/** targetRoute 步骤操作枚举（AgvSubmitTaskDTO：COLLECT 取货 / DELIVERY 送货 / ROTATE 旋转） */
export const ROUTE_OPERATION = {
  COLLECT: "COLLECT",
  DELIVERY: "DELIVERY",
  ROTATE: "ROTATE",
} as const;

/** targetRoute 单步结构 */
export interface RouteStep {
  /** 目标类型（见 ROUTE_SITE_TYPE） */
  type: string;
  /** 目标点位编码 */
  code: string;
  /** 操作（见 ROUTE_OPERATION） */
  operation: string;
}

/**
 * 由「源位置 / 目标位置」自动生成 targetRoute（搬运主场景：源取货 → 目标送货）
 *
 * @param fromLocation 源位置编码
 * @param toLocation 目标位置编码
 * @returns 步骤列表；两个位置均为空时返回空数组
 */
export function buildTargetRoute(fromLocation?: string, toLocation?: string): RouteStep[] {
  const steps: RouteStep[] = [];
  if (fromLocation) {
    steps.push({ type: ROUTE_SITE_TYPE.PICK, code: fromLocation, operation: ROUTE_OPERATION.COLLECT });
  }
  if (toLocation) {
    steps.push({ type: ROUTE_SITE_TYPE.DELIVERY, code: toLocation, operation: ROUTE_OPERATION.DELIVERY });
  }
  return steps;
}

/**
 * 从 targetRoute 反推源/目标位置（编辑回显用）
 *
 * @param route targetRoute 步骤列表
 * @returns { fromLocation, toLocation }
 */
export function parseTargetRoute(route?: unknown): { fromLocation?: string; toLocation?: string } {
  const result: { fromLocation?: string; toLocation?: string } = {};
  if (!Array.isArray(route)) return result;
  for (const step of route as RouteStep[]) {
    if (step?.operation === ROUTE_OPERATION.COLLECT && step.code) {
      result.fromLocation = step.code;
    } else if (step?.operation === ROUTE_OPERATION.DELIVERY && step.code) {
      result.toLocation = step.code;
    }
  }
  return result;
}

/** 高级选项字段类型定义 */
export interface AdvancedField {
  /** payload 中的参数名（下发时平铺给 RCS） */
  key: string;
  /** 界面标签 */
  label: string;
  /** 控件类型 */
  type: "number" | "datetime" | "select" | "multiselect" | "switch" | "text";
  /** select / multiselect 选项 */
  options?: { label: string; value: string | number }[];
  /** 输入占位/说明 */
  placeholder?: string;
  /** el-input-number 范围 */
  min?: number;
  max?: number;
}

/**
 * 高级选项字段（对应 AgvSubmitTaskDTO 其余可选字段，搬运场景默认缺省）
 *
 * ⚠️ robotCode 车号列表来源待确认（待确认项 2），暂用自由输入 multiselect（allow-create）。
 */
export const ADVANCED_FIELDS: AdvancedField[] = [
  { key: "initPriority", label: "初始优先级", type: "number", min: 1, max: 120, placeholder: "1~120，越大越优先，缺省即可" },
  { key: "deadline", label: "截止时间", type: "datetime", placeholder: "任务截止时间" },
  {
    key: "robotType",
    label: "机器人范围",
    type: "select",
    options: [
      { label: "资源组 GROUPS", value: "GROUPS" },
      { label: "指定车号 ROBOTS", value: "ROBOTS" },
    ],
    placeholder: "默认资源组",
  },
  { key: "robotCode", label: "指定车号", type: "multiselect", placeholder: "输入车号回车，可多个" },
  { key: "interrupt", label: "可打断", type: "switch" },
  { key: "groupCode", label: "任务组编号", type: "text", placeholder: "可缺省" },
];

/** extra 扩展对象已知键（未知键仍可自由输入） */
export const EXTRA_KNOWN_KEYS = ["angleInfo", "carrierInfo", "crossVisionDoor", "pickStationCode"];
