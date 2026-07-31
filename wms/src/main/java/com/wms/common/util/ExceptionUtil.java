package com.wms.common.util;

/**
 * 异常工具类
 *
 * @author YangZheng
 * @date 2026-07-31
 */
public class ExceptionUtil {
    private ExceptionUtil() {
    }

    /**
     * 获取异常信息
     */
    public static String getExceptionMessage(Throwable e) {
        if (e == null) {
            return null;
        }
        if (StringUtils.isEmpty(e.getMessage())) {
            return e.toString();
        }
        return e.getMessage();
    }
}
