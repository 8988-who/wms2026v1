package com.wms.plc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TPlcSectorSignals;
import com.wms.plc.model.dto.TPlcSectorSignalsCreateDTO;
import com.wms.plc.model.dto.TPlcSectorSignalsQueryDTO;

import java.util.List;

/**
 * PLC信号块读写信号配置业务服务接口
 */
public interface TPlcSectorSignalsService extends IService<TPlcSectorSignals> {

    /**
     * 分页查询PLC信号块读写信号配置
     */
    IPage<TPlcSectorSignals> getTPlcSectorSignalsPage(TPlcSectorSignalsQueryDTO queryParams);

    /**
     * 信号块下拉选项（host,信号块地址）
     */
    List<Option<String>> getSignalConfigOptions();

    /**
     * 新增PLC信号块读写信号配置
     */
    boolean saveTPlcSectorSignal(TPlcSectorSignalsCreateDTO dto);

    /**
     * 删除PLC信号块读写信号配置
     */
    boolean deleteTPlcSectorSignals(String id);
}
