package com.wms.business.plc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.business.plc.domain.TWmsPlcConnection;
import org.apache.ibatis.annotations.Mapper;

/**
 * PLC 连接配置 Mapper
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.mapper
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC连接配置数据访问层
 * @Version: 1.0
 */
@Mapper
public interface TWmsPlcConnectionMapper extends BaseMapper<TWmsPlcConnection> {
}
