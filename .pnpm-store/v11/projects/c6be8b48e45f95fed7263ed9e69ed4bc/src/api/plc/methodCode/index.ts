import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type {
  PlcMethodCodeCreateForm,
  PlcMethodCodeItem,
  PlcMethodCodeOption,
  PlcMethodCodeQueryParams,
} from "./types";

export type {
  PlcMethodCodeCreateForm,
  PlcMethodCodeItem,
  PlcMethodCodeOption,
  PlcMethodCodeQueryParams,
} from "./types";

const PLC_METHOD_CODE_BASE_URL = "/api/v1/plc/methodCode";

const PlcMethodCodeAPI = {
  /** 获取信号值方法配置分页数据 */
  getPage(queryParams?: PlcMethodCodeQueryParams) {
    return request<unknown, PageResult<PlcMethodCodeItem>>({
      url: PLC_METHOD_CODE_BASE_URL,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取PLC连接下拉选项 */
  getPlcOptions() {
    return request<unknown, PlcMethodCodeOption[]>({
      url: `${PLC_METHOD_CODE_BASE_URL}/plc-options`,
      method: "get",
    });
  },
  /** 按PLC获取信号块下拉选项 */
  getSignalOptions(plcId?: string) {
    return request<unknown, PlcMethodCodeOption[]>({
      url: `${PLC_METHOD_CODE_BASE_URL}/signal-options`,
      method: "get",
      params: { plcId },
    });
  },
  /** 获取方法下拉选项 */
  getMethodOptions() {
    return request<unknown, PlcMethodCodeOption[]>({
      url: `${PLC_METHOD_CODE_BASE_URL}/method-options`,
      method: "get",
    });
  },
  /** 新增信号值方法配置 */
  create(data: PlcMethodCodeCreateForm) {
    return request({
      url: PLC_METHOD_CODE_BASE_URL,
      method: "post",
      data,
    });
  },
  /** 删除信号值方法配置 */
  deleteById(id: string) {
    return request({
      url: `${PLC_METHOD_CODE_BASE_URL}/${id}`,
      method: "delete",
    });
  },
};

export default PlcMethodCodeAPI;
