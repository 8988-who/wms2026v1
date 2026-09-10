package com.wms.plc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import com.wms.plc.model.dto.TWmsPlcSignalConfigCreateDTO;
import com.wms.plc.model.dto.TWmsPlcSignalConfigQueryDTO;
import com.wms.plc.model.vo.TWmsPlcConnectionOptionVO;
import com.wms.plc.model.vo.TWmsPlcPointOptionVO;
import com.wms.plc.model.vo.TWmsPlcSignalConfigVO;

import java.util.List;

/**
 * PLC信号块配置业务服务接口
 */
public interface TWmsPlcSignalConfigService extends IService<TWmsPlcSignalConfig> {

    IPage<TWmsPlcSignalConfigVO> getTWmsPlcSignalConfigPage(TWmsPlcSignalConfigQueryDTO queryParams);

    List<TWmsPlcConnectionOptionVO> getTWmsPlcConnectionOptions();

    List<TWmsPlcPointOptionVO> getWmsPointOptions();

    boolean saveTWmsPlcSignalConfig(TWmsPlcSignalConfigCreateDTO dto);

    boolean deleteTWmsPlcSignalConfig(String id);

    boolean updateTWmsPlcSignalConfigEnabled(String id, Integer enabled);
}
