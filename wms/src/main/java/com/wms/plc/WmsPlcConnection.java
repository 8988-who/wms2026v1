package com.wms.plc;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.github.xingshuangs.iot.protocol.s7.enums.EPlcType;
import com.github.xingshuangs.iot.protocol.s7.service.S7PLC;
import com.wms.plc.mapper.TWmsPlcSignalConfigMapper;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 单个PLC连接实例
 * <p>每个实例独立线程执行定时检测、心跳与信号块读取。</p>
 */
@Slf4j
public class WmsPlcConnection {

    private static final long PERIOD_SECONDS = 3L;

    /** 同一 PLC 实例的互斥锁，保护连接生命周期和读写操作 */
    private final Object lock = new Object();
    private final TWmsPlcConnection config;
    private final TWmsPlcSignalConfigMapper signalConfigMapper;
    private final ScheduledExecutorService executor;

    /** 启动标记，避免重复拉起定时线程 */
    private volatile boolean started;
    /** 停止标记，连续失败后置为 true，后续不再继续检测 */
    private volatile boolean stopped;

    /** 当前 S7 连接对象 */
    private S7PLC s7PLC;
    /** 当前在线状态 */
    private volatile boolean online;
    /** 最近一次成功读取心跳的时间 */
    private LocalDateTime lastHeartbeat;
    /** 连续重连失败次数 */
    private int reconnectFailureRounds;

    /**
    * @Description: 构造方法 
    * @Param: [config, signalConfigMapper]
    * @return: 
    */
    public WmsPlcConnection(TWmsPlcConnection config, TWmsPlcSignalConfigMapper signalConfigMapper) {
        this.config = config;
        this.signalConfigMapper = signalConfigMapper;
        this.executor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread thread = new Thread(r, "wms-plc-" + safeThreadName());
            thread.setDaemon(true);
            return thread;
        });
    }

    /**
    * @Description: 启动定时检测 
    * @Param: []
    * @return: void
    */
    public void start() {
        if (started) {
            return;
        }
        synchronized (lock) {
            if (started) {
                return;
            }
            started = true;
            stopped = false;
            log.info("PLC[{}] 定时检测线程启动: {} ({})", config.getId(), config.getName(), config.getHost());
            // 每个 PLC 独占一个单线程调度器，避免同一 PLC 的检测任务并发重入
            executor.scheduleAtFixedRate(this::safeExecute, 0, PERIOD_SECONDS, TimeUnit.SECONDS);
        }
    }

    public void stop() {
        synchronized (lock) {
            stopLocked("主动停止");
        }
    }

    /**
    * @Description: 定时检测做的事 
    * @Param: []
    * @return: void
    */
    private void safeExecute() {
        if (stopped) {
            return;
        }
        try {
            executeCycle();
        } catch (Exception e) {
            log.error("PLC[{}] 周期检测未捕获异常: {}", config.getId(), e.getMessage(), e);
            handleCycleFailure(e);
        }
    }

    /**
    * @Description: 定时检测做的事 
    * @Param: []
    * @return: void
    */
    private void executeCycle() {
        // 信号块配置先在锁外读取，减少锁占用时间
        List<TWmsPlcSignalConfig> signalConfigs = loadEnabledSignalConfigs();
        synchronized (lock) {
            if (stopped) {
                return;
            }
            try {
                // 1. 确保连接存在
                ensureConnectedLocked();
                // 2. 读取心跳地址
                readHeartbeatLocked();
                // 3. 读取所有启用的信号块
                readSignalBlocksLocked(signalConfigs);
                // 只要本轮完整成功，失败计数清零
                reconnectFailureRounds = 0;
            } catch (Exception e) {
                online = false;
                log.warn("PLC[{}] 本轮检测异常，将执行重连: {}", config.getId(), e.getMessage());
                // 本轮任何一步失败，立即走重连逻辑
                reconnectAfterFailureLocked();
            }
        }
    }

    private List<TWmsPlcSignalConfig> loadEnabledSignalConfigs() {
        try {
            List<TWmsPlcSignalConfig> signalConfigs = signalConfigMapper.selectList(
                    new LambdaQueryWrapper<TWmsPlcSignalConfig>()
                            .eq(TWmsPlcSignalConfig::getPlcId, config.getId())
                            .eq(TWmsPlcSignalConfig::getEnabled, 1)
            );
            return signalConfigs == null ? Collections.emptyList() : signalConfigs;
        } catch (Exception e) {
            log.error("PLC[{}] 读取信号块配置失败: {}", config.getId(), e.getMessage(), e);
            throw e;
        }
    }

    /**
    * @Description: 检测连接是否存在 
    * @Param: []
    * @return: void
    */
    private void ensureConnectedLocked() {
        if (s7PLC != null) {
            return;
        }
        log.info("PLC[{}] 当前无连接，准备建立连接", config.getId());
        if (!doConnectLocked()) {
            throw new IllegalStateException("PLC[" + config.getId() + "] 连接失败");
        }
    }

    private boolean doConnectLocked() {
        // 先关闭旧连接，避免资源占用或残留半开连接
        closeCurrentLocked();
        try {
            // PLC 类型来自配置，按 S7 库枚举做映射
            EPlcType type = EPlcType.valueOf(normalizePlcType(config.getPlcType()));
            this.s7PLC = new S7PLC(type, config.getHost());
            log.info("PLC[{}] S7 客户端已创建: {} ({})", config.getId(), config.getName(), config.getHost());

            // 连接创建后立即做一次心跳校验，尽早刷新在线状态
            if (StringUtils.hasText(config.getHeartbeatAddr())) {
                try {
                    short heartbeat = readUInt16Locked(config.getHeartbeatAddr());
                    this.online = true;
                    this.lastHeartbeat = LocalDateTime.now();
                    log.info("PLC[{}] 心跳成功, 地址={}, 值={}", config.getId(), config.getHeartbeatAddr(), heartbeat);
                } catch (Exception e) {
                    this.online = false;
                    log.warn("PLC[{}] 心跳失败, 状态置为离线: {}", config.getId(), e.getMessage());
                    return false;
                }
            } else {
                this.online = true;
                log.info("PLC[{}] 未配置心跳地址, 连接创建后默认在线", config.getId());
            }
            return true;
        } catch (Exception e) {
            this.online = false;
            this.s7PLC = null;
            log.error("PLC[{}] S7 客户端创建异常: {} | IP={} type={} - {}",
                    config.getId(), config.getName(), config.getHost(), config.getPlcType(), e.getMessage(), e);
            return false;
        }
    }

    /**
    * @Description: plc重连
    * @Param: []
    * @return: void
    */
    private void reconnectAfterFailureLocked() {
        if (stopped) {
            return;
        }
        // 连接失败时，立即尝试重连
        if (doConnectLocked()) {
            reconnectFailureRounds = 0;
            log.info("PLC[{}] 重连成功", config.getId());
            return;
        }
        // 一轮重连失败，计数加一
        reconnectFailureRounds++;
        log.error("PLC[{}] 重连失败，第{}轮", config.getId(), reconnectFailureRounds);
        // 连续 3 轮失败后停止定时检测，交给人工处理
        if (reconnectFailureRounds >= 3) {
            log.error("PLC[{}] 连续3轮重连失败，停止定时检测，等待人工重启", config.getId());
            stopLocked("连续3轮重连失败");
        }
    }

    /**
    * @Description: 读取心跳地址 
    * @Param: []
    * @return: void
    */
    private void readHeartbeatLocked() {
        if (!StringUtils.hasText(config.getHeartbeatAddr())) {
            return;
        }
        short heartbeat = readUInt16Locked(config.getHeartbeatAddr());
        this.online = true;
        this.lastHeartbeat = LocalDateTime.now();
        log.info("PLC[{}] 心跳读取成功: addr={}, value={}", config.getId(), config.getHeartbeatAddr(), heartbeat);
    }

    /**
    * @Description: 遍历读取对应plc的信号块 
    * @Param: [signalConfigs]
    * @return: void
    */
    private void readSignalBlocksLocked(List<TWmsPlcSignalConfig> signalConfigs) {
        if (signalConfigs.isEmpty()) {
            log.info("PLC[{}] 未配置启用的信号块地址", config.getId());
            return;
        }
        for (TWmsPlcSignalConfig signalConfig : signalConfigs) {
            if (!StringUtils.hasText(signalConfig.getPlcAddress())) {
                continue;
            }
            // 这里按你要求：任一地址读取失败，就让本轮直接进入重连流程
            short value = readUInt16Locked(signalConfig.getPlcAddress());
            log.info("PLC[{}] 信号块读取成功: address={}, value={}, description={}",
                    config.getId(), signalConfig.getPlcAddress(), value, signalConfig.getDescription());
        }
    }

    /**
    * @Description: 检测是否需要重连
    * @Param: [e]
    * @return: void
    */
    private void handleCycleFailure(Exception e) {
        synchronized (lock) {
            if (stopped) {
                return;
            }
            online = false;
            log.warn("PLC[{}] 周期检测异常后准备重连: {}", config.getId(), e.getMessage());
            reconnectAfterFailureLocked();
        }
    }

    private void stopLocked(String reason) {
        if (stopped) {
            return;
        }
        stopped = true;
        started = false;
        online = false;
        closeCurrentLocked();
        executor.shutdownNow();
        log.error("PLC[{}] 定时检测已停止: {}", config.getId(), reason);
    }

    /**
    * @Description: 关闭旧连接 
    * @Param: []
    * @return: void
    */
    private void closeCurrentLocked() {
        if (s7PLC == null) {
            return;
        }
        try {
            s7PLC.close();
            log.info("PLC[{}] 旧连接已关闭", config.getId());
        } catch (Exception e) {
            log.warn("PLC[{}] 关闭旧连接失败: {}", config.getId(), e.getMessage());
        } finally {
            s7PLC = null;
        }
    }

    /**
    * @Description: plc连接对象
    * @Param: []
    * @return: com.github.xingshuangs.iot.protocol.s7.service.S7PLC
    */
    private S7PLC getS7PLC() {
        if (s7PLC == null) {
            throw new RuntimeException("PLC[" + config.getId() + "] 未连接");
        }
        return s7PLC;
    }

    private String normalizePlcType(String plcType) {
        if (!StringUtils.hasText(plcType)) {
            throw new IllegalArgumentException("PLC类型不能为空");
        }
        return plcType.trim().toUpperCase(Locale.ROOT);
    }

    private String safeThreadName() {
        return config.getId() == null ? "unknown" : String.valueOf(config.getId());
    }

    private short readUInt16Locked(String address) {
        synchronized (lock) {
            return (short) getS7PLC().readUInt16(address);
        }
    }

    // ==================== 读写操作 ====================

    public boolean readBoolean(String address) {
        synchronized (lock) {
            return getS7PLC().readBoolean(address);
        }
    }

    public short readUInt16(String address) {
        synchronized (lock) {
            return (short) getS7PLC().readUInt16(address);
        }
    }

    public short readInt16(String address) {
        synchronized (lock) {
            return getS7PLC().readInt16(address);
        }
    }

    public int readInt32(String address) {
        synchronized (lock) {
            return getS7PLC().readInt32(address);
        }
    }

    public float readFloat32(String address) {
        synchronized (lock) {
            return getS7PLC().readFloat32(address);
        }
    }

    public double readFloat64(String address) {
        synchronized (lock) {
            return getS7PLC().readFloat64(address);
        }
    }

    public String readString(String address) {
        synchronized (lock) {
            return getS7PLC().readString(address);
        }
    }

    public void writeBoolean(String address, boolean value) {
        synchronized (lock) {
            getS7PLC().writeBoolean(address, value);
        }
    }

    public void writeUInt16(String address, int value) {
        synchronized (lock) {
            getS7PLC().writeUInt16(address, value);
        }
    }

    public void writeInt16(String address, short value) {
        synchronized (lock) {
            getS7PLC().writeInt16(address, value);
        }
    }

    public void writeInt32(String address, int value) {
        synchronized (lock) {
            getS7PLC().writeInt32(address, value);
        }
    }

    public void writeFloat32(String address, float value) {
        synchronized (lock) {
            getS7PLC().writeFloat32(address, value);
        }
    }

    public void writeFloat64(String address, double value) {
        synchronized (lock) {
            getS7PLC().writeFloat64(address, value);
        }
    }

    public void writeString(String address, String value) {
        synchronized (lock) {
            getS7PLC().writeString(address, value);
        }
    }

    // ==================== 状态查询 ====================

    public String getId() {
        return config.getId();
    }

    public String getName() {
        return config.getName();
    }

    public String getHost() {
        return config.getHost();
    }

    public String getPlcType() {
        return config.getPlcType();
    }

    public Integer getEnabled() {
        return config.getEnabled();
    }

    public boolean isOnline() {
        return online;
    }

    public LocalDateTime getLastHeartbeat() {
        return lastHeartbeat;
    }
}
