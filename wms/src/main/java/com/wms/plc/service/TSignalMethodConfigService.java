package com.wms.plc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TSignalMethodConfig;
import com.wms.plc.model.dto.TSignalMethodConfigCreateDTO;
import com.wms.plc.model.dto.TSignalMethodConfigQueryDTO;

import java.util.List;

/**
 * 信号值方法配置业务服务接口
 */
public interface TSignalMethodConfigService extends IService<TSignalMethodConfig> {

    /**
     * 分页查询信号值方法配置
     */
    IPage<TSignalMethodConfig> getTSignalMethodConfigPage(TSignalMethodConfigQueryDTO queryParams);

    /**
     * PLC连接下拉选项(t_plc_connection)
     */
    List<Option<String>> getPlcOptions();

    /**
     * 按PLC查询信号块下拉选项(t_plc_signal_config)
     */
    List<Option<String>> getSignalConfigOptions(String plcId);

    /**
     * 方法下拉选项(t_task_method_name)
     */
    List<Option<String>> getMethodOptions();

    /**
     * 新增信号值方法配置
     */
    boolean saveTSignalMethodConfig(TSignalMethodConfigCreateDTO dto);

    /**
     * 删除信号值方法配置
     */
    boolean deleteTSignalMethodConfig(String id);
}
