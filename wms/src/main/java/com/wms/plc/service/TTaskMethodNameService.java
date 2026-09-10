package com.wms.plc.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.common.model.entity.TTaskMethodName;
import com.wms.plc.model.dto.TTaskMethodNameCreateDTO;
import com.wms.plc.model.dto.TTaskMethodNameQueryDTO;

/**
 * 方法名配置业务服务接口
 */
public interface TTaskMethodNameService extends IService<TTaskMethodName> {

    /**
     * 分页查询方法名配置
     */
    IPage<TTaskMethodName> getTTaskMethodNamePage(TTaskMethodNameQueryDTO queryParams);

    /**
     * 新增方法名配置
     */
    boolean saveTTaskMethodName(TTaskMethodNameCreateDTO dto);

    /**
     * 删除方法名配置
     */
    boolean deleteTTaskMethodName(String id);
}
