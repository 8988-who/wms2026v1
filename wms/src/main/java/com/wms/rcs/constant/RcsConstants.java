package com.wms.rcs.constant;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.rcs.constant
 * @Author: YangZheng
 * @CreateTime: 2026-08-03 09:25
 * @Description: RCS常量定义类（请求头标识、版本号）
 * @Version: 1.0
 */
public class RcsConstants {
    private RcsConstants() {
    }

    public static final String HEADER_REQUEST_ID = "X-lr-request-id";
    public static final String HEADER_VERSION = "X-lr-version";
    public static final String HEADER_TRACE_ID = "X-lr-trace-id";
    public static final String VERSION = "4.3";
}
