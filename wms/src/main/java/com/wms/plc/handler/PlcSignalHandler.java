package com.wms.business.plc.handler;

/**
 * PLC 信号处理器接口
 * <p>
 * 实现此接口并注册为 Spring Bean，在信号配置表中指定 handler 名称即可自动关联。
 *
 * <pre>
 * &#64;Component("line1PlcHandler")
 * public class Line1PlcHandler implements PlcSignalHandler {
 *     &#64;Override
 *     public void onSignal(String plcId, String address, short newVal) {
 *         switch (address) {
 *             case "DB2000.14" -&gt; handleDispatch(newVal);
 *             case "DB2000.16" -&gt; handleAgvStatus(newVal);
 *         }
 *     }
 * }
 * </pre>
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@FunctionalInterface
public interface PlcSignalHandler {

    /**
     * 信号触发
     *
     * @param plcId            PLC 标识
     * @param plcAddress       PLC 读取地址
     * @param mesAddress       MES 写入地址（正常）
     * @param exceptionAddress 异常写入地址
     * @param newVal           当前值
     */
    void onSignal(String plcId, String plcAddress, String mesAddress, String exceptionAddress, short newVal);
}
