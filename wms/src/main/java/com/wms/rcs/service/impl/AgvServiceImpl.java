package com.wms.rcs.service.impl;

import cn.hutool.core.bean.BeanUtil;
import com.alibaba.fastjson2.JSONObject;
import com.wms.common.util.StringUtils;
import com.wms.rcs.enums.RcsApiEnum;
import com.wms.rcs.service.AgvService;
import com.wms.common.result.Result;
import com.wms.rcs.utils.RcsApiInvoker;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.Map;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:31
 * @Description: AGV服务实现（基于 RcsApiEnum + RcsApiInvoker 的枚举驱动出站调用）
 * @Version: 1.0
 */
@Slf4j
@Service
public class AgvServiceImpl implements AgvService {

    @Override
    public Result<Object> commonRequest(String methodName, Map<String, Object> params) {
        // 按接口编码（如 AGV_submitTask）查枚举
        RcsApiEnum api = RcsApiEnum.fromCode(methodName);
        if (api == RcsApiEnum.UNKNOWN) {
            return Result.failed("未找到RCS接口：" + methodName);
        }
        return commonRequest(api, params);
    }

    /**
     * 通用请求接口（DTO 形式）：DTO → Map（忽略 null）后再走统一请求链路。
     * 业务层直接构造出站 DTO 调用，字段名在编译期即正确。
     */
    @Override
    public Result<Object> commonRequest(RcsApiEnum api, Object params) {
        Map<String, Object> map = BeanUtil.beanToMap(params, false, true);
        return commonRequest(api, map);
    }

    /**
     * 通用请求接口（Map 形式）：走 RcsApiInvoker 统一出站调用。
     */
    @Override
    public Result<Object> commonRequest(RcsApiEnum api, Map<String, Object> params) {
        // 调用统一出站请求方法
        String result = RcsApiInvoker.invoke(api, params);
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
