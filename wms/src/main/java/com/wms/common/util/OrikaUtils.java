package com.wms.common.util;

import ma.glasnost.orika.MapperFacade;
import ma.glasnost.orika.impl.DefaultMapperFactory;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.util
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 11:23
 * @Description: TODO
 * @Version: 1.0
 */
public class OrikaUtils {
    private OrikaUtils(){
    }
    // 单例模式(懒汉式、线程安全）
    private static class Builder {
        // 通过工厂和建造者创建MapperFacade实例
        private static final MapperFacade mapper = new DefaultMapperFactory.Builder().build().getMapperFacade();
    }

    public static MapperFacade getMapper() {
        return Builder.mapper;
    }

    /**
     * @param srcObj   被拷贝对象
     * @param dstClass 目标对象类型
     * @return 返回新的目标对象的一个深拷贝
     *
     */
    public static <S, D> D mapBean(S srcObj, Class<D> dstClass) {
        return getMapper().map(srcObj, dstClass);
    }
}
