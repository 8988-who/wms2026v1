import request from "@/utils/request";
import type {
  AvailableCartOption,
  AvailablePointOption,
  AvailablePointQueryParams,
  CartInventoryFilterOptions,
  CartInventoryItem,
  CartInventoryQueryParams,
} from "./types";
import type { PageResult } from "@/api/common";

export type {
  AvailableCartOption,
  AvailablePointOption,
  AvailablePointQueryParams,
  CartInventoryFilterOptions,
  CartInventoryItem,
  CartInventoryQueryParams,
} from "./types";

const CART_INVENTORY_BASE_URL = "/api/v1/cart-inventory";

const CartInventoryAPI = {
  /** 获取料车库存分页数据（库存显示/库存管理共用） */
  getPage(queryParams?: CartInventoryQueryParams) {
    return request<unknown, PageResult<CartInventoryItem>>({
      url: `${CART_INVENTORY_BASE_URL}/page`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取可用料车下拉（不在任何点位且非维修） */
  getAvailableCarts() {
    return request<unknown, AvailableCartOption[]>({
      url: `${CART_INVENTORY_BASE_URL}/available-carts`,
      method: "get",
    });
  },
  /** 获取可用点位下拉（空位且未锁定，可按区域/巷道联动筛选后局部加载） */
  getAvailablePoints(params?: AvailablePointQueryParams) {
    return request<unknown, AvailablePointOption[]>({
      url: `${CART_INVENTORY_BASE_URL}/available-points`,
      method: "get",
      params,
    });
  },
  /** 获取搜索筛选下拉（区域列表 + 巷道列表） */
  getFilterOptions() {
    return request<unknown, CartInventoryFilterOptions>({
      url: `${CART_INVENTORY_BASE_URL}/filter-options`,
      method: "get",
    });
  },
  /** 绑定（料车入位） */
  bind(data: { pointId: string; cartId: string }) {
    return request({
      url: `${CART_INVENTORY_BASE_URL}/bind`,
      method: "post",
      data,
    });
  },
  /** 解绑（料车离位） */
  unbind(data: { pointId: string }) {
    return request({
      url: `${CART_INVENTORY_BASE_URL}/unbind`,
      method: "post",
      data,
    });
  },
  /** 锁定库存 */
  lock(data: { pointId: string }) {
    return request({
      url: `${CART_INVENTORY_BASE_URL}/lock`,
      method: "post",
      data,
    });
  },
  /** 解锁库存 */
  unlock(data: { pointId: string }) {
    return request({
      url: `${CART_INVENTORY_BASE_URL}/unlock`,
      method: "post",
      data,
    });
  },
};

export default CartInventoryAPI;
