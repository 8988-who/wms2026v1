package com.wms.business.plc.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.business.plc.domain.TWmsPlcSignalConfig;
import com.wms.business.plc.mapper.TWmsPlcSignalConfigMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * PLC 信号配置 CRUD 服务
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@Service
public class PlcSignalConfigService extends ServiceImpl<TWmsPlcSignalConfigMapper, TWmsPlcSignalConfig> {

    /**
     * 查询指定 PLC 的所有启用信号
     */
    public List<TWmsPlcSignalConfig> listEnabledByPlcId(String plcId) {
        return list(new LambdaQueryWrapper<TWmsPlcSignalConfig>()
                .eq(TWmsPlcSignalConfig::getPlcId, plcId)
                .eq(TWmsPlcSignalConfig::getEnabled, 1)
                .orderByAsc(TWmsPlcSignalConfig::getSort));
    }

    /**
     * 查询所有启用的信号
     */
    public List<TWmsPlcSignalConfig> listAllEnabled() {
        return list(new LambdaQueryWrapper<TWmsPlcSignalConfig>()
                .eq(TWmsPlcSignalConfig::getEnabled, 1)
                .orderByAsc(TWmsPlcSignalConfig::getSort));
    }
}
