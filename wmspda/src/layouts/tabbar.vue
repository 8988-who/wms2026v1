<template>
  <view :class="`wot-theme-${theme}`" :style="themeCSSVars">
    <wd-config-provider :theme-vars="themeVars" :theme="theme === 'dark' ? 'dark' : ''">
      <slot />
      <wd-tabbar
        v-model="active"
        bordered
        safe-area-inset-bottom
        fixed
        @change="handleTabbarChange"
      >
        <wd-tabbar-item
          v-for="item in tabbarList"
          :key="item.name"
          :name="item.name"
          :title="item.title"
          :icon="item.icon"
        />
      </wd-tabbar>
      <wd-notify />
      <wd-toast />
      <wd-dialog />
    </wd-config-provider>
  </view>
</template>

<script setup lang="ts">
import { ref, computed, nextTick } from "vue";
import { onShow } from "@dcloudio/uni-app";
import { useThemeStore } from "@/store";

const themeStore = useThemeStore();
const theme = computed(() => themeStore.theme);
const themeVars = computed(() => themeStore.themeVars);
const themeCSSVars = computed(() => themeStore.themeCSSVars);

/** tabbar 配置：name 与页面路径一一对应 */
const tabbarList = [
  { name: "/pages/index/index", title: "首页", icon: "home" },
  { name: "/pages/work/index", title: "工作台", icon: "apps" },
  { name: "/pages/mine/index", title: "我的", icon: "user" },
];

/** 当前激活项，用页面路径作为 name，初始化时根据当前页面设置 */
const active = ref(tabbarList[0].name);

function initActive() {
  const pages = getCurrentPages();
  const currentPage = pages[pages.length - 1];
  const route = (currentPage?.route as string) || "";
  const matched = tabbarList.find((item) => item.name === `/${route}`);
  if (matched) {
    active.value = matched.name;
  }
}

function handleTabbarChange({ value }: { value: string }) {
  active.value = value;
  nextTick(() => {
    uni.switchTab({ url: value });
  });
}

onMounted(() => {
  initActive();

  // #ifdef APP-PLUS
  uni.hideTabBar();
  // #endif
});

onShow(() => {
  initActive();
});
</script>

<script lang="ts">
export default {
  options: {
    addGlobalClass: true,
    virtualHost: false,
    styleIsolation: "shared",
  },
};
</script>
