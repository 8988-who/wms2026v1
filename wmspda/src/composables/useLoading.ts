import { type Ref, type ComputedRef } from "vue";

/**
 * 加载状态管理
 *
 * 提供全局或局部的加载状态管理，支持多个加载任务的并发控制。
 *
 * @example
 * ```ts
 * // 基本使用
 * const loading = useLoading()
 * loading.start()
 * await fetchData()
 * loading.stop()
 *
 * // 带消息
 * loading.start('正在加载数据...')
 *
 * // 异步包装
 * const result = await loading.wrap(fetchData())
 *
 * // 独立实例
 * const localLoading = useLoading({ singleton: false })
 * ```
 */

export interface UseLoadingOptions {
  /** 是否使用全局单例，默认 true */
  singleton?: boolean;
  /** 初始加载状态，默认 false */
  initial?: boolean;
  /** 加载提示消息 */
  message?: string;
}

export interface UseLoadingReturn {
  /** 是否处于加载状态 */
  isLoading: ComputedRef<boolean>;
  /** 加载计数（支持并发） */
  loadingCount: Ref<number>;
  /** 当前加载消息 */
  message: Ref<string>;
  /** 开始加载 */
  start: (msg?: string) => void;
  /** 结束加载 */
  stop: () => void;
  /** 包装异步函数，自动管理加载状态 */
  wrap: <T>(promise: Promise<T>) => Promise<T>;
  /** 设置加载消息 */
  setMessage: (msg: string) => void;
}

/**
 * 创建加载状态实例
 */
function createLoadingState(options: UseLoadingOptions = {}) {
  const { message: initialMessage = "" } = options;

  const loadingCount = ref(0);
  const message = ref(initialMessage);

  const isLoading = computed(() => loadingCount.value > 0);

  /**
   * 开始加载
   * @param msg 加载提示消息
   */
  const start = (msg?: string): void => {
    loadingCount.value++;
    if (msg) {
      message.value = msg;
    }
  };

  /**
   * 结束加载
   */
  const stop = (): void => {
    if (loadingCount.value > 0) {
      loadingCount.value--;
    }
    if (loadingCount.value === 0) {
      message.value = "";
    }
  };

  /**
   * 包装异步函数，自动管理加载状态
   * @param promise 异步 Promise
   */
  const wrap = async <T>(promise: Promise<T>): Promise<T> => {
    try {
      start();
      return await promise;
    } finally {
      stop();
    }
  };

  /**
   * 设置加载消息
   * @param msg 消息内容
   */
  const setMessage = (msg: string): void => {
    message.value = msg;
  };

  return {
    isLoading,
    loadingCount,
    message,
    start,
    stop,
    wrap,
    setMessage,
  };
}

/** 全局单例实例 */
let loadingInstance: UseLoadingReturn | null = null;

/**
 * 加载状态管理 Hook
 *
 * 默认使用全局单例模式，确保整个应用共享同一加载状态。
 * 如需独立状态（如组件内部的局部加载），可传入 `{ singleton: false }`。
 *
 * @param options 配置选项
 */
export function useLoading(options?: UseLoadingOptions): UseLoadingReturn {
  const { singleton = true } = options ?? {};

  if (singleton) {
    if (!loadingInstance) {
      loadingInstance = createLoadingState(options);
    }
    return loadingInstance;
  }

  return createLoadingState(options);
}
