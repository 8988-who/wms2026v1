import request from "@/utils/request";
import type { CartForm, CartItem, CartModelOption, CartQueryParams } from "./types";
import type { PageResult } from "@/api/common";

export type { CartForm, CartItem, CartModelOption, CartQueryParams } from "./types";

const CART_BASE_URL = "/api/v1/cart";

const CartAPI = {
  /** 获取料车分页数据 */
  getPage(queryParams?: CartQueryParams) {
    return request<unknown, PageResult<CartItem>>({
      url: `${CART_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取料车表单数据 */
  getFormData(id: string) {
    return request<unknown, CartForm>({
      url: `${CART_BASE_URL}/${id}/form`,
      method: "get",
    });
  },
  /** 新增料车 */
  create(data: CartForm) {
    return request({
      url: `${CART_BASE_URL}`,
      method: "post",
      data,
    });
  },
  /** 更新料车 */
  update(id: string, data: CartForm) {
    return request({
      url: `${CART_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  /** 批量删除料车 */
  deleteByIds(ids: string) {
    return request({
      url: `${CART_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  /** 批量修改料车状态 */
  batchUpdateStatus(ids: number[], status: number) {
    return request({
      url: `${CART_BASE_URL}/batch-status`,
      method: "put",
      params: { status },
      data: ids,
    });
  },
  /** 获取表单下拉选项（型号列表） */
  getFormOptions() {
    return request<unknown, CartModelOption[]>({
      url: `${CART_BASE_URL}/form-options`,
      method: "get",
    });
  },
  /** 获取筛选下拉选项（型号列表） */
  getFilterOptions() {
    return request<unknown, CartModelOption[]>({
      url: `${CART_BASE_URL}/filter-options`,
      method: "get",
    });
  },
  /** 获取区域列表（筛选下拉） */
  getAreas() {
    return request<unknown, string[]>({
      url: `${CART_BASE_URL}/areas`,
      method: "get",
    });
  },
  /** 获取可用料车列表 */
  getAvailableCarts() {
    return request({
      url: `${CART_BASE_URL}/available`,
      method: "get",
    });
  },
};

export default CartAPI;
