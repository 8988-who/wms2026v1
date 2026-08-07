package com.wms.business.plc.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * PLC 全局配置属性
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.config
 * @Author: YangZheng
 * @CreateTime: 2026-07-20 17:13
 * @Description: PLC全局配置
 * @Version: 1.0
 */
@Configuration
@ConfigurationProperties(prefix = "plc")
public class PlcProperties {

    /** 是否启用 PLC 模块 */
    private boolean enabled = false;

    /** 寄存器轮询间隔（毫秒），默认 500ms */
    private long pollInterval = 500;

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public long getPollInterval() {
        return pollInterval;
    }

    public void setPollInterval(long pollInterval) {
        this.pollInterval = pollInterval;
    }
}
