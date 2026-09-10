/**
 * WmsLocation 库位/区域类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 库位/区域查询参数 */
export interface WmsLocationQueryParams extends BaseQueryParams {
  plantCode?: string;
  locationCode?: string;
  locationName?: string;
  floor?: string;
  updatedBy?: string;
  status?: number;
}

/** 库位/区域表单对象 */
export interface WmsLocationForm {
  id?: string;
  plantCode?: string;
  locationCode?: string;
  locationName?: string;
  locationType?: string;
  parentId?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
}

/** 库位/区域详情对象 */
export type WmsLocationDetail = WmsLocationItem & WmsLocationForm;

/** 库位/区域列表项 */
export interface WmsLocationItem {
  id?: string;
  plantCode?: string;
  locationCode?: string;
  locationName?: string;
  locationType?: string;
  parentId?: string;
  floor?: string;
  sortOrder?: number;
  status?: number;
  remark?: string;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}
