import request from "@/utils/request";
import type { WmsLocationForm, WmsLocationQueryParams, WmsLocationItem } from "./types";
import type { PageResult } from "@/api/common";

const WMS_LOCATION_BASE_URL = "/api/v1/wms-location";

const WmsLocationAPI = {
    /** 获取库位/区域分页数据 */
    getPage(queryParams?: WmsLocationQueryParams) {
        return request<unknown, PageResult<WmsLocationItem>>({
            url: `${WMS_LOCATION_BASE_URL}`,
            method: "get",
            params: queryParams,
        });
    },
    /** 获取库位/区域表单数据 */
    getFormData(id: string) {
        return request<unknown, WmsLocationForm>({
            url: `${WMS_LOCATION_BASE_URL}/${id}/form`,
            method: "get",
        });
    },
    /** 新增库位/区域 */
    create(data: WmsLocationForm) {
        return request({
            url: `${WMS_LOCATION_BASE_URL}`,
            method: "post",
            data,
        });
    },
    /** 更新库位/区域 */
     update(id: string, data: WmsLocationForm) {
        return request({
            url: `${WMS_LOCATION_BASE_URL}/${id}`,
            method: "put",
            data,
        });
    },
    /** 批量删除库位/区域，多个以英文逗号(,)分割 */
     deleteByIds(ids: string) {
        return request({
            url: `${WMS_LOCATION_BASE_URL}/${ids}`,
            method: "delete",
        });
    },
    /** 批量更新库位/区域状态（启用/停用） */
    updateStatus(data: { ids: number[]; status: number }) {
        return request({
            url: `${WMS_LOCATION_BASE_URL}/status`,
            method: "put",
            data,
        });
    },
    /** 获取搜索下拉选项（支持级联筛选：厂区→楼层→区域编码） */
    getFilterOptions(plantCode?: string, floor?: string) {
        return request<unknown, { plantCodes: string[]; locationCodes: string[]; floors: string[]; updatedByNames: string[]; statuses: string[] }>({
            url: `${WMS_LOCATION_BASE_URL}/filter-options`,
            method: "get",
            params: { plantCode, floor },
        });
    }
}

export default WmsLocationAPI;

// 重导出类型
export * from "./types";
