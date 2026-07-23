import request from "@/utils/request";

const USER_BASE_URL = "/api/v1/users";

const UserAPI = {
  /**
   * 获取当前登录用户信息
   *
   * @returns 登录用户昵称、头像信息，包括角色和权限
   */
  getUserInfo(): Promise<UserInfo> {
    return request<UserInfo>({
      url: `${USER_BASE_URL}/me`,
      method: "GET",
    });
  },

  /**
   * 获取用户分页列表
   *
   * @param queryParams 查询参数
   */
  getPage(queryParams: UserPageQuery) {
    return request<PageResult<UserItem>>({
      url: `${USER_BASE_URL}`,
      method: "GET",
      data: queryParams,
    });
  },
  /**
   * 添加用户
   *
   * @param data 用户表单数据
   */
  add(data: UserForm) {
    return request({
      url: `${USER_BASE_URL}`,
      method: "POST",
      data: data,
    });
  },

  /**
   * 获取用户表单详情
   *
   * @param userId 用户ID
   * @returns 用户表单详情
   */
  getFormData(userId: number) {
    return request<UserForm>({
      url: `${USER_BASE_URL}/${userId}/form`,
      method: "GET",
    });
  },

  /**
   * 修改用户
   *
   * @param id 用户ID
   * @param data 用户表单数据
   */
  update(id: number, data: UserForm) {
    return request({
      url: `${USER_BASE_URL}/${id}`,
      method: "PUT",
      data: data,
    });
  },

  /** 获取个人中心用户信息 */
  getProfile() {
    return request<UserProfile>({
      url: `${USER_BASE_URL}/profile`,
      method: "GET",
    });
  },

  /** 修改个人中心用户信息 */
  updateProfile(data: UserProfileForm) {
    return request({
      url: `${USER_BASE_URL}/profile`,
      method: "PUT",
      data: data,
    });
  },

  /** 修改个人中心用户密码 */
  changePassword(data: PasswordChangeForm) {
    return request({
      url: `${USER_BASE_URL}/password`,
      method: "PUT",
      data: data,
    });
  },

  /** 解绑第三方账号 */
  unbindSocial(platform: string) {
    return request({
      url: `${USER_BASE_URL}/social?platform=${encodeURIComponent(platform)}`,
      method: "DELETE",
    });
  },

  /**
   *   发送手机/邮箱验证码
   *
   * @param contact 联系方式  手机号/邮箱
   * @param contactType 联系方式类型 MOBILE:手机;EMAIL:邮箱
   */
  sendVerificationCode(contact: string, contactType: string) {
    return request({
      url: `${USER_BASE_URL}/send-verification-code?contact=${contact}&contactType=${contactType}`,
      method: "POST",
    });
  },

  /** 绑定个人中心用户手机 */
  bindMobile(data: MobileBindingForm) {
    return request({
      url: `${USER_BASE_URL}/mobile`,
      method: "PUT",
      data: data,
    });
  },

  /** 绑定个人中心用户邮箱 */
  bindEmail(data: EmailBindingForm) {
    return request({
      url: `${USER_BASE_URL}/email`,
      method: "PUT",
      data: data,
    });
  },

  /**
   * 批量删除用户，多个以英文逗号(,)分割
   *
   * @param ids 用户ID字符串，多个以英文逗号(,)分割
   */
  deleteByIds(ids: string) {
    return request({
      url: `${USER_BASE_URL}/${ids}`,
      method: "DELETE",
    });
  },

  /**
   * 重置用户密码
   *
   * @param userId 用户ID
   * @param password 新密码
   */
  resetPassword(userId: number | string, password: string) {
    return request({
      url: `${USER_BASE_URL}/${userId}/password/reset`,
      method: "PUT",
      data: { password },
    });
  },
};
export default UserAPI;

interface BaseUser {
  username?: string;
  nickname?: string;
  avatar?: string;
  gender?: number;
  mobile?: string;
  email?: string;
  deptName?: string;
}

/** 登录用户信息 */
export interface UserInfo extends BaseUser {
  /** 用户ID */
  userId?: number;
  /** 角色编码集合 */
  roles?: string[];
  /** 权限标识集合 */
  perms?: string[];
  /** 角色名称（前端计算字段，取 roles[0] 的中文映射） */
  roleName?: string;
}

/**
 * 用户分页查询对象
 */
export interface UserPageQuery extends PageQuery {
  /** 搜索关键字 */
  keywords?: string;

  /** 用户状态 */
  status?: number;

  /** 部门ID */
  deptId?: number;

  /** 开始时间 */
  createTime?: [string, string] | string;

  /** 排序字段 */
  field?: string;

  /** 排序方式(asc:正序,desc:倒序) */
  direction?: string;
}

/** 用户分页对象 */
export interface UserItem {
  /** 用户头像URL */
  avatar?: string;
  /** 创建时间 */
  createTime?: string;
  /** 部门名称 */
  deptName?: string;
  /** 用户邮箱 */
  email?: string;
  /** 性别 */
  gender?: number;
  /** 用户ID */
  id: number;
  /** 手机号 */
  mobile?: string;
  /** 用户昵称 */
  nickname?: string;
  /** 角色名称，多个使用英文逗号(,)分割 */
  roleNames?: string;
  /** 用户状态(1:启用;0:禁用) */
  status?: number;
  /** 用户名 */
  username?: string;
}

/** 个人中心用户信息 */
export interface UserProfile extends BaseUser {
  /** 用户ID */
  id?: number;
  /** 角色名称，多个使用英文逗号(,)分割 */
  roleNames?: string;
  /** 创建时间 */
  createTime?: string;
}

/** 个人中心用户信息表单 */
export interface UserProfileForm extends Pick<
  BaseUser,
  "username" | "nickname" | "avatar" | "gender" | "mobile" | "email"
> {
  /** 用户ID */
  id?: number;
}

/** 修改密码表单 */
export interface PasswordChangeForm {
  /** 原密码 */
  oldPassword?: string;
  /** 新密码 */
  newPassword?: string;
  /** 确认新密码 */
  confirmPassword?: string;
}

/** 修改手机表单 */
export interface MobileBindingForm {
  /** 手机号 */
  mobile?: string;
  /** 验证码 */
  code?: string;
}

/** 修改邮箱表单 */
export interface EmailBindingForm {
  /** 邮箱 */
  email?: string;
  /** 验证码 */
  code?: string;
}

/** 用户表单 */
export interface UserForm {
  /** 用户头像 */
  avatar?: string;
  /** 部门ID */
  deptId?: number;
  /** 用户邮箱 */
  email?: string;
  /** 性别 */
  gender?: number;
  /** 用户ID */
  id?: number;
  /** 手机号 */
  mobile?: string;
  /** 昵称 */
  nickname?: string;
  /** 角色ID集合 */
  roleIds: number[];
  /** 用户状态(1:正常;0:禁用) */
  status?: number;
  /** 用户名 */
  username?: string;
}
