package com.wms.business.plc.manager;

import com.wms.business.plc.PlcConnection;
import com.wms.business.plc.config.PlcProperties;
import com.wms.business.plc.domain.TWmsPlcConnection;
import com.wms.business.plc.service.PlcConnectionService;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

/**
 * PLC 连接统一管理器
 * <p>
 * 管理所有 PLC 连接的生命周期：启动时从数据库加载启用配置并建连，
 * 运行时支持新增、启用、禁用、删除、重连。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: 多PLC连接管理器
 * @Version: 1.0
 */
@Component
public class PlcConnectionManager {

    private static final Logger log = LoggerFactory.getLogger(PlcConnectionManager.class);

    @Autowired
    private PlcConnectionService plcConnectionService;

    @Autowired
    private PlcProperties plcProperties;

    /** plcId → PlcConnection */
    private final Map<String, PlcConnection> connections = new ConcurrentHashMap<>();

    /**
     * 启动时从 DB 加载所有启用的连接
     */
    @PostConstruct
    public void init() {
        if (!plcProperties.isEnabled()) {
            log.info("PLC 连接未启用，跳过初始化");
            return;
        }
        List<TWmsPlcConnection> configs = plcConnectionService.listEnabled();
        log.info("加载到 {} 个启用的 PLC 连接配置", configs.size());
        for (TWmsPlcConnection config : configs) {
            try {
                createAndStart(config);
            } catch (Exception e) {
                log.error("PLC[{}] 初始化失败: {}", config.getId(), e.getMessage());
            }
        }
    }

    /**
     * 关闭所有连接
     */
    @PreDestroy
    public void destroy() {
        log.info("正在关闭所有 PLC 连接...");
        for (PlcConnection pc : connections.values()) {
            try {
                pc.close();
            } catch (Exception ignored) {
            }
        }
        connections.clear();
    }

    // ==================== 运行时管理 ====================

    /**
     * 新增并启动一个 PLC 连接
     */
    public void addConnection(TWmsPlcConnection config) {
        plcConnectionService.save(config);
        if (config.getEnabled() != null && config.getEnabled() == 1) {
            createAndStart(config);
        }
        log.info("PLC[{}] 新增配置: {}", config.getId(), config.getName());
    }

    /**
     * 更新配置（不重启连接，下次重连生效）
     */
    public void updateConfig(TWmsPlcConnection config) {
        plcConnectionService.updateById(config);
        log.info("PLC[{}] 配置已更新: {}", config.getId(), config.getName());
    }

    /**
     * 启用指定 PLC
     */
    public void enableConnection(String plcId) {
        TWmsPlcConnection config = plcConnectionService.getById(plcId);
        if (config == null) {
            throw new RuntimeException("PLC 配置不存在: " + plcId);
        }
        config.setEnabled(1);
        plcConnectionService.updateById(config);

        PlcConnection existing = connections.get(plcId);
        if (existing != null) {
            existing.close();
        }
        createAndStart(config);
        log.info("PLC[{}] 已启用: {}", plcId, config.getName());
    }

    /**
     * 禁用指定 PLC
     */
    public void disableConnection(String plcId) {
        TWmsPlcConnection config = plcConnectionService.getById(plcId);
        if (config == null) {
            throw new RuntimeException("PLC 配置不存在: " + plcId);
        }
        config.setEnabled(0);
        plcConnectionService.updateById(config);

        PlcConnection pc = connections.remove(plcId);
        if (pc != null) {
            pc.close();
        }
        log.info("PLC[{}] 已禁用: {}", plcId, config.getName());
    }

    /**
     * 删除指定 PLC
     */
    public void deleteConnection(String plcId) {
        PlcConnection pc = connections.remove(plcId);
        if (pc != null) {
            pc.close();
        }
        plcConnectionService.removeById(plcId);
        log.info("PLC[{}] 已删除", plcId);
    }

    /**
     * 重连指定 PLC
     */
    public void reconnect(String plcId) {
        TWmsPlcConnection config = plcConnectionService.getById(plcId);
        if (config == null) {
            throw new RuntimeException("PLC 配置不存在: " + plcId);
        }
        PlcConnection existing = connections.remove(plcId);
        if (existing != null) {
            existing.close();
        }
        createAndStart(config);
        log.info("PLC[{}] 已重连: {}", plcId, config.getName());
    }

    // ==================== 查询 ====================

    /**
     * 获取所有连接的状态列表（供前端面板）
     */
    public List<PlcStatusVO> listStatus() {
        // 从 DB 获取所有配置
        List<TWmsPlcConnection> allConfigs = plcConnectionService.listAll();
        return allConfigs.stream().map(c -> {
            PlcConnection pc = connections.get(c.getId());
            return new PlcStatusVO(
                    c.getId(), c.getName(), c.getHost(), c.getPlcType(),
                    c.getEnabled(), c.getHeartbeatAddr(),
                    pc != null && pc.isOnline(),
                    pc != null ? pc.getLastHeartbeat() : null
            );
        }).collect(Collectors.toList());
    }

    /**
     * 获取单个连接（供内部使用）
     */
    public PlcConnection getConnection(String plcId) {
        PlcConnection pc = connections.get(plcId);
        if (pc == null) {
            throw new RuntimeException("PLC 未连接: " + plcId);
        }
        return pc;
    }

    // ==================== 内部方法 ====================

    private void createAndStart(TWmsPlcConnection config) {
        PlcConnection pc = new PlcConnection(config, plcProperties.getPollInterval());
        pc.start();
        connections.put(config.getId(), pc);
    }

    // ==================== 状态VO ====================

    @Setter
    @Getter
    @AllArgsConstructor
    @NoArgsConstructor
    public static class PlcStatusVO {
        private String id;
        private String name;
        private String host;
        private String plcType;
        private Integer enabled;
        private String heartbeatAddr;
        private boolean online;
        private LocalDateTime lastHeartbeat;
    }
}
