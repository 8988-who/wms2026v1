import { ref, computed, shallowRef, type Ref, type ComputedRef } from "vue";

/**
 * 请求状态管理
 *
 * 封装异步请求的加载状态、错误处理和数据缓存，提供统一的请求管理方式。
 *
 * @example
 * ```ts
 * const { data, loading, error, execute } = useRequest(
 *   () => UserAPI.getUserInfo()
 * )
 *
 * // 立即执行
 * const { data } = useRequest(() => UserAPI.getUserInfo(), { immediate: true })
 *
 * // 手动执行
 * await execute()
 *
 * // 刷新数据
 * await refresh()
 * ```
 */

export interface UseRequestOptions<T> {
  /** 是否立即执行，默认 false */
  immediate?: boolean;
  /** 初始数据 */
  initialData?: T | null;
  /** 请求前的回调 */
  onBefore?: () => void;
  /** 请求成功的回调 */
  onSuccess?: (data: T) => void;
  /** 请求失败的回调 */
  onError?: (error: Error) => void;
  /** 请求完成的回调（无论成功失败） */
  onFinally?: () => void;
  /** 是否重置数据在重新请求时，默认 false */
  resetOnExecute?: boolean;
}

export interface UseRequestReturn<T> {
  /** 响应数据 */
  data: Ref<T | null>;
  /** 是否正在加载 */
  loading: ComputedRef<boolean>;
  /** 错误信息 */
  error: Ref<Error | null>;
  /** 是否已请求过（用于区分初始状态和请求后状态） */
  hasExecuted: Ref<boolean>;
  /** 执行请求 */
  execute: () => Promise<T | null>;
  /** 刷新数据（重新执行请求） */
  refresh: () => Promise<T | null>;
  /** 重置状态 */
  reset: () => void;
}

/**
 * 请求状态管理 Hook
 *
 * @param requestFn 请求函数
 * @param options 配置选项
 */
export function useRequest<T>(
  requestFn: () => Promise<T>,
  options: UseRequestOptions<T> = {}
): UseRequestReturn<T> {
  const {
    immediate = false,
    initialData = null,
    onBefore,
    onSuccess,
    onError,
    onFinally,
    resetOnExecute = false,
  } = options;

  // 使用 shallowRef 避免深层响应式，提升性能
  const data = shallowRef<T | null>(initialData) as Ref<T | null>;
  const error = ref<Error | null>(null);
  const loadingCount = ref(0);
  const hasExecuted = ref(false);

  const loading = computed(() => loadingCount.value > 0);

  /**
   * 执行请求
   */
  const execute = async (): Promise<T | null> => {
    // 重置状态
    if (resetOnExecute) {
      data.value = initialData;
      error.value = null;
    }

    loadingCount.value++;
    hasExecuted.value = true;

    try {
      onBefore?.();
      const result = await requestFn();
      data.value = result;
      error.value = null;
      onSuccess?.(result);
      return result;
    } catch (e) {
      const err = e instanceof Error ? e : new Error(String(e));
      error.value = err;
      onError?.(err);
      return null;
    } finally {
      loadingCount.value--;
      onFinally?.();
    }
  };

  /**
   * 刷新数据
   */
  const refresh = async (): Promise<T | null> => {
    return execute();
  };

  /**
   * 重置状态
   */
  const reset = (): void => {
    data.value = initialData;
    error.value = null;
    loadingCount.value = 0;
    hasExecuted.value = false;
  };

  // 立即执行
  if (immediate) {
    execute();
  }

  return {
    data,
    loading,
    error,
    hasExecuted,
    execute,
    refresh,
    reset,
  };
}

/**
 * 分页请求状态管理
 *
 * @example
 * ```ts
 * const { list, loading, loadMore, refresh, hasMore } = usePagination(
 *   (params) => UserAPI.getUserPage({ ...params, status: 1 }),
 *   { pageSize: 20 }
 * )
 *
 * // 加载更多
 * await loadMore()
 *
 * // 刷新
 * await refresh()
 * ```
 */

export interface PaginationParams {
  pageNum: number;
  pageSize: number;
}

export interface UsePaginationOptions<T> {
  /** 每页条数，默认 10 */
  pageSize?: number;
  /** 初始数据 */
  initialData?: T[];
  /** 请求成功的回调 */
  onSuccess?: (list: T[], total: number) => void;
  /** 请求失败的回调 */
  onError?: (error: Error) => void;
}

export interface UsePaginationReturn<T> {
  /** 数据列表 */
  list: Ref<T[]>;
  /** 是否正在加载 */
  loading: ComputedRef<boolean>;
  /** 错误信息 */
  error: Ref<Error | null>;
  /** 是否还有更多数据 */
  hasMore: ComputedRef<boolean>;
  /** 当前页码 */
  pageNum: Ref<number>;
  /** 总条数 */
  total: Ref<number>;
  /** 是否为空 */
  isEmpty: ComputedRef<boolean>;
  /** 加载更多 */
  loadMore: () => Promise<T[]>;
  /** 刷新（从第一页开始） */
  refresh: () => Promise<T[]>;
  /** 重置 */
  reset: () => void;
}

/**
 * 分页请求 Hook
 *
 * @param requestFn 分页请求函数
 * @param options 配置选项
 */
export function usePagination<T>(
  requestFn: (params: PaginationParams) => Promise<PageResult<T>>,
  options: UsePaginationOptions<T> = {}
): UsePaginationReturn<T> {
  const { pageSize = 10, initialData = [], onSuccess, onError } = options;

  const list = ref<T[]>(initialData) as Ref<T[]>;
  const loadingCount = ref(0);
  const error = ref<Error | null>(null);
  const pageNum = ref(1);
  const total = ref(0);

  const loading = computed(() => loadingCount.value > 0);
  const hasMore = computed(() => list.value.length < total.value);
  const isEmpty = computed(() => list.value.length === 0 && !loading.value);

  /**
   * 加载更多
   */
  const loadMore = async (): Promise<T[]> => {
    // 如果正在加载或没有更多数据，直接返回
    if (loading.value || !hasMore.value) {
      return list.value;
    }

    loadingCount.value++;

    try {
      const result = await requestFn({
        pageNum: pageNum.value,
        pageSize,
      });

      // 如果是第一页，替换数据；否则追加数据
      if (pageNum.value === 1) {
        list.value = result.list;
      } else {
        list.value = [...list.value, ...result.list];
      }

      total.value = result.total;
      pageNum.value++;
      onSuccess?.(result.list, result.total);

      return result.list;
    } catch (e) {
      const err = e instanceof Error ? e : new Error(String(e));
      error.value = err;
      onError?.(err);
      return [];
    } finally {
      loadingCount.value--;
    }
  };

  /**
   * 刷新（从第一页开始）
   */
  const refresh = async (): Promise<T[]> => {
    pageNum.value = 1;
    total.value = 0;
    list.value = [];
    return loadMore();
  };

  /**
   * 重置
   */
  const reset = (): void => {
    list.value = initialData;
    loadingCount.value = 0;
    error.value = null;
    pageNum.value = 1;
    total.value = 0;
  };

  return {
    list,
    loading,
    error,
    hasMore,
    pageNum,
    total,
    isEmpty,
    loadMore,
    refresh,
    reset,
  };
}
