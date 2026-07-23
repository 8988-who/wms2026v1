<template>
  <view class="page settings-page">
    <view class="settings-group-wrap">
      <wd-cell-group>
        <wd-cell title="主题设置" icon="settings" is-link @click="navigateToTheme" />
        <wd-cell title="用户协议" icon="user" is-link @click="navigateToUserAgreement" />
        <wd-cell title="关于我们" icon="info-circle" is-link @click="navigateToAbout" />
      </wd-cell-group>
    </view>

    <view class="settings-group-wrap">
      <wd-cell-group custom-style="margin-top:24rpx">
        <wd-cell title="网络测试" icon="wifi" is-link @click="navigateToNetworkTest" />
        <wd-cell
          title="清空缓存"
          icon="delete"
          :value="cacheSize"
          clickable
          @click="handleClearCache"
        />
      </wd-cell-group>
    </view>

    <view v-if="isLogin" class="logout-section">
      <wd-button type="danger" block custom-class="logout-btn" @click="handleLogout">
        退出登录
      </wd-button>
    </view>

    <wd-loading
      v-if="isClearing"
      v-model="isClearing"
      text="正在清理..."
      mask
      custom-class="loading-center"
    />
  </view>
</template>

<script lang="ts" setup>
import { useUserStore } from "@/store";
import { onLoad } from "@dcloudio/uni-app";
import { useToast } from "@wot-ui/ui";

definePage({
  name: "settings",
  style: { navigationBarTitleText: "设置" },
});

const userStore = useUserStore();
const toast = useToast();
const isLogin = computed(() => !!userStore.userInfo);

// 主题设置
const navigateToTheme = () => {
  uni.navigateTo({
    url: "/pages/mine/settings/theme/index",
  });
};

// 用户协议
const navigateToUserAgreement = () => {
  uni.navigateTo({
    url: "/pages/mine/settings/agreement/index",
  });
};

// 关于我们
const navigateToAbout = () => {
  uni.navigateTo({
    url: "/pages/mine/about/index",
  });
};

// 网络测试
const navigateToNetworkTest = () => {
  uni.navigateTo({ url: "/pages/mine/settings/network/index" });
};

// 是否正在清理
const isClearing = ref(false);
// 缓存大小
const cacheSize = ref<string>("计算中...");
// 获取缓存大小
const getCacheSize = async () => {
  try {
    // #ifdef MP-WEIXIN
    const res = await uni.getStorageInfo();
    cacheSize.value = formatSize(res.currentSize);
    // #endif
    // #ifdef H5
    cacheSize.value = formatSize(
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

// 格式化存储大小
const formatSize = (size: number) => {
  if (size < 1024) {
    return size + "B";
  } else if (size < 1024 * 1024) {
    return (size / 1024).toFixed(2) + "KB";
  } else {
    return (size / 1024 / 1024).toFixed(2) + "MB";
  }
};

// 处理清除缓存
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
    // 模拟清理过程
    await new Promise((resolve) => setTimeout(resolve, 1500));
    // 清除缓存
    await uni.clearStorage();
    // 更新缓存大小显示
    await getCacheSize();
    // 提示清理成功
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

// 退出登录
const handleLogout = () => {
  uni.showModal({
    title: "提示",
    content: "确定要退出登录吗？",
    confirmColor: "#ff4757",
    success: (res) => {
      if (res.confirm) {
        userStore.logout();
        toast.success("已退出登录");
        setTimeout(() => {
          uni.reLaunch({ url: "/pages/mine/index" });
        }, 800);
      }
    },
  });
};

// 检查登录状态
onLoad(() => {
  getCacheSize();
});
</script>

<style lang="scss" scoped>
.logout-section {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 48rpx;
}

.settings-page {
  padding: 24rpx;
}

.settings-group-wrap {
  margin-bottom: 24rpx;
}

:deep(.wd-cell:active) {
  background-color: var(--color-bg-tertiary) !important;
}

:deep(.logout-btn) {
  height: 88rpx;
  font-size: 32rpx;
  font-weight: 500;
  border-radius: 24rpx;
}

.loading-center {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background-color: rgba(0, 0, 0, 0.6);
  border-radius: 12rpx;
}

.loading-center :deep(.wd-loading__spinner) {
  margin: 0 auto;
}

.loading-center :deep(.wd-loading__text) {
  margin-top: 20rpx;
  color: var(--color-text-inverse);
  text-align: center;
}
</style>
