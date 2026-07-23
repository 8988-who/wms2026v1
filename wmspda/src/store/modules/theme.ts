import { defineStore } from "pinia";
import { Storage } from "@/utils/storage";
import { THEME_MODE_KEY, THEME_COLOR_KEY } from "@/constants";
import type { ProviderThemeVars, ThemeColorOption, ThemeMode } from "@/composables/types/theme";
import { themeColorOptions } from "@/composables/types/theme";

/**
 * 主题状态管理 Store
 *
 * 功能说明：
 * - 主题模式切换（明/暗）
 * - 主题色定制
 * - 导航栏颜色同步
 */

export const useThemeStore = defineStore("theme", () => {
  // ==========================================================================
  // 状态
  // ==========================================================================

  /** 当前主题模式 */
  const theme = ref<ThemeMode>(Storage.get<ThemeMode>(THEME_MODE_KEY, "light"));

  /** 当前主题色 */
  const currentThemeColor = ref<ThemeColorOption>(
    Storage.get<ThemeColorOption>(THEME_COLOR_KEY, themeColorOptions[0])
  );

  /**
   * 深色主题变量（仅在 dark 模式下注入）
   * 注意：Wot UI v2 内置了完整的暗黑模式，不需要手动覆盖各个组件变量。
   * 只需在 ConfigProvider 上设置 theme="dark" + 引入官方主题 SCSS 即可。
   * 这里只保留颜色名映射，供自定义 CSS 类使用。
   */
  const darkThemeVars = {};

  /** 主题变量（计算属性，根据模式动态切换） */
  const themeVars = computed<ProviderThemeVars>(() => {
    const base = { colorTheme: currentThemeColor.value.primary };
    if (theme.value === "dark") {
      return { ...base, ...darkThemeVars } as ProviderThemeVars;
    }
    return base as ProviderThemeVars;
  });

  // ==========================================================================
  // 计算属性
  // ==========================================================================

  /** 是否为暗黑模式 */
  const isDark = computed(() => theme.value === "dark");

  /**
   * 将 themeVars 转换为 CSS 变量内联样式字符串
   * light 模式下只注入主题色，避免覆盖 Wot UI 默认亮色样式
   * dark 模式下注入完整的深色变量覆盖
   */
  const kebabCase = (str: string) =>
    str
      .replace(/^./, (s) => s.toLowerCase())
      .replace(/([a-z])([A-Z])/g, "$1-$2")
      .replace(/(\d)/g, "-$1")
      .toLowerCase();

  const themeCSSVars = computed(() => {
    if (theme.value === "light") {
      return `--wot-color-theme:${themeVars.value.colorTheme};`;
    }
    return Object.entries(themeVars.value)
      .map(([key, val]) => `--wot-${kebabCase(key)}:${val}`)
      .join(";");
  });

  // ==========================================================================
  // 方法
  // ==========================================================================

  /**
   * 设置导航栏颜色
   */
  const setNavigationBarColor = () => {
    uni.setNavigationBarColor({
      frontColor: theme.value === "light" ? "#000000" : "#ffffff",
      backgroundColor: theme.value === "light" ? "#ffffff" : "#1f2937",
    });
  };

  /**
   * 切换主题
   * @param mode 指定主题模式，不传则自动切换
   */
  const toggleTheme = (mode?: ThemeMode) => {
    theme.value = mode || (theme.value === "light" ? "dark" : "light");
    Storage.set(THEME_MODE_KEY, theme.value);
    setNavigationBarColor();
  };

  /**
   * 设置主题色
   * @param color 主题色选项
   */
  const setCurrentThemeColor = (color: ThemeColorOption) => {
    currentThemeColor.value = color;
    Storage.set(THEME_COLOR_KEY, color);
  };

  /**
   * 初始化主题
   */
  const initTheme = () => {
    nextTick(() => {
      setNavigationBarColor();
    });
  };

  // ==========================================================================
  // 导出
  // ==========================================================================

  return {
    // 状态
    theme,
    currentThemeColor,
    themeVars,

    // 计算属性
    isDark,
    themeCSSVars,

    // 方法
    toggleTheme,
    setCurrentThemeColor,
    setNavigationBarColor,
    initTheme,
  };
});
