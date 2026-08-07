package com.wms.business.plc.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.business.plc.domain.TWmsPlcReplenishmentConfig;
import com.wms.business.plc.mapper.TWmsPlcReplenishmentConfigMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * PLC 信号 → 补料参数配置 CRUD
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@Service
public class PlcReplenishmentConfigService extends ServiceImpl<TWmsPlcReplenishmentConfigMapper, TWmsPlcReplenishmentConfig> {

    /**
    * @Description: 根据 PLC ID + 地址 + 信号值查询补料配置
    * @Param: [plcId, address, triggerValue]
    * @return: com.wms.business.plc.domain.TWmsPlcReplenishmentConfig
    */
    public TWmsPlcReplenishmentConfig findByAddressAndTriggerValue(String plcId, String address, int triggerValue) {
        return getOne(new LambdaQueryWrapper<TWmsPlcReplenishmentConfig>()
                .eq(TWmsPlcReplenishmentConfig::getPlcId, plcId)
                .eq(TWmsPlcReplenishmentConfig::getAddress, address)
                .eq(TWmsPlcReplenishmentConfig::getTriggerValue, triggerValue)
                .eq(TWmsPlcReplenishmentConfig::getEnabled, 1));
    }

    /**
    * @Description: 查询指定 PLC 的所有配置
    * @Param: [plcId]
    * @return: java.util.List<com.wms.business.plc.domain.TWmsPlcReplenishmentConfig>
    */
    public List<TWmsPlcReplenishmentConfig> listByPlcId(String plcId) {
        return list(new LambdaQueryWrapper<TWmsPlcReplenishmentConfig>()
                .eq(TWmsPlcReplenishmentConfig::getPlcId, plcId)
                .orderByAsc(TWmsPlcReplenishmentConfig::getAddress));
    }
}
