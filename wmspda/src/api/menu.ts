import request from "@/utils/request";

const MENU_BASE_URL = "/api/v1/menus";

const MenuAPI = {
  /** 获取菜单列表 */
  getList(queryParams?: MenuQuery) {
    return request<MenuItem[]>({
      url: `${MENU_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },

  /** 获取菜单下拉选项 */
  getOptions(includeButton = false) {
    return request<OptionType[]>({
      url: `${MENU_BASE_URL}/options`,
      method: "GET",
      data: { includeButton },
    });
  },

  /** 获取菜单表单数据 */
  getFormData(id: string) {
    return request<MenuForm>({
      url: `${MENU_BASE_URL}/${id}/form`,
      method: "GET",
    });
  },

  /** 新增菜单 */
  add(data: MenuForm) {
    return request({
      url: `${MENU_BASE_URL}`,
      method: "POST",
      data,
    });
  },

  /** 修改菜单 */
  update(id: string, data: MenuForm) {
    return request({
      url: `${MENU_BASE_URL}/${id}`,
      method: "PUT",
      data,
    });
  },

  /** 删除菜单 */
  deleteById(id: string) {
    return request({
      url: `${MENU_BASE_URL}/${id}`,
      method: "DELETE",
    });
  },
};

export default MenuAPI;

/** 菜单查询参数 */
export interface MenuQuery {
  /** 搜索关键字 */
  keywords?: string;
  /** 状态 */
  visible?: number;
}

/** 菜单类型 */
export interface MenuItem {
  /** 子菜单 */
  children?: MenuItem[];
  /** 组件路径 */
  component?: string;
  /** 创建时间 */
  createTime?: Date;
  /** 图标 */
  icon?: string;
  /** 菜单ID */
  id?: string;
  /** 菜单名称 */
  name?: string;
  /** 父菜单ID */
  parentId?: string;
  /** 权限标识 */
  perm?: string;
  /** 路由名称 */
  routeName?: string;
  /** 路由路径 */
  routePath?: string;
  /** 排序 */
  sort?: number;
  /** 状态(1:显示；0:隐藏) */
  visible?: number;
  /** 菜单类型(C:目录；M:菜单；B:按钮) */
  type?: string | number;
}

/** 菜单表单类型 */
export interface MenuForm {
  /** 菜单ID(新增不填) */
  id?: string;
  /** 菜单名称 */
  name?: string;
  /** 父菜单ID */
  parentId: string;
  /** 菜单类型(C:目录；M:菜单；B:按钮) */
  type: string | number;
  /** 路由名称 */
  routeName?: string;
  /** 路由路径 */
  routePath?: string;
  /** 组件路径 */
  component?: string;
  /** 权限标识 */
  perm?: string;
  /** 图标 */
  icon?: string;
  /** 排序 */
  sort?: number;
  /** 状态(1:显示；0:隐藏) */
  visible?: number;
}
