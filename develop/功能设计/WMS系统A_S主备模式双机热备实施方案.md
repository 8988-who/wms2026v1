# WMS 系统 A/S 主备模式双机热备实施方案

> 版本：v1.0
> 编写日期：2026-07-15
> 适用范围：wms（后端 youlai-boot 4.3.3） + wmsui（前端 vue3-element-admin 4.7.7）
> 部署模式：Active / Standby 主备（主机 Active 跑全量业务，备机 Standby 待机，故障时 VIP 漂移到备机 3~10 秒内接管）

---

## 目录

- [一、部署架构总览](#一部署架构总览)
- [二、部署前准备（两台机器 + 一台存储机，全部先做）](#二部署前准备两台机器--一台存储机全部先做)
- [三、PostgreSQL 16 流复制主备部署（P0-1）](#三postgresql-16-流复制主备部署p0-1)
- [四、Redis 7.x Sentinel 哨兵主从部署（P0-1）](#四redis-7x-sentinel-哨兵主从部署p0-1)
- [五、Keepalived VIP 漂移部署（App-VIP + 可选 DB-VIP）](#五keepalived-vip-漂移部署app-vip--可选-db-vip)
- [六、MinIO 共享存储部署 / 阿里云 OSS 确认（P0-4）](#六minio-共享存储部署--阿里云-oss-确认p0-4)
- [七、WMS 后端（youlai-boot）配置与代码改造](#七wms-后端youlai-boot配置与代码改造)
- [八、WMS 前端（vue3-element-admin）配置改造](#八wms-前端vue3-element-admin配置改造)
- [九、标准启动顺序 + 上线前冒烟测试](#九标准启动顺序--上线前冒烟测试)
- [十、切机演练 SOP（必须执行 3 次，附 Checklist）](#十切机演练-sop必须执行-3-次附-checklist)
- [十一、故障回滚 SOP + 应急预案](#十一故障回滚-sop--应急预案)
- [十二、日常运维巡检脚本](#十二日常运维巡检脚本)
- [附录：全部配置文件全文（可直接复制粘贴）](#附录全部配置文件全文可直接复制粘贴)

---

## 一、部署架构总览

### 1.1 服务器角色规划（示例 IP，实际按现场替换）

| 角色 | 主机名 | 内网 IP | 硬件配置建议 | 部署组件 |
|------|--------|---------|--------------|----------|
| **应用主机 Active** | wms-app-node1 | `192.168.68.155`（当前在用） | 4C/8G/系统盘50G + 日志盘100G | WMS 后端应用 + Nginx 前端静态 + Keepalived + Sentinel1 + MinIO1(如果用两节点纠删码) |
| **应用备机 Standby** | wms-app-node2 | `192.168.68.156`（新增） | 4C/8G/系统盘50G + 日志盘100G（与主机完全对称） | WMS 后端应用 + Nginx 前端静态 + Keepalived + Sentinel2 + MinIO2(如果用两节点纠删码) |
| **数据库主机 Primary** | wms-db-node1 | `192.168.68.155`（或独立DB机 `192.168.68.160`，建议独立） | 4C/16G/SSD 200G（WMS对IO要求高，推荐独立DB机） | PostgreSQL 16 主库 + Sentinel3（第三个哨兵放这里，避免50/50脑裂） |
| **数据库备机 Standby** | wms-db-node2 | `192.168.68.156`（或独立DB机 `192.168.68.161`，建议独立） | 4C/16G/SSD 200G（和主库同配置） | PostgreSQL 16 从库 |
| **虚拟 IP（VIP）** | - | **App-VIP `192.168.68.200`** <br>（可选）**DB-VIP `192.168.68.201`** | - | 所有客户端 / 前端 / 第三方回调 **必须写 VIP，禁止写单机 IP** |
| （可选）独立存储机 | wms-storage-node1 | `192.168.68.162` | 4C/8G + SSD/NAS 大容量盘 | 单实例 MinIO / 阿里云 OSS 不需要机器 |

> ⚠️ **硬约束（来自项目配置）务必遵守**：
> - PostgreSQL 版本必须 16.14（或同一大版本 16.x）
> - Redis 版本必须 7.x（7.0.8 / 7.2.3 均可）
> - Redis 密码：`Admin@zw8888!`，PostgreSQL 密码：`Admin@zw8888!`
> - 数据库名固定 `wms_all_template`，schema 固定 `public`
> - Redis 哨兵节点数必须奇数（本方案 3 个：S1+S2+S3，分别放在 node1 / node2 / db-node1，防止脑裂）

### 1.2 整体架构 ASCII 图

```
         ┌─────────────────────────────────────────────────────────────────┐
         │                      客户端 / 前端 / 第三方                       │
         │         VITE_API_BASE_URL = http://App-VIP:8000                  │
         └───────────────────────────────┬─────────────────────────────────┘
                                         │
                                         ▼
                           ┌──────────────────────────┐
                           │      App-VIP .200        │◄────── Keepalived VRRP 心跳
                           │  （可选 DB-VIP .201）    │
                           └─────────────┬────────────┘
                   ┌─────────────────────┴───────────────────────┐
                   │                                             │
         ┌─────────▼──────────┐                      ┌──────────▼─────────┐
         │ wms-app-node1 (A)  │   VIP 漂移后接管      │ wms-app-node2 (S)  │
         │ WMS App + Nginx    │◄────────────────────►│ WMS App + Nginx    │
         │ Sentinel1 (端口26379)                      │ Sentinel2 (端口26379) │
         └─────────┬──────────┘                      └──────────┬─────────┘
                   │                                             │
                   └──────────────────────┬──────────────────────┘
                                          │
          ┌───────────────────────────────┼───────────────────────────────┐
          │                               │                               │
          ▼                               ▼                               ▼
 ┌────────────────────┐       ┌────────────────────┐         ┌─────────────────────┐
 │ PostgreSQL 16 主    │       │ PostgreSQL 16 从    │         │ MinIO / 阿里云 OSS   │
 │ 192.168.68.160:5432 │ ─WAL─►│ 192.168.68.161:5432 │         │ 文件共享，双机都读写 │
 │  + Sentinel3 (26379)│       │                    │         └─────────────────────┘
 └─────────┬──────────┘       └────────────────────┘
           │
     ┌─────▼──────┐
     │ Redis 7.x  │◄─────── 3 个 Sentinel 监控，故障自动选主
     │ 主(6379)+从 │
     └────────────┘
```

---

## 二、部署前准备（两台机器 + 一台存储机，全部先做）

以下命令在 **node1、node2、db-node1、db-node2、storage-node1** 所有机器上执行。

### 2.1 操作系统基础配置

```bash
# 1) 关闭防火墙（内网环境，生产建议按端口开，不要直接关）
systemctl stop firewalld && systemctl disable firewalld
# 或者开放需要的端口：
# firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.68.0/24" accept' && firewall-cmd --reload

# 2) 关闭 SELinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

# 3) 配置主机名（每台机器对应自己的名字）
hostnamectl set-hostname wms-app-node1   # node1 上跑
hostnamectl set-hostname wms-app-node2   # node2 上跑
hostnamectl set-hostname wms-db-node1    # db-node1 上跑
hostnamectl set-hostname wms-db-node2    # db-node2 上跑

# 4) 所有机器的 /etc/hosts 追加下面这段（互相解析，内网不要用 DNS）
cat >> /etc/hosts <<'EOF'
192.168.68.155  wms-app-node1
192.168.68.156  wms-app-node2
192.168.68.160  wms-db-node1
192.168.68.161  wms-db-node2
192.168.68.162  wms-storage-node1
192.168.68.200  wms-app-vip
192.168.68.201  wms-db-vip
EOF

# 5) 内核参数优化（PostgreSQL / Redis / 高并发都需要）
cat >> /etc/sysctl.conf <<'EOF'
# 文件句柄
fs.file-max = 2097152
# 共享内存段最大尺寸（PostgreSQL用，一般设为内存的1/4）
kernel.shmmax = 4294967295
kernel.shmall = 1073741823
# TCP 优化，快速回收 TIME_WAIT，切机后快速释放旧连接
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 1024 65535
# 允许非绑定 VIP（Keepalived 需要）
net.ipv4.ip_nonlocal_bind = 1
EOF
sysctl -p

# 6) 文件句柄限制
cat >> /etc/security/limits.conf <<'EOF'
* soft nofile 655350
* hard nofile 655350
postgres soft nofile 655350
postgres hard nofile 655350
redis soft nofile 655350
redis hard nofile 655350
* soft nproc 65535
* hard nproc 65535
EOF

# 7) 时间同步（PostgreSQL 流复制 + 日志排错强依赖时钟一致，差1分钟都可能出玄学问题）
yum install -y chrony
systemctl enable --now chronyd
chronyc sources -v        # 确认能看到 * 打头的同步源
timedatectl set-timezone Asia/Shanghai
```

### 2.2 所有机器之间 postgres/root 用户 SSH 免密

```bash
# 在 node1 / db-node1（两台主机）上执行
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
ssh-copy-id root@wms-app-node1
ssh-copy-id root@wms-app-node2
ssh-copy-id root@wms-db-node1
ssh-copy-id root@wms-db-node2
# 测试免密：
ssh wms-app-node2 "date;hostname"
```

### 2.3 YUM 源准备（内网没外网的话提前搭内网源）

```bash
# PostgreSQL 16 官方源（RedHat/Rocky/AlmaLinux 8/9）
dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
# Redis 7.x (Remi 源或 EPEL)
dnf install -y epel-release
# Keepalived
dnf install -y keepalived
# JDK 17 (youlai-boot 4.x 要求 JDK17+)
dnf install -y java-17-openjdk java-17-openjdk-devel
java -version   # 确认 openjdk version "17.x.x"
```

---

## 三、PostgreSQL 16 流复制主备部署（P0-1）

> 如果您已经把 PostgreSQL 单独部署在 db-node1/db-node2 两台机上，就按下面的步骤操作。如果和 App 混合部署（当前 192.168.68.155 既是 App 又是 DB），所有命令仍适用，只是主机名 IP 改成对应即可。

### 3.1 安装 PostgreSQL 16（db-node1 + db-node2 都执行）

```bash
# 两台 DB 机都执行
dnf install -y postgresql16-server postgresql16-contrib
# 验证
/usr/pgsql-16/bin/postgres -V   # postgres (PostgreSQL) 16.14 或 16.x
```

### 3.2 初始化主库（**仅 db-node1 执行**）

```bash
# 仅 db-node1 执行！
/usr/pgsql-16/bin/postgresql-16-setup initdb
systemctl enable --now postgresql-16
su - postgres -c "psql -c \"ALTER USER postgres WITH PASSWORD 'Admin@zw8888!';\""
```

### 3.3 主库配置（仅 db-node1 操作）

#### 3.3.1 postgresql.conf 关键段

```bash
vi /var/lib/pgsql/16/data/postgresql.conf
```
找到以下参数逐一修改（附：完整全文见 附录A）：

```ini
# ========== 基础 ==========
listen_addresses = '*'                  # 监听所有网卡
port = 5432
max_connections = 500                   # 两台应用 max-active=8，够用
superuser_reserved_connections = 10

# ========== 内存（4C/16G 机器的推荐值）==========
shared_buffers = 4GB                    # 内存 25%
effective_cache_size = 12GB             # 内存 75%
work_mem = 16MB
maintenance_work_mem = 1GB
huge_pages = try

# ========== WAL / 流复制（主备核心） ==========
wal_level = replica
max_wal_senders = 10
max_replication_slots = 10
synchronous_standby_names = 'standby1'  # 同步复制，A/S 强烈建议开，防止最后一笔数据丢失
synchronous_commit = remote_write       # 性能/安全平衡：写到从库OS缓存就返回
wal_sync_method = fdatasync
full_page_writes = on
wal_compression = on
archive_mode = on
archive_command = 'test ! -f /var/lib/pgsql/16/archive/%f && cp %p /var/lib/pgsql/16/archive/%f'  # 先手动建目录
archive_timeout = 10min

# ========== 日志 ==========
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d.log'
log_min_duration_statement = 1000       # 记录 1s 以上慢 SQL
log_line_prefix = '%m [%p] %u@%d app=%a client=%h '
```

建归档目录：
```bash
mkdir -p /var/lib/pgsql/16/archive
chown -R postgres:postgres /var/lib/pgsql/16/archive
chmod 700 /var/lib/pgsql/16/archive
```

#### 3.3.2 pg_hba.conf（主库加复制用户白名单）

```bash
vi /var/lib/pgsql/16/data/pg_hba.conf
```
文件**末尾**追加（完整内容见附录B）：

```ini
# ======= 复制专用账号 =======
host    replication     repluser        127.0.0.1/32            scram-sha-256
host    replication     repluser        192.168.68.155/32       scram-sha-256
host    replication     repluser        192.168.68.156/32       scram-sha-256
host    replication     repluser        192.168.68.160/32       scram-sha-256
host    replication     repluser        192.168.68.161/32       scram-sha-256
# ======= 业务账号：WMS 应用 =======
host    wms_all_template  wms_user      192.168.68.155/32       scram-sha-256
host    wms_all_template  wms_user      192.168.68.156/32       scram-sha-256
host    wms_all_template  postgres      192.168.68.0/24         scram-sha-256
```

#### 3.3.3 创建复制专用账号 + 业务账号

```bash
su - postgres
psql
```
在 psql 里执行：

```sql
-- 1) 复制账号（从库用这个账号连主库拉 WAL）
CREATE ROLE repluser REPLICATION LOGIN PASSWORD 'Repl@zw8888!';

-- 2) WMS 业务账号（建议不用 postgres 超级用户直接跑业务）
CREATE ROLE wms_user LOGIN PASSWORD 'Wms@zw8888!';
GRANT ALL PRIVILEGES ON DATABASE wms_all_template TO wms_user;
\c wms_all_template
GRANT ALL ON SCHEMA public TO wms_user;
GRANT ALL ON ALL TABLES IN SCHEMA public TO wms_user;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO wms_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO wms_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO wms_user;

-- 3) 建复制槽（防止主库从库断开期间主库把 WAL 删了，从库再也跟不上）
SELECT pg_create_physical_replication_slot('standby1_slot');
\q
```

#### 3.3.4 重启主库让配置生效

```bash
systemctl restart postgresql-16
ss -lntp | grep 5432   # 确认监听 0.0.0.0:5432
```

### 3.4 从库基础备份（**仅 db-node2 执行！千万不要在主库跑**）

```bash
# 1) 先把 db-node2 上的 PostgreSQL 16 如果之前 initdb 过，先停再清空
systemctl stop postgresql-16
rm -rf /var/lib/pgsql/16/data/*
chown postgres:postgres /var/lib/pgsql/16/data
chmod 700 /var/lib/pgsql/16/data

# 2) 从主库物理拷贝整个实例（包含所有 database、表空间、WAL）
# 会交互式输入 repluser 的密码 Repl@zw8888!
su - postgres -c "/usr/pgsql-16/bin/pg_basebackup \
  -h wms-db-node1 -p 5432 -U repluser \
  -D /var/lib/pgsql/16/data \
  -Fp -Xs -P -R \
  -S standby1_slot"
```

参数解释：
- `-R`：**自动帮你生成 `standby.signal` 文件 + 在 `postgresql.auto.conf` 里写好 `primary_conninfo`（主库连接串 + repluser 密码）**，这一步最关键，99% 的人从库启动失败就是忘了 -R 还要手写
- `-S standby1_slot`：绑定我们主库上建好的复制槽，断开期间 WAL 不丢
- `-Xs`：流式同步拷贝基础备份过程中产生的 WAL

执行成功后验证：
```bash
ls -la /var/lib/pgsql/16/data/standby.signal   # 文件必须存在！
cat /var/lib/pgsql/16/data/postgresql.auto.conf  # 里面应该已经有 primary_conninfo = 'host=wms-db-node1 ...'
```

### 3.5 从库微调端口 + 启动（db-node2）

```bash
# 因为是拷主库的 postgresql.conf，大部分参数都继承了，按需微调（同机测试需要改 port=5433，跨机不用改）
# vi /var/lib/pgsql/16/data/postgresql.conf
# port = 5432   # 跨机部署保持 5432 即可

# 启动从库
systemctl enable --now postgresql-16
```

### 3.6 主从同步状态验证（最重要的步骤，不通过绝对不要进入下一步）

#### 在**主库 db-node1** 执行：

```sql
SELECT
  pid,
  usename,
  application_name,
  state,
  sync_state,
  client_addr,
  write_lag,
  flush_lag,
  replay_lag,
  pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)) AS delay_size
FROM pg_stat_replication;
```

✅ **预期结果**：
- `state` = `streaming`
- `sync_state` = `sync`（因为我们开了 synchronous_standby_names）
- `delay_size` = `0 bytes` 或 < 1MB
- `client_addr` = 从库 IP

#### 在**从库 db-node2** 执行：

```sql
-- 确认是只读恢复模式
SHOW transaction_read_only;     -- on
SELECT pg_is_in_recovery();      -- t (true)

-- 确认能读业务表
\l                                  -- 能看到 wms_all_template 和 wms_test
\c wms_all_template
SELECT COUNT(*) FROM public.sys_user;  -- 能正常查到数据
```

#### 主从写入同步验证（主库写，从库 10ms 内能读到）：

```sql
-- 主库执行
\c wms_all_template
CREATE TABLE IF NOT EXISTS public.test_sync (id BIGSERIAL PRIMARY KEY, name TEXT, created_at TIMESTAMP DEFAULT NOW());
INSERT INTO test_sync(name) VALUES ('主从写入测试-'||NOW());

-- 立刻去从库执行
SELECT * FROM public.test_sync ORDER BY id DESC LIMIT 1;  -- 必须能看到刚插的那条
```

### 3.7 （强烈推荐）PostgreSQL 也配一个独立 DB-VIP

A/S 模式下**强烈建议 DB 层也配 Keepalived 独立的 DB-VIP `192.168.68.201`**，而不是在 JDBC URL 里写 multi-host：
- 优点：应用 JDBC URL 还是简单的单 IP，完全不用改业务代码，所有数据库端主备切换对应用透明
- 做法：Keepalived 直接部署在 db-node1 和 db-node2 上，和 App-VIP 完全一致（见第五章），只是检测脚本从探 App 改为探 PostgreSQL 的 `SELECT 1`

**附录D中包含完整的 DB-VIP keepalived.conf 样例**。

---

## 四、Redis 7.x Sentinel 哨兵主从部署（P0-1）

> **⚠️ 哨兵数量必须是奇数（3/5/7）才能选举！** 本方案部署 3 个哨兵：
> - Sentinel1 → wms-app-node1 端口 26379
> - Sentinel2 → wms-app-node2 端口 26379
> - Sentinel3 → wms-db-node1 端口 26379
>
> 这样即使任意一整台机器挂了（1 App + 1 DB），存活的 2 个哨兵仍然满足 quorum=2，能正常选主。

### 4.1 安装 Redis 7.x（4 台机：node1 / node2 / db-node1（放哨兵+Redis主） / db-node2（放Redis从））

```bash
# node1 node2 db-node1 db-node2 全部执行
dnf install -y redis7
redis-server -v   # Redis server v=7.2.x  或 7.0.x
mkdir -p /data/redis/{data,log,run}
chown -R redis:redis /data/redis
```

### 4.2 Redis 主库（wms-db-node1 端口 6379）

**/etc/redis/redis.conf** 全文修改（或见附录C）：

```ini
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
timeout 300
tcp-keepalive 60
daemonize yes
supervised systemd
pidfile /data/redis/run/redis_6379.pid
loglevel notice
logfile /data/redis/log/redis_6379.log

dir /data/redis/data
dbfilename dump.rdb
save 900 1
save 300 10
save 60 10000
rdbcompression yes
rdbchecksum yes

# 密码（两台 Redis 主从 + 3 个哨兵必须完全一致）
requirepass Admin@zw8888!
masterauth Admin@zw8888!    # 从库连主库用的密码，主库虽然不用，但写上避免主从切换后新主没密码

maxmemory 4gb
maxmemory-policy allkeys-lru

# AOF 持久化（RDB+AOF双开更安全）
appendonly yes
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb

# 哨兵主从切换必备
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
min-replicas-to-write 1     # 最少 1 台从库连上才允许写，避免脑裂写
min-replicas-max-lag 10
```

```bash
# 启动主库并设置开机自启
systemctl enable --now redis
ss -lntp | grep 6379
redis-cli -a Admin@zw8888! ping   # 返回 PONG
```

### 4.3 Redis 从库（wms-db-node2 端口 6379）

**/etc/redis/redis.conf** 和主库几乎完全一样，**只多加一行**（或直接在启动时执行 replicaof）：

```ini
# 其他所有参数和主库相同（bind/port/password/memory/aof 全部一样）
replicaof wms-db-node1 6379    # <--- 只有从库要加这一行！告诉它主库在哪
```

```bash
systemctl enable --now redis
redis-cli -a Admin@zw8888! INFO replication
```
✅ **从库预期输出**：`role:slave`、`master_host:wms-db-node1`、`master_link_status:up`

✅ **主库预期输出**：`role:master`、`connected_slaves:1`，下面列出从库IP

### 4.4 部署 3 个 Sentinel 哨兵（node1 / node2 / db-node1 各一个）

三台机器上分别创建 `/etc/redis/sentinel.conf`（三台完全一样，内容见附录C）：

```ini
# 3 台机器完全相同
port 26379
daemonize yes
protected-mode no
bind 0.0.0.0
pidfile /data/redis/run/sentinel_26379.pid
logfile /data/redis/log/sentinel_26379.log
dir /data/redis/data

# 监控的主库信息（Sentinel 会自动发现从库，不需要手动加从库）
# 语法：sentinel monitor <主名> <主IP> <主端口> <quorum>
# quorum=2 含义：必须有 2 个哨兵都认为主库挂了，才会开始选主（3个哨兵的标准配置）
sentinel monitor mymaster wms-db-node1 6379 2

# 主库密码（哨兵连主从做心跳也需要密码）
sentinel auth-pass mymaster Admin@zw8888!

# 多少毫秒没 ping 通就认为客观下线（O_DOWN）
sentinel down-after-milliseconds mymaster 3000

# 故障转移后允许多少台从库同时同步新主（1 = 一台一台来，避免带宽打满）
sentinel parallel-syncs mymaster 1

# 故障转移超时时间（超过就放弃重选）
sentinel failover-timeout mymaster 60000

# 通知脚本（切主后调用发企业微信告警，可空）
# sentinel notification-script mymaster /etc/redis/notify_sentinel.sh
```

三台分别启动哨兵：
```bash
# node1, node2, db-node1 分别执行
redis-sentinel /etc/redis/sentinel.conf
# 建议做成 systemd 服务
ss -lntp | grep 26379
```

### 4.5 Sentinel 状态验证 + 主从切换演练

```bash
# 任意一个哨兵上看集群状态
redis-cli -p 26379 sentinel master mymaster
# 关键项：
#   - flags = master（没有 sdown/odown）
#   - num-slaves = 1
#   - num-other-sentinels = 2（总共3个，它自己之外还有2个）
#   - quorum = 2

redis-cli -p 26379 sentinel sentinels mymaster   # 列出所有哨兵
redis-cli -p 26379 sentinel replicas mymaster    # 列出所有从库
```

#### 故障切换模拟（Redis 主库手动崩溃）：

```bash
# 步骤 1：记住当前主库是谁
redis-cli -h wms-db-node1 -p 6379 -a Admin@zw8888! INFO replication | head -2
# role:master

# 步骤 2：写入一条测试数据
redis-cli -h wms-db-node1 -p 6379 -a Admin@zw8888! SET test_failover "hello"

# 步骤 3：DEBUG SEGFAULT 模拟主库崩溃
redis-cli -h wms-db-node1 -p 6379 -a Admin@zw8888! DEBUG SEGFAULT

# 步骤 4：3~6 秒后任意哨兵查询，看 mymaster 的 ip/port 是否变了
sleep 6
redis-cli -p 26379 sentinel get-master-addr-by-name mymaster
# 期望输出：1) "wms-db-node2"   2) "6379"   <--- 从库被选成新主了

# 步骤 5：验证数据还在（新主上有这条 key）
redis-cli -h wms-db-node2 -p 6379 -a Admin@zw8888! GET test_failover
# 输出 "hello" ✅

# 步骤 6：把旧主启动回来，变成新从库（不要立刻又抢回主，让哨兵决定）
systemctl start redis
# 等 30 秒，哨兵会自动把旧主 SLAVEOF 到新主上，变成一主一从恢复
```

✅ Sentinel 主从切换没问题，进入下一步。

---

## 五、Keepalived VIP 漂移部署（App-VIP + 可选 DB-VIP）

### 5.1 安装 Keepalived（node1/node2 两台应用机；若做 DB-VIP 则 db-node1/db-node2 也装）

```bash
dnf install -y keepalived
systemctl enable keepalived
# 启动前先清空默认配置，我们会覆盖
mv /etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf.bak
```

### 5.2 健康检查脚本（两台应用机的 /etc/keepalived/check_wms_app.sh，完全相同）

```bash
mkdir -p /etc/keepalived/scripts
cat > /etc/keepalived/scripts/check_wms_app.sh <<'EOF'
#!/bin/bash
# WMS 应用健康检查脚本
# 探 Actuator readiness 端点：200=健康，返回码0；否则返回码1触发 Keepalived 降 priority
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 \
  http://127.0.0.1:8000/actuator/health/readiness)
if [ "$HTTP_CODE" = "200" ]; then
    exit 0
else
    # 连续 3 次失败再降权，避免抖动
    sleep 1
    HTTP_CODE2=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 \
      http://127.0.0.1:8000/actuator/health/readiness)
    if [ "$HTTP_CODE2" = "200" ]; then
        exit 0
    fi
    exit 1
fi
EOF
chmod +x /etc/keepalived/scripts/check_wms_app.sh
# 手动测一下：
/etc/keepalived/scripts/check_wms_app.sh && echo "HEALTHY" || echo "UNHEALTHY"
```

如果做 DB-VIP，额外再写一份 check_postgresql.sh（见附录D）。

### 5.3 切机通知脚本（两台都放 /etc/keepalived/scripts/notify_wms.sh）

切机时自动发企业微信/钉钉，避免业务方先告诉你"系统挂了"：

```bash
cat > /etc/keepalived/scripts/notify_wms.sh <<'EOF'
#!/bin/bash
# 用法：notify_wms.sh <INSTANCE> <STATE>
# Keepalived 会在状态变时按顺序传入 3 个参数：$1=GROUP|INSTANCE $2=name $3=MASTER|BACKUP|FAULT
NOW=$(date "+%Y-%m-%d %H:%M:%S")
HOST=$(hostname -s)
STATE="$3"
MSG="[WMS-VIP切换告警] 时间=$NOW 机器=$HOST 角色=$STATE"
# 企业微信 Webhook（替换为你们的机器人地址）
curl -s 'https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxx-xxxx-xxxx' \
  -H 'Content-Type: application/json' \
  -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"$MSG\"}}" >/dev/null 2>&1
# 同时落本地日志
echo "$MSG" >> /var/log/keepalived-notify.log
EOF
chmod +x /etc/keepalived/scripts/notify_wms.sh
```

### 5.4 应用主机（node1）keepalived.conf

**/etc/keepalived/keepalived.conf**（完整全文见附录D）：

```ini
! Configuration File for keepalived (WMS APP NODE1 - MASTER)
global_defs {
   router_id WMS_APP_NODE1
   enable_script_security
   script_user root
}

# 健康检查脚本声明（可以被多个 vrrp_instance 复用）
vrrp_script chk_wms {
    script "/etc/keepalived/scripts/check_wms_app.sh"
    interval 2                  # 每 2 秒探一次
    weight -70                  # 脚本返回非0，priority -= 70（150-70=80 < 备机100，触发漂移）
    fall 2                      # 连续 2 次失败才触发
    rise 2                      # 连续 2 次成功才恢复
}

vrrp_instance VI_APP {
    state MASTER                # 主机 MASTER
    interface ens33             # ⚠️ 改为你实际的内网网卡名！（ip a 看）
    virtual_router_id 51        # 主备必须相同，网段内不可冲突（0~255）
    priority 150                # 主机优先级要比备机高（150 vs 100）
    advert_int 1                # 每 1 秒发一次 VRRP 心跳
    nopreempt                   # ⭐ 非抢占模式：主机恢复后不自动抢回 VIP，防止抖动

    authentication {
        auth_type PASS
        auth_pass WmsKp88!      # 主备密码一致（8位）
    }

    unicast_src_ip 192.168.68.155
    unicast_peer {
        192.168.68.156          # 对端 IP（备机地址）
    }

    virtual_ipaddress {
        192.168.68.200/24 dev ens33 label ens33:0   # App-VIP，网卡名必须对！
    }

    # 健康检查绑定
    track_script {
        chk_wms
    }

    # 状态切换通知脚本
    notify_master "/etc/keepalived/scripts/notify_wms.sh VI_APP MASTER"
    notify_backup "/etc/keepalived/scripts/notify_wms.sh VI_APP BACKUP"
    notify_fault  "/etc/keepalived/scripts/notify_wms.sh VI_APP FAULT"
}
```

### 5.5 应用备机（node2）keepalived.conf

和主机几乎一样，**只改 4 处**：

```ini
global_defs {
   router_id WMS_APP_NODE2     # <--- 改1
}
vrrp_instance VI_APP {
    state BACKUP               # <--- 改2：备机 BACKUP
    interface ens33
    virtual_router_id 51
    priority 100               # <--- 改3：比主机低 50

    unicast_src_ip 192.168.68.156   # <--- 改4
    unicast_peer {
        192.168.68.155
    }
    # 其余 VIP / 密码 / track_script / notify 全部和主机一样
```

### 5.6 启动 + VIP 漂移验证

```bash
# 先起备机，再起主机（避免主机没起来时 VIP 也能在备机上顶着）
# node2 执行：
systemctl start keepalived
# node1 执行：
systemctl start keepalived

# ====== 验证 1：VIP 应该在主机 node1 上 ======
# 在 node1 上执行
ip a | grep 192.168.68.200
# 预期：inet 192.168.68.200/24 scope global secondary ens33:0

# ====== 验证 2：ping VIP 通 + 应用 curl 通 ======
# 在任一台第三机（或你本机Windows cmd）：
ping 192.168.68.200 -t
curl -sf http://192.168.68.200:8000/actuator/health/readiness
# {"status":"UP"}

# ====== 验证 3：手动把主机 App kill -9，看 VIP 漂移 ======
# node1 上 kill 掉 WMS App（模拟崩溃，不是停 keepalived）
pkill -9 -f youlai-boot
# 观察 ping VIP：丢 1~5 个包后恢复
# 再看 node2：ip a 应该出现 .200
# node1 App 重新启动恢复后：因为开了 nopreempt，VIP 不会自动抢回（推荐！），除非手动触发
```

✅ 以上三步都通过 → Keepalived App-VIP 部署完成。

---

## 六、MinIO 共享存储部署 / 阿里云 OSS 确认（P0-4）

### 6.1 方案 A（推荐生产）：直接用阿里云 OSS

零改造零运维，只需要 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml#L110-L138) 的 `oss.type` 改成 `aliyun` 并填上阿里云申请的 accessKeyId/accessKeySecret/bucket/endpoint 即可。

**两台应用机都不需要装 MinIO**，直接公网/VPC 访问 OSS，100% 共享。

### 6.2 方案 B：独立存储机单实例 MinIO（最小成本）

在存储机 `wms-storage-node1 192.168.68.162` 上部署：

```bash
useradd -s /sbin/nologin -d /data/minio -m minio
# 下载二进制（有外网直接下，没有先下载好传进去）
wget https://dl.min.io/server/minio/release/linux-amd64/minio -O /usr/local/bin/minio
chmod +x /usr/local/bin/minio
mkdir -p /data/minio/data
chown -R minio:minio /data/minio
# systemd 服务：
cat > /etc/systemd/system/minio.service <<'EOF'
[Unit]
Description=MinIO
After=network.target
[Service]
User=minio
Group=minio
WorkingDirectory=/data/minio
Environment="MINIO_ROOT_USER=minioadmin"
Environment="MINIO_ROOT_PASSWORD=Admin@zw8888!"
ExecStart=/usr/local/bin/minio server /data/minio/data --console-address ":9001"
ExecStop=/bin/kill -s QUIT $MAINPID
Restart=on-failure
LimitNOFILE=655360
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now minio
ss -lntp | grep -E ':9000|:9001'
```

访问 Web 控制台 `http://192.168.68.162:9001` → 创建 `public` 桶 → 设置 Bucket Access Policy 为 public 或者为 WMS 应用生成 AccessKey（不要用 root 账号）。

**两台应用机 application-prod.yml 都改成**：
```yaml
oss:
  type: minio
  minio:
    endpoint: http://192.168.68.162:9000    # 统一写存储机 IP，绝对不能写 localhost
    access-key: minioadmin
    secret-key: Admin@zw8888!
    bucket-name: public
```

### 6.3 方案 C：两节点 MinIO 纠删码（存储高可用，两台机都挂盘）

如果存储也要双机不挂，在 node1/node2 上各挂 2 块盘，共 4 块盘做纠删码（MinIO 最少 4 块盘才能纠删码），挂一整块盘甚至整台机不丢数据。部署命令：

```bash
# node1/node2 都执行（注意 4 个挂载点，2 台 × 2 块 = 4 块）
minio server http://wms-app-node{1...2}/data/minio/disk{1...2} \
  --console-address ":9001"
```

两台同时启动即可组成分布式集群，**任一节点宕机文件仍可读可写**。

---

## 七、WMS 后端（youlai-boot）配置与代码改造

### 7.1 pom.xml 依赖检查：补 spring-boot-starter-actuator

在 [pom.xml](file:///e:/wms20260712/wms/youlai-boot/pom.xml) 里 grep 一下，没有下面这段就补上：

```xml
<dependencies>
    <!-- 如果已存在，不用再加 -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
</dependencies>
```

### 7.2 application-prod.yml 全量改造（最关键步骤之一）

把 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml) 的 DB / Redis / Session / Druid / OSS / 优雅停机 / Actuator 按下面示例全量覆盖。

> ⚠️ **两台应用机的 application-prod.yml 内容完全一致！** 任何差异化配置（如果有的话）都用环境变量注入，不要维护两份文件。

完整改造后示例见附录G，核心改动摘要：

```yaml
server:
  port: 8000
  shutdown: graceful                # 优雅停机
  shutdown-timeout: 30s
  address: 0.0.0.0                  # 监听所有网卡（含VIP绑定网卡）

spring:
  application:
    name: wms
  lifecycle:
    timeout-per-shutdown-phase: 30s

  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: org.postgresql.Driver
    # ======== 改造 1：DB 走 DB-VIP（推荐），应用零感知切主 ========
    url: jdbc:postgresql://192.168.68.201:5432/wms_all_template?currentSchema=public&stringtype=unspecified&connectTimeout=5&socketTimeout=30
    # ======== 备选：不做 DB-VIP，用 JDBC multi-host 自动找主 ========
    # url: jdbc:postgresql://192.168.68.160:5432,192.168.68.161:5432/wms_all_template?currentSchema=public&stringtype=unspecified&targetServerType=primary&connectTimeout=5&socketTimeout=30
    username: ${WMS_DB_USER:wms_user}          # 建议用环境变量，不要硬编码
    password: ${WMS_DB_PASSWORD:Wms@zw8888!}
    druid:
      initial-size: 5
      max-active: 20                            # 两台应用总 40，小于 PG max_connections
      min-idle: 5
      max-wait: 3000                            # 获取连接 3秒超时，切机不死等
      test-while-idle: true
      validation-query: SELECT 1
      time-between-eviction-runs-millis: 5000   # 每 5 秒检测一次
      min-evictable-idle-time-millis: 300000
      remove-abandoned: true
      remove-abandoned-timeout: 60              # 60 秒没关闭的连接强行回收，防止切机泄漏
      log-abandoned: true

  data:
    redis:
      database: 1
      password: ${WMS_REDIS_PASSWORD:Admin@zw8888!}
      timeout: 5s                               # 切主时不阻塞
      lettuce:
        pool:
          max-active: 32
          max-idle: 16
          min-idle: 4
          max-wait: 2000ms
        shutdown-timeout: 200ms
      # ======== 改造 2：Redis 走 Sentinel，不是单节点 host ========
      sentinel:
        master: mymaster
        nodes:                                   # 3 个哨兵 IP:26379
          - 192.168.68.155:26379
          - 192.168.68.156:26379
          - 192.168.68.160:26379

  cache:
    enabled: true
    type: redis
    redis:
      time-to-live: 3600000
      cache-null-values: true

  # ======== 改造 3：文件存储 MinIO/OSS 统一（绝对不能用 local！）========
  mail:
    host: smtp.exmail.qq.com
    port: 465
    username: wms@yourcompany.com
    password: ${WMS_MAIL_PASSWORD:}
    properties:
      smtp:
        auth: true
        ssl:
          enable: true
    from: wms@yourcompany.com

# ======== 改造 4：会话切 Redis-Token（权限/禁用用户实时生效）========
security:
  session:
    type: redis-token
    access-token-time-to-live: 7200
    refresh-token-time-to-live: 604800
    redis-token:
      allow-multi-login: true
  ignore-urls:
    - /api/v1/auth/login/**
    - /api/v1/auth/captcha
    - /api/v1/auth/sms/code
    - /api/v1/auth/refresh-token
    - /api/v1/wxma/auth/**
    - /api/v1/logs/**
  unsecured-urls:
    - /actuator/health/**                       # 健康端点要允许匿名（Keepalived要探）
    - /actuator/info
    - /swagger-ui/**
    - /v3/api-docs/**
    - /doc.html
    - /webjars/**
    - /favicon.ico
    - /error

# ======== 改造 5：Actuator 只暴露健康 + 信息 ========
management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus
  endpoint:
    health:
      show-details: never
      probes:
        enabled: true
    info:
      env:
        enabled: true
  info:
    build:
      enabled: true
    env:
      enabled: true

oss:
  type: minio
  minio:
    endpoint: http://192.168.68.162:9000
    access-key: ${WMS_MINIO_AK:minioadmin}
    secret-key: ${WMS_MINIO_SK:Admin@zw8888!}
    bucket-name: public
  local:
    storage-path: /tmp/disabled       # 本地存储路径占位，防止误点 type=local 写死到 /Users

mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  global-config:
    db-config:
      db-type: postgresql
      id-type: none
      logic-delete-field: isDeleted
      logic-delete-value: 1
      logic-not-delete-value: 0
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl    # 生产关掉 SQL 打印

xxl:
  job:
    enabled: false                    # A/S 模式本地 @Scheduled 就够了，不要 XXL-JOB
```

### 7.3 SSE 后端改造（P0-2：加 1 秒重连 + server-shutdown 广播）

对 [SseSessionRegistry.java](file:///e:/wms20260712/wms/youlai-boot/src/main/java/com/youlai/boot/message/registry/SseSessionRegistry.java) 做以下两个小改动：

#### 改动 1：`userConnected()` 第一次连上时推送 retry:1000 + open 事件

修改 `userConnected()` 方法，在第 45~49 行之后加一行推送：

```java
public void userConnected(String username, SseEmitter emitter) {
    userEmittersMap.computeIfAbsent(username, k -> ConcurrentHashMap.newKeySet()).add(emitter);
    emitterUserMap.put(emitter, username);
    emitterTimeMap.put(emitter, System.currentTimeMillis());

    // ===== 新增：告诉浏览器 1 秒后重连 + 首次 open 事件（A/S 切机秒级恢复关键）=====
    try {
        emitter.send(SseEmitter.event()
                .name("open")
                .reconnectTime(1000)   // 1 秒重连间隔，比默认 3 秒快 2 倍
                .data("{\"serverTime\":" + System.currentTimeMillis() + "}"));
    } catch (IOException e) {
        log.warn("SSE 发送 open+retry 事件失败: {}", e.getMessage());
        removeEmitter(emitter);
    }

    log.debug("用户[{}]SSE连接已建立", username);
    // ... 原有的 onCompletion / onTimeout / onError 保持不变
}
```

#### 改动 2：`destroy()` 容器关闭前先广播 `server-shutdown` 事件让前端立刻主动重连

在 `destroy()` 方法里，`log.info("应用关闭，主动断开...")` **之前**，先推 `server-shutdown`：

```java
@Order(Ordered.HIGHEST_PRECEDENCE)
@EventListener(ContextClosedEvent.class)
public void destroy() {
    int count = emitterUserMap.size();
    // ===== 新增：先推 server-shutdown 让前端立即主动重连到备机，不用等 TCP 超时 =====
    if (count > 0) {
        log.info("应用关闭前，广播 server-shutdown 事件给 {} 个客户端触发主动重连...", count);
        getAllEmitters().forEach(emitter -> {
            try {
                emitter.send(SseEmitter.event()
                        .name("server-shutdown")
                        .data("App instance is shutting down, please reconnect immediately."));
            } catch (Exception ignored) {
            }
        });
        // 给前端 1.5 秒收 server-shutdown 事件并发起重连，再真正 complete 断开
        try { Thread.sleep(1500); } catch (InterruptedException ignored) { Thread.currentThread().interrupt(); }
    }
    if (count == 0) {
        return;
    }
    log.info("应用关闭，主动断开 {} 个SSE连接...", count);
    // ... 后面原有的 emitter.complete() + map.clear() 保持不变
}
```

### 7.4 WMS 应用 systemd 部署脚本（两台应用机完全一样）

两台机器各部署一套 youlai-boot jar，路径 `/opt/wms/`：

```bash
# 创建用户
useradd -s /sbin/nologin -d /opt/wms -m wms
mkdir -p /opt/wms/{bin,config,logs,lib,backup}
# 把你本地打出来的 youlai-boot-4.3.3.jar 上传到 /opt/wms/lib/
chown -R wms:wms /opt/wms
```

`/etc/systemd/system/wms-app.service`：
```ini
[Unit]
Description=WMS Backend App (youlai-boot)
After=network.target keepalived.service
Wants=keepalived.service
Requires=network.target

[Service]
Type=simple
User=wms
Group=wms
WorkingDirectory=/opt/wms
# 敏感配置通过环境变量注入（密码不要写 yml）
EnvironmentFile=-/etc/wms/env.conf
Environment="JAVA_TOOL_OPTIONS=-Xms2g -Xmx4g -XX:+UseG1GC -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/opt/wms/logs/ -XX:+PrintGCDetails -Xloggc:/opt/wms/logs/gc.log -Dfile.encoding=UTF-8 -Duser.timezone=Asia/Shanghai -Djava.security.egd=file:/dev/./urandom"

# 用 -Dspring.profiles.active=prod 启用生产配置
ExecStart=/usr/bin/java -jar /opt/wms/lib/youlai-boot-4.3.3.jar \
  -Dspring.profiles.active=prod \
  -Dspring.config.location=file:/opt/wms/config/,classpath:/

# 优雅停机：先 SIGTERM（触发 graceful shutdown），1 分钟后 SIGKILL
KillSignal=SIGTERM
TimeoutStopSec=90
Restart=on-failure
RestartSec=5
LimitNOFILE=655360
LimitNPROC=65536
StandardOutput=append:/opt/wms/logs/stdout.log
StandardError=append:/opt/wms/logs/stderr.log
SuccessExitStatus=143

[Install]
WantedBy=multi-user.target
```

`/etc/wms/env.conf`（文件权限 600 root:root）：
```
WMS_DB_PASSWORD=Wms@zw8888!
WMS_REDIS_PASSWORD=Admin@zw8888!
WMS_MINIO_AK=minioadmin
WMS_MINIO_SK=Admin@zw8888!
WMS_MAIL_PASSWORD=your-smtp-password
```

启动：
```bash
systemctl daemon-reload
systemctl enable wms-app
systemctl start wms-app
# 验证健康端点
curl -sf http://127.0.0.1:8000/actuator/health/readiness
# {"status":"UP"}
tail -100f /opt/wms/logs/stdout.log
```

---

## 八、WMS 前端（vue3-element-admin）配置改造

### 8.1 .env.production 改 API 地址为 **App-VIP**

打开 [.env.production](file:///e:/wms20260712/wmsui/vue3-element-admin/.env.production)：

```env
VITE_API_BASE_URL=http://192.168.68.200:8000
#                  ^^^^^^^^^^ 绝对不能写 192.168.68.155！
VITE_APP_TITLE=WMS系统
```

> 如果用了域名 + Nginx，`VITE_API_BASE_URL` 也可以写相对路径 `/api`，然后 Nginx 反代到 VIP:8000，同样不能写单机 IP。

### 8.2 SSE 前端改造：加断连 Toast + server-shutdown 立即重连（P0-2 前端关键）

在 wmsui 项目下全局搜索 `EventSource` 或 `new EventSource` 找到 SSE 管理文件（通常在 `src/utils/sse.ts` 或 `src/utils/sseClient.ts` 或 `src/api/system/message.ts` 等），按以下模板改造：

```typescript
// 示例 sse-client.ts（替换为您项目中的实际实现）
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/store/modules/user'

let eventSource: EventSource | null = null
let reconnectTimer: number | null = null
let reconnectAttempts = 0
const MAX_RECONNECT_DELAY = 5000  // 最大重连间隔 5 秒
let showDisconnectToast = true    // 只弹一次断开提示，不要每 1 秒弹一次

/** 建立 SSE 连接（从 JWT 拿 token 拼接 /api/v1/message/connect?token=xxx）*/
export function connectSse() {
  if (eventSource && eventSource.readyState === EventSource.OPEN) return
  const userStore = useUserStore()
  const token = userStore.getToken
  if (!token) return

  const url = `${import.meta.env.VITE_API_BASE_URL}/api/v1/message/connect?token=${encodeURIComponent(token)}`
  eventSource = new EventSource(url, { withCredentials: false })

  eventSource.onopen = () => {
    reconnectAttempts = 0
    if (!showDisconnectToast) {
      ElMessage({ type: 'success', message: '连接已恢复，通知推送重新正常', duration: 2000 })
      showDisconnectToast = true
    }
  }

  eventSource.onerror = (e) => {
    console.warn('[SSE] 连接异常，正在自动重连...', e)
    // 只弹一次"断开"的 Toast，避免刷屏
    if (showDisconnectToast) {
      ElMessage({ type: 'warning', message: '连接已断开，正在尝试自动重连（请不要关闭页面）...', duration: 0 })
      showDisconnectToast = false
    }
    // EventSource 原生自动重连 + 我们加一个指数退避兜底（比如 1s、2s、4s、5s 最大）
    if (reconnectTimer) clearTimeout(reconnectTimer)
    reconnectAttempts++
    const delay = Math.min(1000 * Math.pow(1.5, reconnectAttempts), MAX_RECONNECT_DELAY)
    reconnectTimer = window.setTimeout(() => {
      closeSse(false)
      connectSse()
    }, delay)
  }

  // 事件名 1：open（后端推的 1s reconnectTime）
  eventSource.addEventListener('open', (e) => {
    console.debug('[SSE] open handshake:', e.data)
  })

  // 事件名 2：server-shutdown（后端停机/切机时主动广播，立即重连不等 TCP 超时！）
  eventSource.addEventListener('server-shutdown', (e) => {
    console.warn('[SSE] server shutdown signal received, reconnect immediately!', e.data)
    // 不等 onerror，立即关 + 100ms 后立刻连新主（VIP已漂移）
    closeSse(false)
    setTimeout(connectSse, 100)
  })

  // 事件名 3：ping（后端 30s 心跳）
  eventSource.addEventListener('ping', (e) => {
    // 心跳只打 debug，不上屏
    console.debug('[SSE] heartbeat ping:', e.data)
  })

  // 事件名 4：notification / online-count 等业务事件（原项目已有的，保留）
  eventSource.addEventListener('notification', (e) => {
    console.log('[SSE] 新通知:', e.data)
    // 原项目的业务处理逻辑保持不变...
  })
  eventSource.addEventListener('online-count', (e) => {
    // 在线人数更新，原逻辑保持不变...
  })
}

/**
 * 关闭 SSE 连接
 * @param permanent true=用户登出/切账号，永久关不要重连；false=内部重连用，不弹 Toast
 */
export function closeSse(permanent = true) {
  if (reconnectTimer) { clearTimeout(reconnectTimer); reconnectTimer = null }
  if (eventSource) {
    eventSource.close()
    eventSource = null
  }
  if (permanent) {
    reconnectAttempts = 0
    showDisconnectToast = true
  }
}
```

### 8.3 前端生产构建 + Nginx 静态部署

```bash
# 本机或 CI 机器执行
cd e:\wms20260712\wmsui\vue3-element-admin
pnpm.cmd install    # 首次才需要
pnpm.cmd build:prod
# 产物在 dist/ 目录
```

把 dist/ 整个目录传到 node1、node2 两台的 `/usr/share/nginx/html/wms/`，Nginx server 段配置：

```nginx
server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html/wms;
    index index.html;
    client_max_body_size 50m;
    access_log  /var/log/nginx/wms_access.log main;
    error_log   /var/log/nginx/wms_error.log;

    # 前端路由 history 模式回退
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 静态资源缓存 7 天
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff2?|ttf)$ {
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    # 前端访问 /api/* 反向代理到本机 WMS App（前端、后端同机部署，不跨域；App-VIP 漂移时 node2 的 Nginx 也会代理 node2 本机 App）
    location /api/ {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 5s;
        proxy_read_timeout 300s;     # SSE 长连接超时要长
        proxy_send_timeout 300s;
        # SSE 必须关缓冲 + 强制长连接
        proxy_buffering off;
        proxy_cache off;
        proxy_http_version 1.1;
        proxy_set_header Connection '';
    }

    # SSE 端点 /api/v1/message/connect 额外保活参数
    location ~* /api/v1/message/connect {
        proxy_pass http://127.0.0.1:8000;
        proxy_http_version 1.1;
        proxy_set_header Connection '';
        proxy_buffering off;
        proxy_cache off;
        chunked_transfer_encoding off;
        proxy_read_timeout 1h;
    }
}
```

两台机都装好 Nginx，`systemctl enable --now nginx`。验证：`curl -I http://App-VIP/` 返回 200 + Content-Type: text/html。

---

## 九、标准启动顺序 + 上线前冒烟测试

### 9.1 开机启动顺序（两台机重启后也按这个顺序，依赖链不能错）

| 序号 | 启动项 | 节点 | 命令 / 验证 |
|------|--------|------|-------------|
| 1 | Chronyd 时间同步 | 所有节点 | chronyc sources -v 确认 Sync |
| 2 | PostgreSQL 主库 + 从库 | db-node1 → db-node2 | 主：`systemctl start postgresql-16` → 主从验证 SQL（3.6节） |
| 3 | Redis 主 + 从 | db-node1 → db-node2 | `INFO replication` 确认主从 up |
| 4 | 3 个 Redis Sentinel | node1 / node2 / db-node1 | `sentinel master mymaster` 确认 3 sentinel |
| 5 | MinIO / 阿里云 OSS 连通性 | 存储机或外网 | `curl OSS endpoint` 通 |
| 6 | WMS 后端（先备后主，备机先跑着）| node2 → node1 | `systemctl start wms-app` → 探 readiness 端点 UP |
| 7 | Nginx 前端静态 | node1 + node2 | `systemctl start nginx` |
| 8 | Keepalived（先备后主！） | node2 → node1 | `systemctl start keepalived` → 验证 VIP 在 node1 |

### 9.2 上线前冒烟测试（一台机切机前 15 分钟做完）

| # | 测试项 | 操作 | 预期结果 |
|---|--------|------|----------|
| 1 | 登录登出 | admin 账号登录 → 登出 → 再登录 | 正常，Redis 里 `login:token:*` 能看到 key |
| 2 | 用户管理 CRUD | 新增用户 → 编辑 → 禁用 → 删除 | 成功；禁用后该用户立刻 401（redis-token 生效）|
| 3 | SSE 推送 | 开两个浏览器 tab 互发通知 | 都能收到；online-count 数字正确 |
| 4 | 文件上传下载 | 上传头像 → 下载导入模板 → 上传 Excel 入库 | 另一台应用机上也能下载到相同文件（共享存储生效）|
| 5 | DB 读写压测 | 100 次用户新增/查询 | 无报错，主从 delay < 1MB |
| 6 | Redis 读/写/过期 | set/get 测试 + 验证码生成 10 次 | 全部成功 |
| 7 | 前端访问 VIP | `http://App-VIP/` 打开页面 | 正常显示，API 全部 200，没有 CORS 错误 |
| 8 | Nginx 反向代理 | F12 看 Network 所有请求走 /api/ | 都有响应，无 499/502 |

---

## 十、切机演练 SOP（必须执行 3 次，附 Checklist）

### 10.1 场景一：计划性人工切机（最常用：升级/维护/重启主机）

> **时间估算**：操作时间 < 3 分钟 + 观察时间 10 分钟

```text
步骤 1 [运维操作 wms-app-node1]：
  登录 node1，手动把 Keepalived priority 从 150 降到 80：
  方法 A（推荐不改文件，运行时改）：
    ip addr del 192.168.68.200/24 dev ens33 或 更优雅：systemctl restart keepalived（改完配置后）
  方法 B（改 keepalived.conf）：
    vi /etc/keepalived/keepalived.conf  → priority 改成 80
    systemctl reload keepalived
  → 预期：VIP 从 node1 漂移到 node2（< 3 秒）

步骤 2 [运维操作 wms-app-node1]：
  tail -f /opt/wms/logs/stdout.log 观察 30~60 秒，确认不再有新请求进来（或者看 Nginx access.log）

步骤 3 [运维操作 wms-app-node1]：
  应用停机（触发优雅停机，会先推 server-shutdown SSE 事件）：
    systemctl stop wms-app
  预期：destroy() 被调用 → SSE 客户端 1.5 秒后主动重连 → 都连到 node2

步骤 4 [业务测试]：
  立即按 10.4 的 Checklist 跑 1~8 项，业务全部正常

步骤 5 [运维操作 wms-app-node1]：
  执行升级/维护/重启操作系统...（< 2 小时）

步骤 6 [运维操作 wms-app-node1]：
  WMS 应用启动，健康端点 readiness UP
  不要立刻把 priority 改回 150（因为 nopreempt 非抢占，改了也不会抢，先观察 10 分钟）
  如果您希望回主，手动在 node2 上 systemctl reload keepalived（或临时停一下 node2 keepalived 10 秒再启），让 VIP 回到 node1

步骤 7 [发群通知]：
  本次切机/维护完成，观察 10 分钟，有异常 @运维
```

### 10.2 场景二：故障自动切机（模拟主机 App / OS / Keepalived 崩溃）

> **时间估算**：自动切机 3~10 秒 + 业务回稳 < 1 分钟

```text
步骤 1 [运维操作 wms-app-node1]：
  模拟应用崩溃：pkill -9 -f youlai-boot
  （或者模拟机器断电：直接 stop VM / poweroff / 拔网线）

步骤 2 [观察]：
  ping App-VIP：丢 1~8 个包（Keepalived 2s interval × fall=2 = 4s 检测 + 1s 免费 ARP = 约 5 秒）
  node2 上 ip a 出现 .200

步骤 3 [业务测试]：
  浏览器继续操作 WMS 网页（不要关）：
    - 普通请求：axios 重试 1~2 次后成功（用户感觉卡一下，不会报错）
    - SSE：前端 onerror → 1 秒后自动重连到 node2 → Toast "连接已恢复"
    - 已登录用户：redis-token 模式不用重新登录！

步骤 4 [回验证]：
  按 10.4 Checklist 全部打勾 ✅

步骤 5 [排障恢复]：
  排查 node1 崩溃的根因（OOM？GC？磁盘满？）→ 修复 → 重启 WMS App
  保持现状运行不回切，等下次维护窗口再计划回主（避免抖动）
```

### 10.3 场景三：DB / Redis 主故障 + Sentinel 自动选主

> 时间估算：3~10 秒 Sentinel/PG 选主 + 应用连接池自动重连 < 30 秒

```text
步骤 1：模拟 DB 主库宕机（db-node1）：
  systemctl stop postgresql-16
步骤 2：PostgreSQL 从库提升为新主（DB-VIP 方案下，VIP 会自动从 db-node1 漂移到 db-node2，应用不用感知）
        或 无 DB-VIP 下，手动 pg_ctl promote
步骤 3：应用侧：Druid 连接池 5 秒发现旧连接死了，自动回收并创建指向新主的新连接
步骤 4：业务验证：立即执行用户新增 → 成功（< 30 秒恢复）

Redis 故障切换：
步骤 1：redis-cli -h db-node1 DEBUG SEGFAULT
步骤 2：3~6 秒后 Sentinel 选主（db-node2 被选成新主）
步骤 3：Lettuce 刷新拓扑（因为配置了 Sentinel topology refresh）
步骤 4：业务：验证码接口立刻调用 → 成功
```

### 10.4 Checklist（每次切机演练逐项打勾，保存为 PDF 归档）

#### 10.4.1 业务功能（**所有场景都要测**）

- [ ] 登录：admin 账号密码登录成功（切机前已登录用户不要重新登录）
- [ ] 登出：手动登出 → 再次访问 / 跳转登录页
- [ ] 用户管理：新增 → 编辑 → 查询 → 禁用 → 启用 → 删除 成功
- [ ] 角色权限：新建角色 → 分配菜单 → 用户切角色 → 对应菜单立刻可见（redis-token 权限实时生效）
- [ ] 部门管理：CRUD 成功，切用户的部门后用户列表部门名同步
- [ ] 字典/配置：字典值修改后对应页面下拉刷新成功
- [ ] 文件上传下载：上传 2MB Excel → 下载，SHA256 和上传前一致
- [ ] SSE 通知：A 用户发系统通知 → B 用户 3 秒内收到 Toast + 消息中心 +1
- [ ] 在线人数：右侧边栏 /dashboard 在线人数和实际在线 tab 数一致
- [ ] 核心 WMS 接口（如有）：入库单创建 → 确认 → 库存增加；出库单确认 → 库存扣减；AGV 下发任务

#### 10.4.2 数据一致性（切机后对比）

- [ ] PostgreSQL：执行以下 SQL，最大 ID/行数 和切机前快照一致（SQL 见 12.1）
- [ ] Redis：`DBSIZE` 切机前后差值 < 5%（token 不会大批量丢）
- [ ] `SCAN 0 MATCH login:token:* COUNT 20`：至少有自己的 token key
- [ ] sys_log 表：切机瞬间没有大量 ERROR（如果有，Druid timeout 调小）

#### 10.4.3 第三方系统 / 网络

- [ ] AGV / RCS 回调：手动调 AGV 测试接口，回调记录写进 DB（非切机瞬间的）
- [ ] 邮件/短信：触发找回密码 / 通知接口，正常收到
- [ ] 移动端 PDA：关闭 WiFi 重连 → 请求都到 VIP（看访问日志 IP）
- [ ] ping VIP：丢包 < 10 个，无持续丢包

---

## 十一、故障回滚 SOP + 应急预案

### 11.1 场景 1：切机后业务大量报错 → **紧急回切 VIP**

> 时间 < 1 分钟就能回切

```bash
# 切到备机后发现大量 500 / DB 报错，不要排查问题，先 VIP 回切到主机！

# [node2]：临时把 keepalived 停 10 秒，VIP 会漂回 node1（前提是 node1 的 App 已经是 UP 状态）
systemctl stop keepalived
sleep 10
systemctl start keepalived

# 或者 [node1]：把 priority 改回 150 并 systemctl reload keepalived（关 nopreempt 才生效）
```

### 11.2 场景 2：PostgreSQL 主从切换后应用连接不上（没配 DB-VIP 的旧方案）

```sql
-- 1. 确认新主（假设原来从库 node2 提升为主）
-- 在 db-node2 上执行：
SELECT pg_is_in_recovery();        -- 必须 false（新主不再是恢复模式）
ALTER USER repluser WITH PASSWORD 'Repl@zw8888!';
-- pg_hba.conf 里之前的白名单已经是双向的，不用改

-- 2. DB 双写检查（脑裂时两台都可写，最严重）：
-- 在 db-node1 和 db-node2 分别查 wms_all_template.test_sync 的最大 id
-- 如果不一样大 → 脑裂了！必须立刻停掉其中一台（停先发现写不同步的），用最新的那台重建从库
```

### 11.3 场景 3：Redis Sentinel 不选主（quorum 不够）

```bash
# 3 个哨兵只活了 1 个 → 达不到 quorum=2 → 永远不选主
# 临时应急：手动从 3 个哨兵里挑 1 个，强制故障转移
redis-cli -p 26379 SENTINEL FAILOVER mymaster
# 预期：+OK（强制忽略 quorum，直接让当前从库变主）
# 后续：把另外 2 个哨兵拉起来，重新加入集群
```

### 11.4 场景 4：Keepalived 脑裂（两台机上都能看到 VIP .200）

```bash
# 原因：VRRP 心跳包不通（防火墙没关 / switch 跨 VLAN 禁了组播 / unicast_peer 配置错）
# 检测：两台机都执行 ip a | grep .200，都有 = 脑裂
# 应急：立即手动停掉备机 keepalived → 只留一台持有 VIP → 检查 VRRP 单播是否通
systemctl stop keepalived   # 在 node2 上执行
nc -zv wms-app-node1 112    # node2 上探测 node1 的 VRRP 单播端口（默认是组播，unicast_src_ip 配的话直接是 TCP 连通性）
```

### 11.5 场景 5：MinIO 单实例存储机挂了 / 阿里云 OSS 故障

```text
应急降级 30 分钟（业务继续跑，只有文件上传下载挂）：
  1) 临时在两台应用机开 Nginx 目录共享（/data/shared-files/ 用 NFS 互相挂载）
  2) 把 oss.type 临时改成 local，storage-path 指 NFS 共享目录
  3) 发群通知：文件功能暂时不可用，预计 30 分钟恢复
长期：MinIO 改成两节点纠删码模式（6.3方案C）+ 每周定时把 MinIO 数据备份到 OSS
```

---

## 十二、日常运维巡检脚本

放一台跳板机（或 node1 的 crontab 每天 08:00 跑），输出 `巡检报告-YYYYMMDD.html` 发群里。

### 12.1 PostgreSQL 巡检 SQL（跑在主库）

```sql
-- 1. 基本信息
SELECT 'PG_VERSION' AS item, version() AS value
UNION ALL SELECT 'DB_SIZE', pg_size_pretty(pg_database_size('wms_all_template'))
UNION ALL SELECT 'ACTIVE_CONN', COUNT(*)::TEXT FROM pg_stat_activity WHERE state='active'
UNION ALL SELECT 'MAX_CONN_USED', COUNT(*)::TEXT||'/'||setting FROM pg_stat_activity, pg_settings WHERE name='max_connections';

-- 2. 主从状态
SELECT pid, usename, application_name, state, sync_state, client_addr,
       pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), replay_lsn)) delay
FROM pg_stat_replication;

-- 3. 慢 SQL TOP 10（最近 24 小时）
SELECT query, calls, total_exec_time, mean_exec_time, rows
FROM pg_stat_statements
WHERE query NOT LIKE '%pg_%'
ORDER BY total_exec_time DESC LIMIT 10;

-- 4. 死锁 / 长事务
SELECT pid, usename, datname, state, wait_event_type, wait_event,
       now()-xact_start AS xact_duration, query
FROM pg_stat_activity
WHERE state <> 'idle' AND (now()-xact_start) > interval '5 minutes'
ORDER BY xact_duration DESC;

-- 5. 核心表行数 + 最大ID（对比昨日快照做增量校验）
SELECT 'sys_user' tbl, COUNT(*) cnt, MAX(id) max_id FROM wms_all_template.public.sys_user
UNION ALL SELECT 'sys_log', COUNT(*), MAX(id) FROM wms_all_template.public.sys_log
UNION ALL SELECT 'sys_dept', COUNT(*), MAX(id) FROM wms_all_template.public.sys_dept
UNION ALL SELECT 'sys_role', COUNT(*), MAX(id) FROM wms_all_template.public.sys_role;
```

### 12.2 Redis 巡检 Shell

```bash
#!/bin/bash
# check_redis.sh
MASTER=$(redis-cli -h 192.168.68.155 -p 26379 --no-auth-warning \
  -a Admin@zw8888! sentinel get-master-addr-by-name mymaster | head -1)
echo "[Redis] 当前主库：$MASTER"
redis-cli -h $MASTER -p 6379 -a Admin@zw8888! INFO memory | grep -E "used_memory_human|maxmemory_human"
redis-cli -h $MASTER -p 6379 -a Admin@zw8888! INFO stats | grep -E "keyspace_hits|keyspace_misses"
redis-cli -h $MASTER -p 6379 -a Admin@zw8888! INFO replication | grep -E "role:|connected_slaves:"
redis-cli -p 26379 sentinel ckquorum mymaster   # 输出 OK (3) quorum 满足
```

### 12.3 WMS 应用 + VIP 巡检 Shell

```bash
#!/bin/bash
VIP=192.168.68.200
echo "[VIP] 归属机器："
for h in wms-app-node1 wms-app-node2; do
  ssh root@$h "ip a | grep -q $VIP && echo \"  >>> VIP 在 $h <<<\" || echo \"  $h 无 VIP\""
done
echo -n "[App健康 node1] " ; curl -sf http://192.168.68.155:8000/actuator/health | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'])"
echo -n "[App健康 node2] " ; curl -sf http://192.168.68.156:8000/actuator/health | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'])"
echo -n "[App健康 VIP  ] " ; curl -sf http://$VIP:8000/actuator/health | python3 -c "import sys,json;d=json.load(sys.stdin);print(d['status'])"
echo "[日志近1小时ERROR数]："
for h in wms-app-node1 wms-app-node2; do
  n=$(ssh root@$h "grep -cE 'ERROR|Exception' /opt/wms/logs/stdout.log --since='1 hour ago' 2>/dev/null||echo 0")
  echo "  $h: $n 条"
done
```

Crontab：
```
0 8 * * * /root/check_daily.sh > /var/log/daily_check_$(date +\%Y\%m\%d).log 2>&1 ; sh /root/send_report.sh
```

---

## 附录：全部配置文件全文（可直接复制粘贴）

> 所有文件可以在 `e:\wms20260712\develop\双机热备配置文件合集\` 下归档一份，运维部署时直接拷贝。

### 附录 A：PostgreSQL 主库 postgresql.conf 关键段全文

```ini
# ============ PostgreSQL 16 postgresql.conf ============
# ============ CONNECTION ============
listen_addresses = '*'
port = 5432
max_connections = 500
superuser_reserved_connections = 10
unix_socket_directories = '/var/run/postgresql, /tmp'

# ============ MEMORY (16GB RAM 推荐值) ============
shared_buffers = 4GB
huge_pages = try
temp_buffers = 64MB
work_mem = 16MB
maintenance_work_mem = 1GB
autovacuum_work_mem = 512MB
effective_cache_size = 12GB

# ============ WAL & REPLICATION (主从复制核心) ============
wal_level = replica
synchronous_commit = remote_write
synchronous_standby_names = 'standby1'
fsync = on
wal_sync_method = fdatasync
full_page_writes = on
wal_compression = on
wal_writer_delay = 200ms
wal_buffers = 16MB
checkpoint_timeout = 30min
max_wal_size = 16GB
min_wal_size = 4GB
archive_mode = on
archive_command = 'test ! -f /var/lib/pgsql/16/archive/%f && cp %p /var/lib/pgsql/16/archive/%f'
archive_timeout = 10min
max_wal_senders = 10
max_replication_slots = 10
wal_keep_size = 4096
wal_sender_timeout = 10s
wal_receiver_timeout = 10s

# ============ LOGGING ============
logging_collector = on
log_directory = 'log'
log_filename = 'postgresql-%Y-%m-%d.log'
log_rotation_age = 1d
log_rotation_size = 200MB
log_min_duration_statement = 1000
log_line_prefix = '%m [%p] %u@%d app=%a client=%h tx=%x '
log_timezone = 'Asia/Shanghai'
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on
log_temp_files = 0

# ============ VACUUM / AUTOVACUUM ============
autovacuum = on
autovacuum_max_workers = 4
autovacuum_vacuum_threshold = 500
autovacuum_vacuum_scale_factor = 0.1

# ============ LOCALE / TIMEZONE ============
datestyle = 'iso, mdy'
timezone = 'Asia/Shanghai'
lc_messages = 'en_US.UTF-8'
lc_monetary = 'en_US.UTF-8'
lc_numeric = 'en_US.UTF-8'
lc_time = 'en_US.UTF-8'
default_text_search_config = 'pg_catalog.simple'

# ============ EXTENSIONS ============
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 5000
track_activity_query_size = 4096
```

### 附录 B：PostgreSQL pg_hba.conf 追加行全文

```ini
# ============ pg_hba.conf (追加到文件末尾) ============
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# 1. Local
local   all             all                                     peer
# 2. IPv4 local
host    all             all             127.0.0.1/32            scram-sha-256
host    all             all             ::1/128                 scram-sha-256
# 3. Replication (主从复制账号白名单)
local   replication     postgres                                peer
host    replication     repluser        127.0.0.1/32            scram-sha-256
host    replication     repluser        192.168.68.155/32       scram-sha-256
host    replication     repluser        192.168.68.156/32       scram-sha-256
host    replication     repluser        192.168.68.160/32       scram-sha-256
host    replication     repluser        192.168.68.161/32       scram-sha-256
# 4. 业务账号：WMS 应用服务器访问 wms_all_template
host    wms_all_template wms_user       192.168.68.155/32       scram-sha-256
host    wms_all_template wms_user       192.168.68.156/32       scram-sha-256
# 5. DBA 管理：运维跳板机 postgres 超级用户（限制到最小 IP）
host    all             postgres        192.168.68.0/24         scram-sha-256
# 6. 禁止默认所有人 all/all（最后一行，黑名单兜底）
# host all all 0.0.0.0/0 reject
```

### 附录 C：Redis / Sentinel 配置全文

Redis 主/从 /etc/redis/redis.conf（从库额外加一行 replicaof）：
```ini
# redis.conf 7.x 统一配置
bind 0.0.0.0
protected-mode no
port 6379
tcp-backlog 511
timeout 300
tcp-keepalive 60
daemonize yes
supervised systemd
pidfile /data/redis/run/redis_6379.pid
loglevel notice
logfile /data/redis/log/redis_6379.log
databases 16
always-show-logo no
set-proc-title yes
proc-title-template "{title} {listen-addr} {server-mode}"

dir /data/redis/data
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error no     # 参考之前项目经验：开发环境必须 no
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
rdb-del-sync-files no

replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync yes
repl-diskless-sync-delay 5
repl-diskless-sync-max-replicas 0
repl-diskless-load disabled
repl-disable-tcp-nodelay no
replica-priority 100
acllog-max-len 128

requirepass Admin@zw8888!
masterauth Admin@zw8888!
# 从库只加下面这一行：
# replicaof wms-db-node1 6379

min-replicas-to-write 1
min-replicas-max-lag 10

maxmemory 4gb
maxmemory-policy allkeys-lru
lazyfree-lazy-eviction yes
lazyfree-lazy-expire yes
lazyfree-lazy-server-del yes
replica-lazy-flush yes
lazyfree-lazy-user-del yes

appendonly yes
appendfilename "appendonly.aof"
appenddirname "appendonlydir"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
aof-timestamp-enabled no

slowlog-log-slower-than 10000
slowlog-max-len 128
latency-monitor-threshold 0

notify-keyspace-events ""
hash-max-listpack-entries 512
hash-max-listpack-value 64
list-max-listpack-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-listpack-entries 128
zset-max-listpack-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100

activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60

hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
jemalloc-bg-thread yes
```

Sentinel /etc/redis/sentinel.conf（三台完全相同）：
```ini
port 26379
daemonize yes
supervised systemd
protected-mode no
bind 0.0.0.0
pidfile /data/redis/run/sentinel_26379.pid
logfile /data/redis/log/sentinel_26379.log
dir /data/redis/data

sentinel monitor mymaster wms-db-node1 6379 2
sentinel auth-pass mymaster Admin@zw8888!
sentinel down-after-milliseconds mymaster 3000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 60000
sentinel deny-scripts-reconfig yes
sentinel resolve-hostnames yes
sentinel announce-hostnames no
```

### 附录 D：Keepalived 配置（App-VIP 主/备 + DB-VIP）

#### D-1. App 主机（node1）完整 keepalived.conf

```ini
! Configuration File for keepalived - WMS APP NODE1 (MASTER)
global_defs {
   router_id WMS_APP_NODE1
   notification_email_from wms@yourcompany.com
   enable_script_security
   script_user root
   max_auto_priority 99
}

vrrp_script chk_wms {
    script "/etc/keepalived/scripts/check_wms_app.sh"
    interval 2
    weight -70
    fall 2
    rise 2
}

vrrp_script chk_nginx {
    script "killall -0 nginx || exit 1"
    interval 2
    weight -10
    fall 2
    rise 2
}

vrrp_instance VI_APP {
    state MASTER
    interface ens33                 # ⚠️ 改成你的内网网卡名！！！
    virtual_router_id 51
    priority 150
    advert_int 1
    nopreempt
    smtp_alert

    unicast_src_ip 192.168.68.155
    unicast_peer {
        192.168.68.156
    }

    authentication {
        auth_type PASS
        auth_pass WmsKp88!
    }

    virtual_ipaddress {
        192.168.68.200/24 dev ens33 label ens33:0
    }

    track_script {
        chk_wms
        chk_nginx
    }

    notify_master "/etc/keepalived/scripts/notify_wms.sh VI_APP MASTER"
    notify_backup "/etc/keepalived/scripts/notify_wms.sh VI_APP BACKUP"
    notify_fault  "/etc/keepalived/scripts/notify_wms.sh VI_APP FAULT"
    notify_stop   "/etc/keepalived/scripts/notify_wms.sh VI_APP STOP"
}
```

#### D-2. App 备机（node2）完整 keepalived.conf

```ini
! Configuration File for keepalived - WMS APP NODE2 (BACKUP)
global_defs {
   router_id WMS_APP_NODE2
   enable_script_security
   script_user root
}

vrrp_script chk_wms {
    script "/etc/keepalived/scripts/check_wms_app.sh"
    interval 2
    weight -70
    fall 2
    rise 2
}
vrrp_script chk_nginx {
    script "killall -0 nginx || exit 1"
    interval 2
    weight -10
    fall 2
    rise 2
}

vrrp_instance VI_APP {
    state BACKUP
    interface ens33
    virtual_router_id 51
    priority 100
    advert_int 1
    nopreempt

    unicast_src_ip 192.168.68.156
    unicast_peer {
        192.168.68.155
    }
    authentication {
        auth_type PASS
        auth_pass WmsKp88!
    }
    virtual_ipaddress {
        192.168.68.200/24 dev ens33 label ens33:0
    }
    track_script {
        chk_wms
        chk_nginx
    }
    notify_master "/etc/keepalived/scripts/notify_wms.sh VI_APP MASTER"
    notify_backup "/etc/keepalived/scripts/notify_wms.sh VI_APP BACKUP"
    notify_fault  "/etc/keepalived/scripts/notify_wms.sh VI_APP FAULT"
}
```

#### D-3. 健康检查 check_wms_app.sh + 检查 PG check_postgresql.sh

```bash
#!/bin/bash
# /etc/keepalived/scripts/check_wms_app.sh （两台应用机）
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://127.0.0.1:8000/actuator/health/readiness)
[ "$HTTP_CODE" = "200" ] && exit 0
sleep 1
HTTP_CODE2=$(curl -s -o /dev/null -w "%{http_code}" --max-time 2 http://127.0.0.1:8000/actuator/health/readiness)
[ "$HTTP_CODE2" = "200" ] && exit 0
exit 1
```

```bash
#!/bin/bash
# /etc/keepalived/scripts/check_postgresql.sh （两台DB机，DB-VIP 用）
# 选主：SELECT pg_is_in_recovery()=f 才能持有 DB-VIP（只有主库可写）
export PGPASSWORD='Admin@zw8888!'
IS_IN_RECOVERY=$(psql -h 127.0.0.1 -U postgres -d wms_all_template -t -c "SELECT pg_is_in_recovery();" 2>/dev/null | tr -d '[:space:]')
if [ "$IS_IN_RECOVERY" = "f" ] ; then
  # 是主库，再探一下可写
  WRITABLE=$(psql -h 127.0.0.1 -U postgres -t -c "CREATE TABLE IF NOT EXISTS public.kp_heartbeat(id int); INSERT INTO public.kp_heartbeat VALUES(1) ON CONFLICT DO NOTHING;" 2>/dev/null; echo $?)
  [ "$WRITABLE" = "0" ] && exit 0
fi
exit 1
```

### 附录 E：通知脚本 + SOP 数据一致性 SQL

```bash
#!/bin/bash
# /etc/keepalived/scripts/notify_wms.sh  (两台一样)
NOW=$(date "+%Y-%m-%d %H:%M:%S")
HOST=$(hostname -s)
GROUP="$1"; STATE="$3"
# 企业微信机器人
WEBHOOK="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=REPLACE_WITH_YOUR_KEY"
MSG="【WMS 双机热备告警】
- 时间：$NOW
- 机器：$HOST
- 角色切换：$STATE
- VIP 组：$GROUP
- 说明：请运维确认业务是否正常"
if [ "$STATE" = "MASTER" ] || [ "$STATE" = "FAULT" ]; then
  curl -s "$WEBHOOK" -H 'Content-Type: application/json' \
    -d "{\"msgtype\":\"markdown\",\"markdown\":{\"content\":\"$MSG\"}}" >/dev/null 2>&1
fi
echo "[$NOW] $GROUP $STATE" >> /var/log/keepalived-notify.log
```

数据一致性对比 SQL（切机前后各执行一次，保存结果对比）：
```sql
SELECT 'sys_user' tbl, COUNT(*) cnt, MAX(id) max_id FROM public.sys_user
UNION ALL SELECT 'sys_dept',    COUNT(*), MAX(id) FROM public.sys_dept
UNION ALL SELECT 'sys_role',    COUNT(*), MAX(id) FROM public.sys_role
UNION ALL SELECT 'sys_menu',    COUNT(*), MAX(id) FROM public.sys_menu
UNION ALL SELECT 'sys_log',     COUNT(*), MAX(id) FROM public.sys_log
UNION ALL SELECT 'sys_dict',    COUNT(*), MAX(id) FROM public.sys_dict
UNION ALL SELECT 'sys_dict_item', COUNT(*), MAX(id) FROM public.sys_dict_item;
```

### 附录 F：systemd 服务完整样例

`/etc/systemd/system/wms-app.service` 见 7.4 节正文。

`/etc/systemd/system/minio.service` 见 6.2 节正文。

### 附录 G：application-prod.yml 改造后完整示例

> 直接替换 [application-prod.yml](file:///e:/wms20260712/wms/youlai-boot/src/main/resources/application-prod.yml) 全文：

```yaml
server:
  port: 8000
  address: 0.0.0.0
  shutdown: graceful
  shutdown-timeout: 30s

spring:
  application:
    name: wms
  profiles:
    active: prod
  config:
    import: classpath:codegen.yml
  lifecycle:
    timeout-per-shutdown-phase: 30s
  servlet:
    multipart:
      max-file-size: 50MB
      max-request-size: 50MB

  datasource:
    type: com.alibaba.druid.pool.DruidDataSource
    driver-class-name: org.postgresql.Driver
    url: jdbc:postgresql://192.168.68.201:5432/wms_all_template?currentSchema=public&stringtype=unspecified&connectTimeout=5&socketTimeout=30&ApplicationName=wms-app
    username: ${WMS_DB_USER:wms_user}
    password: ${WMS_DB_PASSWORD:Wms@zw8888!}
    druid:
      initial-size: 5
      max-active: 20
      min-idle: 5
      max-wait: 3000
      test-while-idle: true
      test-on-borrow: false
      test-on-return: false
      validation-query: SELECT 1
      validation-query-timeout: 2
      time-between-eviction-runs-millis: 5000
      min-evictable-idle-time-millis: 300000
      remove-abandoned: true
      remove-abandoned-timeout: 60
      log-abandoned: true
      pool-prepared-statements: true
      max-pool-prepared-statement-per-connection-size: 50
      filters: stat,wall,slf4j
      connection-properties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=3000
      web-stat-filter:
        enabled: true
        url-pattern: /*
        exclusions: "*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*,/actuator/*"
      stat-view-servlet:
        enabled: true
        url-pattern: /druid/*
        login-username: ${WMS_DRUID_USER:admin}
        login-password: ${WMS_DRUID_PASSWORD:WmsAdmin88!}
        allow: 127.0.0.1,192.168.68.0/24
        deny: 0.0.0.0/0

  data:
    redis:
      database: 1
      password: ${WMS_REDIS_PASSWORD:Admin@zw8888!}
      timeout: 5s
      lettuce:
        pool:
          max-active: 32
          max-wait: 2000ms
          max-idle: 16
          min-idle: 4
        shutdown-timeout: 200ms
      sentinel:
        master: mymaster
        nodes:
          - 192.168.68.155:26379
          - 192.168.68.156:26379
          - 192.168.68.160:26379

  cache:
    enabled: true
    type: redis
    redis:
      time-to-live: 3600000
      cache-null-values: true
      use-key-prefix: true

  mail:
    host: smtp.exmail.qq.com
    port: 465
    username: wms@yourcompany.com
    password: ${WMS_MAIL_PASSWORD:}
    properties:
      smtp:
        auth: true
        ssl:
          enable: true
    from: wms <wms@yourcompany.com>

mybatis-plus:
  mapper-locations: classpath*:/mapper/**/*.xml
  global-config:
    db-config:
      db-type: postgresql
      id-type: none
      logic-delete-field: isDeleted
      logic-delete-value: 1
      logic-not-delete-value: 0
  configuration:
    map-underscore-to-camel-case: true
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl

# 限流（保留 Redis 实现）
rate-limit:
  default-limit: 50
  default-window-seconds: 60
  ip:
    enabled: true
    limit: 5000
    window-seconds: 60

security:
  session:
    type: redis-token
    access-token-time-to-live: 7200
    refresh-token-time-to-live: 604800
    jwt:
      secret-key: ${WMS_JWT_SECRET:SecretKey012345678901234567890123456789012345678901234567890123456789}
    redis-token:
      allow-multi-login: true
  ignore-urls:
    - /api/v1/auth/login/**
    - /api/v1/auth/captcha
    - /api/v1/auth/sms/code
    - /api/v1/auth/refresh-token
    - /api/v1/wxma/auth/**
    - /api/v1/logs/**
  unsecured-urls:
    - /actuator/health/**
    - /actuator/info
    - /actuator/prometheus
    - /swagger-ui/**
    - /v3/api-docs/**
    - /doc.html
    - /webjars/**
    - /favicon.ico
    - /error

management:
  endpoints:
    web:
      exposure:
        include: health,info,prometheus,metrics
  endpoint:
    health:
      show-details: never
      probes:
        enabled: true
      status:
        http-mapping:
          down: 503
          out-of-service: 503
    info:
      env:
        enabled: true
  metrics:
    export:
      prometheus:
        enabled: true
  info:
    build:
      enabled: true
    env:
      enabled: true

oss:
  type: minio
  minio:
    endpoint: http://192.168.68.162:9000
    access-key: ${WMS_MINIO_AK:minioadmin}
    secret-key: ${WMS_MINIO_SK:Admin@zw8888!}
    bucket-name: public
    custom-domain:
  aliyun:
    endpoint: oss-cn-hangzhou.aliyuncs.com
    access-key-id: ${WMS_OSS_AK_ID:}
    access-key-secret: ${WMS_OSS_AK_SECRET:}
    bucket-name: default
  local:
    storage-path: /tmp/disabled_wms_local_storage_do_not_use

sms:
  aliyun:
    accessKeyId: ${WMS_SMS_AK_ID:}
    accessKeySecret: ${WMS_SMS_AK_SECRET:}
    domain: dysmsapi.aliyuncs.com
    regionId: cn-hangzhou
    signName: WMS系统
    templates:
      register: SMS_XXXXXXXX
      login: SMS_XXXXXXXX
      change-mobile: SMS_XXXXXXXX

springdoc:
  swagger-ui:
    path: /swagger-ui.html
    operationsSorter: alpha
    tags-sorter: alpha
  api-docs:
    path: /v3/api-docs
  group-configs:
    - group: "系统管理"
      paths-to-match: "/**"
      packages-to-scan:
        - com.youlai.boot.auth.controller
        - com.youlai.boot.system.controller
        - com.youlai.boot.file.controller
        - com.youlai.boot.codegen.controller
        - com.youlai.boot.message.controller
  default-flat-param-object: true

knife4j:
  enable: true
  production: true       # ⭐ 生产关闭 Swagger 文档
  setting:
    language: zh_cn

xxl:
  job:
    enabled: false          # A/S 模式用本地 @Scheduled 足够

captcha:
  type: circle
  width: 120
  height: 40
  interfere-count: 2
  text-alpha: 0.8
  code:
    type: math
    length: 1
  font:
    name: SansSerif
    weight: 1
    size: 24
  expire-seconds: 120

wx:
  miniapp:
    app-id: ${WMS_WX_APPID:}
    app-secret: ${WMS_WX_SECRET:}
```

---

## 实施总进度预估（标准版 4.5 人天）

| 阶段 | 内容 | 人天 | 交付物 |
|------|------|------|--------|
| 1 部署前准备 | 机器、网络、hosts、内核、免密、YUM 源 | 0.5 天 | 基础环境 Ready |
| 2 中间件部署 | PG 主从 + Sentinel 主从 + Keepalived + MinIO | 1 天 | 中间件全部通过 3.6 / 4.5 / 5.6 验证 |
| 3 后端改造 | application-prod.yml + SSE 两处代码改造 + systemd 部署 | 0.5 天 | node1/node2 后端健康端点 UP |
| 4 前端改造 | SSE 重连 Toast + .env.production VIP + Nginx 部署 | 0.5 天 | VIP 直接访问 WMS 网页成功 |
| 5 冒烟测试 | 第九章 8 项 + 中间件状态 | 0.5 天 | 冒烟测试报告 |
| 6 切机演练 3 次 | 计划性 / 故障 / DB+Redis 选主 + 3 套 Checklist 打勾 | 1 天 | 3 次切机演练 Checklist 归档 |
| 7 巡检脚本 + 文档交付 | 第十二章巡检 + 应急预案培训 | 0.5 天 | 巡检脚本 + 运维手册 |

**文档至此结束。部署过程中任何配置问题、命令报错可以直接对照附录中的完整配置文件逐一核对。**
