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
  modelCode?: string;
  status?: number;
}

/** 巷道表单对象 */
export interface WmsAisleForm {
  id?: string;
  plantCode?: string;
  locationId?: string;
  aisleCode?: string;
  aisleName?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  modelCode?: string;
  aislePurpose?: string;
  isHandoverPoint?: number;
}

/** 巷道列表项 */
export interface WmsAisleItem {
  id?: string;
  plantCode?: string;
  locationId?: string;
  locationCode?: string;
  aisleCode?: string;
  aisleName?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  modelCode?: string;
  modelName?: string;
  aislePurpose?: string;
  isHandoverPoint?: number;
  pointCount?: number;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}

/** 货架型号下拉选项（来自料车型号配置） */
export interface WmsAisleModelOption {
  modelCode: string;
  modelName: string;
  label: string;
}

/** 区域下拉选项 */
export interface WmsAisleLocationOption {
  id: string;
  code: string;
  plantCode?: string;
  name: string;
  floor: string;
  label: string;
}

/** 表单下拉选项 */
export interface WmsAisleFormOptions {
  plantCodes: string[];
  locations: WmsAisleLocationOption[];
  modelOptions: WmsAisleModelOption[];
}

/** 搜索筛选下拉选项 */
export interface WmsAisleFilterOptions {
  aisleCodes: string[];
  locationCodes: string[];
  modelOptions: WmsAisleModelOption[];
}
