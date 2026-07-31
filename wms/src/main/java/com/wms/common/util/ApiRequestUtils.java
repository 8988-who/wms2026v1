package com.wms.common.util;

import cn.hutool.core.map.MapUtil;
import cn.hutool.http.Header;
import cn.hutool.http.HttpRequest;
import cn.hutool.http.HttpResponse;
import cn.hutool.http.HttpUtil;
import cn.hutool.http.webservice.SoapClient;
import cn.hutool.json.XML;
import com.alibaba.fastjson2.JSON;
import com.alibaba.fastjson2.JSONObject;
import com.wms.business.log.domain.TWmsApiRequestLog;

import com.wms.business.log.service.ITWmsApiRequestLogService;
import com.wms.common.enums.ApiEnum;
import com.wms.common.util.spring.SpringUtils;
import com.wms.system.service.ISysConfigService;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.http.HttpEntity;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.util.EntityUtils;
import org.springframework.util.CollectionUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.nio.charset.Charset;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;


/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.util
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 11:21
 * @Description: TODO
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
        TWmsApiRequestLog requestLog = new TWmsApiRequestLog();
        requestLog.setApiCode(apiEnum.getCode());
        requestLog.setApiName(apiEnum.getName());
        requestLog.setApiMethodName(apiEnum.getMethodName());
        requestLog.setApiUrl(url);
        requestLog.setModule(apiEnum.getModule());
        requestLog.setReqTime(DateUtils.getNowDate());
        requestLog.setReqParams(JSONObject.toJSONString(params));
        Exception exception = null;
        try {
            // 执行方法
            HttpResponse result = null;
            String resString = null;
            Integer httpCode = null;
            if ("POST".equals(apiEnum.getMethod())) {
                result = doPost(url, headers, params);
            } else if ("GET".equals(apiEnum.getMethod())) {
                result = doGet(url, params);
            }
            // 如果是WebService的话返回值只有字符串，获取不到http状态码
            else if ("WebService".equals(apiEnum.getMethod())) {
                resString = doWebService(baseurl, apiEnum.getDesc(), params);
            }
            // 如果是WebServiceMesCode的话返回值只有字符串， 单个获取
            else if ("WebServiceMesCode".equals(apiEnum.getMethod())) {
                resString = getMesBarcode(MapUtil.getStr(params, "Barcode"));
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
            requestLog.setResTime(DateUtils.getNowDate());
            SpringUtils.getBean(ITWmsApiRequestLogService.class).saveLogAsync(requestLog);
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
     * 不同模块的解析逻辑
     */
    private static void handleByModule(TWmsApiRequestLog requestLog) {
        // 模块
        String module = requestLog.getModule();
        // 解析返回值
        if (StringUtils.isNotEmpty(requestLog.getResParams())) {
            String resCode = null;
            String isSuccess = null;
            // agv模块的解析逻辑
            if ("agv".equals(module)) {
                JSONObject resParams = JSONObject.parse(requestLog.getResParams());
                resCode = resParams.getString("code");
                isSuccess = "0".equals(resCode) ? "Y" : "N";
            }
            // mes模块的解析逻辑
            else if ("mes".equals(module)) {
                try {
                    String json;
                    JSONObject resParams;
                    // 尝试xml格式解析
                    try {
                        cn.hutool.json.JSONObject jsonObject = XML.toJSONObject(requestLog.getResParams());
                        json = jsonObject.toString();
                        resParams = JSONObject.parse(json);
                    } catch (Exception e) {
                        // 如果解析不出来尝试json解析
                        resParams = JSONObject.parse(requestLog.getResParams());
                    }
//                    requestLog.setResParams(resParams.toJSONString());
                    isSuccess = "Y";
                } catch (Exception e) {
                    isSuccess = "N";
                }
            }
            // 此处添加其他模块的解析逻辑
            else {
                JSONObject resParams = JSONObject.parse(requestLog.getResParams());
                resCode = resParams.getString("code");
                isSuccess = "0".equals(resCode) ? "Y" : "N";
            }
            requestLog.setResCode(resCode);
            requestLog.setIsSuccess(isSuccess);
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


    public static String getMesBarcode(String code) {
        String url = SpringUtils.getBean(ISysConfigService.class).selectConfigByKey("wms.mes.baseurl");
        // 根据实际情况拼接xml
        String xmlData = String.format("<soapenv:Envelope\n" +
                "    xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\"\n" +
                "    xmlns:tem=\"http://tempuri.org/\">\n" +
                "    <soapenv:Header/>\n" +
                "    <soapenv:Body>\n" +
                "        <tem:CBM_IF_GetBarcodeInfo>\n" +
                "            <!--Optional:-->\n" +
                "            <tem:json>{\"Barcode\":\"%s\"}</tem:json>\n" +
                "        </tem:CBM_IF_GetBarcodeInfo>\n" +
                "    </soapenv:Body>\n" +
                "</soapenv:Envelope>", code);

        String postSoap = doPostSoap(url, xmlData, "http://tempuri.org/IPackage/CBM_IF_GetBarcodeInfo");
        // 去除转义字符
        String unPostSoap = StringEscapeUtils.unescapeXml(postSoap);
        return unPostSoap;
    }

    //使用SOAP1.1发送消息
    public static String doPostSoap(String postUrl, String soapXml, String soapAction) {
        // 初始化日志
        TWmsApiRequestLog requestLog = new TWmsApiRequestLog();
        requestLog.setIsSuccess("Y");
        requestLog.setApiCode(ApiEnum.MES_CBM_IF_GETBARCODEINFO.getCode());
        requestLog.setApiName(ApiEnum.MES_CBM_IF_GETBARCODEINFO.getName());
        requestLog.setApiMethodName(ApiEnum.MES_CBM_IF_GETBARCODEINFO.getMethodName());
        requestLog.setApiUrl(postUrl);
        requestLog.setModule(ApiEnum.MES_CBM_IF_GETBARCODEINFO.getModule());
        requestLog.setReqTime(DateUtils.getNowDate());
        requestLog.setReqParams(JSONObject.toJSONString(soapXml));
        String retStr = "";
        // 创建HttpClientBuilder
        HttpClientBuilder httpClientBuilder = HttpClientBuilder.create();
        // HttpClient
        CloseableHttpClient closeableHttpClient = httpClientBuilder.build();
        HttpPost httpPost = new HttpPost(postUrl);
        // 设置请求和传输超时时间
        RequestConfig requestConfig = RequestConfig.custom().setSocketTimeout(10000)
                .setConnectTimeout(10000).build();
        httpPost.setConfig(requestConfig);
        try {
            httpPost.setHeader("Content-Type", "text/xml;charset=UTF-8");
            httpPost.setHeader("SOAPAction", soapAction);
            StringEntity data = new StringEntity(soapXml, Charset.forName("UTF-8"));
            httpPost.setEntity(data);
            CloseableHttpResponse response = closeableHttpClient.execute(httpPost);
            HttpEntity httpEntity = response.getEntity();
            if (httpEntity != null) {
                // 打印响应内容
                String resXml = EntityUtils.toString(httpEntity, "UTF-8");
                // 记录返回参数、http状态码
                requestLog.setResTime(DateUtils.getNowDate());
                requestLog.setResParams(resXml);
                //解析返回xml 的json
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factory.newDocumentBuilder();
                Document document = builder.parse(new ByteArrayInputStream(resXml.getBytes()));

                Element root = document.getDocumentElement();
                NodeList nodeList = root.getElementsByTagName("CBM_IF_GetBarcodeInfoResult");
                if (nodeList.getLength() > 0) {
                    String jsonStr = nodeList.item(0).getTextContent();
                    JSONObject jsonObject = JSON.parseObject(jsonStr);
                    String infoStr = jsonObject.getString("Info");
                    String result = jsonObject.getString("Result");
                    if (StringUtils.equals("OK", result)) {
                        JSONObject infoObject = JSON.parseObject(infoStr);
                        retStr = infoObject.getString("Fnumber");
                    } else if (StringUtils.equals("NG", result)) {
                        String error = jsonObject.getString("Error");
                        throw new RuntimeException(error);
                    }
                }
            }
            // 释放资源
            closeableHttpClient.close();
        } catch (Exception e) {
            requestLog.setIsSuccess("N");
            requestLog.setErrMsg(subMessage(ExceptionUtil.getExceptionMessage(e), 5000));
            log.error("对接MES获取条码基础信息发生错误：", e);
            throw new RuntimeException("对接MES获取条码基础信息发生错误：" + e.getMessage());
        } finally {
            SpringUtils.getBean(ITWmsApiRequestLogService.class).save(requestLog);
        }
        return retStr;
    }
}
