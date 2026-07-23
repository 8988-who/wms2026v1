import { getAccessToken } from "@/utils/auth";

export interface UseSseOptions {
  url?: string;
  debug?: boolean;
  connectionTimeout?: number;
  reconnectInterval?: number;
  maxReconnectInterval?: number;
  maxReconnectAttempts?: number;
}

type EventHandler = (data: any) => void;

export enum SseConnectionState {
  DISCONNECTED = "DISCONNECTED",
  CONNECTING = "CONNECTING",
  CONNECTED = "CONNECTED",
}

let globalInstance: ReturnType<typeof createSseConnection> | null = null;

function createSseConnection(options: UseSseOptions = {}) {
  const baseUrl = import.meta.env.VITE_APP_BASE_API;
  const defaultUrl = `${baseUrl}/api/v1/sse/connect`;

  const config = {
    url: options.url ?? defaultUrl,
    debug: options.debug ?? false,
    connectionTimeout: options.connectionTimeout ?? 10000,
    reconnectInterval: options.reconnectInterval ?? 5000,
    maxReconnectInterval: options.maxReconnectInterval ?? 120000,
    maxReconnectAttempts: options.maxReconnectAttempts ?? 10,
  };

  const connectionState = ref<SseConnectionState>(SseConnectionState.DISCONNECTED);
  const isConnected = computed(() => connectionState.value === SseConnectionState.CONNECTED);

  let eventSource: EventSource | null = null;
  let connectionTimeoutTimer: ReturnType<typeof setTimeout> | null = null;
  let isManualDisconnect = false;
  let reconnectTimer: ReturnType<typeof setTimeout> | null = null;
  let reconnectAttempts = 0;
  let currentReconnectInterval = config.reconnectInterval;

  const eventHandlers = new Map<string, Set<EventHandler>>();

  const log = (...args: any[]) => config.debug && console.log("[SSE]", ...args);
  const logError = (...args: any[]) => console.error("[SSE]", ...args);

  const clearTimer = (timer: typeof connectionTimeoutTimer) => {
    if (timer) {
      clearTimeout(timer);
      return null;
    }
    return timer;
  };

  const scheduleReconnect = () => {
    if (isManualDisconnect) return;
    if (config.maxReconnectAttempts > 0 && reconnectAttempts >= config.maxReconnectAttempts) {
      log(`已达到最大重试次数 ${config.maxReconnectAttempts}，停止重连`);
      return;
    }

    reconnectAttempts++;
    log(`将在 ${currentReconnectInterval}ms 后重试（${reconnectAttempts}）`);

    reconnectTimer = setTimeout(() => {
      connect();
      currentReconnectInterval = Math.min(
        currentReconnectInterval * 2,
        config.maxReconnectInterval
      );
    }, currentReconnectInterval);
  };

  const connect = () => {
    isManualDisconnect = false;

    if (connectionState.value !== SseConnectionState.DISCONNECTED) {
      log("SSE 已连接或正在连接中，跳过重复连接");
      return;
    }

    const token = getAccessToken();
    if (!token) {
      log("未检测到有效令牌，跳过 SSE 连接");
      return;
    }

    connectionState.value = SseConnectionState.CONNECTING;

    connectionTimeoutTimer = setTimeout(() => {
      if (connectionState.value === SseConnectionState.CONNECTING) {
        log("SSE 连接超时");
        disconnect();
      }
    }, config.connectionTimeout);

    log("正在建立 SSE 连接...");

    // SSE 连接地址附带 token 参数（EventSource 不支持自定义 Header）
    const separator = config.url.includes("?") ? "&" : "?";
    const fullUrl = `${config.url}${separator}accessToken=${encodeURIComponent(token)}`;

    eventSource = new EventSource(fullUrl);

    eventSource.onopen = () => {
      connectionTimeoutTimer = clearTimer(connectionTimeoutTimer);
      connectionState.value = SseConnectionState.CONNECTED;
      reconnectAttempts = 0;
      currentReconnectInterval = config.reconnectInterval;
      log("SSE 连接已建立");
    };

    eventSource.onerror = () => {
      logError("SSE 连接错误");
      connectionState.value = SseConnectionState.DISCONNECTED;
      cleanupEventSource();
      scheduleReconnect();
    };

    // 监听所有命名事件
    for (const [eventName] of eventHandlers) {
      bindEvent(eventName);
    }

    // 默认监听 message 事件
    bindEvent("message");
  };

  const bindEvent = (eventName: string) => {
    if (!eventSource) return;
    eventSource.addEventListener(eventName, (event: MessageEvent) => {
      const handlers = eventHandlers.get(eventName);
      if (handlers) {
        try {
          const data = JSON.parse(event.data);
          handlers.forEach((h) => h(data));
        } catch {
          handlers.forEach((h) => h(event.data));
        }
      }
      log(`收到事件[${eventName}]:`, event.data);
    });
  };

  const on = (eventName: string, handler: EventHandler): (() => void) => {
    if (!eventHandlers.has(eventName)) {
      eventHandlers.set(eventName, new Set());
      // 如果已连接，动态绑定新事件
      if (eventSource) {
        bindEvent(eventName);
      }
    }
    const handlers = eventHandlers.get(eventName);
    if (!handlers) return () => {};
    handlers.add(handler);
    log(`已订阅事件: ${eventName}`);

    return () => {
      const handlers = eventHandlers.get(eventName);
      if (handlers) {
        handlers.delete(handler);
        if (handlers.size === 0) {
          eventHandlers.delete(eventName);
        }
      }
    };
  };

  const cleanupEventSource = () => {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  };

  const disconnect = () => {
    isManualDisconnect = true;
    connectionTimeoutTimer = clearTimer(connectionTimeoutTimer);
    reconnectTimer = clearTimer(reconnectTimer);
    cleanupEventSource();
    connectionState.value = SseConnectionState.DISCONNECTED;
    log("SSE 连接已断开");
  };

  const cleanup = () => {
    disconnect();
    eventHandlers.clear();
    log("SSE 资源已清理");
  };

  return {
    connectionState: readonly(connectionState),
    isConnected,
    connect,
    disconnect,
    cleanup,
    on,
  };
}

export function useSse(options: UseSseOptions = {}) {
  if (!globalInstance) {
    globalInstance = createSseConnection(options);
  }
  return globalInstance;
}

export function cleanupSse() {
  if (globalInstance) {
    globalInstance.cleanup();
    globalInstance = null;
  }
}
