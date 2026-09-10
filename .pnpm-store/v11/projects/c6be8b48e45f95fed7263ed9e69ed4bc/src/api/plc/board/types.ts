import type { BaseQueryParams } from "@/api/common";

/** PLC板块配置查询参数 */
export interface PlcBoardQueryParams extends BaseQueryParams {
  id?: string;
  plcId?: string;
  plcAddress?: string;
  description?: string;
  enabled?: number;
}

/** PLC板块配置列表项 */
export interface PlcBoardItem {
  id?: string;
  plcId?: string;
  plcAddress?: string;
  description?: string;
  pointId?: string;
  enabled?: number;
}

export interface PlcBoardCreateForm {
  plcId?: string;
  plcAddress?: string;
  description?: string;
  pointId?: string;
}

export interface PlcConnectionOption {
  id: string;
  host: string;
}

/** 储位（点位）下拉选项 */
export interface PlcPointOption {
  id: string;
  pointName: string;
}
