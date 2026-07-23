import type { BaseQueryParams } from "@/api/common";

export interface WmsPointQueryParams extends BaseQueryParams {
  plantCode?: string;
  pointCode?: string;
  pointName?: string;
  floor?: string;
  status?: number;
  aisleId?: number;
}

export interface WmsPointForm {
  id?: number;
  plantCode?: string;
  locationId?: number;
  aisleId?: number;
  pointCode?: string;
  pointName?: string;
  barcode?: string;
  coordinate?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
}

export interface WmsPointItem {
  id?: number;
  plantCode?: string;
  locationId?: number;
  locationCode?: string;
  locationName?: string;
  aisleId?: number;
  aisleCode?: string;
  aisleName?: string;
  pointCode?: string;
  pointName?: string;
  barcode?: string;
  coordinate?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}

export interface WmsPointLocationOption {
  id: number;
  code: string;
  name: string;
  floor: string;
  label: string;
}

export interface WmsPointAisleOption {
  id: number;
  code: string;
  name: string;
  locationId: number;
  label: string;
}

export interface WmsPointFormOptions {
  plantCodes: string[];
  locations: WmsPointLocationOption[];
  aisles: WmsPointAisleOption[];
}

/** 批量状态更新表单 */
export interface WmsPointBatchStatusForm {
  ids: number[];
  status: number;
}