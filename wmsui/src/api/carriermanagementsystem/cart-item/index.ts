import request from "@/utils/request";
import type {
  AvailableCart,
  CartItemForm,
  CartItemQueryParams,
  CartItemRecord,
} from "./types";
import type { PageResult } from "@/api/common";

export type {
  AvailableCart,
  CartItemForm,
  CartItemQueryParams,
  CartItemRecord,
} from "./types";

const CART_ITEM_BASE_URL = "/api/v1/cart-item";

const CartItemAPI = {
  /** 获取分页数据 */
  getPage(queryParams?: CartItemQueryParams) {
    return request<unknown, PageResult<CartItemRecord>>({
      url: `${CART_ITEM_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 装车（新增） */
  create(data: CartItemForm) {
    return request({
      url: `${CART_ITEM_BASE_URL}`,
      method: "post",
      data,
    });
  },
  /** 修改明细 */
  update(id: string, data: CartItemForm) {
    return request({
      url: `${CART_ITEM_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  /** 获取表单数据 */
  getFormData(id: string) {
    return request<unknown, CartItemForm>({
      url: `${CART_ITEM_BASE_URL}/${id}/form`,
      method: "get",
    });
  },
  /** 删除已取走的记录 */
  deleteByIds(ids: string) {
    return request({
      url: `${CART_ITEM_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  /** 取走单件物品 */
  take(id: string) {
    return request({
      url: `${CART_ITEM_BASE_URL}/${id}/take`,
      method: "put",
    });
  },
  /** 批量取走物品 */
  batchTake(ids: string[]) {
    return request({
      url: `${CART_ITEM_BASE_URL}/batch-take`,
      method: "put",
      data: ids,
    });
  },
  /** 按料车ID查询 */
  getByCartId(cartId: string) {
    return request<unknown, CartItemRecord[]>({
      url: `${CART_ITEM_BASE_URL}/by-cart/${cartId}`,
      method: "get",
    });
  },
  /** 获取表单选项（可用料车列表） */
  getFormOptions() {
    return request<unknown, AvailableCart[]>({
      url: `${CART_ITEM_BASE_URL}/form-options`,
      method: "get",
    });
  },
  /** 获取料车编号筛选选项（有货料车列表） */
  getFilterCartOptions() {
    return request<unknown, AvailableCart[]>({
      url: `${CART_ITEM_BASE_URL}/filter-cart-options`,
      method: "get",
    });
  },
  /** 获取筛选选项 */
  getFilterOptions() {
    return request<string[]>({
      url: `${CART_ITEM_BASE_URL}/filter-options`,
      method: "get",
    });
  },
};

export default CartItemAPI;
