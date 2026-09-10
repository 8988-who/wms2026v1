import type { BaseQueryParams } from "@/api/common";

/** 方法名配置查询参数 */
export interface PlcTaskNameQueryParams extends BaseQueryParams {
  /** id */
  id?: string;
  /** 方法名 */
  methodName?: string;
  /** 方法描述 */
  methodDescription?: string;
}

/** 方法名配置列表项 */
export interface PlcTaskNameItem {
  /** id */
  id?: string;
  /** 方法名 */
  methodName?: string;
  /** 方法描述 */
  methodDescription?: string;
}

/** 方法名配置新增表单 */
export interface PlcTaskNameCreateForm {
  /** 方法名 */
  methodName: string;
  /** 方法描述 */
  methodDescription: string;
}
