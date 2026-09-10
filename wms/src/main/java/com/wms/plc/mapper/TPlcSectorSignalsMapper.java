package com.wms.plc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.common.model.entity.TPlcSectorSignals;
import org.apache.ibatis.annotations.Mapper;

/**
 * PLC信号块读写信号配置 Mapper
 */
@Mapper
public interface TPlcSectorSignalsMapper extends BaseMapper<TPlcSectorSignals> {
}
