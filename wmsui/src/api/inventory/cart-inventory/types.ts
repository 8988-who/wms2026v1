/**
 * CartInventory 料车库存类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 料车库存查询参数 */
export interface CartInventoryQueryParams extends BaseQueryParams {
  locationId?: string;
  aisleId?: string;
  pointCode?: string;
  cartCode?: string;
  lockStatus?: number;
}

/** 料车库存列表项 */
export interface CartInventoryItem {
  pointId?: string;
  cartId?: string;
  pointCode?: string;
  pointName?: string;
  locationName?: string;
  aisleName?: string;
  cartCode?: string;
  arriveTime?: string;
  arriveQuantity?: number;
  currentQuantity?: number;
  lockStatus?: number;
  remark?: string;
  updatedByName?: string;
  updatedTime?: string;
}

/** 可用料车下拉项 */
export interface AvailableCartOption {
  id?: string;
  cartCode?: string;
  status?: number;
}

/** 可用点位下拉项 */
export interface AvailablePointOption {
  pointId?: string;
  pointCode?: string;
  pointName?: string;
  locationName?: string;
  aisleName?: string;
}

/** 区域筛选下拉项 */
export interface LocationOption {
  id?: string;
  locationName?: string;
}

/** 巷道筛选下拉项 */
export interface AisleOption {
  id?: string;
  aisleName?: string;
  locationId?: string;
}

/** 搜索筛选下拉 */
export interface CartInventoryFilterOptions {
  locations: LocationOption[];
  aisles: AisleOption[];
}
