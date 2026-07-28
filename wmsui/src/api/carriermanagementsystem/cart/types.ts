/**
 * Cart 料车类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 料车查询参数 */
export interface CartQueryParams extends BaseQueryParams {
  keyword?: string;
  status?: number;
  modelId?: number;
  area?: string;
}

/** 料车表单对象 */
export interface CartForm {
  id?: number;
  cartCode?: string;
  modelId?: number;
  area?: string;
  bindWorker?: string;
  actualCapacity?: number;
}

/** 料车列表项 */
export interface CartItem {
  id?: number;
  cartCode?: string;
  modelId?: number;
  modelCode?: string;
  modelName?: string;
  maxCapacity?: number;
  currentQuantity?: number;
  status?: number;
  area?: string;
  bindWorker?: string;
  actualCapacity?: number;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}

/** 型号下拉选项 */
export interface CartModelOption {
  id: number;
  modelCode: string;
  modelName: string;
  maxCapacity: number;
}
