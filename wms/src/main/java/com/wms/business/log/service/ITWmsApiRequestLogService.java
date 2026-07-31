package com.wms.business.log.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.business.log.domain.TWmsApiRequestLog;
import com.wms.business.log.dto.TWmsApiRequestLogQueryDTO;

/**
 * 接口请求日志Service接口
 *
 * @author YangZheng
 * @date 2026-07-31
 */
public interface ITWmsApiRequestLogService extends IService<TWmsApiRequestLog> {

    /**
     * 分页查询接口请求日志列表
     *
     * @param queryDTO 查询参数
     * @return 接口请求日志分页集合
     */
    IPage<TWmsApiRequestLog> findList(TWmsApiRequestLogQueryDTO queryDTO);

    /**
     * 异步保存日志
     */
    void saveLogAsync(TWmsApiRequestLog requestLog);

    /**
     * 异步删除自动任务的报错历史日志
     */
    void delLogAsync(TWmsApiRequestLog requestLog);

}
