package com.wms.business.plc.listener;

/**
 * PLC 寄存器信号变化监听器
 * <p>
 * 当轮询到寄存器值发生变化时触发。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-20
 * @Description: PLC信号变化回调
 * @Version: 1.0
 */
@FunctionalInterface
public interface PlcSignalListener {

    /**
     * 寄存器值变化时回调
     *
     * @param plcAddress       PLC 读取地址，如 "DB2000.24"
     * @param mesAddress       MES 写入地址（正常），如 "DB2000.100"
     * @param exceptionAddress 异常写入地址，如 "DB2000.200"
     * @param prevVal          上一次的值，首次触发时为 null
     * @param newVal           当前值
     */
    void onSignalChanged(String plcAddress, String mesAddress, String exceptionAddress, Short prevVal, short newVal);
}
