import request from "@/utils/request";

const AUTH_BASE_URL = "/api/v1/auth";
const WXMA_AUTH_BASE_URL = "/api/v1/wxma/auth";

export interface LoginData {
  username: string;
  password: string;
  captchaId?: string;
  captchaCode?: string;
}

export interface LoginResult {
  accessToken: string;
  refreshToken?: string;
  tokenType: string;
  expiresIn: number;
  isNewUser?: boolean;
  needBindMobile?: boolean;
  openid?: string;
}

export interface Captcha {
  captchaId: string;
  captchaBase64: string;
}

export interface SmsLoginData {
  mobile: string;
  code: string;
}

export interface WxMaLoginResp {
  accessToken?: string;
  refreshToken?: string;
  tokenType?: string;
  expiresIn?: number;
  isNewUser: boolean;
  needBindMobile: boolean;
  openid?: string;
}

export interface WxMaPhoneLoginData {
  loginCode: string;
  phoneCode: string;
}

export interface WxMaBindMobileData {
  openid: string;
  mobile: string;
  smsCode: string;
}

const AuthAPI = {
  /**
   * 获取图形验证码
   */
  getCaptcha(): Promise<Captcha> {
    return request<Captcha>({
      url: `${AUTH_BASE_URL}/captcha`,
      method: "GET",
    });
  },

  /**
   * 账号密码登录
   */
  login(data: LoginData): Promise<LoginResult> {
    return request<LoginResult>({
      url: `${AUTH_BASE_URL}/login`,
      method: "POST",
      data: data,
    });
  },

  /**
   * 发送短信验证码
   *
   * 演示环境说明：短信服务未配置，验证码固定为 123456
   */
  sendSmsLoginCode(mobile: string): Promise<void> {
    const mobileSafe = encodeURIComponent(mobile);
    return request({
      url: `${AUTH_BASE_URL}/sms/code?mobile=${mobileSafe}`,
      method: "POST",
    });
  },

  /**
   * 短信验证码登录
   */
  loginBySms(data: SmsLoginData): Promise<LoginResult> {
    const mobileSafe = encodeURIComponent(data.mobile);
    const codeSafe = encodeURIComponent(data.code);
    return request<LoginResult>({
      url: `${AUTH_BASE_URL}/login/sms?mobile=${mobileSafe}&code=${codeSafe}`,
      method: "POST",
    });
  },

  /**
   * 微信小程序静默登录
   *
   * 适用场景：个人小程序
   * - 已绑定手机号的用户：直接返回 token，登录成功
   * - 未绑定手机号的用户：返回 openid，需调用绑定手机号接口
   */
  wxMaSilentLogin(code: string): Promise<WxMaLoginResp> {
    return request<WxMaLoginResp>({
      url: `${WXMA_AUTH_BASE_URL}/silent-login?code=${encodeURIComponent(code)}`,
      method: "POST",
    });
  },

  /**
   * 微信小程序手机号快捷登录
   *
   * 适用场景：企业认证小程序（已开通手机号快捷登录权限）
   * 一步完成登录，无需绑定流程，自动创建新用户
   */
  wxMaPhoneLogin(data: WxMaPhoneLoginData): Promise<LoginResult> {
    return request<LoginResult>({
      url: `${WXMA_AUTH_BASE_URL}/phone-login`,
      method: "POST",
      data: data,
    });
  },

  /**
   * 微信小程序绑定手机号
   *
   * 演示环境说明：短信服务未配置，验证码固定为 123456
   */
  wxMaBindMobile(data: WxMaBindMobileData): Promise<LoginResult> {
    return request<LoginResult>({
      url: `${WXMA_AUTH_BASE_URL}/bind-mobile`,
      method: "POST",
      data: data,
    });
  },

  /**
   * 检查会话有效性
   */
  checkSession(): Promise<{ valid: boolean }> {
    return request<{ valid: boolean }>({
      url: `${AUTH_BASE_URL}/check-session`,
      method: "GET",
    });
  },

  /**
   * 登出
   */
  logout() {
    return request({
      url: `${AUTH_BASE_URL}/logout`,
      method: "DELETE",
    });
  },

  /**
   * 刷新令牌
   */
  refreshToken(refreshToken: string): Promise<{ accessToken: string; expiresIn: number }> {
    return request<{ accessToken: string; expiresIn: number }>({
      url: `${AUTH_BASE_URL}/refresh-token`,
      method: "POST",
      data: { refreshToken },
    });
  },
};

export default AuthAPI;
