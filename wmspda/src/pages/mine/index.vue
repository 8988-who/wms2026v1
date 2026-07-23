<template>
  <view class="page page--tabbar">
    <view class="mine-hero" :style="{ paddingTop: `${navbar.totalHeight.value}px` }">
      <!-- 蓝色背景 -->
      <view class="mine-hero__bg" :style="{ background: headerBackground }" />

      <custom-navbar
        bg-color="transparent"
        title-color="var(--color-text-inverse)"
        icon-color="var(--color-text-inverse)"
        :show-back="false"
        :placeholder="false"
      >
        <template #center>
          <text class="mine-navbar__title">个人中心</text>
        </template>
      </custom-navbar>

      <view class="mine-hero__content">
        <view class="profile-card">
          <view class="profile-card__header">
            <view class="profile-card__left" @click="isLogin ? openProfile() : navigateToLogin()">
              <image
                class="profile-card__avatar"
                :src="isLogin && userInfo?.avatar ? userInfo.avatar : defaultAvatar"
                mode="aspectFill"
                lazy-load
              />
              <view v-if="isLogin" class="profile-card__online-dot" />
            </view>

            <view class="profile-card__main" @click="isLogin ? openProfile() : navigateToLogin()">
              <view class="profile-card__top">
                <text class="profile-card__name">
                  {{ isLogin ? userInfo?.nickname || "匿名用户" : "欢迎使用" }}
                </text>
              </view>

              <view v-if="isLogin" class="profile-card__tags">
                <view class="profile-tag">
                  <wd-icon name="user" size="12" color="var(--color-text-inverse)" />
                  <text>{{ isLogin ? userInfo?.username || "未设置账号" : "快捷登录" }}</text>
                </view>
                <view class="profile-tag">
                  <wd-icon
                    :name="isLogin && deptNameText ? 'home' : 'safe'"
                    size="12"
                    color="var(--color-text-inverse)"
                  />
                  <text>{{ isLogin && deptNameText ? deptNameText : "安全可靠" }}</text>
                </view>
              </view>

              <text v-else class="profile-card__hint">登录使用更多功能</text>
            </view>

            <view v-if="isLogin" class="profile-card__actions">
              <view
                class="profile-card__action-btn"
                aria-label="通知"
                @click.stop="openNotifications"
              >
                <wd-icon name="notification" size="16" color="var(--color-text-inverse)" />
              </view>
            </view>

            <view v-if="!isLogin" class="profile-card__action" @click.stop="navigateToLogin()">
              <wd-button custom-class="profile-card__button" size="small" type="primary">
                立即登录
              </wd-button>
            </view>
          </view>
        </view>

        <!-- 官方社区推广区域 -->
        <view class="community-card" @click="openOfficialAccount">
          <image
            class="community-card__bg"
            src="/static/images/official-bg.png"
            mode="aspectFill"
          />
          <view class="community-card__mask" />
          <view class="community-card__logo">
            <image src="/static/logo.png" mode="aspectFit" class="w-full h-full" />
          </view>
          <view class="community-card__body">
            <view class="community-card__title-row">
              <text class="community-card__title">关注有来技术</text>
              <wd-tag type="success" plain custom-class="community-card__tag">官方社区</wd-tag>
            </view>
            <text class="community-card__desc">开源更新、实战内容、交流群入口，统一在这里查看</text>
          </view>
          <view class="community-card__arrow">
            <wd-icon name="right" size="16" color="var(--color-text-secondary)" />
          </view>
        </view>

        <view v-if="isLogin" class="quick-cards">
          <view class="quick-card" @click="openProfile">
            <view class="quick-card__icon quick-card__icon--info">
              <wd-icon name="user" size="28" color="var(--color-primary)" />
            </view>
            <view class="quick-card__body">
              <text class="quick-card__title">我的资料</text>
              <text class="quick-card__desc">修改个人信息</text>
            </view>
          </view>
          <view class="quick-card" @click="openAccount">
            <view class="quick-card__icon quick-card__icon--success">
              <wd-icon name="safe" size="28" color="var(--color-success)" />
            </view>
            <view class="quick-card__body">
              <text class="quick-card__title">账号安全</text>
              <text class="quick-card__desc">修改密码 / 账号绑定</text>
            </view>
          </view>
        </view>
      </view>
    </view>

    <view class="mine-body">
      <view class="section-card">
        <text class="section-title">系统工具</text>
        <view class="menu-list menu-list--flat">
          <view class="menu-row" @click="openNetworkTest">
            <view class="menu-row__icon menu-row__icon--warning">
              <wd-icon name="tool" size="18" color="var(--color-primary)" />
            </view>
            <view class="menu-row__main">
              <text class="menu-row__title">网络检测</text>
              <text class="menu-row__desc">检测接口连通性</text>
            </view>
            <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
          </view>
          <view class="menu-row" @click="handleClearCache">
            <view class="menu-row__icon menu-row__icon--danger">
              <wd-icon name="delete" size="18" color="var(--color-danger)" />
            </view>
            <view class="menu-row__main">
              <text class="menu-row__title">清理缓存</text>
              <text class="menu-row__desc">显示当前缓存大小</text>
            </view>
            <text class="menu-row__value">{{ cacheSize }}</text>
            <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
          </view>
        </view>
      </view>

      <view class="section-card">
        <text class="section-title">帮助与支持</text>
        <view class="menu-list menu-list--flat">
          <view class="menu-row" @click="openSettings">
            <view class="menu-row__icon menu-row__icon--primary">
              <wd-icon name="settings" size="18" color="var(--color-primary)" />
            </view>
            <view class="menu-row__main">
              <text class="menu-row__title">系统设置</text>
              <text class="menu-row__desc">主题、语言、通知等设置</text>
            </view>
            <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
          </view>
          <view class="menu-row" @click="openUserAgreement">
            <view class="menu-row__icon menu-row__icon--success">
              <wd-icon name="safe" size="18" color="var(--color-success)" />
            </view>
            <view class="menu-row__main">
              <text class="menu-row__title">用户协议</text>
              <text class="menu-row__desc">了解产品使用规则</text>
            </view>
            <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
          </view>
          <view class="menu-row" @click="openAbout">
            <view class="menu-row__icon menu-row__icon--info">
              <wd-icon name="info-circle" size="18" color="var(--color-info)" />
            </view>
            <view class="menu-row__main">
              <text class="menu-row__title">关于系统</text>
              <text class="menu-row__desc">产品介绍与联系方式</text>
            </view>
            <text class="menu-row__value">v{{ appVersion }}</text>
            <wd-icon name="right" size="16" color="var(--color-text-placeholder)" />
          </view>
        </view>
      </view>
    </view>

    <wd-loading
      v-if="isClearing"
      v-model="isClearing"
      text="正在清理..."
      mask
      custom-class="loading-center"
    />
    <wd-toast />
  </view>
</template>

<script lang="ts" setup>
import { computed, ref } from "vue";
import { onShow } from "@dcloudio/uni-app";
import { useUserStore, useThemeStore } from "@/store";
import { useRouter } from "uni-mini-router";
import { useNavbar } from "@/composables/useNavbar";
import { getAccessToken } from "@/utils/auth";
import { formatBytes } from "@/utils/format";

definePage({
  name: "mine",
  style: { navigationStyle: "custom" },
  layout: "tabbar",
});

const userStore = useUserStore();
const themeStore = useThemeStore();
const currentThemeColor = computed(() => themeStore.themeVars.colorTheme);
const userInfo = computed(() => userStore.userInfo);
const defaultAvatar = "/static/images/default-avatar.png";

const isLogin = computed(() => !!getAccessToken());

const headerBackground = computed(() => {
  const color = currentThemeColor.value || "var(--color-primary)";
  const colorWithAlpha = color.length === 7 ? `${color}E6` : color;
  const colorWithAlpha2 = color.length === 7 ? `${color}CC` : color;
  return `linear-gradient(135deg, ${colorWithAlpha} 0%, ${colorWithAlpha2} 100%)`;
});

const router = useRouter();
const appVersion = ref("1.0.0");
const navbar = useNavbar({ hasTabbar: true });

const hasUserProfile = computed(() => {
  const info = userInfo.value;
  return !!(info && (info.userId || info.username || info.nickname));
});

const deptNameText = computed(() => {
  if (!isLogin.value) return "";
  return userInfo.value?.deptName || "";
});

const fetchUserInfoIfNeeded = async () => {
  if (!isLogin.value || hasUserProfile.value) return;
  try {
    await userStore.getInfo();
  } catch {
    // ignore
  }
};

const syncMiniProgramVersion = () => {
  // #ifdef MP-WEIXIN
  appVersion.value = uni.getAccountInfoSync().miniProgram.version || "1.0.0";
  // #endif
};

onShow(async () => {
  await fetchUserInfoIfNeeded();
  await fetchCacheSize();
  syncMiniProgramVersion();
});

// 登录
const navigateToLogin = () => {
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1];
  const currentPagePath = `/${currentPage.route}`;
  router.push({ path: "/pages/login/index", query: { redirect: currentPagePath } });
};

// 个人信息
const openProfile = () => {
  if (!isLogin.value) {
    navigateToLogin();
    return;
  }
  router.push({ path: "/pages/mine/profile/index" });
};

// 账号和安全
const openAccount = () => {
  if (!isLogin.value) {
    navigateToLogin();
    return;
  }
  router.push({ path: "/pages/mine/account/index" });
};

const openNotifications = () => {
  if (!isLogin.value) {
    navigateToLogin();
    return;
  }
  uni.showToast({
    title: "功能开发中",
    icon: "none",
  });
};

// 系统设置
const openSettings = () => {
  router.push({ path: "/pages/mine/settings/index" });
};

// 用户协议
const openUserAgreement = () => {
  router.push({ path: "/pages/mine/settings/agreement/index" });
};

// 网络测试
const openNetworkTest = () => {
  router.push({ path: "/pages/mine/settings/network/index" });
};

const openAbout = () => {
  router.push({ path: "/pages/mine/about/index" });
};

const isClearing = ref(false);
const cacheSize = ref<string>("计算中...");

const fetchCacheSize = async () => {
  try {
    // #ifdef MP-WEIXIN
    const res = await uni.getStorageInfo();
    cacheSize.value = formatBytes(res.currentSize);
    // #endif
    // #ifdef H5
    cacheSize.value = formatBytes(
      Object.keys(localStorage).reduce((size, key) => size + localStorage[key].length, 0)
    );
    // #endif
    if (!cacheSize.value) {
      cacheSize.value = "0B";
    }
  } catch {
    cacheSize.value = "获取失败";
  }
};

const handleClearCache = async () => {
  if (cacheSize.value === "获取失败") {
    uni.showToast({
      title: "获取缓存信息失败，请稍后重试",
      icon: "none",
      duration: 2000,
    });
    return;
  }
  if (cacheSize.value === "0B") {
    uni.showToast({
      title: "暂无缓存需要清理",
      icon: "none",
      duration: 2000,
    });
    return;
  }
  if (isClearing.value) {
    return;
  }

  try {
    isClearing.value = true;
    await new Promise((resolve) => setTimeout(resolve, 1500));
    await uni.clearStorage();
    await fetchCacheSize();
    uni.showToast({
      title: "清理成功",
      icon: "success",
    });
  } catch {
    uni.showToast({
      title: "清理失败",
      icon: "error",
    });
  } finally {
    isClearing.value = false;
  }
};

// 有来技术公众号
const openOfficialAccount = () => {
  uni.navigateTo({
    url: "/pages/mine/official/index",
  });
};
</script>

<style lang="scss" scoped>
// ...
.mine-hero {
  position: relative;
  padding-bottom: 24rpx;
  overflow: visible;
}

.mine-hero__bg {
  position: absolute;
  top: 0;
  right: 0;
  left: 0;
  height: 520rpx;
  pointer-events: none;
}

.mine-hero__content,
.profile-card,
.profile-card__top,
.profile-card__tags,
.menu-row {
  display: flex;
}

.mine-hero__content {
  position: relative;
  z-index: var(--z-sticky);
  flex-direction: column;
  gap: 20rpx;
  padding: 20rpx 28rpx 0;
}

.mine-navbar__title {
  font-size: 32rpx;
  font-weight: 600;
  color: var(--color-text-inverse);
  letter-spacing: 2rpx;
}

.profile-tag {
  display: inline-flex;
  gap: 8rpx;
  align-items: center;
  justify-content: center;
  padding: 8rpx 14rpx;
  font-size: 22rpx;
  color: var(--color-text-inverse);
  background: var(--color-glass-light);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 12rpx;
}

.profile-card {
  position: relative;
  padding: 28rpx 28rpx;
  overflow: hidden;
  background: var(--color-bg-alpha-95);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 28rpx;
  box-shadow: var(--shadow-md);

  @supports (backdrop-filter: blur(20px)) or (-webkit-backdrop-filter: blur(20px)) {
    background: linear-gradient(135deg, var(--color-glass) 0%, var(--color-glass-light) 100%);
    -webkit-backdrop-filter: blur(20px);
    backdrop-filter: blur(20px);
  }
}

.profile-card__header {
  display: flex;
  gap: 28rpx;
  align-items: center;
  width: 100%;
}

.profile-card__left {
  position: relative;
  flex-shrink: 0;
  width: 120rpx;
  height: 120rpx;
}

.profile-card__avatar {
  flex-shrink: 0;
  width: 120rpx;
  height: 120rpx;
  border: 3rpx solid var(--color-border-glass-strong);
  border-radius: 50%;
  box-shadow: var(--shadow-sm);
}

.profile-card__online-dot {
  position: absolute;
  right: -4rpx;
  bottom: -4rpx;
  width: 16rpx;
  height: 16rpx;
  background: var(--color-success);
  border: 2rpx solid var(--color-bg);
  border-radius: 50%;
}

.profile-card__actions {
  display: flex;
  flex-shrink: 0;
  gap: 10rpx;
  align-items: center;
  margin-right: -10rpx;
  margin-left: auto;
}

.profile-card__action-btn {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 52rpx;
  height: 52rpx;
  background: var(--color-bg-alpha-95);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 999rpx;

  @supports (backdrop-filter: blur(10px)) or (-webkit-backdrop-filter: blur(10px)) {
    background: var(--color-glass-light);
    -webkit-backdrop-filter: blur(10px);
    backdrop-filter: blur(10px);
  }
}

.profile-card__notify-badge {
  position: absolute;
  top: -8rpx;
  right: -6rpx;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 30rpx;
  height: 30rpx;
  padding: 0 8rpx;
  font-size: 18rpx;
  color: var(--color-text-inverse);
  background: var(--color-danger);
  border: 2rpx solid var(--color-border-glass-strong);
  border-radius: 999rpx;
}

.profile-card__main {
  flex: 1;
  min-width: 0;
}

.profile-card__top {
  gap: 16rpx;
  align-items: center;
  margin-bottom: 18rpx;
}

.profile-card__name {
  flex: 1;
  min-width: 0;
  font-size: 38rpx;
  font-weight: 700;
  color: var(--color-text-inverse);
}

.profile-card__desc {
  display: -webkit-box;
  margin-top: 12rpx;
  overflow: hidden;
  font-size: 24rpx;
  line-height: 1.6;
  color: var(--color-text-inverse);
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
}

.profile-card__hint {
  display: block;
  margin-top: 14rpx;
  font-size: 24rpx;
  color: var(--color-text-inverse);
}

.profile-card__tags {
  flex-wrap: wrap;
  gap: 12rpx;
}

.profile-card__action {
  flex-shrink: 0;
  align-self: center;
}

.quick-cards {
  position: relative;
  z-index: var(--z-sticky);
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20rpx;
  margin-top: 24rpx;
  margin-bottom: 0;
}

.community-card {
  position: relative;
  display: flex;
  gap: 24rpx;
  align-items: center;
  padding: 36rpx;
  overflow: hidden;
  background: transparent;
  border-radius: 32rpx;
  box-shadow: var(--shadow-md);
}

.community-card__bg {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-base);
  width: 100%;
  height: 100%;
  pointer-events: none;
  opacity: 1;
}

.community-card__mask {
  position: absolute;
  top: 0;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-sticky);
  background: linear-gradient(
    90deg,
    var(--color-glass) 0%,
    var(--color-glass-light) 55%,
    var(--color-glass) 100%
  );
}

.community-card__logo {
  position: relative;
  box-sizing: border-box;
  width: 84rpx;
  height: 84rpx;
  padding: 10rpx;
  background: var(--color-bg-alpha-95);
  border: 1rpx solid var(--color-border-glass);
  border-radius: 20rpx;
  box-shadow: var(--shadow-sm);
}

.community-card__body {
  position: relative;
  flex: 1;
  min-width: 0;
}

.community-card__arrow {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 44rpx;
  height: 44rpx;
  background: var(--color-glass);
  border-radius: 999rpx;
}

.community-card__title-row {
  display: flex;
  gap: 16rpx;
  align-items: center;
}

.community-card__title {
  display: block;
  margin-top: 14rpx;
  font-size: 32rpx;
  font-weight: 600;
  color: var(--color-text);
  letter-spacing: 0.4rpx;
}

.community-card__tag {
  margin-top: 14rpx;
}

.community-card__desc {
  display: -webkit-box;
  margin-top: 10rpx;
  overflow: hidden;
  font-size: 24rpx;
  line-height: 1.55;
  color: var(--color-text-secondary);
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
}

.section-card {
  padding: 28rpx;
  background: var(--color-bg);
  border-radius: 32rpx;
  box-shadow: var(--shadow-md);
}

.section-card + .section-card {
  margin-top: 24rpx;
}

.section-title {
  display: block;
  margin-bottom: 18rpx;
  font-size: 26rpx;
  font-weight: 600;
  color: var(--color-text);
}

.quick-card {
  display: flex;
  gap: 20rpx;
  align-items: center;
  padding: 28rpx 24rpx;
  background: var(--color-bg);
  border-radius: 24rpx;
  box-shadow: var(--shadow-sm);
}

.quick-card:active {
  box-shadow: var(--shadow-sm);
  transform: scale(0.96);
}

.quick-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 84rpx;
  height: 84rpx;
  border-radius: 22rpx;

  &--info {
    background: var(--color-primary-light);
  }

  &--success {
    background: var(--color-success-light);
  }
}

.quick-card__body {
  flex: 1;
  min-width: 0;
}

.quick-card__title {
  display: block;
  overflow: hidden;
  font-size: 28rpx;
  font-weight: 500;
  line-height: 1.35;
  color: var(--color-text);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.quick-card__desc {
  display: block;
  margin-top: 8rpx;
  overflow: hidden;
  font-size: 22rpx;
  line-height: 1.6;
  color: var(--color-text-secondary);
  text-overflow: ellipsis;
  white-space: nowrap;
}

.menu-row__icon {
  display: flex;
  flex-shrink: 0;
  align-items: center;
  justify-content: center;
  width: 72rpx;
  height: 72rpx;
  border-radius: 22rpx;

  &--primary {
    background: var(--color-primary-alpha-15);
  }

  &--warning {
    background: var(--color-primary-alpha-15);
  }

  &--danger {
    background: var(--color-danger-light);
  }

  &--success {
    background: var(--color-success-light);
  }

  &--info {
    background: var(--color-info-light);
  }
}

.mine-body {
  position: relative;
  z-index: var(--z-base);
  padding: 0 28rpx 40rpx;
  margin-top: 0;
  background: var(--color-bg-secondary);
  border-top-left-radius: 48rpx;
  border-top-right-radius: 48rpx;
}

.menu-list {
  padding: 0 28rpx;
  margin-top: 24rpx;
  overflow: hidden;
  background: var(--color-bg);
  border-radius: 32rpx;
  box-shadow: var(--shadow-lg);
}

.menu-list--flat {
  padding: 0;
  margin-top: 0;
  background: transparent;
  border-radius: 0;
  box-shadow: none;
}

.menu-row {
  gap: 20rpx;
  align-items: center;
  padding: 24rpx 20rpx;
  background: transparent;
}

.menu-row + .menu-row {
  border-top: 1rpx solid var(--color-border-light);
}

.menu-row__main {
  flex: 1;
  min-width: 0;
}

.menu-row__title {
  display: block;
  font-size: 26rpx;
  font-weight: 500;
  color: var(--color-text);
}

.menu-row__desc {
  display: block;
  margin-top: 8rpx;
  font-size: 22rpx;
  color: var(--color-text-secondary);
}

.menu-row__value {
  margin-left: 12rpx;
  font-size: 22rpx;
  color: var(--color-text-placeholder);
}

.logout-section {
  display: flex;
  padding: 36rpx 28rpx 0;
}

.profile-card__button {
  flex-shrink: 0;
  min-width: 156rpx;
  height: 72rpx;
  padding: 0 24rpx;
  font-size: 24rpx;
  font-weight: 600;
  border: 0;
  border-radius: 999rpx;
}

.logout-btn {
  flex: 1;
  width: auto;
  height: 88rpx;
  font-size: 28rpx;
  color: var(--color-danger);
  background: var(--color-bg);
  border: 1rpx solid rgba(239, 68, 68, 0.18);
  border-radius: 24rpx;
  box-shadow: var(--shadow-md);
}

.loading-center {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: rgba(15, 23, 42, 0.72);
  border-radius: 24rpx;
}
</style>
