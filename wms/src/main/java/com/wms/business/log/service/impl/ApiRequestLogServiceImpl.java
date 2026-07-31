package com.wms.business.log.service.impl;

import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.business.log.domain.ApiRequestLog;
import com.wms.business.log.dto.ApiRequestLogQueryDTO;
import com.wms.business.log.mapper.ApiRequestLogMapper;
import com.wms.business.log.service.IApiRequestLogService;
import com.wms.framework.security.util.SecurityUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.concurrent.Executor;

/**
 * 接口请求日志Service业务层处理
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Slf4j
@Service
public class ApiRequestLogServiceImpl extends ServiceImpl<ApiRequestLogMapper, ApiRequestLog>
        implements IApiRequestLogService {

    /**
     * 异步保存日志使用的线程池
     */
    private final Executor operationLogExecutor;

    public ApiRequestLogServiceImpl(
            @Qualifier("operationLogExecutor") Executor operationLogExecutor
    ) {
        this.operationLogExecutor = operationLogExecutor;
    }

    /**
     * 分页查询接口请求日志列表
     *
     * @param queryDTO 查询参数
     * @return 接口请求日志分页集合
     */
    @Override
    public IPage<ApiRequestLog> findList(ApiRequestLogQueryDTO queryDTO) {
        LambdaQueryWrapper<ApiRequestLog> query = new LambdaQueryWrapper<ApiRequestLog>()
                .eq(StrUtil.isNotBlank(queryDTO.getModule()), ApiRequestLog::getModule, queryDTO.getModule())
                .eq(StrUtil.isNotBlank(queryDTO.getApiCode()),ApiRequestLog::getApiCode, queryDTO.getApiCode())
                .like(StrUtil.isNotBlank(queryDTO.getApiUrl()), ApiRequestLog::getApiUrl, queryDTO.getApiUrl())
                .like(StrUtil.isNotBlank(queryDTO.getApiName()), ApiRequestLog::getApiName, queryDTO.getApiName())
                .eq(StrUtil.isNotBlank(queryDTO.getIsSuccess()), ApiRequestLog::getIsSuccess, queryDTO.getIsSuccess())
                .like(StrUtil.isNotBlank(queryDTO.getReqParams()), ApiRequestLog::getReqParams, queryDTO.getReqParams())
                .orderByDesc(ApiRequestLog::getReqTime);
        Page<ApiRequestLog> page = new Page<>(queryDTO.getPageNum(), queryDTO.getPageSize());
        return this.page(page, query);
    }

    /**
     * 异步保存日志，避免外层事务回滚导致日志丢失
     */
    @Override
    public void saveLogAsync(ApiRequestLog requestLog) {
        SecurityUtils.getUser().ifPresent(user -> {
            String userId = user.getUserId() == null ? null : user.getUserId().toString();
            requestLog.setCreateBy(userId);
            requestLog.setCreateName(user.getUsername());
            requestLog.setUpdateBy(userId);
            requestLog.setUpdateName(user.getUsername());
        });
        requestLog.setCreateTime(LocalDateTime.now());
        requestLog.setUpdateTime(LocalDateTime.now());
        operationLogExecutor.execute(() -> {
            try {
                super.save(requestLog);
            } catch (Exception e) {
                log.error("保存接口请求日志失败 apiCode={}", requestLog.getApiCode(), e);
            }
        });
    }

    /**
     * 异步删除自动任务的报错历史日志
     */
    @Override
    public void delLogAsync(ApiRequestLog requestLog) {
        operationLogExecutor.execute(() -> {
            try {
                super.remove(new LambdaQueryWrapper<ApiRequestLog>()
                        .eq(ApiRequestLog::getIsSuccess, "N")
                        .eq(ApiRequestLog::getRemark, requestLog.getRemark())
                );
            } catch (Exception e) {
                log.error("删除接口请求日志失败 remark={}", requestLog.getRemark(), e);
            }
        });
    }

}
