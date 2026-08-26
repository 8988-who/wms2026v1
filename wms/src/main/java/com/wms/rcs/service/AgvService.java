package com.wms.rcs.service;

import com.wms.common.enums.ApiEnum;
import com.wms.common.result.Result;

import java.util.Map;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:31
 * @Description: AgvService接口
 * @Version: 1.0
 */
public interface AgvService {
    Result<Object> commonRequest(String methodName, Map<String, Object> params);
    Result<Object> commonRequest(ApiEnum apiEnum, Map<String, Object> params);

    /**
     * 出站请求 DTO 形式（字段名编译期正确，推荐业务层直接构造 DTO 调用）
     */
    Result<Object> commonRequest(ApiEnum apiEnum, Object params);
}
