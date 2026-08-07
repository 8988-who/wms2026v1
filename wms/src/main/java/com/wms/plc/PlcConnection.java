package com.wms.business.plc;

import com.github.xingshuangs.iot.protocol.s7.enums.EPlcType;
import com.github.xingshuangs.iot.protocol.s7.service.S7PLC;
import com.wms.business.plc.domain.TWmsPlcConnection;
import com.wms.business.plc.listener.PlcSignalListener;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.Closeable;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * 单个 PLC 连接包装
 * <p>
 * 封装一个 S7PLC 实例，管理独立的轮询线程、信号监听和在线状态。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: 单PLC连接
 * @Version: 1.0
 */
public class PlcConnection implements Closeable {

    private static final Logger log = LoggerFactory.getLogger(PlcConnection.class);

    private final TWmsPlcConnection config;
    private S7PLC s7PLC;
    private final Object lock = new Object();

    /** 在线状态 */
    private volatile boolean online = false;

    /** 上次心跳时间 */
    private volatile LocalDateTime lastHeartbeat;

    /** 信号监听: plcAddress → {listener, mesAddress, lastValue} */
    private final Map<String, SignalEntry> signalListeners = new ConcurrentHashMap<>();

    private ScheduledExecutorService pollExecutor;
    private final long pollInterval;
    private static final int SHUTDOWN_TIMEOUT = 3;

    private static class SignalEntry {
        final PlcSignalListener listener;
        final String mesAddress;
        final String exceptionAddress;
        volatile Short lastValue;

        SignalEntry(PlcSignalListener listener, String mesAddress, String exceptionAddress) {
            this.listener = listener;
            this.mesAddress = mesAddress;
            this.exceptionAddress = exceptionAddress;
        }
    }

    public PlcConnection(TWmsPlcConnection config, long pollInterval) {
        this.config = config;
        this.pollInterval = pollInterval;
    }

    /**
     * 建立 S7 连接并启动轮询
     */
    public void start() {
        synchronized (lock) {
            try {
                EPlcType type = EPlcType.valueOf(config.getPlcType());
                this.s7PLC = new S7PLC(type, config.getHost());
                log.info("PLC[{}] S7 客户端已创建: {} ({})", config.getId(), config.getName(), config.getHost());

                // 创建连接后立即执行一次心跳检测，同步刷新 online 状态
                // 避免 reconnect/启动后前端立即查询时仍显示离线
                if (config.getHeartbeatAddr() != null && !config.getHeartbeatAddr().isEmpty()) {
                    try {
                        s7PLC.readUInt16(config.getHeartbeatAddr());
                        this.online = true;
                        this.lastHeartbeat = LocalDateTime.now();
                        log.info("PLC[{}] 首次心跳成功，状态设为在线", config.getId());
                    } catch (Exception e) {
                        this.online = false;
                        log.warn("PLC[{}] 首次心跳失败，状态为离线: {}", config.getId(), e.getMessage());
                    }
                } else {
                    // 无心跳地址时，默认连接成功即为在线
                    this.online = true;
                }
            } catch (Exception e) {
                online = false;
                log.error("PLC[{}] S7 客户端创建异常: {} | IP={} type={} - {}", config.getId(), config.getName(), config.getHost(), config.getPlcType(), e.getMessage());
                return;
            }
        }
        startPolling();
    }

    /**
     * 关闭连接并停止轮询
     */
    @Override
    public void close() {
        stopPolling();
        synchronized (lock) {
            if (s7PLC != null) {
                try {
                    s7PLC.close();
                } catch (Exception ignored) {
                }
                s7PLC = null;
            }
            online = false;
            log.info("PLC[{}] 已关闭: {}", config.getId(), config.getName());
        }
    }

    // ==================== 轮询 ====================

    private void startPolling() {
        pollExecutor = Executors.newSingleThreadScheduledExecutor(r -> {
            Thread t = new Thread(r, "plc-poll-" + config.getId());
            t.setDaemon(true);
            return t;
        });
        pollExecutor.scheduleWithFixedDelay(this::doPoll, pollInterval, pollInterval, TimeUnit.MILLISECONDS);
        log.info("PLC[{}] 轮询已启动, 间隔 {}ms", config.getId(), pollInterval);
    }

    private void stopPolling() {
        if (pollExecutor != null && !pollExecutor.isShutdown()) {
            pollExecutor.shutdown();
            try {
                if (!pollExecutor.awaitTermination(SHUTDOWN_TIMEOUT, TimeUnit.SECONDS)) {
                    pollExecutor.shutdownNow();
                }
            } catch (InterruptedException e) {
                pollExecutor.shutdownNow();
                Thread.currentThread().interrupt();
            }
        }
    }

    private void doPoll() {
        // 1. 心跳检测
        if (config.getHeartbeatAddr() != null && !config.getHeartbeatAddr().isEmpty()) {
            try {
                getS7PLC().readUInt16(config.getHeartbeatAddr());
                if (!online) {
                    online = true;
                    log.info("PLC[{}] 已上线: {}", config.getId(), config.getName());
                }
                lastHeartbeat = LocalDateTime.now();
            } catch (Exception e) {
                if (online) {
                    online = false;
                    log.warn("PLC[{}] 已离线: {} | IP={} type={}", config.getId(), config.getName(), config.getHost(), config.getPlcType());
                }
            }
        }

        // 2. 信号监听
        if (!signalListeners.isEmpty()) {
            for (Map.Entry<String, SignalEntry> entry : signalListeners.entrySet()) {
                String plcAddress = entry.getKey();
                SignalEntry se = entry.getValue();
                try {
                    short newVal = (short) getS7PLC().readUInt16(plcAddress);
                    Short prev = se.lastValue;
                    if (prev == null || prev != newVal) {
                        se.lastValue = newVal;
                        log.info("PLC[{}] 信号变化: addr={}, {} → {}", config.getId(), plcAddress, prev, newVal);
                        try {
                            se.listener.onSignalChanged(plcAddress, se.mesAddress, se.exceptionAddress, prev, newVal);
                        } catch (Exception ex) {
                            log.error("PLC[{}] 信号回调异常: addr={}", config.getId(), plcAddress, ex);
                        }
                    }
                } catch (Exception e) {
                    log.error("PLC[{}] 轮询读取失败: addr={} | IP={} type={}", config.getId(), plcAddress, config.getHost(), config.getPlcType(), e);
                }
            }
        }
    }

    // ==================== 监听管理 ====================

    public void registerSignalListener(String plcAddress, String mesAddress, String exceptionAddress, PlcSignalListener listener) {
        signalListeners.put(plcAddress, new SignalEntry(listener, mesAddress, exceptionAddress));
        log.info("PLC[{}] 注册信号监听: plc={}, mes={}, exc={}", config.getId(), plcAddress, mesAddress, exceptionAddress);
    }

    public void removeSignalListener(String plcAddress) {
        signalListeners.remove(plcAddress);
        log.info("PLC[{}] 移除信号监听: addr={}", config.getId(), plcAddress);
    }

    // ==================== 读写操作 ====================

    private S7PLC getS7PLC() {
        if (s7PLC == null) {
            throw new RuntimeException("PLC[" + config.getId() + "] 未连接");
        }
        return s7PLC;
    }

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
