import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type {
  PlcSectorSignalsCreateForm,
  PlcSectorSignalsItem,
  PlcSectorSignalsQueryParams,
  SignalBlockOption,
} from "./types";

export type {
  PlcSectorSignalsCreateForm,
  PlcSectorSignalsItem,
  PlcSectorSignalsQueryParams,
  SignalBlockOption,
} from "./types";

const PLC_SECTOR_BASE_URL = "/api/v1/plc/sector";

const PlcSectorSignalsAPI = {
  /** 获取PLC信号块读写信号配置分页数据 */
  getPage(queryParams?: PlcSectorSignalsQueryParams) {
    return request<unknown, PageResult<PlcSectorSignalsItem>>({
      url: PLC_SECTOR_BASE_URL,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取信号块下拉选项 */
  getSignalBlockOptions() {
    return request<unknown, SignalBlockOption[]>({
      url: `${PLC_SECTOR_BASE_URL}/signal-block-options`,
      method: "get",
    });
  },
  /** 新增PLC信号块读写信号配置 */
  create(data: PlcSectorSignalsCreateForm) {
    return request({
      url: PLC_SECTOR_BASE_URL,
      method: "post",
      data,
    });
  },
  /** 删除PLC信号块读写信号配置 */
  deleteById(id: string) {
    return request({
      url: `${PLC_SECTOR_BASE_URL}/${id}`,
      method: "delete",
    });
  },
};

export default PlcSectorSignalsAPI;
