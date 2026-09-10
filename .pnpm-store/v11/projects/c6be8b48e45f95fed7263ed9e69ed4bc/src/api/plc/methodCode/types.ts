import type { BaseQueryParams } from "@/api/common";

/** 信号值方法配置查询参数 */
export interface PlcMethodCodeQueryParams extends BaseQueryParams {
  /** id */
  id?: string;
  /** 信号块id */
  signalId?: string;
  /** 信号值 */
  signalCode?: string;
  /** 方法id */
  methodId?: string;
}

/** 信号值方法配置列表项 */
export interface PlcMethodCodeItem {
  /** id */
  id?: string;
  /** 信号块id */
  signalId?: string;
  /** 信号值 */
  signalCode?: string;
  /** 方法id */
  methodId?: string;
}

/** 信号值方法配置新增表单 */
export interface PlcMethodCodeCreateForm {
  /** 信号块配置ID(t_plc_signal_config.id) */
  signalId: string;
  /** 信号值 */
  signalCode: string;
  /** 方法ID(t_task_method_name.id) */
  methodId: string;
}

/** 下拉选项 */
export interface PlcMethodCodeOption {
  /** 实际值 */
  value: string;
  /** 展示文本 */
  label: string;
}
