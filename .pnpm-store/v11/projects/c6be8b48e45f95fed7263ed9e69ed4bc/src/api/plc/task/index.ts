import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type { PlcLocationOption, PlcTaskCreateForm, PlcTaskItem, PlcTaskQueryParams } from "./types";

export type { PlcLocationOption, PlcTaskCreateForm, PlcTaskItem, PlcTaskQueryParams } from "./types";

const PLC_TASK_BASE_URL = "/api/v1/plc/task";

const PlcTaskAPI = {
  /** 获取PLC配置分页数据 */
  getPage(queryParams?: PlcTaskQueryParams) {
    return request<unknown, PageResult<PlcTaskItem>>({
      url: PLC_TASK_BASE_URL,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取PLC区域选项 */
  getLocationOptions() {
    return request<unknown, PlcLocationOption[]>({
      url: `${PLC_TASK_BASE_URL}/location-options`,
      method: "get",
    });
  },
  /** 新增PLC配置 */
  create(data: PlcTaskCreateForm) {
    return request({
      url: PLC_TASK_BASE_URL,
      method: "post",
      data,
    });
  },
  /** 删除PLC配置 */
  deleteByIds(ids: string) {
    return request({
      url: `${PLC_TASK_BASE_URL}/${ids}`,
      method: "delete",
    });
  },
  /** 修改PLC启用状态 */
  updateEnabled(id: string, enabled: number) {
    return request({
      url: `${PLC_TASK_BASE_URL}/${id}/enabled`,
      method: "put",
      params: { enabled },
    });
  },
  /** 重新连接PLC */
  reconnect(id: string) {
    return request({
      url: `${PLC_TASK_BASE_URL}/${id}/reconnect`,
      method: "put",
    });
  },
};

export default PlcTaskAPI;
