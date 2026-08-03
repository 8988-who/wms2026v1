package com.wms.business.log.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.business.log.domain.ApiRequestLog;
import com.wms.business.log.dto.ApiRequestLogQueryDTO;

/**
 * 接口请求日志Service接口
 *
 * @author YangZheng
 * @date 2026-07-31
 */
public interface IApiRequestLogService extends IService<ApiRequestLog> {

    /**
     * 分页查询接口请求日志列表
     *
     * @param queryDTO 查询参数
     * @return 接口请求日志分页集合
     */
    IPage<ApiRequestLog> findList(ApiRequestLogQueryDTO queryDTO);

    /**
     * 异步保存日志
     */
    void saveLogAsync(ApiRequestLog requestLog);

    /**
     * 异步删除自动任务的报错历史日志
     */
    void delLogAsync(ApiRequestLog requestLog);

}
