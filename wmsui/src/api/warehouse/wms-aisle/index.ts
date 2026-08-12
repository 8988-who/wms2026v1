import request from "@/utils/request";
import type { WmsAisleForm, WmsAisleQueryParams, WmsAisleItem, WmsAisleFormOptions } from "./types";
import type { PageResult } from "@/api/common";

export type { WmsAisleForm, WmsAisleQueryParams, WmsAisleItem, WmsAisleLocationOption, WmsAisleFormOptions } from "./types";

const WMS_AISLE_BASE_URL = "/api/v1/wms-aisle";

const WmsAisleAPI = {
  /** 获取巷道分页数据 */
  getPage(queryParams?: WmsAisleQueryParams) {
    return request<unknown, PageResult<WmsAisleItem>>({
      url: `${WMS_AISLE_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取巷道表单数据 */
  getFormData(id: string) {
    return request<unknown, WmsAisleForm>({
      url: `${WMS_AISLE_BASE_URL}/${id}/form`,
      method: "get",
    });
  },
  /** 新增巷道 */
  create(data: WmsAisleForm) {
    return request({
      url: `${WMS_AISLE_BASE_URL}`,
      method: "post",
      data,
    });
  },
  /** 更新巷道 */
  update(id: string, data: WmsAisleForm) {
    return request({
      url: `${WMS_AISLE_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  /** 批量删除巷道 */
  deleteByIds(ids: string) {
    return request({
      url: `${WMS_AISLE_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  /** 批量更新巷道状态（启用/停用），雪花 ID 为字符串 */
  updateStatus(data: { ids: string[]; status: number }) {
    return request({
      url: `${WMS_AISLE_BASE_URL}/status`,
      method: "put",
      data,
    });
  },
  /** 获取表单下拉选项（厂区编码、所属区域） */
  getFormOptions() {
    return request<unknown, WmsAisleFormOptions>({
      url: `${WMS_AISLE_BASE_URL}/form-options`,
      method: "get",
    });
  },
  /** 获取搜索筛选下拉选项（巷道编码） */
  getFilterOptions() {
    return request<unknown, Record<string, string[]>>({
      url: `${WMS_AISLE_BASE_URL}/filter-options`,
      method: "get",
    });
  },
};

export default WmsAisleAPI;
