import type { BaseQueryParams } from "@/api/common";

/** PLC配置查询参数 */
export interface PlcTaskQueryParams extends BaseQueryParams {
  id?: string;
  name?: string;
  host?: string;
  plcType?: string;
  enabled?: number;
  connected?: boolean;
  heartbeatAddr?: string;
}

export interface PlcTaskCreateForm {
  name?: string;
  host?: string;
  plcType?: string;
  heartbeatAddr?: string;
}

export interface PlcLocationOption {
  locationName: string;
  status?: number;
}

/** PLC配置列表项 */
export interface PlcTaskItem {
  id?: string;
  name?: string;
  host?: string;
  plcType?: string;
  enabled?: number;
  connected?: boolean;
  heartbeatAddr?: string;
}
