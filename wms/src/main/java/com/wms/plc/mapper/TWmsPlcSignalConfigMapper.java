package com.wms.plc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import com.wms.plc.model.dto.TWmsPlcSignalConfigQueryDTO;
import com.wms.plc.model.vo.TWmsPlcSignalConfigVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * PLC信号配置Mapper
 */
@Mapper
public interface TWmsPlcSignalConfigMapper extends BaseMapper<TWmsPlcSignalConfig> {

    Page<TWmsPlcSignalConfigVO> getTWmsPlcSignalConfigPage(
            Page<TWmsPlcSignalConfigVO> page,
            @Param("queryParams") TWmsPlcSignalConfigQueryDTO queryParams
    );
}
