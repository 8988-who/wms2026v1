/**
 * WmsAisle 巷道类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 巷道查询参数 */
export interface WmsAisleQueryParams extends BaseQueryParams {
  plantCode?: string;
  aisleCode?: string;
  aisleName?: string;
  floor?: string;
  locationCode?: string;
  aislePurpose?: string;
  status?: number;
}

/** 巷道表单对象 */
export interface WmsAisleForm {
  id?: number;
  plantCode?: string;
  locationId?: number;
  aisleCode?: string;
  aisleName?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
  aislePurpose?: string;
  isHandoverPoint?: number;
}

/** 巷道列表项 */
export interface WmsAisleItem {
  id?: number;
  plantCode?: string;
  locationId?: number;
  locationCode?: string;
  aisleCode?: string;
  aisleName?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
  aislePurpose?: string;
  isHandoverPoint?: number;
  pointCount?: number;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}

/** 区域下拉选项 */
export interface WmsAisleLocationOption {
  id: number;
  code: string;
  name: string;
  floor: string;
  label: string;
}

/** 表单下拉选项 */
export interface WmsAisleFormOptions {
  plantCodes: string[];
  locations: WmsAisleLocationOption[];
}
