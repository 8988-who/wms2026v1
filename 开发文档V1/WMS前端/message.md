# 消息推送模块（message）

## 1. 模块概述

消息推送模块基于 **SSE（Server-Sent Events）** 实现服务端 → 前端的实时单向推送，解决"字典变更实时同步"与"在线人数实时展示"两类业务问题：

- **`useSse.ts`**：自定义 EventSource 封装（fetch + ReadableStream 手写 SSE 协议解析），提供连接/断开/事件订阅/指数退避重连，单例复用，无需原生 `EventSource`（原生不支持自定义 Authorization 头）；
- **`useDictSync.ts`**：订阅 `dict` 事件，收到字典变更通知后清除 `stores/dict` 中对应字典缓存，下次使用自动重新拉取；
- **`useOnlineCount.ts`**：订阅 `online-count` 事件，实时更新在线用户数（dashboard 首页展示）；
- **`stores/dict.ts`**：字典缓存 Store（localStorage 持久化 + 请求队列去重）；
- **`composables/index.ts` / `sse/index.ts`**：统一出口，`setupSse()` 在 `main.ts` 启动时初始化所有 SSE 服务，`cleanupSseServices()` 在登出时统一清理；
- **后端对接**：连接 `/api/v1/sse/connect`（Spring `SseEmitter`，事件名 `dict` / `online-count` / `system`）。

> 连接地址：`${VITE_APP_BASE_API}/api/v1/sse/connect`（dev 为 `/dev-api/api/v1/sse/connect`，prod 为 `/prod-api/api/v1/sse/connect`），经 Vite 代理转发到后端。

## 2. 能力清单

| 能力 | 模块/文件 | 功能概述 |
| --- | --- | --- |
| SSE 连接管理 | [composables/sse/useSse.ts](../../wmsui/src/composables/sse/useSse.ts) | 建立连接（Bearer token 鉴权）、连接超时（10s）、指数退避重连（5s→120s、最多 10 次）、事件订阅/取消订阅、主动断开、资源清理；连接状态机 DISCONNECTED/CONNECTING/CONNECTED |
| 字典实时同步 | [composables/sse/useDictSync.ts](../../wmsui/src/composables/sse/useDictSync.ts) | 订阅 `dict` 事件，`dictStore.removeDictItem(dictCode)` 清除缓存，并广播给注册的回调（onDictChange） |
| 在线人数实时展示 | [composables/sse/useOnlineCount.ts](../../wmsui/src/composables/sse/useOnlineCount.ts) | 订阅 `online-count` 事件，维护 `onlineUserCount`（只读 ref）与 `lastUpdateTime`；dashboard 页使用 |
| 字典缓存 | [stores/dict.ts](../../wmsui/src/stores/dict.ts) | 字典项本地缓存（localStorage，键 `vea:system:dict_cache`）+ 请求队列防止并发重复请求 |
| 全局初始化/清理 | [composables/index.ts](../../wmsui/src/composables/index.ts) / [composables/sse/index.ts](../../wmsui/src/composables/sse/index.ts) | `setupSse()`（main.ts 启动时初始化字典同步 + 在线人数）、`cleanupSseServices()`（登出时清理所有连接） |

## 3. 后端接口

### 3.1 SSE 连接端点（[SseController.java](../../wms/src/main/java/com/wms/message/controller/SseController.java)）

| API | HTTP 方法与路径 | 说明 |
| --- | --- | --- |
| `connect()` | GET `/api/v1/sse/connect` | 建立 SSE 长连接（`produces = text/event-stream`）；基于 Spring `SseEmitter`（超时 30 分钟）；需登录态（`SecurityUtils.getUser()`），未登录返回 null；连接建立后立即推送一次当前在线用户数 |
| `getOnlineCount()` | GET `/api/v1/sse/online-count` | 普通 JSON 接口，查询当前在线用户数（`Result<Integer>`），兜底轮询用 |

### 3.2 SSE 事件协议（[SseTopics.java](../../wms/src/main/java/com/wms/message/topic/SseTopics.java)）

| 事件名（event:） | 数据（data:） | 说明 |
| --- | --- | --- |
| `dict` | `{"dictCode": "gender", "timestamp": 1720000000000}`（[DictChangeEvent.java](../../wms/src/main/java/com/wms/message/dto/DictChangeEvent.java)） | 字典变更通知：后端 `DictServiceImpl` 增删改字典后广播，前端收到后清除对应缓存 |
| `online-count` | 纯数字（如 `12`） | 在线用户数：连接建立时发送一次 + `OnlineUserCountTask` 定时任务 + 上下线变更时广播（[SseService.java](../../wms/src/main/java/com/wms/message/service/SseService.java) `sendOnlineCount`） |
| `system` | `{"sender": "系统通知", "content": "...", "timestamp": ...}` | 系统消息广播（当前前端未订阅，预留） |

### 3.3 连接细节

- **鉴权**：前端用 `fetch` 携带 `Authorization: Bearer <accessToken>`（从 `AuthStorage` 读取）与 `Accept: text/event-stream`，因此不能使用不支持自定义请求头的原生 `EventSource`；
- **认证失败处理**：未检测到令牌时直接跳过连接（`log("未检测到有效令牌，跳过 SSE 连接")`）；后端未登录返回 null，前端读流得到 done 断开；
- **连接建立时机**：`main.ts` 启动即 `setupSse()` 初始化（登录成功后 token 已就绪）；`useOnlineCount` 组件内 `autoInit` 在 onMounted 时若未连接则补充初始化；
- **服务端心跳**：`SseEmitter` 30 分钟超时，连接长期空闲由服务端侧超时回收。

## 4. 文件清单

| 文件 | 作用 | 引用的关键依赖 | 实现要点 |
| --- | --- | --- | --- |
| [composables/sse/useSse.ts](../../wmsui/src/composables/sse/useSse.ts) | SSE 连接封装（核心） | `@/utils/auth`（AuthStorage）、Vue API（ref/computed） | ①**单例**（模块级 `globalInstance`），`useSse()` 幂等返回；②连接：`fetch(url, {headers:{Authorization: Bearer, Accept: text/event-stream}, signal: AbortController})` → `response.body.getReader()` 流式读取；③**手写 SSE 协议解析**：`consumeSseStream` 按行解析 `event:`/`data:`/空行分隔，多行 data 用 `\n` 拼接，空行触发 `flushSseEvent`；④事件分发：`eventHandlers: Map<string, Set<handler>>`，data 优先 `JSON.parse`，解析失败按字符串原样分发；⑤重连：指数退避 `min(基数×2^n, 最大间隔)`，默认 5s 起、上限 120s、最多 10 次（`maxReconnectAttempts: 0` 可无限重试）；连接成功后 `resetReconnectState` 重置计数；主动 `disconnect()` 置 `isManualDisconnect` 不重连；⑥连接超时 10s（`connectionTimeout`）；⑦`on()` 返回取消订阅函数（handler 集合删除，空集合清理事件）；⑧`cleanupSse()` 断开 + 清空全部事件订阅并置空单例；⑨状态机 `SseConnectionState`（DISCONNECTED/CONNECTING/CONNECTED），导出 `isConnected` computed |
| [composables/sse/useDictSync.ts](../../wmsui/src/composables/sse/useDictSync.ts) | 字典变更同步 | `@/stores/dict`（useDictStoreHook）、`./useSse`（useSse） | ①单例；②`initialize()`：`sse.connect()` + `sse.on("dict", handler)`；③收到消息校验 `dictCode` 非空，`dictStore.removeDictItem(dictCode)` 清除缓存；④`onDictChange(cb)` 注册业务回调（可多个，失败单回调 catch 不影响其他），返回取消函数；⑤`cleanup()` 退订 + 清空回调数组 |
| [composables/sse/useOnlineCount.ts](../../wmsui/src/composables/sse/useOnlineCount.ts) | 在线人数更新 | `vue`（ref/onMounted/getCurrentInstance/readonly）、`./useSse`（useSse） | ①单例；②`initialize()`：`sse.connect()` + `sse.on("online-count", cb)`；③回调校验 `Number.isFinite(count) && count >= 0` 后更新 `onlineUserCount`（readonly 暴露）与 `lastUpdateTime`；④组件内 `autoInit: true` 时 onMounted 自动初始化（未连接才连）；⑤`cleanup()` 退订并清零 |
| [composables/sse/index.ts](../../wmsui/src/composables/sse/index.ts) | SSE 服务聚合入口 | `./useDictSync`、`./useOnlineCount`、`./useSse` | ①`setupSse()`：初始化 dictSync + onlineCount 两个服务（调用各自 `initialize`）；②`cleanupSseServices()`：依次 cleanup 两个服务后 `cleanupSse()` 断开底层连接；③重导出 useSse/useDictSync/useOnlineCount/cleanupSse/SseConnectionState 及类型 |
| [composables/index.ts](../../wmsui/src/composables/index.ts) | 组合式函数总出口 | `./sse`、`./useTableSelection`、`./usePageTable` | SSE 相关与表格相关组合式函数的统一 re-export |
| [stores/dict.ts](../../wmsui/src/stores/dict.ts) | 字典缓存 Store | `pinia`（defineStore）、`@/stores`（store）、`@/api/system/dict`（DictAPI/DictItemOption）、`@/constants`（STORAGE_KEYS）、`@vueuse/core`（useStorage） | ①`dictCache` 用 `useStorage` 持久化到 localStorage（键 `vea:system:dict_cache`）；②`loadDictItems`：缓存命中直接返回，未命中走**请求队列**（`requestQueue` 按 dictCode 去重，失败清理队列允许重试）；③`getDictItems` 同步读取；④`removeDictItem` / `clearDictCache` 供 SSE 字典同步与登出清理调用 |
| [main.ts](../../wmsui/src/main.ts) | 应用入口（辅助） | `@/composables`（setupSse） | 启动即调用 `setupSse()` 初始化全部 SSE 服务 |
| [views/dashboard/index.vue](../../wmsui/src/views/dashboard/index.vue) | 仪表盘（使用场景，辅助） | `@/composables`（useOnlineCount）、element-plus | `const { onlineUserCount, isConnected } = useOnlineCount()` 展示在线用户数与连接状态 |

## 5. 核心实现逻辑

### 5.1 useSse 的 EventSource 封装（fetch + 手写协议解析）

```
connect()：
  ① 读取 AuthStorage.getAccessToken()，无 token 则跳过（登录前不建连）
  ② 置 CONNECTING，创建 AbortController
  ③ 启动连接超时定时器（默认 10s，超时自动 disconnect）
  ④ fetch(url, { headers: { Authorization: Bearer <token>, Accept: text/event-stream }, signal })
  ⑤ 响应 OK → 置 CONNECTED + 重置重连计数 → response.body.getReader() 流式读取
     consumeSseStream 循环：decoder.decode(stream:true) 追加 buffer → split("\n") 逐行解析
        - 注释行(:) 忽略
        - event:  → currentEvent（默认 "message"）
        - data:   → 多行以 \n 拼接
        - 空行    → flushSseEvent(currentEvent, data)：JSON.parse 成功分发对象、失败分发字符串
  ⑥ 流 done（服务端关闭）→ 置 DISCONNECTED
  ⑦ catch：
        - AbortError → 主动断开，不重连
        - 其他错误 → 置 DISCONNECTED + scheduleReconnect()：指数退避（5s→10s→…→120s 封顶），超过 10 次停止

事件订阅：
  const unsub = sse.on("online-count", (data) => {...})   // 返回取消订阅函数
  sse.on("dict", (data) => {...})

断开/清理：
  disconnect()：置 isManualDisconnect → 清定时器 → reader.cancel() → abort() → 置 DISCONNECTED
  cleanup()：disconnect() + 清空全部事件订阅（登出时经 cleanupSseServices 调用）
```

### 5.2 字典同步流程（dict 事件 → stores/dict 更新）

```
后端字典增删改（DictServiceImpl）→ SseService.sendDictChange(dictCode)
        ↓ 广播事件 event: dict / data: {"dictCode":"gender","timestamp":...}
前端 useSse 解析分发 → useDictSync.handleDictChangeMessage：
  ① 校验 dictCode 非空
  ② dictStore.removeDictItem(dictCode)（移除 localStorage 与内存中的该字典项）
  ③ 通知 onDictChange 注册的业务回调（逐个 try/catch）
        ↓
业务组件下次调用 useDictStore.loadDictItems(dictCode) 时缓存未命中
  → 经请求队列（防并发重复）重新 GET /api/v1/dicts/{dictCode}/items/options 拉取最新数据
```

### 5.3 在线数更新

```
连接建立（SseService.createConnection）→ 立即发送一次 online-count（当前在线数）
登录/登出或定时任务（OnlineUserCountTask）→ SseService.sendOnlineCount() 广播
        ↓
前端 useOnlineCount：sse.on("online-count") → 数值合法性校验 → onlineUserCount.value = count
        ↓
dashboard 首页：const { onlineUserCount, isConnected } = useOnlineCount() 实时渲染
```

### 5.4 生命周期联动

- **启动**：`main.ts` → `setupSse()` → 初始化字典同步 + 在线人数两个服务（各自 `sse.connect()`，连接单例复用，不会重复建连）；
- **登出**：`userStore.resetAllState()` → `cleanupSseServices()` → 各服务 `cleanup()` 退订 + `cleanupSse()` 断开底层连接并释放资源（详见 auth 模块）；
- **令牌失效**：SSE 连接使用 accessToken 鉴权，token 过期或登出后连接断开即停止推送，随登录重新初始化。

## 6. 技术栈

- **框架**：Vue 3.5（`<script setup>` 组合式函数模式）+ TypeScript
- **状态管理**：Pinia（组合式 Store：dict 字典缓存）
- **实时通信**：SSE（Server-Sent Events）——前端 `fetch` + `ReadableStream` 手写协议解析（替代原生 EventSource 以支持 Bearer 头鉴权）；后端 Spring `SseEmitter`
- **工具库**：@vueuse/core（`useStorage` 实现字典缓存持久化）
- **HTTP 代理**：Vite（`VITE_APP_BASE_API` 前缀，dev `/dev-api`、prod `/prod-api` 代理到后端）
- **构建**：Vite
