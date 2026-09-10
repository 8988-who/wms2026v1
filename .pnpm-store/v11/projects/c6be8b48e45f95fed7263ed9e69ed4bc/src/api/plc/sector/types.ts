import type { BaseQueryParams } from "@/api/common";

/** PLC信号块读写信号配置查询参数 */
export interface PlcSectorSignalsQueryParams extends BaseQueryParams {
  /** id */
  id?: string;
  /** 信号类型: 1=货架号 2=产品条码 3=产品型号 */
  signalType?: number;
  /** 信号地址 */
  signalAddress?: string;
  /** 信号描述 */
  signalDescription?: string;
  /** 信号ID */
  signalId?: string;
}

/** PLC信号块读写信号配置列表项 */
export interface PlcSectorSignalsItem {
  /** id */
  id?: string;
  /** 信号类型: 1=货架号 2=产品条码 3=产品型号 */
  signalType?: number;
  /** 排序号 */
  number?: number;
  /** 信号地址 */
  signalAddress?: string;
  /** 信号描述 */
  signalDescription?: string;
  /** 信号ID */
  signalId?: string;
}

/** 信号块下拉选项 */
export interface SignalBlockOption {
  /** 信号块配置ID */
  value: string;
  /** 展示文本: host,信号块地址 */
  label: string;
}

/** PLC信号块读写信号配置新增表单 */
export interface PlcSectorSignalsCreateForm {
  /** 信号类型: 1=货架号 2=产品条码 3=产品型号 */
  signalType?: number;
  /** 排序号，信号类型为1时可空，其余必填 */
  number?: number;
  /** 信号地址 */
  signalAddress?: string;
  /** 信号描述 */
  signalDescription?: string;
  /** 信号块配置ID(t_plc_signal_config.id) */
  signalId?: string;
}
