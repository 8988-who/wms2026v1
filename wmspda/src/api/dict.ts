import request from "@/utils/request";

const DICT_BASE_URL = "/api/v1/dicts";

const DictAPI = {
  getPage(queryParams: DictTypePageQuery) {
    return request<PageResult<DictTypeItem>>({
      url: `${DICT_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },

  getFormData(id: string | number) {
    return request<DictTypeForm>({
      url: `${DICT_BASE_URL}/${id}/form`,
      method: "GET",
    });
  },

  create(data: DictTypeForm) {
    return request({
      url: `${DICT_BASE_URL}`,
      method: "POST",
      data,
    });
  },

  update(id: string | number, data: DictTypeForm) {
    return request({
      url: `${DICT_BASE_URL}/${id}`,
      method: "PUT",
      data,
    });
  },

  deleteByIds(ids: string) {
    return request({
      url: `${DICT_BASE_URL}/${ids}`,
      method: "DELETE",
    });
  },

  getItemPage(dictCode: string, queryParams: DictItemPageQuery) {
    return request<PageResult<DictDataItem>>({
      url: `${DICT_BASE_URL}/${dictCode}/items`,
      method: "GET",
      data: queryParams,
    });
  },

  getItemFormData(dictCode: string, id: string | number) {
    return request<DictItemForm>({
      url: `${DICT_BASE_URL}/${dictCode}/items/${id}/form`,
      method: "GET",
    });
  },

  createItem(dictCode: string, data: DictItemForm) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items`,
      method: "POST",
      data,
    });
  },

  updateItem(dictCode: string, id: string | number, data: DictItemForm) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items/${id}`,
      method: "PUT",
      data,
    });
  },

  deleteItems(dictCode: string, ids: string) {
    return request({
      url: `${DICT_BASE_URL}/${dictCode}/items/${ids}`,
      method: "DELETE",
    });
  },
};

export default DictAPI;

export interface DictTypePageQuery extends PageQuery {
  keywords?: string;
  status?: number;
}

export interface DictTypeForm {
  id?: string;
  name?: string;
  dictCode?: string;
  status?: number;
  remark?: string;
}

export interface DictTypeItem {
  id?: string;
  name?: string;
  dictCode?: string;
  status?: number;
  remark?: string;
}

export interface DictItemPageQuery extends PageQuery {
  keywords?: string;
}

export interface DictItemForm {
  id?: string;
  dictCode?: string;
  label?: string;
  value?: string;
  sort: number;
  status?: number;
  remark?: string;
}

export interface DictDataItem {
  id?: string;
  dictCode?: string;
  label?: string;
  value?: string;
  sort?: number;
  status?: number;
  remark?: string;
}
