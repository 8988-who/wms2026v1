package com.wms.rcs.service.impl;

import com.alibaba.fastjson2.JSONObject;
import com.wms.common.util.ApiRequestUtils;
import com.wms.common.util.StringUtils;
import com.wms.rcs.service.AgvService;
import com.wms.common.enums.ApiEnum;
import com.wms.common.result.Result;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:31
 * @Description: AGV服务实现
 * @Version: 1.0
 */
@Slf4j
@Service
public class AgvServiceImpl implements AgvService {

    @Override
    public Result<Object> commonRequest(String methodName, Map<String, Object> params) {
        // 获取接口枚举
        ApiEnum apiEnum = ApiEnum.getApiEnumByModuleAndMethodName("rcs", methodName);
        return commonRequest(apiEnum, params);
    }

    /**
     * 通用请求接口
     */
    @Override
    public Result<Object> commonRequest(ApiEnum apiEnum, Map<String, Object> params) {
        // 调用统一接口请求方法
        String result = ApiRequestUtils.execute(apiEnum, null, params);
        // 空响应保护
        if (StringUtils.isEmpty(result)) {
            return Result.failed("AGV系统返回空响应");
        }
        // 解析响应：RCS 返回 code="SUCCESS"/success=true，兼容旧系统 code="0"
        JSONObject resJsonObj = JSONObject.parse(result);
        String code = resJsonObj.getString("code");
        String msg = resJsonObj.getString("message");
        Object data = resJsonObj.get("data");
        Boolean success = resJsonObj.getBoolean("success");
        boolean isOk = (success != null && success) || "0".equals(code) || "SUCCESS".equals(code);
        if (isOk) {
            return Result.success(data, msg);
        } else {
            return Result.failed("AGV系统" + msg);
        }
    }
}
