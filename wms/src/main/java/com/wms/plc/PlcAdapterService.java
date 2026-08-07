package com.wms.business.plc;

import com.wms.business.plc.domain.TWmsPlcConnection;
import com.wms.business.plc.domain.TWmsPlcSignalConfig;
import com.wms.business.plc.listener.PlcSignalListener;
import com.wms.business.plc.manager.PlcConnectionManager;
import com.wms.business.plc.manager.PlcSignalManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * PLC 适配门面
 * <p>
 * 多 PLC 场景下，所有读写和监听操作通过 plcId 路由到对应的 PlcConnection。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC适配门面
 * @Version: 2.0
 */
@Service
public class PlcAdapterService {

    @Autowired
    private PlcConnectionManager connectionManager;

    @Autowired
    private PlcSignalManager signalManager;

    // ==================== 管理 API（供 Controller 调用） ====================

    public List<PlcConnectionManager.PlcStatusVO> listStatus() {
        return connectionManager.listStatus();
    }

    public void addConnection(TWmsPlcConnection config) {
        connectionManager.addConnection(config);
    }

    public void updateConnection(TWmsPlcConnection config) {
        connectionManager.updateConfig(config);
    }

    public void enableConnection(String plcId) {
        connectionManager.enableConnection(plcId);
        signalManager.registerAllForPlc(plcId);
    }

    public void disableConnection(String plcId) {
        signalManager.unregisterAllForPlc(plcId);
        connectionManager.disableConnection(plcId);
    }

    public void deleteConnection(String plcId) {
        signalManager.unregisterAllForPlc(plcId);
        connectionManager.deleteConnection(plcId);
    }

    public void reconnect(String plcId) {
        connectionManager.reconnect(plcId);
        signalManager.registerAllForPlc(plcId);
    }

    // ==================== 信号配置 API ====================

    public TWmsPlcSignalConfig addSignal(TWmsPlcSignalConfig config) {
        return signalManager.addSignal(config);
    }

    public void updateSignal(TWmsPlcSignalConfig config) {
        signalManager.updateSignal(config);
    }

    public void enableSignal(String signalId) {
        signalManager.enableSignal(signalId);
    }

    public void disableSignal(String signalId) {
        signalManager.disableSignal(signalId);
    }

    public void deleteSignal(String signalId) {
        signalManager.deleteSignal(signalId);
    }

    public List<TWmsPlcSignalConfig> listSignals(String plcId) {
        return signalManager.listByPlcId(plcId);
    }

    // ==================== 信号监听 ====================

    public void registerSignalListener(String plcId, String plcAddress, PlcSignalListener listener) {
        connectionManager.getConnection(plcId).registerSignalListener(plcAddress, null, null, listener);
    }

    public void registerSignalListener(String plcId, String plcAddress, String mesAddress, String exceptionAddress, PlcSignalListener listener) {
        connectionManager.getConnection(plcId).registerSignalListener(plcAddress, mesAddress, exceptionAddress, listener);
    }

    public void removeSignalListener(String plcId, String plcAddress) {
        connectionManager.getConnection(plcId).removeSignalListener(plcAddress);
    }

    // ==================== 读取操作 ====================

    public boolean readBoolean(String plcId, String address) {
        return connectionManager.getConnection(plcId).readBoolean(address);
    }

    public short readUInt16(String plcId, String address) {
        return connectionManager.getConnection(plcId).readUInt16(address);
    }

    public short readInt16(String plcId, String address) {
        return connectionManager.getConnection(plcId).readInt16(address);
    }

    public int readInt32(String plcId, String address) {
        return connectionManager.getConnection(plcId).readInt32(address);
    }

    public float readFloat32(String plcId, String address) {
        return connectionManager.getConnection(plcId).readFloat32(address);
    }

    public String readString(String plcId, String address) {
        return connectionManager.getConnection(plcId).readString(address);
    }

    // ==================== 写入操作 ====================

    public void writeBoolean(String plcId, String address, boolean value) {
        connectionManager.getConnection(plcId).writeBoolean(address, value);
    }

    public void writeUInt16(String plcId, String address, int value) {
        connectionManager.getConnection(plcId).writeUInt16(address, value);
    }

    public void writeInt16(String plcId, String address, short value) {
        connectionManager.getConnection(plcId).writeInt16(address, value);
    }

    public void writeInt32(String plcId, String address, int value) {
        connectionManager.getConnection(plcId).writeInt32(address, value);
    }

    public void writeFloat32(String plcId, String address, float value) {
        connectionManager.getConnection(plcId).writeFloat32(address, value);
    }

    public void writeString(String plcId, String address, String value) {
        connectionManager.getConnection(plcId).writeString(address, value);
    }
}
