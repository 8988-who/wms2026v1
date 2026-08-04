package com.wms.common.util;

import cn.hutool.core.util.IdUtil;
import cn.hutool.http.Header;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.http.HttpUtil;
import cn.hutool.http.webservice.SoapClient;
import com.alibaba.fastjson2.JSONObject;
import com.wms.business.log.domain.ApiRequestLog;

import com.wms.business.log.service.IApiRequestLogService;
import com.wms.common.enums.ApiEnum;
import com.wms.common.util.spring.SpringUtils;
import com.wms.rcs.constant.RcsConstants;
import com.wms.system.service.ISysConfigService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.CollectionUtils;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;


/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.util
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 11:21
 * @Description: API统一请求工具类（统一入口，支持POST/GET/WebService，按模块解析返回值并记录日志）
 * @Version: 1.0
 */
@Slf4j
public class ApiRequestUtils {
    private ApiRequestUtils() {

    }

    /**
     * 统一请求方法入口
     */
    public static String execute(ApiEnum apiEnum, Map<String, String> headers, Map<String, Object> params) {
        // 参数校验
        if (Objects.nonNull(apiEnum.getParamsClass())) {
            Object dto = OrikaUtils.mapBean(params, apiEnum.getParamsClass());
            ValidatorUtils.validateEntity(dto);
        }
        // 解析出url（去掉baseurl末尾、methodName开头的"/"，避免拼出双斜杠）
        String baseurl = StringUtils.stripEnd(getBaseurl(apiEnum.getModule()), "/");
        String url = baseurl + "/" + StringUtils.stripStart(apiEnum.getMethodName(), "/");
        // 初始化日志
        ApiRequestLog requestLog = new ApiRequestLog();
        requestLog.setApiCode(apiEnum.getCode());
        requestLog.setApiName(apiEnum.getName());
        requestLog.setApiMethodName(apiEnum.getMethodName());
        requestLog.setApiUrl(url);
        requestLog.setModule(apiEnum.getModule());
        requestLog.setReqTime(LocalDateTime.now());
        requestLog.setReqParams(JSONObject.toJSONString(params));
        Exception exception = null;
        try {
            // 执行方法
            HttpResponse result = null;
            String resString = null;
            Integer httpCode = null;
            if ("POST".equals(apiEnum.getMethod())) {
                result = doPost(url, mergeHeaders(headers), params);
            } else if ("GET".equals(apiEnum.getMethod())) {
                result = doGet(url, params);
            }
            // 如果是WebService的话返回值只有字符串，获取不到http状态码
            else if ("WebService".equals(apiEnum.getMethod())) {
                resString = doWebService(baseurl, apiEnum.getDesc(), params);
            }
            // 解析HttpResponse
            if (Objects.nonNull(result)) {
                resString = result.body();
                httpCode = result.getStatus();
            }
            // 记录返回参数、http状态码
            requestLog.setResParams(resString);
            requestLog.setHttpCode(Objects.isNull(httpCode) ? null : httpCode.toString());
            // 根据模块执行不同的解析逻辑，记录成功标志、返回状态码
            handleByModule(requestLog);

        } catch (Exception e) {
            // 如果出现异常则记录同步失败标志、同步结果、异常信息
            requestLog.setIsSuccess("N");
            requestLog.setErrMsg(subMessage(ExceptionUtil.getExceptionMessage(e), 5000));
            log.error(apiEnum.getName() + "接口请求失败", e);
            exception = e;
        } finally {
            // 保存日志
            requestLog.setResTime(LocalDateTime.now());
            SpringUtils.getBean(IApiRequestLogService.class).saveLogAsync(requestLog);
        }
        // 存在异常的话继续向上抛出
        if (Objects.nonNull(exception)) {
            throw new RuntimeException(apiEnum.getName() + "接口请求失败", exception);
        }
        return requestLog.getResParams();
    }

    private static String getBaseurl(String module) {
        String key = String.format("wms.%1$s.baseurl", module);
        String baseurl = SpringUtils.getBean(ISysConfigService.class).selectConfigByKey(key);
        if (StringUtils.isEmpty(baseurl)) {
            throw new RuntimeException(String.format("尚未配置参数：%1$s", key));
        }
        return baseurl;
    }

    /**
     * 组装统一headers，调用方传入的会覆盖默认值
     */
    public static Map<String, String> mergeHeaders(Map<String, String> headers) {
        Map<String, String> merged = new HashMap<>();
        merged.put(RcsConstants.HEADER_REQUEST_ID, IdUtil.fastSimpleUUID()); // 动态生成
        merged.put(RcsConstants.HEADER_VERSION, RcsConstants.VERSION);
        merged.put(RcsConstants.HEADER_TRACE_ID, IdUtil.fastSimpleUUID());
        if (!CollectionUtils.isEmpty(headers)) {
            merged.putAll(headers); // 调用方优先
        }
        return merged;
    }

    /**
     * 不同模块的解析逻辑（预留 if-else 扩展点）
     */
    private static void handleByModule(ApiRequestLog requestLog) {
        if (StringUtils.isNotEmpty(requestLog.getResParams())) {
            JSONObject resParams = JSONObject.parse(requestLog.getResParams());
            String resCode = resParams.getString("code");
            // 如需按模块定制解析逻辑，可在此添加 if-else 分支
            requestLog.setResCode(resCode);
            requestLog.setIsSuccess("0".equals(resCode) ? "Y" : "N");
        }
    }

    private static String doWebService(String baseurl, String method, Map<String, Object> params) {
        // 指定 Web Service 的 WSDL 地址
        SoapClient client = SoapClient.create(baseurl);
        // 设置命名空间和方法名
        String[] methods = method.split(",");
        client.header("SOAPAction", methods[0]);
        client.setMethod(methods[1], methods[2]);
        // 设置请求参数
        client.setParams(params, true);
        // 发送请求并获取响应结果
        return client.send(false);
    }

    private static HttpResponse doPost(String url, Map<String, String> headers, Map<String, Object> params) {
        HttpRequest request = HttpUtil.createPost(url);
        if (!CollectionUtils.isEmpty(headers)) {
            request.headerMap(headers, true);
        }
        if (CollectionUtils.isEmpty(params)) {
            params = new HashMap<>();
        }
        // hutool 的 body() 不会自动设置 Content-Type，需手动指定为JSON
        if (CollectionUtils.isEmpty(headers) || !headers.containsKey(Header.CONTENT_TYPE.getValue())) {
            request.header(Header.CONTENT_TYPE, "application/json;charset=UTF-8");
        }
        request.body(JSONObject.toJSONString(params));
        return request.execute();
    }

    private static HttpResponse doGet(String url, Map<String, Object> params) {
        return HttpUtil.createGet(url).form(params).execute();
    }

    public static String subMessage(String message, int size) {
        if (StringUtils.isEmpty(message) || message.length() <= size) {
            return message;
        }
        return message.substring(0, size);
    }
}
