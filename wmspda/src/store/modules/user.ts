import { defineStore } from "pinia";
import AuthAPI, {
  type LoginData,
  type SmsLoginData,
  type WxMaPhoneLoginData,
  type WxMaBindMobileData,
} from "@/api/auth";
import UserAPI, { type UserInfo } from "@/api/user";
import { setAccessToken, clearTokens } from "@/utils/auth";
import { Storage } from "@/utils/storage";
import { USER_INFO_KEY } from "@/constants";

/**
 * 用户状态管理 Store
 *
 * 功能说明：
 * - 用户登录/登出
 * - 用户信息管理
 * - 多种登录方式支持（密码、短信、微信小程序）
 * - 会话状态检查
 */

export const useUserStore = defineStore("user", () => {
  // ==========================================================================
  // 状态
  // ==========================================================================

  /** 用户信息 */
  const userInfo = ref<UserInfo | undefined>(Storage.get<UserInfo>(USER_INFO_KEY));

  // ==========================================================================
  // 登录方法
  // ==========================================================================

  /**
   * 账号密码登录
   */
  const login = async (data: LoginData) => {
    const result = await AuthAPI.login(data);
    setAccessToken(result.accessToken);
    return result;
  };

  /**
   * 短信验证码登录
   */
  const loginBySms = async (data: SmsLoginData) => {
    const result = await AuthAPI.loginBySms(data);
    setAccessToken(result.accessToken);
    return result;
  };

  /**
   * 微信小程序静默登录
   */
  const loginByWxMa = async (code: string) => {
    const result = await AuthAPI.wxMaSilentLogin(code);
    if (result.accessToken) {
      setAccessToken(result.accessToken);
    }
    return result;
  };

  /**
   * 微信小程序一键登录（企业小程序）
   */
  const loginByWxMaPhone = async (data: WxMaPhoneLoginData) => {
    const result = await AuthAPI.wxMaPhoneLogin(data);
    setAccessToken(result.accessToken);
    return result;
  };

  /**
   * 微信小程序绑定手机号
   */
  const bindMobileForWxMa = async (data: WxMaBindMobileData) => {
    const result = await AuthAPI.wxMaBindMobile(data);
    setAccessToken(result.accessToken);
    return result;
  };

  // ==========================================================================
  // 用户信息方法
  // ==========================================================================

  /**
   * 检查会话状态
   */
  const checkSession = async (): Promise<boolean> => {
    try {
      const result = await AuthAPI.checkSession();
      return result.valid;
    } catch {
      return false;
    }
  };

  /**
   * 获取用户信息
   */
  const getInfo = async () => {
    const data = await UserAPI.getUserInfo();
    Storage.set(USER_INFO_KEY, data);
    userInfo.value = data;
    return data;
  };

  /**
   * 登出
   */
  const logout = async () => {
    try {
      await AuthAPI.logout();
    } catch {
      // 登出失败静默处理，继续清理本地状态
    } finally {
      clearTokens();
      Storage.remove(USER_INFO_KEY);
      userInfo.value = undefined;
      uni.reLaunch({ url: "/pages/login/index" });
    }
  };

  /**
   * 判断用户信息是否完整
   */
  const isUserInfoComplete = (): boolean => {
    if (!userInfo.value) return false;
    return !!(userInfo.value.nickname && userInfo.value.avatar);
  };

  // ==========================================================================
  // 导出
  // ==========================================================================

  return {
    userInfo,
    login,
    loginBySms,
    loginByWxMa,
    loginByWxMaPhone,
    bindMobileForWxMa,
    logout,
    getInfo,
    checkSession,
    isUserInfoComplete,
  };
});
