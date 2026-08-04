package com.wms.business.log.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.business.log.model.entity.ApiRequestLog;
import org.apache.ibatis.annotations.Mapper;

/**
 * 接口请求日志Mapper接口
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Mapper
public interface ApiRequestLogMapper extends BaseMapper<ApiRequestLog> {
}
