package com.wms.plc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.plc.model.dto.TWmsPlcConnectionCreateDTO;
import com.wms.plc.model.dto.TWmsPlcConnectionQueryDTO;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.plc.model.vo.TWmsPlcConnectionLocationVO;
import com.wms.plc.model.vo.TWmsPlcConnectionVO;

import java.util.List;

/**
 * PLC连接配置业务服务接口
 */
public interface TWmsPlcConnectionService extends IService<TWmsPlcConnection> {

    IPage<TWmsPlcConnectionVO> getTWmsPlcConnectionPage(TWmsPlcConnectionQueryDTO queryParams);

    List<TWmsPlcConnectionLocationVO> getTWmsPlcConnectionLocationOptions();

    boolean saveTWmsPlcConnection(TWmsPlcConnectionCreateDTO dto);

    boolean deleteTWmsPlcConnections(String ids);

    boolean updateTWmsPlcConnectionEnabled(String id, Integer enabled);

    boolean reconnectTWmsPlcConnection(String id);
}
