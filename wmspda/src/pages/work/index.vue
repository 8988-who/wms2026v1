<template>
  <custom-navbar title="工作台" :show-back="false" />
  <view class="page page--tabbar" :style="{ padding: `${navbar.totalHeight.value + 8}px 32rpx 0` }">
    <template v-for="(item, index) in visibleGridList" :key="index">
      <wd-card :title="item.title">
        <wd-grid clickable :column="4">
          <wd-grid-item
            v-for="(child, childIndex) in item.children"
            :key="childIndex"
            use-slot
            @click="handleNavClick(child)"
          >
            <view class="work-grid__icon p-2">
              <image class="w-72rpx h-72rpx rounded-8rpx" :src="child.icon" />
            </view>
            <view class="work-grid__label">{{ child.title }}</view>
          </wd-grid-item>
        </wd-grid>
      </wd-card>
    </template>
  </view>
</template>

<script lang="ts" setup>
import { computed } from "vue";
import { useNavbar } from "@/composables/useNavbar";
import { useNavigation } from "@/composables/useNavigation";
import { menuConfig } from "@/config/menu";
import { hasPermission as checkPermission } from "@/utils/permission";

definePage({
  name: "work",
  style: {
    navigationStyle: "custom",
    navigationBarTitleText: "工作台",
  },
  layout: "tabbar",
});

const navbar = useNavbar();
const { handleNavClick } = useNavigation();

// 检查是否有权限
const hasPermission = (perm: string) => {
  if (!perm) return true;
  return checkPermission(perm);
};

// 根据权限过滤后的菜单列表
const visibleGridList = computed(() => {
  return menuConfig
    .map((group) => ({
      ...group,
      children: group.children.filter((item) => hasPermission(item.perm)),
    }))
    .filter((group) => group.children.length > 0);
});
</script>
