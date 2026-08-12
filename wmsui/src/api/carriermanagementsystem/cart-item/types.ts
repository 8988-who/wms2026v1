/**
 * CartItem 料车物品类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 料车物品查询参数 */
export interface CartItemQueryParams extends BaseQueryParams {
  cartId?: string;
  cartCode?: string;
  productCode?: string;
  productModel?: string;
  batchNo?: string;
  status?: number;
  layerNo?: number;
  operator?: string;
  loadedAtStart?: string;
  loadedAtEnd?: string;
  keyword?: string;
}

/** 料车物品表单对象 */
export interface CartItemForm {
  id?: string;
  cartId?: string;
  productCode?: string;
  productModel?: string;
  sortOrder?: number;
  batchNo?: string;
  layerNo?: number;
  operator?: string;
  remark?: string;
}

/** 料车物品列表项 */
export interface CartItemRecord {
  id?: string;
  cartId?: string;
  cartCode?: string;
  cartStatus?: number;
  productCode?: string;
  productModel?: string;
  sortOrder?: number;
  batchNo?: string;
  layerNo?: number;
  operator?: string;
  status?: number;
  loadedAt?: string;
  takenAt?: string;
  remark?: string;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}

/** 可用料车选项 */
export interface AvailableCart {
  id: string;
  cartCode: string;
  currentQuantity: number;
  status: number;
}
