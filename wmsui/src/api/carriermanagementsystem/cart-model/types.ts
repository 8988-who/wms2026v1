/**
 * CartModel 料车型号类型定义
 */

import type { BaseQueryParams } from "@/api/common";

/** 料车型号查询参数 */
export interface CartModelQueryParams extends BaseQueryParams {
  modelCode?: string;
  modelName?: string;
  keyword?: string;
}

/** 料车型号表单对象 */
export interface CartModelForm {
  id?: number;
  modelCode?: string;
  modelName?: string;
  maxCapacity?: number;
  layerCount?: number;
  remark?: string;
}

/** 料车型号列表项 */
export interface CartModelItem {
  id?: number;
  modelCode?: string;
  modelName?: string;
  maxCapacity?: number;
  layerCount?: number;
  remark?: string;
  cartCount?: number;
  createdByName?: string;
  createdTime?: string;
  updatedByName?: string;
  updatedTime?: string;
}
