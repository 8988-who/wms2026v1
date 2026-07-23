import type { ThemeColorOption, ThemeMode } from "@/composables/types/theme";
import { themeColorOptions } from "@/composables/types/theme";
import { useThemeStore } from "@/store";

export function useTheme() {
  const store = useThemeStore();

  /**
   * 切换暗黑模式
   * @param mode 指定主题模式，不传则自动切换
   */
  function toggleTheme(mode?: ThemeMode) {
    store.toggleTheme(mode);
  }

  /**
   * 设置主题色
   * @param option 主题色选项
   */
  function setThemeColor(option: ThemeColorOption) {
    store.setCurrentThemeColor(option);
  }

  /**
   * 初始化主题
   */
  function initTheme() {
    store.initTheme();
  }

  // 注意：全局主题管理已在App.vue中处理
  // 包括：系统主题监听、导航栏颜色同步等
  // 组件中一般不需要再调用initTheme()，除非有特殊需求

  return {
    theme: computed(() => store.theme),
    isDark: computed(() => store.isDark),
    currentThemeColor: computed(() => store.currentThemeColor),
    themeVars: store.themeVars,

    themeColorOptions,

    initTheme,
    toggleTheme,
    setThemeColor,
  };
}

// 导出类型和常量供外部使用
export type { ThemeColorOption, ThemeMode };
export { themeColorOptions };
