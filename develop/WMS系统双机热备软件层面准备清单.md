# WMS系统双机热备软件层面准备清单（A/S 主备模式）

> 编写日期：2026-07-14
> 最后更新：2026-07-15（根据选型调整为 A/S 主备模式专用版）
> 适用项目：wms（后端 youlai-boot 4.3.3） + wmsui（前端 vue3-element-admin 4.7.7）
> 数据库：PostgreSQL 16.14 | 缓存：Redis 7.x
> **本次已选方案：A/S 主备模式（主机 Active + 备机 Standby + Keepalived VIP 漂移）**

---

## 一、方案选型结论

### 1.1 模式对比与最终选择

| 模式 | 说明 | 适用场景 | 本次是否采用 |
|------|------|----------|--------------|
| **A/S 主备模式** ✅ 已选 | 主机 Active 跑全部业务；备机 Standby 处于启动待机但不接流量（或进程不启动）；主机故障时通过 Keepalived 将 VIP（虚拟 IP）漂移到备机，备机自动接管全部业务 | WMS 核心业务无超高并发需求，追求**架构简单、切机可靠、运维成本低** | ✅ **采用** |
| A/A 双活模式 | 两台同时跑业务，前端通过 Nginx/HAProxy 分发请求 | 高吞吐、必须水平扩展 | ❌ 不采用 |

### 1.2 A/S 模式下的整体架构

```
                  ┌───────────────┐
                  │   客户端/前端  │  (VITE_API_BASE_URL → VIP)
                  └───────┬───────┘
                          │
                  ┌───────▼───────┐   VRRP 心跳
                  │   VIP (虚拟IP) │◄─────────── Keepalived
                  └───────┬───────┘
             ┌────────────┴────────────┐
     ┌───────▼───────┐         ┌───────▼───────┐
     │  WMS主机(Active) │         │ WMS备机(Standby)│
     │  - App进程运行    │         │  - App进程待机  │
     │  - 接全部流量      │  切机后  │  - 不接流量      │
     │  - 定时任务执行   │ ───────►│  - 启动接管VIP   │
     └───────┬───────┘         └───────┬───────┘
             │                           │
     ┌───────▼───────────────────────────▼───────┐
     │          PostgreSQL 主从 (流复制+VIP)        │
     └───────────────────┬───────────────────────┘
     ┌───────────────────▼───────────────────────┐
     │          Redis Sentinel (主从+哨兵)          │
     └───────────────────┬───────────────────────┘
     ┌───────────────────▼───────────────────────┐
     │      MinIO (独立部署) / 阿里云OSS (推荐)     │
     └───────────────────────────────────────────┘
```

### 1.3 A/S 模式的关键特点（直接影响改造范围）

- ✅ **备机不接请求**：没有请求分发，不会出现一台发的消息另一台用户收不到的问题
- ✅ **备机不执行定时任务**：要么进程不启动，要么启动后不接流量（@Scheduled 不会重复执行）
- ✅ **没有负载均衡重发**：重复请求概率低，幂等性风险大幅降低
- ⚠️ **切机瞬间 SSE 会断**：SSE 是长连接，VIP 漂移后 TCP 连接仍然指向旧主机，需要前端加重连
- ⚠️ **切机速度依赖 Keepalived**：一般 3~10 秒完成漂移，期间用户可能看到短暂连接失败

> **与 A/A 双活的核心区别：A/S 下不需要做「分布式状态同步」，只需要「状态不丢失 + 故障快速切换」。** 这是改造范围能缩小的根本原因。

---

## 二、按优先级分类的准备事项（A/S 模式专用）

### 🔴 P0 必须做（不做切机必出问题 / 数据必丢失）

---

#### P0-1 中间件层高可用（PostgreSQL + Redis）

**当前问题**：生产配置 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L4-L27) 中数据库和 Redis 均为**单点 IP 连接**，中间件挂了应用全断。

##### PostgreSQL 高可用（A/S 模式推荐方案：流复制 + Keepalived VIP）

| 项 | 当前配置 | A/S 模式改造方案 | 优先级 |
|----|----------|------------------|--------|
| 部署方式 | 单实例 | PostgreSQL 流复制主从（1主1从即可，不需要级联从） | P0 |
| 连接地址 | 单 IP `192.168.68.155:5432` | **方案 A（强烈推荐）：Keepalived 给 PostgreSQL 也配一个独立的 VIP**<br>应用 JDBC URL 写这个 DB-VIP，切机时 IP 不变，应用侧零感知<br><br>**方案 B（次选，不改网络只改配置）：JDBC 多主机格式**<br>`jdbc:postgresql://host1:5432,host2:5432/wms_all_template?currentSchema=public&stringtype=unspecified&targetServerType=primary&connectTimeout=5`<br>`targetServerType=primary` 让驱动自动找可写主库，`connectTimeout` 避免卡住 30 秒才切 | P0 |
| Druid 连接池 | 未配置探活/丢弃 | 补充以下参数（A/S 切机后能快速丢弃指向旧主机的死连接）：<br>`test-while-idle: true`<br>`validation-query: SELECT 1`<br>`time-between-eviction-runs-millis: 5000`（每 5 秒检测一次）<br>`remove-abandoned: true`<br>`remove-abandoned-timeout: 60`<br>`max-wait: 3000`（获取连接最多等 3 秒，避免卡死） | P0 |
| 启动顺序 | - | 两台应用所在机器的启动脚本里，先检查 DB-VIP 是否能通再启动 App，避免启动时 DB 没选主导致连接池初始化失败 | P1 |

> **DB 切机演练必做检查项**：
> - `pg_stat_replication` 视图确认 `sync_state` 为 `sync` 或 `quorum`（不要用默认 async 异步复制模式，至少 `synchronous_commit = remote_write`）
> - 流复制延迟 `pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)` < 100MB / 1 秒
> - 手动 `pg_ctl promote` 提升从库后主从角色互换，应用写入是否正常

##### Redis 高可用（A/S 推荐：Redis Sentinel 哨兵模式）

| 项 | 当前配置（prod） | A/S 模式改造方案 | 优先级 |
|----|------------------|------------------|--------|
| 部署方式 | 单实例（prod 写的 `www.youlai.tech:6379`，prod前必须改为内网） | **Redis Sentinel（最低 3 节点：1主 + 1从 + 3哨兵）**<br>⚠️ 注意：哨兵本身必须奇数台（选举需要），如果只有两台物理机就把 3 个哨兵进程分别放在 2 台 App 机 + 1 台 DB 机上，避免 50/50 脑裂 | P0 |
| Spring 配置 | `spring.data.redis.host` 单节点 | 改为 Sentinel 配置，**驱动自动发现主节点，不需要给 Redis 配 VIP**：<br>```yaml<br>spring:<br>  data:<br>    redis:<br>      database: 1<br>      password: Admin@zw8888!<br>      timeout: 5s<br>      lettuce:<br>        pool:<br>          max-active: 8<br>          max-idle: 8<br>          min-idle: 2<br>      sentinel:                                        # 新增这段<br>        master: mymaster<br>        nodes: host1:26379,host2:26379,host3:26379<br>``` | P0 |
| 切机后刷新拓扑 | - | Lettuce 默认已支持 Sentinel 拓扑刷新，但建议显式开启：<br>`spring.data.redis.lettuce.shutdown-timeout: 200ms`<br>并在 Redis 客户端里加 `client-options` 配置，断线后 3 秒超时失败，不阻塞业务线程 | P1 |

> **Redis 切机验证**：
> - `redis-cli -h 主IP INFO replication` 确认 `role:master`、`connected_slaves:1`
> - 手动 `redis-cli DEBUG SEGFAULT` 模拟主挂掉，哨兵是否 10 秒内选主成功，应用是否能继续读写（redis-token 模式下用户不掉线）

---

#### P0-2 SSE 推送切机断连问题 ⚠️ 中风险（A/S 下性质已变，不是分片问题是重连问题）

**A/S 模式下的新问题描述**（与原 A/A 模式问题完全不同，请重点关注）：

[SseSessionRegistry.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java#L30-L37) 用 JVM 本地 ConcurrentHashMap 存 SseEmitter：

| 阶段 | A/S 模式下的表现 | 影响 |
|------|------------------|------|
| **正常运行时** | ✅ 只有主机接流量，所有 SSE 连接都在主机上，推送 100% 可达 | 无任何问题 |
| **切机瞬间（VIP 漂移那几秒）** | ⚠️ 旧主机上已建立的几百条 SSE TCP 长连接，IP 头的目的 IP 还是 VIP，但现在 VIP 已经在备机上了<br>→ TCP 是状态机，这些连接**不会自动迁移到备机**<br>→ 浏览器会一直等，直到超时（默认 30~90 秒）才发现断了 | 这几十秒内用户收不到推送；如果用户刚好在切机瞬间点了出库按钮，出库完成通知收不到 |
| **切机稳定后** | 用户要么等超时自动重连 EventSource，要么手动刷新页面<br>→ 重新建立到备机的 SSE 连接 → 恢复正常 | 需要等待时间，体验取决于重连速度 |

##### A/S 模式下 SSE 的改造方案（**不需要 Redis Pub/Sub！** 省掉一大块工作量）

| 层级 | 改造内容 | 代码/配置位置 | 优先级 |
|------|----------|---------------|--------|
| **前端（关键，必须改）** | 原生 `EventSource` 默认就会自动重连，但默认重连间隔是 3~5 秒，可以通过服务端下发 `retry: 1000` 让浏览器 1 秒就重连（更快）<br><br>**另外必须加：前端监听 SSE 连接状态，断连时在页面右上角 Toast 一个"连接已断开，正在尝试重连…"提示，连上后自动消失，让用户知道当前状态** | 前端 SSE 管理逻辑（需要搜索 wmsui 下的 EventSource 使用处） | **P0** |
| 后端（建议改） | 在 `SseSessionRegistry.userConnected()` 里第一次建立 SSE 时，先 push 一条：<br>`emitter.send(SseEmitter.event().name("open").reconnectTime(1000).data("connected"))`<br>告诉浏览器"下次断了就 1 秒后重连"<br><br>另外在主机优雅停机（destroy 之后）或 Keepalived 摘 VIP 前，主动向所有 SSE 客户端推一条 `server-shutdown` 事件，前端收到后立即主动重连，不等超时 | [SseSessionRegistry.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java#L45-L64) | P1 |
| 在线用户数统计 | ✅ A/S 只有一台在跑，直接读 `userEmittersMap.size()` 就准，**不需要 Redis 汇总** | [OnlineUserCountTask.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/job/OnlineUserCountTask.java#L22-L28) | ✅ 无需改造 |

> 🔑 **A/S 模式的 SSE 改造总结：只需要前端加自动重连和状态提示，后端不需要引入 Redis Pub/Sub，和 A/A 比节省至少 60% 工作量。**

---

#### P0-3 本地定时任务：✅ A/S 模式下无需改造

这是 A/S 模式最大的省力点之一。回顾当前两个本地定时任务：

| 任务类 | A/S 模式结论 | 理由 |
|--------|--------------|------|
| [OnlineUserCountTask.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/job/OnlineUserCountTask.java) 每3分钟广播在线数 | ✅ 完全不用改 | 要么备机进程根本不启动；要么备机启动但不接流量（SSE 连接数为 0），广播也是空消息，不会重复两次 |
| [SseSessionRegistry.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java#L206-L223) 每30秒 SSE 心跳 | ✅ 完全不用改 | 同上，备机 emitterUserMap 是空的，`heartbeat()` 第208行直接 return，不会有任何副作用 |

> ❌ **注意：绝对不要为了"双机一致性"去引入 XXL-JOB 或分布式锁改造定时任务！** A/S 模式下这是过度设计，增加了中间件依赖反而多了一个故障点。

---

#### P0-4 文件存储共享问题（不解决切机后附件全 404）

**当前问题**：[OSS 配置](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L110-L138) 支持 3 种存储类型，本地存储在 A/S 切机后必然丢失文件。

| 存储类型 | A/S 兼容性 | 改造方案 | 优先级 |
|----------|------------|----------|--------|
| **local 本地存储** `storage-path: /Users/theo/home/` | ❌ **绝对禁用** | 立即替换，不要犹豫。主机存的文件备机磁盘上没有，切机后所有历史附件、上传的 Excel、头像、导入文件全部下载失败 404，无法恢复 | **P0 立即改** |
| **minio 对象存储** `endpoint: http://localhost:9000` | ⚠️ 看部署方式 | **方案 1（简单，推荐 2~3 台机器场景）：MinIO 独立部署到单独一台服务器上**<br>两台 WMS App 都连同一个 MinIO IP + 相同 access-key/bucket<br>⚠️ 注意：**不能每台机器各跑一个 MinIO localhost**，那样还是两个独立存储<br><br>**方案 2（MinIO 自己也高可用）：2 台 MinIO 做分布式纠删码模式（最少 4 块盘，2 节点 × 2 块盘）**，MinIO 自己会在两台之间同步，挂一台数据不丢 | P0 |
| **aliyun 阿里云 OSS** `oss-cn-hangzhou.aliyuncs.com` | ✅ 完美兼容，零改造 | 生产环境推荐，直接用。省去维护 MinIO 的高可用和备份 | P0 |

> 额外注意：如果 WMS 有用户上传头像、导入 Excel 入库、下载出库单 PDF 这类功能，**一定要找 5 个真实文件上传下载场景回归测试一下切机前后是否都能访问**，很多时候桶权限或 endpoint 内网不可达平时测不出来，切机才暴露。

---

### 🟡 P1 建议做（不做也能切机成功，但体验 / 安全 / 运维效率打折）

---

#### P1-5 会话管理：强烈建议从 JWT 切换到 Redis-Token 模式

当前配置 [application-prod.yml 第 84 行](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L84)：`security.session.type: jwt`

| 对比项 | JWT（当前） | Redis-Token（建议） | A/S 模式下的影响 |
|--------|-------------|---------------------|------------------|
| 双机兼容性 | ✅ 无状态，天然兼容 | ✅ Redis 集中存储也兼容 | - |
| **切机后管理员踢人 / 禁用用户** | ❌ 做不到。JWT 一旦签发就没法撤销，管理员在后台把某个恶意用户"禁用"了，只要他 token 没过期（默认 2 小时），仍然可以继续做出入库操作 2 小时，安全风险极高 | ✅ App 节点无状态，禁用用户直接删 Redis 里的 token key，下一次请求就 401 了 | **A/S 模式下更严重：如果切机前管理员刚好在主机上执行了"禁用用户"操作，JWT 模式下这个禁用动作在备机上完全无效** |
| 修改角色/权限后实时生效 | ❌ 旧 token 里的 GrantedAuthority 是改之前的，必须用户重新登录才能拿到新权限 | ✅ 每次请求都从 Redis 加载权限（或有版本号机制），改完立即生效 | 切机后运维修改运维账号权限，必须马上生效不能等重新登录 |
| 在线用户 / 会话管理 | ❌ 依赖 SSE 本地 map 统计，不准，切机后清空 | ✅ 直接 `keys login:token:*` 或 SCAN，实时准确 | 切机后管理员能看到真实在线人数，便于判断影响范围 |

**切换步骤（代码侧零侵入，只改配置 + pom 如果有缺失的话）：**

1. 修改 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L82-L90)：

```yaml
security:
  session:
    type: redis-token              # 从 jwt 改为 redis-token
    access-token-time-to-live: 7200      # 2小时，按需调整
    refresh-token-time-to-live: 604800   # 7天
    redis-token:
      allow-multi-login: true      # PDA + 网页同时登录，建议开；如果要求强制一端登录就关
```

2. 启动后验证：登录 → Redis 里 `SCAN 0 MATCH login:token:*` 能看到自己的 token → 手动 DEL 掉 → 刷新页面立即跳登录页 ✅

3. 切机前后对比（必做验证）：切机前主机登录的用户，切到备机后**不需要重新登录**，直接能访问（因为 token 还在 Redis 里）

> 🔑 这项是 WMS 权限管理场景的强烈建议，很多客户现场切机后第一件事就是"我刚改了权限怎么不生效 / 我明明禁用了这个人他还在操作系统"，JWT 必然踩坑。

---

#### P1-6 Keepalived VIP 漂移层（A/S 模式只需要这一个，不需要 Nginx 做 upstream）

A/S 模式下**应用层不需要 Nginx 反向代理**（没必要多一个中间件多一个故障点），直接用 Keepalived 给两台 App 配一个 VIP 即可。

| 配置项 | 值 / 做法 | 说明 |
|--------|-----------|------|
| **虚拟 IP（VIP）** | 选一个和两台 App 同网段、未被占用的 IP，例如 `192.168.68.200` | 所有客户端、前端生产构建、第三方回调地址，**必须统一写这个 VIP，绝对不能写单机 IP** |
| Keepalived 角色 | 主机：`state MASTER` `priority 150`<br>备机：`state BACKUP` `priority 100` | 主机启动后抢占 VIP |
| `virtual_router_id` | 两台完全一致，例如 `51`（不要和网段里其他 Keepalived 实例冲突） | VRRP 组标识 |
| 健康检查脚本 | 每 2 秒 curl 一次本机 App 的健康端点 `http://127.0.0.1:8000/actuator/health`，连续 3 次失败就把 priority 降低到 80，触发 VIP 漂移 | ⚠️ 不要只 ping IP（进程挂了 IP 还在），必须探 HTTP 健康端点 |
| `nopreempt` 非抢占模式 | **建议开启**（主机恢复后不自动抢回 VIP，除非人工确认） | 避免主机恢复抖动瞬间 VIP 来回飘，SSE 又断一次 |
| App `server.address` | `0.0.0.0` 或者干脆不填（默认） | 必须监听 VIP 绑定的网卡 |
| 漂移通知脚本 | 备机 `notify_master` 钩子：VIP 切过来后发告警到企业微信 / 钉钉运维群 | 有切机第一时间知道，别让业务方先告诉你系统挂了 |

> **前端生产构建提醒**：Vite 打包时 [.env.production](file:///e:/wms20260712/wmsui/vue3-element-admin/.env.production)（或同目录文件）里的 `VITE_API_BASE_URL` 必须写 `http://VIP:8000`，**不能写死 192.168.68.xxx 单机 IP**！打包前最后一步让运维 double check。

> **第三方回调地址核查清单**（单独列出来过一遍，别漏掉）：
> - [ ] AGV / RCS 调度系统配置的"WMS 回调地址"
> - [ ] WCS 设备控制系统回调
> - [ ] ERP / MES 接口回调
> - [ ] 短信/邮件模板里嵌入的 WMS 跳转链接
> - [ ] 企业微信 / 钉钉 / 飞书 Webhook 消息里附带的跳转 URL
> - [ ] PDA / 移动端 APP 里硬编码的 API 地址（如果 APK 里写死了 IP，切机后要重新发版）

---

#### P1-7 健康检查 + 优雅停机 + 流量排空

当前 [SseSessionRegistry.destroy()](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java#L228-L246) 已经有容器关闭时断开 SSE 的逻辑，需要补充下面三件事：

##### （1）暴露 Actuator 健康端点

pom.xml 检查有没有 `spring-boot-starter-actuator` 依赖，[pom.xml](file:///e:/wms20260712/wms/youlai-boot/pom.xml) 没有就补上：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

application-prod.yml 补充：

```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info     # 只暴露健康和信息，够用了，不要暴露 shutdown/env/heapdump
  endpoint:
    health:
      show-details: never       # 生产不暴露细节，避免信息泄漏
      probes:
        enabled: true           # 启用 Kubernetes 风格的 liveness/readiness 分组，Keepalived 直接探 /actuator/health/readiness 更精准
```

Keepalived 健康检查就探：`curl -sf http://127.0.0.1:8000/actuator/health/readiness`（200=健康，503=未就绪）。

##### （2）开启 Spring Boot 优雅停机

application-prod.yml 加：

```yaml
server:
  shutdown: graceful             # 收到 SIGTERM 后，先不再接受新请求，等已有请求跑完
  shutdown-timeout: 30s          # 最多等 30 秒，超时强制关
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```

##### （3）**人工切机操作 SOP（一定要写在运维手册里，避免切机 SSE 长时间断连）**

```
人工计划性切机（非故障自动切）的标准步骤：
1. [主机] Keepalived 先手动降低 priority 到 80，让 VIP 先漂移到备机（让新请求全部去备机）
2. [主机] 等 30~60 秒，观察 access.log 不再有新请求
3. [主机] 手动推一条 SSE 广播事件 `server-shutdown`：前端收到立即主动断开重连到备机
4. [主机] systemctl stop wms-app（触发优雅停机）
5. [备机] 确认健康检查正常、数据库写入正常
6. 发群通知：本次切机完成，观察 10 分钟
```

这样操作，SSE 断连时间 < 3 秒，用户几乎感知不到。

---

### 🟢 P2 可选做（锦上添花，不影响切机成功率，有余力再做）

---

#### P2-8 核心接口幂等性（A/S 风险低，按需启用）

| A/S 模式下幂等风险评估 | 结论 |
|------------------------|------|
| 正常运行时 | ✅ 只有主机接请求，没分发没重发，幂等不会被触发 |
| 切机瞬间（最危险的 3~10 秒） | ⚠️ VIP 正在漂移，部分 TCP 请求可能超时重传 / 用户看到"请求失败"手动点"重试" / 前端 axios 拦截器自动重试 → 这 3 种情况可能导致"同一个入库单被创建两次" |
| 切机稳定后 | ✅ 只有备机接流量，恢复正常 |

**结论：A/S 模式下幂等性不是必须做的 P0，但如果业务上"重复入库 = 库存翻倍 = 重大生产事故"，建议还是给最核心的 5 个接口加幂等兜底。**

**最值得加幂等的 WMS 接口（优先级排序）：**
1. 🥇 出库确认 / 库存扣减（扣两次就是大事故）
2. 🥈 入库确认（入两次库存多一倍）
3. 🥉 AGV 任务下发（下两次 AGV 跑两遍）
4. 调拨单确认
5. 盘点结果提交

**A/S 场景推荐的最简幂等方案（不要引入 Redisson，别加太重的依赖）：**

核心思想：`单据号 + 状态机` 双层兜底，足够覆盖 99% 的 A/S 切机重试场景。

```sql
-- 1. 数据库层：业务单据号加唯一索引兜底（必须加）
ALTER TABLE wms_inbound_order ADD CONSTRAINT uk_inbound_order_no UNIQUE (order_no);
ALTER TABLE wms_outbound_order ADD CONSTRAINT uk_outbound_order_no UNIQUE (order_no);
ALTER TABLE wms_transfer_order ADD CONSTRAINT uk_transfer_order_no UNIQUE (order_no);
-- 即使所有应用层逻辑都漏了，数据库会用唯一索引拒绝重复入库，不会插两条
```

```java
// 2. 业务层：状态机防重复流转（出库单举例，伪代码）
@Transactional
public void confirmOutbound(Long orderId) {
    OutboundOrder order = getById(orderId);
    // 关键：如果已经是"已完成"状态，直接返回成功，不要重复扣库存
    if (order.getStatus() == COMPLETED) {
        return; // 幂等返回
    }
    if (order.getStatus() != PENDING) {
        throw new BizException("当前状态不允许确认出库");
    }
    // 状态从 PENDING -> PROCESSING -> COMPLETED，用 CAS 式更新防并发
    int updated = update(Wrappers.lambdaUpdate(OutboundOrder.class)
        .set(OutboundOrder::getStatus, PROCESSING)
        .eq(OutboundOrder::getId, orderId)
        .eq(OutboundOrder::getStatus, PENDING));
    if (updated != 1) {
        return; // 并发已被别人抢占，幂等返回
    }
    // ... 真正扣库存逻辑 ...
    // 最后更新 COMPLETED
}
```

> 🔑 A/S 模式下用"唯一索引 + 状态机检查"就够了，**不要为了做幂等去引入 Redisson 依赖 + 加分布式锁注解**，多一个依赖多一个配置项，Redis 出问题反而会导致所有写接口全挂，得不偿失。

---

#### P2-9 日志集中采集（两台机器的日志放一起查）

A/S 模式下有个实际的运维痛点：故障排查时你不知道当时 VIP 在主机还是备机上，经常要先登主机 tail，没看到报错，再登备机 tail，来回切很麻烦。

**推荐最轻量的方案（不需要 ELK，两台机器资源可能不富余）：**

- 方案 A：Promtail + Loki + Grafana（比 ELK 少 60% 内存占用），每台机跑一个 Promtail 收集本地 log，统一推到 Loki，Grafana 里按 hostname 过滤直接看到底是哪台报的错
- 方案 B：更简单，用 `journald` 或 `rsyslog` 把两台机器的日志统一转发到一台日志 NFS 目录 / 单独的日志机上，按日期和主机名拆分文件

关键建议：MDC 里统一打字段 `traceId`、`userId`、`username`、`requestId`，切机后跨两台机器的请求日志也能通过 traceId 串起来。

---

#### P2-10 配置外置 / 敏感信息脱敏

当前 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L8-L10) 里数据库密码 `Admin@zw8888!`、Redis 密码都是明文写死在 yml 里，如果被拖库或代码外泄风险很大。

**最轻改造（不引入 Nacos）**：全部改成环境变量注入：

```yaml
spring:
  datasource:
    url:        ${WMS_DB_URL:jdbc:postgresql://DB-VIP:5432/wms_all_template?currentSchema=public&stringtype=unspecified}
    username:   ${WMS_DB_USER:postgres}
    password:   ${WMS_DB_PASSWORD:}          # 默认值留空，启动脚本里必须 export 出来，不 export 就直接报错启动失败，避免用默认密码
  data:
    redis:
      password: ${WMS_REDIS_PASSWORD:}
```

systemd 启动文件里用 `EnvironmentFile=/etc/wms/env.conf` 加载密码，文件权限设为 `600 root:root`。

**好处**：两台机器的 `application-prod.yml` 完全一致，不需要分别维护；改密码不需要重新打 jar 包，改环境变量重启即可。

---

#### P2-11 切机演练数据一致性校验脚本

每次切机演练后，自动跑以下 SQL 快速确认数据有没有丢：

```sql
-- PostgreSQL 切机后核心表行数/最大ID对比（和切机前的快照比）
SELECT 'sys_user'      AS table_name, COUNT(*) AS cnt, MAX(id) AS max_id FROM sys_user
UNION ALL SELECT 'sys_dept',     COUNT(*), MAX(id) FROM sys_dept
UNION ALL SELECT 'sys_role',     COUNT(*), MAX(id) FROM sys_role
UNION ALL SELECT 'sys_log',      COUNT(*), MAX(id) FROM sys_log
UNION ALL SELECT 'wms_inbound_order',  COUNT(*), MAX(id) FROM wms_inbound_order   -- 有就补上
UNION ALL SELECT 'wms_outbound_order', COUNT(*), MAX(id) FROM wms_outbound_order
UNION ALL SELECT 'wms_stock',          COUNT(*), MAX(id) FROM wms_stock;
```

Redis 侧（Sentinel 选完主后）：
```bash
# 对比切机前后 DBSIZE，token 数量不能掉一半
redis-cli -h NEW_MASTER_IP -p 6379 -a PASSWORD DBSIZE
# 快速抽样 10 个 token 还在不在
redis-cli -h ... SCAN 0 MATCH "login:token:*" COUNT 10
```

---

#### P2-12 AGV 接口回放压测（如果有对接 AGV）

WMS + AGV 场景下 A/S 切机最容易出的隐形 Bug：**WMS 切机那几秒，AGV 已经到位了，回调 WMS 的"搬运完成"接口刚好赶上 VIP 漂移没接收到 → AGV 以为 WMS 收到了，WMS 实际没收到 → 下一个搬运任务卡死**。

建议：对接完 AGV 后写一个专门的压测脚本，持续以 1 次/秒的频率调用 WMS 的"AGV 回调接口"，中间人为触发一次 Keepalived 切机，切完后统计有没有漏回调的，有没有自动重试成功的。

---

## 三、已天然支持 A/S 双机的模块（无需改造 ✅）

以下模块经过代码核查，**不需要做任何代码改动**就能在 A/S 模式下跑：

| 模块 | 代码位置 | 说明 |
|------|----------|------|
| 登录验证码 | [CaptchaService.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/framework/captcha/service/CaptchaService.java#L64-L69) | 验证码存 Redis，切机后直接读 |
| 接口限流 | [SlidingWindowScript.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/framework/web/ratelimit/SlidingWindowScript.java) | 基于 Redis Lua 原子滑动窗口 |
| JWT / Redis-Token 认证 | - | JWT 无状态 / Redis-Token 有状态但集中存 Redis，都兼容 |
| 用户/角色/菜单/部门/字典/日志/通知/配置/代码生成 | 纯 CRUD | 所有状态都在 PostgreSQL 里，无本地缓存，切机备机直接读 |
| 定时任务 @Scheduled | [OnlineUserCountTask.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/job/OnlineUserCountTask.java) | A/S 模式下备机空跑或不启动，无重复 |
| 文件上传下载 | 依赖共享存储 | 只要 P0-4 做了 MinIO/OSS，切机无缝 |

---

## 四、A/S 模式分阶段实施建议（三档）

| 级别 | 覆盖范围 | 预计改造工作量（人天） | 切机后用户体验 | 适用场景 |
|------|----------|------------------------|----------------|----------|
| **第一档：精简版（能切机，允许短暂手动刷新）** | P0-1（PG+Redis 高可用）<br>P0-4（MinIO/OSS 共享存储）<br>P1-6（Keepalived VIP） | 1~2 天 | SSE 断了用户可能要手动刷新；被禁用用户要 2 小时后才真正登不上 | 临时上线，后面再补优化 |
| **第二档：标准版（推荐 ✅）** | **P0 全部 4 项**<br>+ **P1-5（Redis-Token 会话）**<br>+ **P1-7（健康检查+优雅停机SOP）**<br>+ P2-8 最重要的 3 个单据加唯一索引 + 状态机 | 3~4 天 | 切机 SSE 断 1~3 秒自动重连提示；禁用用户立即生效；切机有标准 SOP，几乎无感 | **大多数客户现场推荐这个档位** |
| **第三档：增强版（运维体验好）** | 全部 P0 + 全部 P1 + **P2-9 日志集中采集** + **P2-10 配置外置** + **P2-12 AGV 回放** | 5~7 天 | 日志直接一起查，密码安全不泄露，AGV 回调无漏 | 运维要求高的正式生产环境 |

---

## 五、A/S 模式切机演练 Checklist（上线前**至少跑 3 次**，每次都要逐项打勾）

### 5.1 计划性人工切机（模拟升级/维护场景）

- [ ] 执行 P1-7 标准 SOP：先降 priority 让 VIP 漂移 → 等 30s 排空 → 推 shutdown 事件 → stop 主机 App
- [ ] VIP 是否 3 秒内在备机上 `ip addr` 能看到？
- [ ] 前端网页是否不需要刷新就能继续操作（axios 重试几次就能成功）？
- [ ] 正在编辑的用户/部门表单，点保存是否一次性成功？
- [ ] 切机前上传的文件，切机后备机是否能下载到？
- [ ] SSE 是否在 3 秒内自动重连成功？右上角 Toast 是否正确显示"已断开 → 已重连"？
- [ ] 切机前登录的用户是否不需要重新登录？（Redis-Token 模式验证点）
- [ ] 切机前禁用的用户，切机后他的操作是否立即 401？（Redis-Token 模式验证点）

### 5.2 故障模拟切机（模拟进程崩溃 / 机器断电场景）

- [ ] 主机 App 进程 `kill -9`（模拟崩溃），Keepalived 是否自动检测到健康检查失败，VIP 10 秒内漂移？
- [ ] 主机 PostgreSQL `pg_ctl stop -m immediate`（模拟 DB 主挂），流复制是否自动提升从库？应用是否 15 秒内恢复写入？
- [ ] 主机 Redis `redis-cli DEBUG SEGFAULT`（模拟 Redis 主崩溃），Sentinel 是否自动选主？应用是否自动重连新主？
- [ ] 故障切机后，再执行一遍 5.1 的业务验证项，业务是否全部正常？

### 5.3 数据一致性验证

- [ ] 核心业务表 count + max_id，切机前后快照一致（没有丢数据）
- [ ] Redis DBSIZE 切机前后变化 < 5%（token 没有大批量丢失）
- [ ] 随机抽 5 张入库单 / 出库单，状态机流转正确，没有"重复执行"痕迹
- [ ] sys_log 里切机那段时间没有大量 500 / 连接超时错误（如果有，说明 timeout 没配好）

### 5.4 网络/第三方验证

- [ ] 所有第三方系统回调的都是 VIP，不是单机 IP（ping 第三方配置的域名/IP 验证）
- [ ] 移动端 PDA 重新打开 APP 后访问的是 VIP（看网络抓包或日志里的 User-Agent）
- [ ] 邮件 / 短信 / 企业微信通知里嵌入的链接都是 VIP 域名

---

## 六、相关代码位置速查表（A/S 模式改造重点涉及）

| 分类 | 文件路径 | 改造动作 |
|------|----------|----------|
| 生产配置（DB/Redis/Session/OSS/Druid/优雅停机） | [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml) | P0-1 / P1-5 / P0-4 / P1-7 配置修改 |
| 应用主配置 | [application.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application.yml) | Actuator 端口确认 |
| pom 依赖检查（Actuator 是否引入） | [pom.xml](file:///e:/wms20260712/wms/youlai-boot/pom.xml) | 补 spring-boot-starter-actuator |
| SSE 会话注册表（加重连 retry 事件 + shutdown 广播） | [SseSessionRegistry.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java) | P0-2 后端改造 |
| 在线用户定时任务（✅ 无需改） | [OnlineUserCountTask.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/job/OnlineUserCountTask.java) | 无需改造 |
| 验证码服务（✅ 无需改） | [CaptchaService.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/framework/captcha/service/CaptchaService.java) | 无需改造 |
| Redis 限流（✅ 无需改） | [SlidingWindowScript.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/framework/web/ratelimit/SlidingWindowScript.java) | 无需改造 |
| 前端 SSE 管理逻辑（加重连 Toast + 监听 server-shutdown） | wmsui/vue3-element-admin/src 下搜索 `EventSource` / `SSE` / `event-source` | P0-2 前端改造 |
| 前端生产环境 API 地址（改为 VIP） | wmsui/vue3-element-admin/.env.production | P1-6 核查项 |

---

## 七、下一步建议

您现在选好了 **A/S 主备模式**，建议按以下顺序推进：

1. **第一步：确认档位** → 选"精简版 / 标准版 / 增强版"中的哪一档？（个人建议**标准版**，性价比最高）
2. **第二步：确认软件清单** → PostgreSQL 流复制、Redis Sentinel、MinIO/OSS、Keepalived，这些中间件是否已有现成实例？还是需要从零部署？
3. **第三步：代码改造** → 按上面的代码位置速查表，一次性把 P0 + P1 的代码和配置改完（我可以帮您逐个文件改）
4. **第四步：联调 + 演练** → 搭好两台机器环境后，按第五章 Checklist 跑 3 次

您告诉我选哪个档位 + 中间件是否已有现成实例，我就可以开始具体的代码改造了。
