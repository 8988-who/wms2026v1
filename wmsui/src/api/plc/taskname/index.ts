import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type { PlcTaskNameCreateForm, PlcTaskNameItem, PlcTaskNameQueryParams } from "./types";

export type { PlcTaskNameCreateForm, PlcTaskNameItem, PlcTaskNameQueryParams } from "./types";

const PLC_TASKNAME_BASE_URL = "/api/v1/plc/taskname";

const PlcTaskNameAPI = {
  /** 获取方法名配置分页数据 */
  getPage(queryParams?: PlcTaskNameQueryParams) {
    return request<unknown, PageResult<PlcTaskNameItem>>({
      url: PLC_TASKNAME_BASE_URL,
      method: "get",
      params: queryParams,
    });
  },
  /** 新增方法名配置 */
  create(data: PlcTaskNameCreateForm) {
    return request({
      url: PLC_TASKNAME_BASE_URL,
      method: "post",
      data,
    });
  },
  /** 删除方法名配置 */
  deleteById(id: string) {
    return request({
      url: `${PLC_TASKNAME_BASE_URL}/${id}`,
      method: "delete",
    });
  },
};

export default PlcTaskNameAPI;
