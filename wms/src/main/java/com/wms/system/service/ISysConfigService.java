package com.wms.system.service;

/**
 * 参数配置服务接口
 *
 * @author YangZheng
 * @date 2026-07-31
 */
public interface ISysConfigService {

    /**
     * 根据键名查询参数配置信息
     *
     * @param configKey 参数键名
     * @return 参数键值
     */
    String selectConfigByKey(String configKey);
}
