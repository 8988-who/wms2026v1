import request from "@/utils/request";
import type { CartModelForm, CartModelQueryParams, CartModelItem } from "./types";
import type { PageResult } from "@/api/common";

export type { CartModelForm, CartModelQueryParams, CartModelItem } from "./types";

const CART_MODEL_BASE_URL = "/api/v1/cart-model";

const CartModelAPI = {
  /** 获取料车型号分页数据 */
  getPage(queryParams?: CartModelQueryParams) {
    return request<unknown, PageResult<CartModelItem>>({
      url: `${CART_MODEL_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取料车型号表单数据 */
  getFormData(id: string) {
    return request<unknown, CartModelForm>({
      url: `${CART_MODEL_BASE_URL}/${id}/form`,
      method: "get",
    });
  },
  /** 新增料车型号 */
  create(data: CartModelForm) {
    return request({
      url: `${CART_MODEL_BASE_URL}`,
      method: "post",
      data,
    });
  },
  /** 更新料车型号 */
  update(id: string, data: CartModelForm) {
    return request({
      url: `${CART_MODEL_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  /** 批量删除料车型号 */
  deleteByIds(ids: string) {
    return request({
      url: `${CART_MODEL_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  /** 获取表单下拉选项 */
  getFormOptions() {
    return request<unknown, CartModelItem[]>({
      url: `${CART_MODEL_BASE_URL}/form-options`,
      method: "get",
    });
  },
  /** 获取搜索筛选下拉选项 */
  getFilterOptions() {
    return request<unknown, CartModelItem[]>({
      url: `${CART_MODEL_BASE_URL}/filter-options`,
      method: "get",
    });
  },
};

export default CartModelAPI;
