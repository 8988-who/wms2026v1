package com.youlai.boot.warehouse.service;

import java.util.List;

/**
 * 级联操作服务接口
 * <p>
 * 处理库区/巷道/点位之间的级联停用操作。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-21
 */
public interface WmsCascadeService {

    /**
     * 级联停用指定区域下的所有巷道和点位
     *
     * @param locationIds 区域ID列表
     */
    void cascadeDisableLocations(List<Long> locationIds);

    /**
     * 级联停用指定巷道下的所有点位
     *
     * @param aisleIds 巷道ID列表
     */
    void cascadeDisableAisles(List<Long> aisleIds);

}