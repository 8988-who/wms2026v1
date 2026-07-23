import { ref, computed } from "vue";

/**
 * TabBar 状态管理
 *
 * 提供底部导航栏的状态管理功能，包括激活状态切换、徽标数字设置等。
 *
 * @example
 * ```ts
 * const { tabbarList, setTabbarItemActive, setTabbarItem } = useTabbar()
 *
 * // 切换到工作台
 * setTabbarItemActive('work')
 *
 * // 设置徽标数字
 * setTabbarItem('work', 5)
 * ```
 */

export interface TabbarItem {
  /** 唯一标识 */
  name: string;
  /** 徽标数字，null 表示不显示 */
  value: number | null;
  /** 是否激活 */
  active: boolean;
  /** 显示标题 */
  title: string;
  /** 图标名称 */
  icon: string;
}

/** 默认 TabBar 配置 */
const DEFAULT_TABBAR_ITEMS: Omit<TabbarItem, "active">[] = [
  { name: "home", value: null, title: "首页", icon: "home" },
  { name: "work", value: null, title: "工作台", icon: "apps" },
  { name: "mine", value: null, title: "我的", icon: "user" },
];

/**
 * 创建 TabBar 状态实例
 *
 * 使用工厂函数创建独立的状态实例，避免模块级别的状态污染。
 * 每个调用者都可以获得独立的状态管理。
 */
function createTabbarState() {
  const items = ref<TabbarItem[]>(
    DEFAULT_TABBAR_ITEMS.map((item, index) => ({
      ...item,
      active: index === 0,
    }))
  );

  /** TabBar 列表 */
  const tabbarList = computed(() => items.value);

  /** 当前激活的 TabBar 项 */
  const activeTabbar = computed(() => {
    return items.value.find((item) => item.active) || items.value[0];
  });

  /**
   * 获取指定 TabBar 项的徽标数字
   * @param name TabBar 项名称
   */
  const getTabbarItemValue = (name: string): number | null => {
    const item = items.value.find((item) => item.name === name);
    return item?.value ?? null;
  };

  /**
   * 设置 TabBar 项的徽标数字
   * @param name TabBar 项名称
   * @param value 徽标数字
   */
  const setTabbarItem = (name: string, value: number): void => {
    const item = items.value.find((item) => item.name === name);
    if (item) {
      item.value = value;
    }
  };

  /**
   * 设置激活的 TabBar 项
   * @param name TabBar 项名称
   */
  const setTabbarItemActive = (name: string): void => {
    items.value.forEach((item) => {
      item.active = item.name === name;
    });
  };

  /**
   * 重置 TabBar 状态
   */
  const resetTabbar = (): void => {
    items.value = DEFAULT_TABBAR_ITEMS.map((item, index) => ({
      ...item,
      active: index === 0,
    }));
  };

  return {
    tabbarList,
    activeTabbar,
    getTabbarItemValue,
    setTabbarItem,
    setTabbarItemActive,
    resetTabbar,
  };
}

/** 全局单例实例 */
let tabbarInstance: ReturnType<typeof createTabbarState> | null = null;

/**
 * TabBar 状态管理 Hook
 *
 * 默认使用全局单例模式，确保整个应用共享同一状态。
 * 如需独立状态，可传入 `{ singleton: false }` 创建新实例。
 *
 * @param options 配置选项
 * @param options.singleton 是否使用单例模式，默认 true
 */
export function useTabbar(options?: { singleton?: boolean }) {
  const { singleton = true } = options ?? {};

  if (singleton) {
    if (!tabbarInstance) {
      tabbarInstance = createTabbarState();
    }
    return tabbarInstance;
  }

  return createTabbarState();
}
