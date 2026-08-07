package com.wms.business.plc;

import com.github.xingshuangs.iot.protocol.s7.enums.EPlcType;
import com.github.xingshuangs.iot.protocol.s7.service.S7PLC;

/**
 * PLC S7 轻量化测试启动类
 * <p>
 * 不依赖 Spring，直接 main 方法运行，用于快速验证 S7 连接与读写。
 * <p>
 * 用法：运行 main，修改 host/plcType 匹配你的 PLC。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC S7 轻量化测试
 * @Version: 1.0
 */
public class PlcTest {

    public static void main(String[] args) {
        // ========== PLC ==========
        String host = "10.14.158.2";
        EPlcType plcType = EPlcType.S1200;
        // S7 测试地址
        String boolAddr = "DB2000";
        String uint16Addr = "DB2000";
        // =======================================

        S7PLC plc = new S7PLC(plcType, host);
        try {
            System.out.println("== PLC S7 连接测试 ==");
            System.out.println("目标: " + host + ", type=" + plcType);

//            // 1. 读取 Boolean
//            System.out.println("\n--- 读取 Boolean ---");
//            boolean b = plc.readBoolean(boolAddr);
//            System.out.println(boolAddr + " → " + b);

            // 2. 读取 UInt16
            System.out.println("\n--- 读取 UInt16 ---");
            int val = plc.readUInt16(uint16Addr);
            System.out.println(uint16Addr + " → " + val);

            // 4. 写入 UInt16
            System.out.println("\n--- 写入 UInt16 ---");
            System.out.println("写入 " + uint16Addr + " val=10");
            plc.writeUInt16(uint16Addr, 10);
//
//            // 5. 回读验证
//            int after = plc.readUInt16(uint16Addr);
//            System.out.println("回读 " + uint16Addr + " → " + after);
//
//            // 6. 写入 Boolean
//            System.out.println("\n--- 写入 Boolean ---");
//            plc.writeBoolean(boolAddr, true);
//            System.out.println("回读 " + boolAddr + " → " + plc.readBoolean(boolAddr));

            System.out.println("\n=== 测试通过 ===");

        } catch (Exception e) {
            System.err.println("PLC S7 通信失败: " + e.getMessage());
            e.printStackTrace();
        } finally {
            plc.close();
            System.out.println("连接已关闭");
        }
    }
}
