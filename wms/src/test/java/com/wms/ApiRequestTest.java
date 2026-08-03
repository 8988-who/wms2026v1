package com.wms;

import com.wms.common.enums.ApiEnum;
import com.wms.common.util.ApiRequestUtils;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;

import java.util.HashMap;
import java.util.Map;

/**
 * ApiRequestUtils 接口调用测试
 *
 * <p>运行方式：在 IDE 中右键执行本测试类（需保证 dev 环境数据库/Redis 可达，且 sys_config 已配置 wms.rcs.baseurl）</p>
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@SpringBootTest
@ActiveProfiles("dev")
public class ApiRequestTest {

    @Test
    public void testExecuteAgv() {
        // 1. 按需换成其他接口，如 AGV_genAgvSchedulingTask / AGV_cancelTask / MES_CBM_IF_GETBARCODEINFO
        ApiEnum apiEnum = ApiEnum.AGV_queryTask;

        // 2. 组装请求参数（字段与 ApiEnum.paramsClass 对应，如 AgvRequestDTO 必填 reqCode）
        Map<String, String> headers = new HashMap<>();
        headers.put("X-lr-request-id", "12345678");
        headers.put("X-lr-version", "4.3");
//        headers.put("Content-Length", "<calculated when request is sent>");
//        headers.put("Host", "<calculated when request is sent>");
        headers.put("X-lr-trace-id", "1239076324ad123");
        Map<String, Object> params = new HashMap<>();

        // 3. 发起请求（内部会记录请求日志到 api_request_log）
        String result = ApiRequestUtils.execute(apiEnum, headers, params);
        System.out.println("===== 请求结果 =====");
        System.out.println(result);
    }
}
