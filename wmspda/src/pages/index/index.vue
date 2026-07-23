<template>
  <view class="page page--tabbar">
    <!-- 轮播图 -->
    <view class="relative">
      <wd-swiper v-model:current="current" custom-class="swiper-box" :list="swiperList" autoplay />
      <view class="hero-fade"></view>
    </view>

    <!-- 快捷导航 -->
    <view class="section--overlay">
      <wd-grid clickable :column="4">
        <wd-grid-item
          v-for="(item, index) in quickNavList"
          :key="index"
          use-slot
          @click="handleNavClickWithGuard(item)"
        >
          <view class="nav-item">
            <image class="nav-item__icon" :src="item.icon" mode="aspectFit" />
            <text class="nav-item__label">{{ item.title }}</text>
          </view>
        </wd-grid-item>
      </wd-grid>
    </view>

    <!-- 数据统计 -->
    <view class="m-24rpx">
      <view class="grid grid-cols-2 gap-16rpx">
        <view class="stat-card stat-card--uv">
          <image class="stat-card__icon" src="/static/icons/uv.svg" mode="aspectFit" />
          <view class="stat-card__header">
            <text class="stat-card__label">访客数</text>
            <view class="stat-card__dot stat-card__dot--uv"></view>
          </view>
          <text class="stat-card__num stat-card__num--uv">
            {{ visitOverviewData.todayUvCount }}
          </text>
        </view>
        <view class="stat-card stat-card--pv">
          <image class="stat-card__icon" src="/static/icons/pv.svg" mode="aspectFit" />
          <view class="stat-card__header">
            <text class="stat-card__label">浏览量</text>
            <view class="stat-card__dot stat-card__dot--pv"></view>
          </view>
          <text class="stat-card__num stat-card__num--pv">
            {{ visitOverviewData.todayPvCount }}
          </text>
        </view>
      </view>
    </view>

    <!-- 访问趋势图表 -->
    <view class="m-24rpx">
      <view class="chart-wrapper">
        <view class="chart-header">
          <text class="chart-header__title">访问趋势</text>
          <view class="segment-control">
            <view
              class="segment-control__item"
              :class="{ 'is-active': recentDaysRange === 7 }"
              @click="switchRange(7)"
            >
              近7天
            </view>
            <view
              class="segment-control__item"
              :class="{ 'is-active': recentDaysRange === 15 }"
              @click="switchRange(15)"
            >
              近15天
            </view>
          </view>
        </view>
        <view class="w-full h-600rpx px-20rpx box-border">
          <qiun-data-charts type="area" :chartData="chartData" :opts="chartOpts" />
        </view>
      </view>
    </view>
  </view>
</template>

<script setup lang="ts">
import { computed, ref } from "vue";
import dayjs from "dayjs";
import { onReady, onShow } from "@dcloudio/uni-app";
import { useUserStore } from "@/store";
import { useNavigation } from "@/composables/useNavigation";
import { menuConfig } from "@/config/menu";
import { isLoggedIn } from "@/utils/auth";
import { hasPermission } from "@/utils/permission";
import LogAPI, { type VisitOverview, type VisitTrend } from "@/api/log";

definePage({
  name: "home",
  style: { navigationStyle: "custom" },
  layout: "tabbar",
});

interface NavItem {
  icon: string;
  title: string;
  url: string;
  perm: string;
}

const userStore = useUserStore();
const { handleNavClick } = useNavigation();

const current = ref(0);
const recentDaysRange = ref(7);

const swiperList = ref(["https://www.youlai.tech/storage/youlai/bg02.png"]);

/** 访问概览数据 */
const visitOverviewData = ref<VisitOverview>({
  todayUvCount: 0,
  todayPvCount: 0,
} as VisitOverview);

const userPerms = computed(() => userStore.userInfo?.perms || []);
const isLogged = computed(() => isLoggedIn());
const hasAnyPerm = computed(() => userPerms.value.length > 0);

/** 默认菜单（未登录时显示） */
const defaultNavList = computed(() => {
  const result: NavItem[] = [];
  for (const group of menuConfig) {
    for (const item of group.children) {
      result.push(item);
      if (result.length >= 4) return result;
    }
  }
  return result;
});

/** 快捷入口：已登录按权限过滤，未登录显示默认菜单 */
const quickNavList = computed(() => {
  if (!isLogged.value || !hasAnyPerm.value) return defaultNavList.value;
  const result: NavItem[] = [];
  for (const group of menuConfig) {
    for (const item of group.children) {
      if (hasPermission(item.perm)) result.push(item);
      if (result.length >= 4) return result;
    }
  }
  return result;
});

const chartData = ref({});
const chartOpts = ref({
  padding: [20, 0, 20, 0],
  xAxis: { fontSize: 10, rotateLabel: true, rotateAngle: 30 },
  yAxis: { disabled: true },
  extra: {
    area: {
      type: "curve",
      opacity: 0.2,
      addLine: true,
      width: 2,
      gradient: true,
      activeType: "hollow",
    },
  },
});

/** 加载访问概览统计 */
function loadVisitOverviewData() {
  LogAPI.getVisitOverview()
    .then((data) => (visitOverviewData.value = data))
    .catch(() => {});
}

/** 加载访问趋势图表 */
async function loadVisitTrendData() {
  const endDate = dayjs().format("YYYY-MM-DD");
  const startDate = dayjs()
    .subtract(recentDaysRange.value - 1, "day")
    .format("YYYY-MM-DD");
  try {
    const data: VisitTrend = await LogAPI.getVisitTrend({ startDate, endDate });
    chartData.value = JSON.parse(
      JSON.stringify({
        categories: (data.dates || []).map((d) => dayjs(d).format("MM-DD")),
        series: [
          { name: "访客数", data: data.uvList || [] },
          { name: "浏览量", data: data.pvList || [] },
        ],
      })
    );
  } catch {
    chartData.value = { categories: [], series: [] };
  }
}

/** 快捷导航点击（未登录跳转登录） */
function handleNavClickWithGuard(item: NavItem) {
  if (!isLogged.value || !hasAnyPerm.value) {
    uni.navigateTo({ url: "/pages/login/index" });
    return;
  }
  handleNavClick(item);
}

/** 切换趋势时间范围 */
function switchRange(value: number) {
  if (recentDaysRange.value === value) return;
  recentDaysRange.value = value;
  loadVisitTrendData();
}

onReady(() => {
  loadVisitOverviewData();
  loadVisitTrendData();
});

onShow(() => {
  loadVisitOverviewData();
  loadVisitTrendData();
});
</script>

<style lang="scss">
.swiper-box,
.swiper-box .wd-swiper__item,
.swiper-box image {
  height: 420rpx;
}
</style>

<style lang="scss" scoped>
.hero-fade {
  position: absolute;
  right: 0;
  bottom: 0;
  left: 0;
  z-index: var(--z-sticky);
  height: 120rpx;
  pointer-events: none;
  background: linear-gradient(
    to bottom,
    transparent 0%,
    var(--color-bg-secondary) 60%,
    var(--color-bg-secondary) 100%
  );
}

.chart-wrapper {
  box-sizing: border-box;
  overflow: hidden;
  background: var(--color-bg);
  border: 1rpx solid var(--color-border);
  border-radius: 16rpx;
  box-shadow: var(--shadow-sm);
}

.chart-wrapper .chart-header {
  display: flex;
  gap: 24rpx;
  align-items: center;
  justify-content: space-between;
  padding: 24rpx 20rpx;
}

.chart-header__title {
  font-size: 28rpx;
  font-weight: 600;
  color: var(--color-text);
}

.segment-control {
  display: inline-flex;
  align-items: center;
  padding: 4rpx;
  background: var(--color-bg-tertiary);
  border: 1rpx solid var(--color-border);
  border-radius: 12rpx;
}

.segment-control__item {
  padding: 8rpx 20rpx;
  font-size: 24rpx;
  font-weight: 500;
  color: var(--color-text-secondary);
  border-radius: 8rpx;
  transition: all 0.2s ease;
}

.segment-control__item.is-active {
  color: var(--color-text-inverse);
  background: var(--color-primary);
}

.section--overlay {
  position: relative;
  z-index: var(--z-sticky);
  padding: 18rpx 8rpx;
  margin: 24rpx;
  margin-top: -120rpx;
  background: var(--color-bg);
  border-radius: 24rpx;
  box-shadow: var(--shadow-md);
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 16rpx;

  &__icon {
    width: 72rpx;
    height: 72rpx;
    border-radius: 16rpx;
  }

  &__label {
    margin-top: 12rpx;
    font-size: 24rpx;
    color: var(--color-text);
  }
}

.stat-card {
  position: relative;
  display: flex;
  flex-direction: column;
  padding: 24rpx 20rpx;
  overflow: hidden;
  background: var(--color-bg);
  border: 1rpx solid var(--color-border);
  border-radius: 16rpx;
  box-shadow: var(--shadow-sm);

  &__header {
    position: relative;
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 16rpx;
  }

  &__label {
    font-size: 24rpx;
    font-weight: 500;
    color: var(--color-text-secondary);
  }

  &__icon {
    position: absolute;
    right: 4px;
    bottom: 4px;
    width: 72rpx;
    height: 72rpx;
    opacity: 0.25;
  }

  &__dot {
    width: 12rpx;
    height: 12rpx;
    border-radius: 50%;

    &--uv,
    &--green {
      background: var(--color-success);
      box-shadow: 0 0 10rpx rgba(52, 209, 157, 0.35);
    }

    &--pv,
    &--blue {
      background: var(--color-primary);
      box-shadow: 0 0 10rpx rgba(77, 128, 240, 0.3);
    }
  }

  &__num {
    position: relative;
    font-size: 48rpx;
    font-weight: 700;
    line-height: 1;
    letter-spacing: -1rpx;

    &--uv,
    &--green {
      color: var(--color-success);
    }

    &--pv,
    &--blue {
      color: var(--color-primary);
    }
  }

  &--full {
    flex-direction: row;
    grid-column: 1 / -1;
    align-items: center;
    justify-content: space-between;
    padding: 20rpx 20rpx;

    .stat-card__num {
      font-size: 28rpx;
      letter-spacing: 0;
    }
  }
}
</style>
