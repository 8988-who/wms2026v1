import {
  ACCESS_TOKEN_KEY,
  REFRESH_TOKEN_KEY,
  USER_INFO_KEY,
  THEME_MODE_KEY,
  THEME_COLOR_KEY,
} from "@/constants";

/**
 * 存储工具类
 * 提供uni-app Storage操作方法
 */

/**
 * localStorage 存储
 */
function set<T>(key: string, value: T): void {
  uni.setStorageSync(key, JSON.stringify(value));
}

function get<T>(key: string, defaultValue?: T): T {
  const value = uni.getStorageSync(key);
  if (!value) return defaultValue as T;

  try {
    return JSON.parse(value);
  } catch {
    // 如果解析失败，返回原始字符串
    return value as unknown as T;
  }
}

function remove(key: string): void {
  uni.removeStorageSync(key);
}

export const Storage = {
  set,
  get,
  remove,
};

/**
 * 清除所有数据
 */
export function clearAll(): void {
  Storage.remove(ACCESS_TOKEN_KEY);
  Storage.remove(REFRESH_TOKEN_KEY);
  Storage.remove(USER_INFO_KEY);
  Storage.remove(THEME_MODE_KEY);
  Storage.remove(THEME_COLOR_KEY);
}
