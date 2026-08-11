# 消息推送模块（message）

## 1. 模块概述

本模块基于 **SSE（Server-Sent Events）** 实现服务端到浏览器的**单向实时消息推送**，是系统内所有"前端需即时感知"能力的统一出口。SSE 连接为**纯内存态**，不落库、无持久化。

对外能力：

- **建立 SSE 连接**：`GET /api/v1/sse/connect`（`text/event-stream`），登录用户调用后持有长连接；
- **在线用户数**：`GET /api/v1/sse/online-count` 即时查询 + 连接建立时/定时任务主动推送；
- **事件推送**：按主题（topic）区分三类事件——`dict`（字典变更）、`online-count`（在线用户数）、`system`（系统消息）；
- **定向/广播**：支持向全部连接广播、向指定用户（多设备）发送。

关键流程简述：

```
浏览器 ──GET /api/v1/sse/connect──► SseController.connect()
        ◄── SseEmitter（30 分钟超时，text/event-stream）──
用户登录后 ──► SseService.createConnection ──► SseSessionRegistry 注册（三张 ConcurrentHashMap）
业务侧（如系统模块 DictController 字典增删改后）──► SseService.sendDictChange ──► registry.broadcast ──► 所有在线连接
定时任务 OnlineUserCountTask（每 3 分钟）──► SseService.sendOnlineCount ──► 广播在线用户数
SseSessionRegistry.heartbeat（每 30 秒）──► 发送 ping ──► 发送失败视为僵尸连接并清理
```

---

## 2. 数据表设计（来源 public.sql）

**无独立建表**。SSE 连接与会话信息全部保存在 **JVM 内存**（`SseSessionRegistry` 中的 `ConcurrentHashMap`），无对应数据库表；在线用户数、连接数等均为内存态实时统计，应用重启即清空。

---

## 3. 数据库交互

**无数据库交互**。SSE 会话、连接数、在线用户数全部保存在 JVM 内存（`SseSessionRegistry` 的 `ConcurrentHashMap`），应用重启即清空；无 Mapper、无 `@Transactional`。相关状态如需持久化需自行扩展（如将会话心跳落到 Redis，实现多实例横向扩展）。

---

## 4. Java 文件清单

> 包根路径：`wms/src/main/java/com/wms/message/...`；以下"引用的包"为该文件 import 中的主要部分。

### 4.1 控制器层（controller）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SseController.java](../../wms/src/main/java/com/wms/message/controller/SseController.java) | SSE 连接入口与在线数查询：`GET /api/v1/sse/connect`、`GET /api/v1/sse/online-count` | `com.wms.common.result.Result`、`com.wms.framework.security.model.SecurityUserDetails`、`com.wms.framework.security.util.SecurityUtils`、`com.wms.message.service.SseService`、`io.swagger.v3.oas.annotations.*`、`lombok.RequiredArgsConstructor/Slf4j`、`org.springframework.http.MediaType`、`org.springframework.web.bind.annotation.*`、`org.springframework.web.servlet.mvc.method.annotation.SseEmitter` | `connect` 以 `produces = MediaType.TEXT_EVENT_STREAM_VALUE` 返回 `SseEmitter`（响应头 `Content-Type: text/event-stream`）；未取到登录用户时返回 null 并告警；用户名取 `SecurityUtils.getUser().getUsername()` 作为会话标识 |

### 4.2 服务层（service）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SseService.java](../../wms/src/main/java/com/wms/message/service/SseService.java) | SSE 服务：连接创建与各类事件发送 | `com.wms.message.dto.DictChangeEvent/OnlineUserDTO`、`com.wms.message.registry.SseSessionRegistry`、`com.wms.message.topic.SseTopics`、`lombok.RequiredArgsConstructor/Slf4j`、`org.springframework.stereotype.Service`、`org.springframework.web.servlet.mvc.method.annotation.SseEmitter`、`java.io.IOException` | `TIMEOUT = 30 * 60 * 1000L`：`new SseEmitter(TIMEOUT)` 设置 30 分钟超时；连接建立后立即发送一次 `online-count` 事件并再次广播；`sendDictChange` 构造 `DictChangeEvent` 后按 `dict` 主题广播；`sendSystemMessage` 用 `Map.of(...)` 组装系统消息按 `system` 主题广播 |

### 4.3 会话注册表（registry）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SseSessionRegistry.java](../../wms/src/main/java/com/wms/message/registry/SseSessionRegistry.java) | SSE 会话注册表：维护连接、心跳检测、僵尸连接清理 | `com.wms.message.dto.OnlineUserDTO`、`lombok.extern.slf4j.Slf4j`、`org.springframework.context.event.ContextClosedEvent/EventListener`、`org.springframework.core.Ordered`、`org.springframework.core.annotation.Order`、`org.springframework.scheduling.annotation.Scheduled`、`org.springframework.stereotype.Component`、`org.springframework.web.servlet.mvc.method.annotation.SseEmitter`、`java.io.IOException`、`java.util.concurrent.ConcurrentHashMap` | 三张 `ConcurrentHashMap` 互相关联：`userEmittersMap`（用户名→连接集合，支持多设备）、`emitterUserMap`（连接→用户名）、`emitterTimeMap`（连接→建立时间）；注册时挂 `onCompletion/onTimeout/onError` 回调自动移除；`broadcast/sendToUser` 发送事件，`IOException` 时移除该连接；详见 [5. 核心实现逻辑](#5-核心实现逻辑) |

### 4.4 定时任务（job）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [OnlineUserCountTask.java](../../wms/src/main/java/com/wms/message/job/OnlineUserCountTask.java) | 在线用户统计定时任务 | `com.wms.message.registry.SseSessionRegistry`、`com.wms.message.service.SseService`、`lombok.RequiredArgsConstructor/Slf4j`、`org.springframework.scheduling.annotation.Scheduled`、`org.springframework.stereotype.Component` | `@Scheduled(cron = "0 */3 * * * ?")` 每 3 分钟统计在线用户数与总连接数（debug 日志），并调用 `sseService.sendOnlineCount()` 广播给所有在线端；`@EnableScheduling` 在启动类 [WmsApplication.java](../../wms/src/main/java/com/wms/WmsApplication.java) 开启 |

### 4.5 主题常量与传输对象（topic、dto、event）

| 文件 | 作用 | 引用的主要包 | 实现要点 |
|------|------|-------------|---------|
| [SseTopics.java](../../wms/src/main/java/com/wms/message/topic/SseTopics.java) | SSE 事件主题常量 | 无（纯常量类，私有构造器） | `DICT = "dict"`（字典变更）、`ONLINE_COUNT = "online-count"`（在线用户数）、`SYSTEM = "system"`（系统消息），发送/监听统一按此命名 |
| [OnlineUserDTO.java](../../wms/src/main/java/com/wms/message/dto/OnlineUserDTO.java) | 在线用户信息 DTO | `lombok.AllArgsConstructor/Data/NoArgsConstructor`、`java.io.Serial`、`java.io.Serializable` | 字段：username（用户名）、sessionCount（会话数，多设备>1）、loginTime（最早登录时间）；由 `getOnlineUsers()` 组装返回 |
| [DictChangeEvent.java（dto）](../../wms/src/main/java/com/wms/message/dto/DictChangeEvent.java) | 字典变更事件 DTO | `lombok.AllArgsConstructor/Data/NoArgsConstructor`、`java.io.Serial`、`java.io.Serializable` | 字段：dictCode（字典编码）、timestamp（事件时间戳）；提供 `DictChangeEvent(String dictCode)` 构造器自动写入当前时间戳；前端收到后清除对应字典本地缓存 |
| [DictChangeEvent.java（event）](../../wms/src/main/java/com/wms/message/event/DictChangeEvent.java) | 字典变更事件（**空文件**） | 无 | 该路径文件为空，实际实现位于 `dto` 包下的同名类，可视为遗留占位文件 |

---

## 5. 核心实现逻辑

### 5.1 SSE 会话管理流程（建立 → 注册 → 发送 → 清理）

```
浏览器 GET /api/v1/sse/connect（SecurityUtils 取当前用户）
  └─► SseService.createConnection(username)
        ├─ 校验用户名为空 → 返回 null
        ├─ new SseEmitter(30 * 60 * 1000)   // 30 分钟超时
        ├─ sessionRegistry.userConnected(username, emitter)
        │     ├─ userEmittersMap.computeIfAbsent(username).add(emitter)  // 多设备并存
        │     ├─ emitterUserMap.put(emitter, username)
        │     ├─ emitterTimeMap.put(emitter, now)
        │     └─ 挂三回调：onCompletion / onTimeout / onError → removeEmitter(emitter)
        │           （三回调皆自动清理三张表，用户无连接后自动摘除 userEmittersMap 键）
        ├─ 立即发送 SseTopics.ONLINE_COUNT 事件（初始在线数）
        └─ sendOnlineCount() 广播最新在线数
```

**事件发送**（`SseSessionRegistry.sendEvent`）：`emitter.send(SseEmitter.event().name(eventName).data(data))` 构建命名事件；捕获 `IOException` 视为连接失效并 `removeEmitter`。

- **广播** `broadcast(eventName, data)`：遍历 `emitterUserMap.keySet()`（全部活跃连接）逐个发送；
- **定向** `sendToUser(username, ...)`：取 `userEmittersMap.get(username)` 下全部连接发送（多设备全部可达）；
- **下线** `userDisconnected(username)`：摘除该用户全部连接并 `emitter.complete()`。

### 5.2 心跳检测与僵尸连接清理（SseSessionRegistry.heartbeat）

```
@Scheduled(fixedRate = 30000)   // 每 30 秒
  └─► heartbeat()
        ├─ 无连接直接返回
        ├─ 遍历所有 emitter 发送 ping 事件（event name = "ping"，data = "heartbeat"）
        ├─ 发送抛异常的 emitter 收集进 failedEmitters
        └─ 对失效连接逐个 removeEmitter（清出三张 Map），防止僵尸连接占满资源
```

**双保险清理机制**：
1. **被动**：`onCompletion / onTimeout / onError` 回调（浏览器关闭/网络中断/超时触发）；
2. **主动**：30 秒心跳探测，发送失败即判定僵尸并清理。

### 5.3 在线数统计（OnlineUserCountTask + SseService）

- `@Scheduled(cron = "0 */3 * * * ?")` 每 3 分钟执行：`getOnlineUserCount()`（在线用户数 = `userEmittersMap.size()`，去重后的用户名数量）+ `getTotalConnectionCount()`（总连接数 = `emitterUserMap.size()`，含多设备），再 `sendOnlineCount()` 广播；
- 连接建立瞬间也会推送一次在线数（见 [5.1](#51-sse-会话管理流程建立--注册--发送--清理)），保证新连接立刻拿到准确数值；
- 提供 `getUserConnectionCount(username)` / `isUserOnline(username)` / `getOnlineUsers()` 供其他模块按需查询。

### 5.4 应用关闭兜底（destroy）

```
@EventListener(ContextClosedEvent.class) + @Order(HIGHEST_PRECEDENCE)
  └─► destroy()
        ├─ 遍历全部 emitter 执行 complete()
        └─ 清空 userEmittersMap / emitterUserMap / emitterTimeMap
```

容器关闭时优先（最高优先级）主动断开所有 SSE 连接，避免长连接阻塞应用优雅停机。

---

## 6. 技术栈

| 技术 | 用途 |
|------|------|
| Spring MVC `SseEmitter` | 服务端 SSE 长连接（`text/event-stream` 响应），30 分钟超时 + 命名事件发送 |
| Spring `@Scheduled`（`@EnableScheduling`） | 心跳检测（fixedRate 30s）与在线数定时统计（cron 每 3 分钟） |
| `ConcurrentHashMap` | 三张内存映射表维护会话（用户↔连接↔时间），支持多设备并发登录 |
| Spring 事件监听 `@EventListener(ContextClosedEvent)` | 应用关闭时主动断开连接，保障优雅停机 |
| Spring Security `SecurityUtils` | 从安全上下文取当前登录用户名作为会话标识 |
| Lombok | `@RequiredArgsConstructor` 构造注入、`@Slf4j` 日志、`@Data` DTO |
| Knife4j / Swagger 注解 | 接口文档（`@Tag(name = "14. SSE连接")`） |
