package com.wms.business.plc.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.business.plc.domain.TWmsPlcLocationConfig;
import com.wms.business.plc.mapper.TWmsPlcLocationConfigMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 信号地址 → 储位地标码映射 CRUD
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@Service
public class PlcLocationConfigService extends ServiceImpl<TWmsPlcLocationConfigMapper, TWmsPlcLocationConfig> {

    /**
    * @Description: 根据信号值（即数组下标）查询对应地标码
    * @Param: [plcId, address, arrIdx]
    * @return: com.wms.business.plc.domain.TWmsPlcLocationConfig
    */
    public TWmsPlcLocationConfig findByArrIdx(String plcId, String address, int arrIdx) {
        return getOne(new LambdaQueryWrapper<TWmsPlcLocationConfig>()
                .eq(TWmsPlcLocationConfig::getPlcId, plcId)
                .eq(TWmsPlcLocationConfig::getAddress, address)
                .eq(TWmsPlcLocationConfig::getArrIdx, arrIdx));
    }

    /**
    * @Description: 根据地址查询对应地标码
    * @Param: [plcId, address, arrIdx]
    * @return: com.wms.business.plc.domain.TWmsPlcLocationConfig
    */
    public TWmsPlcLocationConfig findByAddress(String plcId, String address) {
        return getOne(new LambdaQueryWrapper<TWmsPlcLocationConfig>()
                .eq(TWmsPlcLocationConfig::getPlcId, plcId)
                .eq(TWmsPlcLocationConfig::getAddress, address));
    }

    /**
    * @Description: 查询地址下的所有地标码（按数组下标排序）
    * @Param: [plcId, address]
    * @return: java.util.List<com.wms.business.plc.domain.TWmsPlcLocationConfig>
    */
    public List<TWmsPlcLocationConfig> listByAddress(String plcId, String address) {
        return list(new LambdaQueryWrapper<TWmsPlcLocationConfig>()
                .eq(TWmsPlcLocationConfig::getPlcId, plcId)
                .eq(TWmsPlcLocationConfig::getAddress, address)
                .orderByAsc(TWmsPlcLocationConfig::getArrIdx));
    }
}
