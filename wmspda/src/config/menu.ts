/**
 * 工作台菜单配置
 */

export interface WorkMenuItem {
  icon: string;
  title: string;
  url: string;
  perm: string;
}

export interface WorkMenuGroup {
  title: string;
  children: WorkMenuItem[];
}

export const menuConfig: WorkMenuGroup[] = [
  {
    title: "系统管理",
    children: [
      {
        icon: "/static/icons/user.svg",
        title: "用户管理",
        url: "/pages/work/user/index",
        perm: "sys:user:list",
      },
      {
        icon: "/static/icons/role.svg",
        title: "角色管理",
        url: "/pages/work/role/index",
        perm: "sys:role:list",
      },
      {
        icon: "/static/icons/company.svg",
        title: "部门管理",
        url: "/pages/work/dept/index",
        perm: "sys:dept:list",
      },
      {
        icon: "/static/icons/settings.svg",
        title: "系统配置",
        url: "/pages/work/config/index",
        perm: "sys:config:list",
      },
      {
        icon: "/static/icons/file.svg",
        title: "字典管理",
        url: "/pages/work/dict/index",
        perm: "sys:dict:list",
      },
      {
        icon: "/static/icons/tree.svg",
        title: "菜单管理",
        url: "/pages/work/menu/index",
        perm: "sys:menu:list",
      },
      {
        icon: "/static/icons/log.svg",
        title: "系统日志",
        url: "/pages/work/log/index",
        perm: "sys:log:list",
      },
    ],
  },
];
