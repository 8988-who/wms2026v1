package com.wms.plc.manager;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.plc.WmsPlcConnection;
import com.wms.plc.mapper.TWmsPlcConnectionMapper;
import com.wms.plc.mapper.TWmsPlcSignalConfigMapper;
import com.wms.common.model.entity.TWmsPlcConnection;
import jakarta.annotation.PreDestroy;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.event.EventListener;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.util.Collection;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * PLC连接管理器
 * <p>应用启动后加载所有启用的PLC连接，并在退出时统一关闭。</p>
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class WmsPlcConnectionManager {

    private final TWmsPlcConnectionMapper connectionMapper;
    private final TWmsPlcSignalConfigMapper signalConfigMapper;
    /** 运行中的 PLC 连接实例，key 为 PLC ID */
    private final Map<String, WmsPlcConnection> connectionMap = new ConcurrentHashMap<>();

    /**
    * @Description: 启动所有连接
    * @Param: []
    * @return: void
    */
    @EventListener(ApplicationReadyEvent.class)
    public void startAll() {
        try {
            // 应用启动时先清空旧实例，避免重复启动
            stopAll();
            // 管理线程
            Map<String, WmsPlcConnection> latestMap = new ConcurrentHashMap<>();
            // 只加载启用状态的 PLC 配置
            connectionMapper.selectList(
                            new LambdaQueryWrapper<TWmsPlcConnection>()
                                    .eq(TWmsPlcConnection::getEnabled, 1)
                                    .orderByAsc(TWmsPlcConnection::getId)
                    )
                    .forEach(connection -> {
                        // 每条 PLC 配置对应一个独立连接实例
                        WmsPlcConnection plcConnection = new WmsPlcConnection(connection, signalConfigMapper);
                        //为该实例启动定时检测
                        plcConnection.start();
                        latestMap.put(connection.getId(), plcConnection);
                    });
            connectionMap.clear();
            connectionMap.putAll(latestMap);
            log.info("PLC连接管理器启动完成, 已启动 {} 个连接", connectionMap.size());
        } catch (Exception e) {
            log.error("PLC连接管理器启动失败: {}", e.getMessage(), e);
        }
    }

    /**
    * @Description: 获取对应plc连接 
    * @Param: [plcId]
    * @return: com.wms.plc.WmsPlcConnection
    */
    public WmsPlcConnection getConnection(String plcId) {
        return plcId == null ? null : connectionMap.get(plcId);
    }

    /**
    * @Description: 启动对应plc连接并加入连接池
    * @Param: [plcId]
    * @return: boolean
    */
    public boolean startConnection(String plcId) {
        if (!StringUtils.hasText(plcId)) {
            return false;
        }
        try {
            TWmsPlcConnection connection = connectionMapper.selectById(plcId);
            if (connection == null) {
                log.warn("PLC[{}] 配置不存在，无法启动连接", plcId);
                return false;
            }

            WmsPlcConnection oldConnection = connectionMap.remove(plcId);
            if (oldConnection != null) {
                oldConnection.stop();
            }

            WmsPlcConnection newConnection = new WmsPlcConnection(connection, signalConfigMapper);
            newConnection.start();
            connectionMap.put(plcId, newConnection);
            log.info("PLC[{}] 连接已启动并加入连接池", plcId);
            return true;
        } catch (Exception e) {
            log.error("PLC[{}] 启动连接失败: {}", plcId, e.getMessage(), e);
            return false;
        }
    }

    /**
    * @Description: 重新连接对应plc
    * @Param: [plcId]
    * @return: boolean
    */
    public boolean reconnectConnection(String plcId) {
        if (!StringUtils.hasText(plcId)) {
            return false;
        }
        try {
            TWmsPlcConnection connection = connectionMapper.selectById(plcId);
            if (connection == null) {
                log.warn("PLC[{}] 配置不存在，无法重连", plcId);
                return false;
            }

            WmsPlcConnection oldConnection = connectionMap.remove(plcId);
            if (oldConnection != null) {
                oldConnection.stop();
            }

            WmsPlcConnection newConnection = new WmsPlcConnection(connection, signalConfigMapper);
            newConnection.start();
            connectionMap.put(plcId, newConnection);
            log.info("PLC[{}] 连接已重连并加入连接池", plcId);
            return true;
        } catch (Exception e) {
            log.error("PLC[{}] 重连失败: {}", plcId, e.getMessage(), e);
            return false;
        }
    }

    /**
    * @Description: 获取所有plc连接 
    * @Param: []
    * @return: java.util.Collection<com.wms.plc.WmsPlcConnection>
    */
    public Collection<WmsPlcConnection> getAllConnections() {
        return connectionMap.values();
    }

    /**
    * @Description: 关闭对应plc连接
    * @Param: [plcId]
    * @return: boolean
    */
    public boolean stopConnection(String plcId) {
        if (!StringUtils.hasText(plcId)) {
            return false;
        }
        WmsPlcConnection plcConnection = connectionMap.remove(plcId);
        if (plcConnection == null) {
            log.warn("PLC[{}] 连接不存在，无需关闭", plcId);
            return false;
        }
        plcConnection.stop();
        log.info("PLC[{}] 连接已关闭", plcId);
        return true;
    }

    /**
    * @Description: 删除PLC前先关闭连接，未找到连接时直接放行
    * @Param: [plcId]
    * @return: boolean
    */
    public boolean closeConnectionForDelete(String plcId) {
        if (!StringUtils.hasText(plcId)) {
            return false;
        }

        WmsPlcConnection plcConnection = connectionMap.get(plcId);
        if (plcConnection == null) {
            log.info("PLC[{}] 连接池中不存在，直接进入删除流程", plcId);
            return true;
        }

        try {
            plcConnection.stop();
            connectionMap.remove(plcId, plcConnection);
            log.info("PLC[{}] 连接已关闭并移出连接池", plcId);
            return true;
        } catch (Exception e) {
            log.error("PLC[{}] 关闭连接失败: {}", plcId, e.getMessage(), e);
            return false;
        }
    }

    /**
    * @Description: 关闭所有plc连接 
    * @Param: []
    * @return: void
    */
    public void stopAll() {
        // 遍历plc连接实例，逐个关闭 PLC 连接，确保定时线程和 S7 连接都退出
        connectionMap.values().forEach(WmsPlcConnection::stop);
        connectionMap.clear();
    }

    /**
    * @Description:  @PreDestroy注解是容器要销毁这个 Bean 之前，自动调用这个`shutdown()`方法。
    * @Param: []
    * @return: void
    */
    @PreDestroy
    public void shutdown() {
        stopAll();
        log.info("PLC连接管理器已关闭");
    }
}
