import request from "@/utils/request";
import type { PageResult } from "@/api/common";
import type {
  PlcBoardCreateForm,
  PlcBoardItem,
  PlcBoardQueryParams,
  PlcConnectionOption,
  PlcPointOption,
} from "./types";

export type {
  PlcBoardCreateForm,
  PlcBoardItem,
  PlcBoardQueryParams,
  PlcConnectionOption,
  PlcPointOption,
} from "./types";

const PLC_BOARD_BASE_URL = "/api/v1/plc/board";

const PlcBoardAPI = {
  /** 获取PLC板块配置分页数据 */
  getPage(queryParams?: PlcBoardQueryParams) {
    return request<unknown, PageResult<PlcBoardItem>>({
      url: PLC_BOARD_BASE_URL,
      method: "get",
      params: queryParams,
    });
  },
  /** 获取PLC连接下拉选项 */
  getPlcOptions() {
    return request<unknown, PlcConnectionOption[]>({
      url: `${PLC_BOARD_BASE_URL}/plc-options`,
      method: "get",
    });
  },
  /** 获取储位（点位）下拉选项 */
  getPointOptions() {
    return request<unknown, PlcPointOption[]>({
      url: `${PLC_BOARD_BASE_URL}/point-options`,
      method: "get",
    });
  },
  /** 新增PLC板块配置 */
  create(data: PlcBoardCreateForm) {
    return request({
      url: PLC_BOARD_BASE_URL,
      method: "post",
      data,
    });
  },
  /** 删除PLC板块配置 */
  deleteById(id: string) {
    return request({
      url: `${PLC_BOARD_BASE_URL}/${id}`,
      method: "delete",
    });
  },
  /** 修改PLC信号块配置启用状态 */
  updateEnabled(id: string, enabled: number) {
    return request({
      url: `${PLC_BOARD_BASE_URL}/${id}/enabled`,
      method: "put",
      params: { enabled },
    });
  },
};

export default PlcBoardAPI;
