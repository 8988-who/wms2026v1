package com.wms.plc.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.plc.model.dto.TWmsPlcConnectionQueryDTO;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.plc.model.vo.TWmsPlcConnectionVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

/**
 * PLC连接配置Mapper
 */
@Mapper
public interface TWmsPlcConnectionMapper extends BaseMapper<TWmsPlcConnection> {

    Page<TWmsPlcConnectionVO> getTWmsPlcConnectionPage(
            Page<TWmsPlcConnectionVO> page,
            @Param("queryParams") TWmsPlcConnectionQueryDTO queryParams
    );
}
