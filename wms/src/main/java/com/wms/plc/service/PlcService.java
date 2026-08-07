package com.wms.business.plc.service;

import com.wms.business.iteminfo.domain.TWmsItemInfo;
import com.wms.business.storage.domain.TWmsStorage;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service
 * @Author: YangZheng
 * @CreateTime: 2026-07-20 15:07
 * @Description: PLC业务层
 * @Version: 1.0
 */
public interface PlcService {

    TWmsItemInfo findStart(String onlineType);

    TWmsItemInfo findStart(String onlineType, String modelCode);

    TWmsStorage findEnd(String onlineType, String modelCode);

}
