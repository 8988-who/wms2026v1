package com.wms.business.plc.manager;

import com.wms.business.plc.PlcConnection;
import com.wms.business.plc.handler.PlcSignalHandler;
import com.wms.business.plc.domain.TWmsPlcSignalConfig;
import com.wms.business.plc.service.PlcSignalConfigService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * PLC 信号配置管理器
 * <p>
 * 启动时从 DB 加载信号配置，查找对应的 Handler Bean 并注册监听。
 * 运行时支持前端增删改信号配置，自动注册/注销监听。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@Component
public class PlcSignalManager {

    private static final Logger log = LoggerFactory.getLogger(PlcSignalManager.class);

    @Autowired
    private PlcSignalConfigService signalConfigService;

    @Autowired
    private PlcConnectionManager connectionManager;

    @Autowired
    private ApplicationContext applicationContext;

    /** 已注册信号 ID 集合，用于去重 */
    private final Map<String, TWmsPlcSignalConfig> registeredSignals = new ConcurrentHashMap<>();

    /**
     * 启动时加载所有启用的信号配置并注册监听
     */
    @PostConstruct
    public void init() {
        List<TWmsPlcSignalConfig> configs = signalConfigService.listAllEnabled();
        log.info("加载到 {} 个 PLC 信号配置", configs.size());
        for (TWmsPlcSignalConfig config : configs) {
            try {
                registerSignal(config);
            } catch (Exception e) {
                log.error("信号注册失败: plcId={}, plc={}, mes={}, handler={}",
                        config.getPlcId(), config.getPlcAddress(), config.getMesAddress(), config.getHandler(), e);
            }
        }
    }

    /**
     * 为指定 PLC 注册其所有启用的信号（PLC 启用后调用）
     */
    public void registerAllForPlc(String plcId) {
        List<TWmsPlcSignalConfig> configs = signalConfigService.listEnabledByPlcId(plcId);
        for (TWmsPlcSignalConfig config : configs) {
            try {
                registerSignal(config);
            } catch (Exception e) {
                log.error("信号注册失败: plcId={}, plc={}", plcId, config.getPlcAddress(), e);
            }
        }
    }

    /**
     * 为指定 PLC 注销其所有信号（PLC 禁用时调用）
     */
    public void unregisterAllForPlc(String plcId) {
        registeredSignals.values().stream()
                .filter(c -> c.getPlcId().equals(plcId))
                .forEach(c -> {
                    try {
                        connectionManager.getConnection(plcId).removeSignalListener(c.getPlcAddress());
                    } catch (Exception ignored) {
                    }
                    registeredSignals.remove(c.getId());
                });
    }

    // ==================== 运行时 CRUD ====================

    /**
     * 新增信号配置并立即注册监听
     */
    public TWmsPlcSignalConfig addSignal(TWmsPlcSignalConfig config) {
        signalConfigService.save(config);
        try {
            registerSignal(config);
        } catch (Exception e) {
            log.warn("信号新增后注册失败: plcId={}, plc={}, mes={}, handler={}",
                    config.getPlcId(), config.getPlcAddress(), config.getMesAddress(), config.getHandler(), e);
        }
        return config;
    }

    /**
     * 更新信号配置
     */
    public void updateSignal(TWmsPlcSignalConfig config) {
        TWmsPlcSignalConfig old = signalConfigService.getById(config.getId());
        if (old == null) {
            throw new RuntimeException("信号配置不存在: " + config.getId());
        }
        // 先注销旧的
        unregisterSignal(old);
        // 保存
        signalConfigService.updateById(config);
        // 注册新的
        if (config.getEnabled() != null && config.getEnabled() == 1) {
            try {
                registerSignal(config);
            } catch (Exception e) {
                log.warn("信号更新后注册失败: plcId={}, plc={}", config.getPlcId(), config.getPlcAddress(), e);
            }
        }
    }

    /**
     * 启用信号
     */
    public void enableSignal(String signalId) {
        TWmsPlcSignalConfig config = signalConfigService.getById(signalId);
        if (config == null) {
            throw new RuntimeException("信号配置不存在: " + signalId);
        }
        config.setEnabled(1);
        signalConfigService.updateById(config);
        try {
            registerSignal(config);
        } catch (Exception e) {
            log.warn("信号启用后注册失败: plcId={}, plc={}", config.getPlcId(), config.getPlcAddress(), e);
        }
    }

    /**
     * 禁用信号
     */
    public void disableSignal(String signalId) {
        TWmsPlcSignalConfig config = signalConfigService.getById(signalId);
        if (config == null) {
            throw new RuntimeException("信号配置不存在: " + signalId);
        }
        config.setEnabled(0);
        signalConfigService.updateById(config);
        unregisterSignal(config);
    }

    /**
     * 删除信号配置
     */
    public void deleteSignal(String signalId) {
        TWmsPlcSignalConfig config = signalConfigService.getById(signalId);
        if (config != null) {
            unregisterSignal(config);
        }
        signalConfigService.removeById(signalId);
    }

    /**
     * 查询指定 PLC 的信号配置列表
     */
    public List<TWmsPlcSignalConfig> listByPlcId(String plcId) {
        return signalConfigService.listEnabledByPlcId(plcId);
    }

    // ==================== 内部方法 ====================

    private void registerSignal(TWmsPlcSignalConfig config) {
        // 获取 handler Bean
        PlcSignalHandler handler = applicationContext.getBean(config.getHandler(), PlcSignalHandler.class);

        // 通过 PlcConnectionManager 注册监听（读取 plcAddress，回调时传入 mesAddress）
        PlcConnection conn = connectionManager.getConnection(config.getPlcId());
        conn.registerSignalListener(config.getPlcAddress(), config.getMesAddress(), config.getExceptionAddress(),
                (plcAddress, mesAddress, exceptionAddress, prevVal, newVal) -> {
            handler.onSignal(config.getPlcId(), plcAddress, mesAddress, exceptionAddress, newVal);
        });

        registeredSignals.put(config.getId(), config);
        log.info("信号已注册: plcId={}, plc={}, mes={}, handler={}",
                config.getPlcId(), config.getPlcAddress(), config.getMesAddress(), config.getHandler());
    }

    private void unregisterSignal(TWmsPlcSignalConfig config) {
        try {
            connectionManager.getConnection(config.getPlcId())
                    .removeSignalListener(config.getPlcAddress());
        } catch (Exception ignored) {
        }
        registeredSignals.remove(config.getId());
    }
}
