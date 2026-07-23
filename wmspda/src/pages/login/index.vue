<template>
  <view class="page login">
    <!-- 背景装饰 -->
    <view class="login__decoration">
      <view class="login__circle login__circle--1" />
      <view class="login__circle login__circle--2" />
    </view>

    <!-- 导航栏 -->
    <view class="login__navbar" :style="{ paddingTop: `${statusBarHeight}px` }">
      <view class="login__navbar-bar" :style="{ height: `${navBarHeight}px` }">
        <view class="login__navbar-btn" hover-class="login__navbar-btn--active" @click="handleBack">
          <text class="login__navbar-icon">‹</text>
        </view>
        <view class="login__navbar-title" />
        <view class="login__navbar-placeholder" />
      </view>
    </view>

    <!-- 主内容 -->
    <view class="login__body" :style="{ paddingTop: `${statusBarHeight + navBarHeight + 4}px` }">
      <!-- Logo -->
      <view class="login__brand">
        <image class="login__logo" src="/static/logo.png" mode="aspectFit" />
        <text class="login__brand-name">youlai-app</text>
      </view>

      <!-- 登录卡片 -->
      <view class="login__card">
        <!-- 标题 -->
        <view class="login__card-head">
          <text class="login__card-title">欢迎登录</text>
          <text class="login__card-subtitle">{{ loginModeDesc }}</text>
        </view>

        <!-- 表单区域 -->
        <wd-form
          v-if="loginMode !== 'WECHAT'"
          ref="loginFormRef"
          :model="formData"
          :schema="formSchema"
          error-type="message"
          hide-asterisk
        >
          <!-- 用户名/手机号 -->
          <wd-form-item prop="username" layout="vertical">
            <view class="login__field">
              <wd-icon name="user" size="20" color="var(--color-text-placeholder)" />
              <input
                v-model="formData.username"
                class="login__field-input"
                :placeholder="loginMode === 'PASSWORD' ? '请输入用户名' : '请输入手机号'"
                :maxlength="loginMode === 'PASSWORD' ? 50 : 11"
              />
            </view>
          </wd-form-item>

          <!-- 密码 -->
          <wd-form-item v-if="loginMode === 'PASSWORD'" prop="password" layout="vertical">
            <view class="login__field">
              <wd-icon name="lock" size="20" color="var(--color-text-placeholder)" />
              <input
                v-model="formData.password"
                class="login__field-input"
                placeholder="请输入密码"
                :maxlength="50"
                password
                @confirm="handleLogin"
              />
            </view>
          </wd-form-item>

          <!-- 图形验证码（密码登录时显示） -->
          <wd-form-item v-if="loginMode === 'PASSWORD'" prop="captchaCode" layout="vertical">
            <view class="login__field">
              <wd-icon name="code-square" size="20" color="var(--color-text-placeholder)" />
              <input
                v-model="formData.captchaCode"
                class="login__field-input"
                placeholder="请输入验证码"
                :maxlength="6"
                @confirm="handleLogin"
              />
              <image
                v-if="captchaBase64"
                class="login__captcha-img"
                :src="captchaBase64"
                mode="aspectFit"
                @click="fetchCaptcha"
              />
            </view>
          </wd-form-item>

          <!-- 短信验证码 -->
          <wd-form-item v-if="loginMode === 'SMS'" prop="code" layout="vertical">
            <view class="login__field">
              <wd-icon name="lock" size="20" color="var(--color-text-placeholder)" />
              <input
                v-model="formData.code"
                class="login__field-input"
                placeholder="请输入验证码"
                type="number"
                :maxlength="6"
                @confirm="handleLogin"
              />
              <view
                class="login__code-btn"
                :class="smsCountdown > 0 ? 'login__code-btn--disabled' : 'login__code-btn--active'"
                @click="handleSendCode"
              >
                {{ smsCountdown > 0 ? `${smsCountdown}s` : "获取验证码" }}
              </view>
            </view>
          </wd-form-item>

          <!-- 演示环境提示 -->
          <view v-if="loginMode === 'SMS'" class="login__form-item login__demo-hint">
            <text class="login__demo-hint-text">演示环境验证码：123456</text>
          </view>

          <!-- 登录按钮 -->
          <view class="login__form-item">
            <wd-button type="primary" block :loading="isLoading" @click="handleLogin">
              登 录
            </wd-button>
          </view>

          <!-- 切换登录方式 -->
          <view class="login__form-item login__mode-switch" @click="toggleLoginMode">
            <text class="login__mode-switch-text">
              {{ loginMode === "PASSWORD" ? "忘记密码？" : "记得密码？" }}
            </text>
            <text class="login__mode-switch-link">
              {{ loginMode === "PASSWORD" ? "验证码登录" : "密码登录" }}
            </text>
          </view>
        </wd-form>

        <!-- #ifdef MP-WEIXIN -->
        <!-- 微信登录区域 -->
        <view v-else class="login__form">
          <view class="login__form-item">
            <button
              class="login__wx-btn"
              open-type="getPhoneNumber"
              @getphonenumber="handleWechatPhoneLogin"
            >
              <image class="login__wx-btn-icon" src="/static/icons/weixin.png" mode="aspectFit" />
              微信一键登录
            </button>
          </view>

          <!-- 其他登录方式 -->
          <view class="login__form-item login__mode-switch" @click="loginMode = 'PASSWORD'">
            <text class="login__mode-switch-text">其他登录方式</text>
            <text class="login__mode-switch-link">账号登录</text>
          </view>
        </view>
        <!-- #endif -->

        <!-- #ifdef MP-WEIXIN -->
        <!-- 分割线 -->
        <view v-if="loginMode !== 'WECHAT'" class="login__divider">
          <view class="login__divider-line" />
          <text class="login__divider-text">其他登录方式</text>
          <view class="login__divider-line" />
        </view>

        <!-- 微信登录入口 -->
        <view v-if="loginMode !== 'WECHAT'" class="login__oauth-row">
          <image
            class="login__wx-icon"
            src="/static/icons/weixin.png"
            mode="aspectFit"
            @click="loginMode = 'WECHAT'"
          />
        </view>

        <!-- 协议勾选 -->
        <view class="login__policy">
          <wd-checkbox v-model="isAgreePolicy" type="square" size="32rpx">
            <text class="login__policy-text">
              我已阅读并同意
              <text class="login__policy-link" @click.stop="navigateToAgreement('user')">
                《用户协议》
              </text>
              与
              <text class="login__policy-link" @click.stop="navigateToAgreement('privacy')">
                《隐私政策》
              </text>
            </text>
          </wd-checkbox>
        </view>
        <!-- #endif -->
      </view>
    </view>

    <!-- 绑定手机号弹窗 -->
    <wd-popup
      v-model="showBindMobilePopup"
      position="bottom"
      closable
      custom-class="popup-bottom"
      @close="resetBindForm"
    >
      <view class="login__bind-panel">
        <text class="login__bind-panel-title">绑定手机号</text>

        <view class="login__form">
          <view class="login__field">
            <wd-icon name="phone" size="20" color="var(--color-text-placeholder)" />
            <input
              v-model="bindMobileForm.mobile"
              class="login__field-input"
              placeholder="请输入手机号"
              type="number"
              :maxlength="11"
            />
          </view>

          <view class="login__field">
            <wd-icon name="lock" size="20" color="var(--color-text-placeholder)" />
            <input
              v-model="bindMobileForm.code"
              class="login__field-input"
              placeholder="请输入验证码"
              type="number"
              :maxlength="6"
            />
            <view
              class="login__code-btn"
              :class="
                bindSmsCountdown > 0 ? 'login__code-btn--disabled' : 'login__code-btn--active'
              "
              @click="handleSendBindCode"
            >
              {{ bindSmsCountdown > 0 ? `${bindSmsCountdown}s` : "获取验证码" }}
            </view>
          </view>

          <!-- 演示环境提示 -->
          <view class="login__demo-hint">
            <text class="login__demo-hint-text">演示环境验证码：123456</text>
          </view>

          <wd-button type="primary" block :loading="isBindLoading" @click="handleBindMobile">
            确认绑定
          </wd-button>
        </view>
      </view>
    </wd-popup>

    <!-- 协议确认弹窗 -->
    <wd-dialog selector="policy-box" root-portal />

    <wd-toast />
  </view>
</template>

<script lang="ts" setup>
import { onLoad, onShow } from "@dcloudio/uni-app";
import { useToast, useDialog } from "@wot-ui/ui";
import type { FormSchema } from "@wot-ui/ui/components/wd-form/types";

import { useUserStore } from "@/store/modules/user";
import { useCountdown } from "@/composables/useCountdown";
import AuthAPI from "@/api/auth";

definePage({
  name: "login",
  style: { navigationStyle: "custom", navigationBarTitleText: "" },
});

const toast = useToast();
const dialog = useDialog("policy-box");
const userStore = useUserStore();
const loginFormRef = ref();

// 导航栏尺寸
const statusBarHeight = ref(20);
const navBarHeight = ref(44);

// 表单状态
const isLoading = ref(false);
const isAgreePolicy = ref(false);
const loginMode = ref<"PASSWORD" | "SMS" | "WECHAT">("PASSWORD");
const { countdown: smsCountdown, start: startSmsCountdown } = useCountdown(60);

const formData = ref({
  username: "admin",
  password: "123456",
  code: "123456",
  captchaCode: "",
});

// 图形验证码
const captchaId = ref("");
const captchaBase64 = ref("");
const isCaptchaLoading = ref(false);

const redirect = ref("/pages/index/index");

// 绑定手机号
const showBindMobilePopup = ref(false);
const isBindLoading = ref(false);
const { countdown: bindSmsCountdown, start: startBindSmsCountdown } = useCountdown(60);
const wechatOpenid = ref("");

const bindMobileForm = ref({
  mobile: "18888888888",
  code: "",
});

const pendingLoginAction = ref<"FORM" | "WECHAT_PHONE" | null>(null);
const pendingWechatPhoneCode = ref("");

// 计算属性
const loginModeDesc = computed(() => {
  const modeMap = {
    PASSWORD: "使用账号密码登录",
    SMS: "使用手机验证码登录",
    WECHAT: "使用微信快捷登录",
  };
  return modeMap[loginMode.value];
});

const isValidMobile = (mobile: string) => /^1\d{10}$/.test((mobile || "").trim());

// 表单校验规则
const formSchema = computed<FormSchema>(() => ({
  validate(model) {
    const issues: { path: string[]; message: string }[] = [];
    if (loginMode.value === "PASSWORD") {
      if (!(model.username || "").trim()) {
        issues.push({ path: ["username"], message: "请输入用户名" });
      }
      if (!(model.password || "").trim()) {
        issues.push({ path: ["password"], message: "请输入密码" });
      }
      if (!(model.captchaCode || "").trim()) {
        issues.push({ path: ["captchaCode"], message: "请输入验证码" });
      }
    } else if (loginMode.value === "SMS") {
      if (!(model.username || "").trim()) {
        issues.push({ path: ["username"], message: "请输入手机号" });
      } else if (!isValidMobile(model.username)) {
        issues.push({ path: ["username"], message: "请输入正确的手机号" });
      }
      if (!(model.code || "").trim()) {
        issues.push({ path: ["code"], message: "请输入验证码" });
      }
    }
    return issues;
  },
}));

// 图形验证码
const fetchCaptcha = async () => {
  if (isCaptchaLoading.value) return;
  try {
    isCaptchaLoading.value = true;
    captchaBase64.value = "";
    const res = await AuthAPI.getCaptcha();
    captchaId.value = res.captchaId;
    captchaBase64.value = res.captchaBase64;
  } catch {
    // 获取验证码失败由 API 层处理
  } finally {
    isCaptchaLoading.value = false;
  }
};

// 切换登录方式
const toggleLoginMode = () => {
  if (loginMode.value === "PASSWORD") {
    loginMode.value = "SMS";
    formData.value.username = "18888888888";
    formData.value.password = "";
    formData.value.code = "";
  } else {
    loginMode.value = "PASSWORD";
    formData.value.username = "admin";
    formData.value.password = "123456";
    formData.value.code = "";
    formData.value.captchaCode = "";
    fetchCaptcha();
  }
};

// 协议弹窗
const openPolicyDialog = (action: "FORM" | "WECHAT_PHONE", phoneCode = "") => {
  pendingLoginAction.value = action;
  pendingWechatPhoneCode.value = phoneCode;
  dialog
    .confirm({
      title: "提示",
      msg: "请阅读并同意《用户协议》与《隐私政策》",
    })
    .then(async () => {
      isAgreePolicy.value = true;
      const act = pendingLoginAction.value;
      const code = pendingWechatPhoneCode.value;
      pendingLoginAction.value = null;
      pendingWechatPhoneCode.value = "";
      if (act === "WECHAT_PHONE") await doWechatPhoneLogin(code);
      else if (act === "FORM") await doFormLogin();
    })
    .catch(() => {
      pendingLoginAction.value = null;
      pendingWechatPhoneCode.value = "";
    });
};

// 表单登录
async function doFormLogin() {
  if (isLoading.value) return;
  isLoading.value = true;
  try {
    if (loginMode.value === "PASSWORD") {
      await userStore.login({
        username: formData.value.username,
        password: formData.value.password,
        captchaId: captchaId.value,
        captchaCode: formData.value.captchaCode,
      });
    } else {
      await userStore.loginBySms({
        mobile: formData.value.username.trim(),
        code: formData.value.code,
      });
    }
    await userStore.getInfo();
    toast.success("登录成功");
    setTimeout(() => uni.reLaunch({ url: redirect.value }), 800);
  } catch (error: any) {
    toast.error(error?.message || "登录失败");
    if (loginMode.value === "PASSWORD") fetchCaptcha();
  } finally {
    isLoading.value = false;
  }
}

const handleLogin = async () => {
  // 先校验表单必填项（内联提示，不再弹窗）
  const validateResult = await loginFormRef.value?.validate();
  if (!validateResult?.valid) return;
  // 再校验隐私协议
  if (!isAgreePolicy.value) {
    openPolicyDialog("FORM");
    return;
  }
  await doFormLogin();
};

const handleSendCode = async () => {
  if (smsCountdown.value > 0) return;
  const mobile = formData.value.username.trim();
  if (!mobile) {
    toast.error("请输入手机号");
    return;
  }
  if (!isValidMobile(mobile)) {
    toast.error("请输入正确的手机号");
    return;
  }
  try {
    await AuthAPI.sendSmsLoginCode(mobile);
    toast.success("验证码已发送");
    startSmsCountdown();
  } catch (error: any) {
    toast.error(error?.message || "发送失败");
  }
};

// 微信登录
const handleWechatPhoneLogin = async (e: any) => {
  const phoneCode = e.detail.code;
  if (!isAgreePolicy.value) {
    openPolicyDialog("WECHAT_PHONE", phoneCode);
    return;
  }
  if (!phoneCode) {
    await handleWechatSilentLogin();
    return;
  }
  await doWechatPhoneLogin(phoneCode);
};

async function doWechatPhoneLogin(phoneCode: string) {
  if (!phoneCode) {
    await handleWechatSilentLogin();
    return;
  }
  isLoading.value = true;
  try {
    const { code: loginCode } = await uni.login();
    await userStore.loginByWxMaPhone({ loginCode, phoneCode });
    await userStore.getInfo();
    toast.success("登录成功");
    setTimeout(() => uni.reLaunch({ url: redirect.value }), 800);
  } catch {
    toast.info("正在尝试其他登录方式...");
    await handleWechatSilentLogin();
  } finally {
    isLoading.value = false;
  }
}

const handleWechatSilentLogin = async () => {
  isLoading.value = true;
  try {
    const { code } = await uni.login();
    const result: any = await userStore.loginByWxMa(code);
    if (result.needBindMobile && result.openid) {
      wechatOpenid.value = result.openid;
      showBindMobilePopup.value = true;
    } else if (result.accessToken) {
      await userStore.getInfo();
      toast.success("登录成功");
      setTimeout(() => uni.reLaunch({ url: redirect.value }), 800);
    }
  } catch (error: any) {
    toast.error(error?.message || "微信登录失败");
  } finally {
    isLoading.value = false;
  }
};

// 绑定手机号
const handleSendBindCode = async () => {
  if (bindSmsCountdown.value > 0) return;
  const mobile = bindMobileForm.value.mobile.trim();
  if (!isValidMobile(mobile)) {
    toast.error("请输入正确的手机号");
    return;
  }
  try {
    await AuthAPI.sendSmsLoginCode(mobile);
    toast.success("验证码已发送");
    startBindSmsCountdown();
  } catch (error: any) {
    toast.error(error?.message || "发送失败");
  }
};

const resetBindForm = () => {
  bindMobileForm.value = { mobile: "", code: "" };
  bindSmsCountdown.value = 0;
};

const handleBindMobile = async () => {
  if (isBindLoading.value) return;
  const { mobile, code } = bindMobileForm.value;
  if (!isValidMobile(mobile)) {
    toast.error("请输入正确的手机号");
    return;
  }
  if (!code.trim()) {
    toast.error("请输入验证码");
    return;
  }
  isBindLoading.value = true;
  try {
    await userStore.bindMobileForWxMa({ openid: wechatOpenid.value, mobile, smsCode: code });
    await userStore.getInfo();
    showBindMobilePopup.value = false;
    resetBindForm();
    toast.success("绑定成功");
    setTimeout(() => uni.reLaunch({ url: redirect.value }), 800);
  } catch (error: any) {
    toast.error(error?.message || "绑定失败");
  } finally {
    isBindLoading.value = false;
  }
};

const navigateToAgreement = (type: string) => {
  const url =
    type === "user" ? "/pages/mine/settings/agreement/index" : "/pages/mine/settings/privacy/index";
  uni.navigateTo({ url });
};

const handleBack = () => {
  if (getCurrentPages().length > 1) {
    uni.navigateBack();
    return;
  }
  uni.reLaunch({ url: "/pages/index/index" });
};

// 生命周期
onLoad((options: any) => {
  const fromQuery = options?.redirect ? decodeURIComponent(options.redirect) : "";
  if (fromQuery && fromQuery !== "/pages/login/index") redirect.value = fromQuery;
  uni.setNavigationBarTitle({ title: "" });
  const systemInfo = uni.getSystemInfoSync();
  statusBarHeight.value = systemInfo.statusBarHeight || 20;
  navBarHeight.value = 44;
  // #ifdef MP-WEIXIN
  const menuButton = uni.getMenuButtonBoundingClientRect();
  navBarHeight.value = menuButton.height + (menuButton.top - statusBarHeight.value) * 2;
  // #endif
  // #ifndef MP-WEIXIN
  if (loginMode.value === "WECHAT") loginMode.value = "PASSWORD";
  // #endif
  fetchCaptcha();
});

onShow(() => uni.setNavigationBarTitle({ title: "" }));
</script>

<style lang="scss" scoped>
.login {
  background: linear-gradient(
    135deg,
    var(--color-bg-tertiary) 0%,
    var(--color-bg) 50%,
    var(--color-primary-light) 100%
  );
}

.login__decoration {
  position: fixed;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  overflow: hidden;
  pointer-events: none;
}

.login__circle {
  position: absolute;
  filter: blur(64px);
  border-radius: 50%;

  &--1 {
    top: -160rpx;
    left: -160rpx;
    width: 480rpx;
    height: 480rpx;
    background-color: var(--color-primary-alpha-20);
  }

  &--2 {
    right: -160rpx;
    bottom: -160rpx;
    width: 640rpx;
    height: 640rpx;
    background-color: var(--color-primary-alpha-15);
  }
}

.login__navbar {
  position: fixed;
  top: 0;
  right: 0;
  left: 0;
  z-index: var(--z-navbar);
  padding: 0 32rpx;
}

.login__navbar-bar {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login__navbar-btn,
.login__navbar-placeholder {
  position: absolute;
  top: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 72rpx;
  height: 72rpx;
  transform: translateY(-50%);
}

.login__navbar-btn {
  left: 0;
  background-color: var(--color-glass);
  border: 2rpx solid var(--color-border-glass);
  border-radius: 999rpx;

  &--active {
    opacity: 0.8;
  }
}

.login__navbar-placeholder {
  right: 0;
}

.login__navbar-icon {
  margin-top: -4rpx;
  font-size: 44rpx;
  font-weight: 500;
  line-height: 1;
  color: var(--color-text);
}

.login__navbar-title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--color-text);
  letter-spacing: 0.08em;
}

.login__body {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 0 96rpx;
}

.login__brand {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 8rpx;
  margin-bottom: 40rpx;
}

.login__logo {
  width: 120rpx;
  height: 120rpx;
  margin-bottom: 20rpx;
}

.login__brand-name {
  font-size: 36rpx;
  font-weight: 600;
  color: var(--color-text);
  letter-spacing: 0.05em;
}

.login__card {
  width: 100%;
  padding: 44rpx;
  background-color: var(--color-bg);
  border: 2rpx solid var(--color-border-light);
  border-radius: 48rpx;
  box-shadow: 0 20rpx 50rpx -10rpx rgba(0, 0, 0, 0.1);

  @supports (backdrop-filter: blur(24px)) or (-webkit-backdrop-filter: blur(24px)) {
    background-color: var(--color-bg-alpha-95);
    -webkit-backdrop-filter: blur(24px);
    backdrop-filter: blur(24px);
  }
}

// 卡片头部
.login__card-head {
  margin-bottom: 36rpx;
  text-align: center;
}

.login__card-title {
  font-size: 40rpx;
  font-weight: 700;
  color: var(--color-text);
}

.login__card-subtitle {
  display: block;
  margin-top: 8rpx;
  font-size: 26rpx;
  color: var(--color-text-secondary);
}

.login__form-item {
  margin-top: 28rpx;

  &:first-child {
    margin-top: 0;
  }
}

// 覆盖 wd-form-item 默认样式，仅用于校验和错误提示
:deep(.wd-form-item) {
  padding: 0 !important;
  margin-top: 28rpx;
  background: transparent;

  &:first-child {
    margin-top: 0;
  }
}

// 垂直布局下隐藏左侧区域（无标题时）
:deep(.wd-form-item .wd-cell__left) {
  display: none;
}

:deep(.wd-form-item .wd-cell__wrapper) {
  flex-direction: column;
}

:deep(.wd-form-item .wd-cell__right) {
  width: 100%;
}

// 错误提示：独占一行，显示在输入框下方
:deep(.wd-form-item__error-message) {
  display: block !important;
  width: 100% !important;
  padding: 8rpx 0 0 !important;
  font-size: 24rpx !important;
  line-height: 1.5 !important;
  color: var(--color-danger) !important;
}

// 输入框行
.login__field {
  display: flex;
  align-items: center;
  height: 88rpx;
  padding: 0 32rpx;
  background-color: var(--color-bg-secondary);
  border-radius: 24rpx;
}

.login__field-input {
  flex: 1;
  height: 100%;
  margin-left: 24rpx;
  font-size: 28rpx;
  color: var(--color-text);
}

// 图形验证码图片
.login__captcha-img {
  width: 200rpx;
  height: 72rpx;
  border-radius: 12rpx;
}

.login__wx-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 88rpx;
  font-size: 32rpx;
  font-weight: 600;
  color: var(--color-text-inverse);
  background-color: var(--color-wx-green);
  border-radius: 24rpx;
  box-shadow: 0 20rpx 30rpx -6rpx rgba(34, 197, 94, 0.3);

  &:active {
    transform: scale(0.98);
  }
}

.login__wx-btn-icon {
  width: 40rpx;
  height: 40rpx;
  margin-right: 16rpx;
}

.login__code-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 64rpx;
  padding: 0 32rpx;
  font-size: 28rpx;
  font-weight: 500;
  border-radius: 16rpx;
  &--active {
    color: var(--color-primary);
    background-color: var(--color-primary-light);
  }

  &--disabled {
    color: var(--color-text-placeholder);
    background-color: var(--color-bg-tertiary);
  }
}

.login__mode-switch {
  display: flex;
  justify-content: center;
  padding-top: 24rpx;
}

.login__mode-switch-text {
  font-size: 28rpx;
  color: var(--color-text-secondary);
}

.login__mode-switch-link {
  margin-left: 8rpx;
  font-size: 28rpx;
  font-weight: 500;
  color: var(--color-primary);
  border-bottom: 2rpx solid var(--color-primary);
}

.login__divider {
  display: flex;
  align-items: center;
  margin: 32rpx 0;
}

.login__divider-line {
  flex: 1;
  height: 2rpx;
  background-color: var(--color-border);
}

.login__divider-text {
  padding: 0 32rpx;
  font-size: 24rpx;
  color: var(--color-text-placeholder);
}

.login__oauth-row {
  display: flex;
  gap: 64rpx;
  justify-content: center;
}

.login__wx-icon {
  width: 72rpx;
  height: 72rpx;

  &:active {
    transform: scale(0.95);
  }
}

.login__policy {
  display: flex;
  align-items: flex-start;
  justify-content: center;
  padding-top: 24rpx;
  margin-top: 32rpx;
  border-top: 2rpx solid var(--color-border-light);
}

.login__policy-text {
  font-size: 24rpx;
  line-height: 1.5;
  color: var(--color-text-secondary);
}

.login__policy-link {
  color: var(--color-primary);
}

.login__bind-panel {
  padding: 48rpx;
}

.login__bind-panel-title {
  display: block;
  margin-bottom: 48rpx;
  font-size: 36rpx;
  font-weight: 600;
  color: var(--color-text);
  text-align: center;
}

.login__demo-hint {
  display: flex;
  justify-content: center;
  margin-top: 24rpx;
}

.login__demo-hint-text {
  padding: 8rpx 24rpx;
  font-size: 24rpx;
  color: var(--color-warning);
  background-color: var(--color-warning-light);
  border-radius: 8rpx;
}
</style>

<style lang="scss">
/* 暗黑模式覆盖 - 非 scoped，因 .wot-theme-dark 位于页面根元素 */

.wot-theme-dark {
  .login__card {
    background-color: #252d3a;
    border-color: rgba(255, 255, 255, 0.08);
    box-shadow: 0 20rpx 50rpx -10rpx rgba(0, 0, 0, 0.4);
  }

  .login__divider-line {
    background-color: rgba(255, 255, 255, 0.12);
  }

  .login__field {
    background-color: rgba(255, 255, 255, 0.06);
  }

  .login__navbar-btn {
    background-color: rgba(255, 255, 255, 0.08);
    border-color: rgba(255, 255, 255, 0.08);
  }
}
</style>
