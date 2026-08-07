package com.wms.business.plc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.business.plc.domain.TWmsPlcSignalConfig;
import org.apache.ibatis.annotations.Mapper;

/**
 * PLC 信号配置 Mapper
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.mapper
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Version: 1.0
 */
@Mapper
public interface TWmsPlcSignalConfigMapper extends BaseMapper<TWmsPlcSignalConfig> {
}
