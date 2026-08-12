import type { BaseQueryParams } from "@/api/common";

export interface WmsPointQueryParams extends BaseQueryParams {
  plantCode?: string;
  pointCode?: string;
  pointName?: string;
  barcode?: string;
  coordinate?: string;
  floor?: string;
  locationCode?: string;
  aisleCode?: string;
  status?: number;
  aisleId?: string;
}

export interface WmsPointForm {
  id?: string;
  plantCode?: string;
  locationId?: string;
  aisleId?: string;
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
  id?: string;
  plantCode?: string;
  locationId?: string;
  locationCode?: string;
  locationName?: string;
  aisleId?: string;
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
  id: string;
  code: string;
  plantCode?: string;
  name: string;
  floor: string;
  label: string;
}

export interface WmsPointAisleOption {
  id: string;
  code: string;
  name: string;
  locationId: string;
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