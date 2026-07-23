import request from "@/utils/request";
import type { WmsPointForm, WmsPointQueryParams, WmsPointItem, WmsPointFormOptions, WmsPointBatchStatusForm } from "./types";
import type { PageResult } from "@/api/common";

export type { WmsPointForm, WmsPointQueryParams, WmsPointItem, WmsPointLocationOption, WmsPointAisleOption, WmsPointFormOptions, WmsPointBatchStatusForm } from "./types";

const WMS_POINT_BASE_URL = "/api/v1/wms-point";

const WmsPointAPI = {
  getPage(queryParams?: WmsPointQueryParams) {
    return request<unknown, PageResult<WmsPointItem>>({
      url: `${WMS_POINT_BASE_URL}`,
      method: "get",
      params: queryParams,
    });
  },
  getFormData(id: string) {
    return request<unknown, WmsPointForm>({
      url: `${WMS_POINT_BASE_URL}/${id}/form`,
      method: "get",
    });
  },
  create(data: WmsPointForm) {
    return request({
      url: `${WMS_POINT_BASE_URL}`,
      method: "post",
      data,
    });
  },
  update(id: string, data: WmsPointForm) {
    return request({
      url: `${WMS_POINT_BASE_URL}/${id}`,
      method: "put",
      data,
    });
  },
  deleteByIds(ids: string) {
    return request({
      url: `${WMS_POINT_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  updateStatus(data: WmsPointBatchStatusForm) {
    return request({
      url: `${WMS_POINT_BASE_URL}/status`,
      method: "put",
      data,
    });
  },
  getFormOptions() {
    return request<unknown, WmsPointFormOptions>({
      url: `${WMS_POINT_BASE_URL}/form-options`,
      method: "get",
    });
  },
  getFilterOptions() {
    return request<unknown, string[]>({
      url: `${WMS_POINT_BASE_URL}/filter-options`,
      method: "get",
    });
  },
};

export default WmsPointAPI;