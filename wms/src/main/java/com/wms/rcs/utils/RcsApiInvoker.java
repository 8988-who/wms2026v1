package com.wms.rcs.utils;

import cn.hutool.core.util.IdUtil;
import cn.hutool.http.Header;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import com.alibaba.fastjson2.JSONObject;
import com.wms.business.log.model.entity.ApiRequestLog;
import com.wms.business.log.service.ApiRequestLogService;
import com.wms.common.constant.RcsConstants;
import com.wms.common.util.OrikaUtils;
import com.wms.common.util.StringUtils;
import com.wms.common.util.ValidatorUtils;
import com.wms.common.util.spring.SpringUtils;
import com.wms.rcs.enums.RcsApiEnum;
import com.wms.system.service.ISysConfigService;
import lombok.extern.slf4j.Slf4j;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

/**
 * RCS 出站接口统一调用器
 * <p>
 * 替代 {@code ApiRequestUtils.execute(ApiEnum, ...)}：按 {@link RcsApiEnum} 元数据拼接
 * {@code wms.rcs.baseurl} + path，统一请求头（X-lr-request-id/version/trace-id），
 * POST JSON body，记录 api_request_log，并解析 RCS 成功标识
 * （code="SUCCESS"/"0" 或 success=true，兼容新旧协议）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-31
 */
@Slf4j
public class RcsApiInvoker {

    private RcsApiInvoker() {
    }

    /**
     * 统一出站调用入口（Map 参数形式）。
     *
     * @param api    接口枚举（必须为 OUTBOUND）
     * @param params 请求参数（Map）
     * @return RCS 原始响应字符串
     */
    public static String invoke(RcsApiEnum api, Map<String, Object> params) {
        if (api == null || api == RcsApiEnum.UNKNOWN) {
            throw new IllegalArgumentException("RCS接口枚举未定义");
        }
        if (api.getDirection() != RcsApiEnum.Direction.OUTBOUND) {
            throw new IllegalArgumentException("RCS接口[" + api.getCode() + "]不是出站接口");
        }
        long startTime = System.currentTimeMillis();
        String traceId = IdUtil.fastSimpleUUID();

        // 参数校验（DTO 强类型校验）
        if (api.getParamsClass() != null) {
            Object dto = OrikaUtils.mapBean(params, api.getParamsClass());
            ValidatorUtils.validateEntity(dto);
        }

        // 拼接 URL：baseurl（去末尾/）+ path（去开头/），避免双斜杠
        String baseurl = StringUtils.stripEnd(getBaseurl(), "/");
        String url = baseurl + "/" + StringUtils.stripStart(api.getPath(), "/");

        // 初始化请求日志
        ApiRequestLog requestLog = new ApiRequestLog();
        requestLog.setApiCode(api.getCode());
        requestLog.setApiName(api.getCode());
        requestLog.setApiMethodName(api.getPath());
        requestLog.setApiUrl(url);
        requestLog.setModule("rcs");
        requestLog.setReqTime(LocalDateTime.now());
        requestLog.setReqParams(JSONObject.toJSONString(params));
        requestLog.setTraceId(traceId);
        requestLog.setRetryCount(0);

        Exception exception = null;
        try {
            Map<String, String> headers = buildHeaders(traceId);
            HttpResponse response = doPost(url, headers, params);
            String resString = response.body();
            requestLog.setResParams(resString);
            requestLog.setHttpCode(String.valueOf(response.getStatus()));
            // 成功判定：code="SUCCESS"/"0" 或 success=true
            if (StringUtils.isNotEmpty(resString)) {
                JSONObject resJson = JSONObject.parse(resString);
                String resCode = resJson.getString("code");
                Boolean success = resJson.getBoolean("success");
                boolean isOk = (success != null && success) || "0".equals(resCode) || "SUCCESS".equals(resCode);
                requestLog.setResCode(resCode);
                requestLog.setIsSuccess(isOk ? "Y" : "N");
            }
        } catch (Exception e) {
            requestLog.setIsSuccess("N");
            requestLog.setErrMsg(subMessage(e.getMessage(), 5000));
            log.error("RCS接口[{}]请求失败, traceId={}, url={}", api.getCode(), traceId, url, e);
            exception = e;
        } finally {
            requestLog.setDuration(System.currentTimeMillis() - startTime);
            requestLog.setResTime(LocalDateTime.now());
            SpringUtils.getBean(ApiRequestLogService.class).saveLogAsync(requestLog);
        }
        if (exception != null) {
            throw new RuntimeException("RCS接口[" + api.getCode() + "]请求失败", exception);
        }
        return requestLog.getResParams();
    }

    /**
     * 读取 RCS baseurl 配置（wms.rcs.baseurl）
     */
    private static String getBaseurl() {
        String baseurl = SpringUtils.getBean(ISysConfigService.class).selectConfigByKey("wms.rcs.baseurl");
        if (StringUtils.isEmpty(baseurl)) {
            throw new RuntimeException("尚未配置参数：wms.rcs.baseurl");
        }
        return baseurl;
    }

    /**
     * 组装统一请求头（X-lr-request-id 动态生成，version/trace-id 固定）
     */
    private static Map<String, String> buildHeaders(String traceId) {
        Map<String, String> headers = new HashMap<>(4);
        headers.put(RcsConstants.HEADER_REQUEST_ID, IdUtil.fastSimpleUUID());
        headers.put(RcsConstants.HEADER_VERSION, RcsConstants.VERSION);
        headers.put(RcsConstants.HEADER_TRACE_ID, traceId);
        return headers;
    }

    /**
     * POST JSON 请求（跟随重定向，保留请求体）
     */
    private static HttpResponse doPost(String url, Map<String, String> headers, Map<String, Object> params) {
        HttpRequest request = HttpRequest.post(url);
        request.setFollowRedirects(true);
        if (headers != null) {
            request.headerMap(headers, true);
        }
        if (params == null) {
            params = new HashMap<>();
        }
        if (headers == null || !headers.containsKey(Header.CONTENT_TYPE.getValue())) {
            request.header(Header.CONTENT_TYPE, "application/json;charset=UTF-8");
        }
        request.body(JSONObject.toJSONString(params));
        return request.execute();
    }

    /**
     * 截断异常信息
     */
    private static String subMessage(String message, int size) {
        if (StringUtils.isEmpty(message) || message.length() <= size) {
            return message;
        }
        return message.substring(0, size);
    }
}
