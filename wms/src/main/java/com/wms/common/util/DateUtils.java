package com.wms.common.util;

import java.util.Date;

/**
 * 日期工具类
 *
 * @author YangZheng
 * @date 2026-07-31
 */
public class DateUtils {
    private DateUtils() {
    }

    /**
     * 获取当前时间
     */
    public static Date getNowDate() {
        return new Date();
    }
}
