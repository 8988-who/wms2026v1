package com.wms.business.plc.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.business.plc.domain.TWmsPlcConnection;
import com.wms.business.plc.mapper.TWmsPlcConnectionMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * PLC 连接配置 CRUD 服务
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC连接配置数据服务
 * @Version: 1.0
 */
@Service
public class PlcConnectionService extends ServiceImpl<TWmsPlcConnectionMapper, TWmsPlcConnection> {

    /**
     * 查询所有启用的连接配置
     */
    public List<TWmsPlcConnection> listEnabled() {
        return list(new LambdaQueryWrapper<TWmsPlcConnection>()
                .eq(TWmsPlcConnection::getEnabled, 1));
    }

    /**
     * 查询所有连接配置
     */
    public List<TWmsPlcConnection> listAll() {
        return list();
    }
}
