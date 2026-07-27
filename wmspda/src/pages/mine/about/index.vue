<template>
  <view class="page page--padding">
    <wd-card>
      <view class="about__header">
        <image class="about__logo" src="/static/logo.png" mode="aspectFit" />
        <view class="about__info">
          <text class="about__app-title">wms-pda</text>
          <text class="about__app-version">版本 {{ version }}</text>
        </view>
      </view>

      <view class="about__intro">
        <text class="about__intro-title">项目介绍</text>
        <text class="about__intro-desc">
          WMS仓储管理系统移动端，支持 PDA 扫码操作，实现生产物料的入库、出库、盘点等仓储作业流程管理。
        </text>
      </view>
    </wd-card>

    <view class="about__footer">
      <text class="about__copyright">Copyright {{ getYear() }}</text>
      <text class="about__copyright about__copyright--sub">All Rights Reserved</text>
    </view>
  </view>
</template>

<script lang="ts" setup>
const version = ref(import.meta.env.VITE_APP_VERSION);

const getYear = () => {
  return new Date().getFullYear();
};

onMounted(() => {
  // #ifdef MP-WEIXIN
  const appVersion = uni.getSystemInfoSync().appVersion;
  if (appVersion) {
    version.value = appVersion;
  }
  // #endif
});
</script>

<style lang="scss" scoped>
.about__header {
  display: flex;
  align-items: center;
  padding: 20rpx;
}

.about__logo {
  width: 120rpx;
  height: 120rpx;
  margin-right: 16rpx;
}

.about__info {
  flex: 1;
}

.about__app-title {
  display: block;
  margin-bottom: 8rpx;
  font-size: 32rpx;
  font-weight: 700;
}

.about__app-version {
  display: block;
  font-size: 24rpx;
  color: var(--color-text-secondary);
}

.about__intro-title {
  display: block;
  margin-bottom: 8rpx;
  font-size: 28rpx;
  font-weight: 500;
}

.about__intro-desc {
  display: block;
  font-size: 24rpx;
  line-height: 1.6;
  color: var(--color-text-secondary);
}

.about__intro {
  padding: 0 20rpx 20rpx;
}

.about__footer {
  padding: 32rpx 0;
  text-align: center;
}

.about__copyright {
  display: block;
  font-size: 24rpx;
  color: var(--color-text-placeholder);

  &--sub {
    margin-top: 8rpx;
  }
}
</style>
