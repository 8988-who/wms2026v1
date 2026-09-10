package com.wms.plc.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.entity.TTaskMethodName;
import com.wms.plc.mapper.TTaskMethodNameMapper;
import com.wms.plc.model.dto.TTaskMethodNameCreateDTO;
import com.wms.plc.model.dto.TTaskMethodNameQueryDTO;
import com.wms.plc.service.TTaskMethodNameService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * 方法名配置业务服务实现
 */
@Service
public class TTaskMethodNameServiceImpl
        extends ServiceImpl<TTaskMethodNameMapper, TTaskMethodName>
        implements TTaskMethodNameService {

    @Override
    public IPage<TTaskMethodName> getTTaskMethodNamePage(TTaskMethodNameQueryDTO queryParams) {
        LambdaQueryWrapper<TTaskMethodName> wrapper = new LambdaQueryWrapper<>();
        // id 精确匹配
        wrapper.eq(StrUtil.isNotBlank(queryParams.getId()), TTaskMethodName::getId, queryParams.getId());
        // 方法名、方法描述模糊匹配
        wrapper.like(StrUtil.isNotBlank(queryParams.getMethodName()),
                TTaskMethodName::getMethodName, queryParams.getMethodName());
        wrapper.like(StrUtil.isNotBlank(queryParams.getMethodDescription()),
                TTaskMethodName::getMethodDescription, queryParams.getMethodDescription());
        wrapper.orderByAsc(TTaskMethodName::getId);

        Page<TTaskMethodName> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.page(page, wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveTTaskMethodName(TTaskMethodNameCreateDTO dto) {
        Assert.notNull(dto, "方法名配置不能为空");

        String methodName = StrUtil.trimToNull(dto.getMethodName());
        String methodDescription = StrUtil.trimToNull(dto.getMethodDescription());
        Assert.isTrue(StrUtil.isNotBlank(methodName), "请输入方法名");
        Assert.isTrue(StrUtil.isNotBlank(methodDescription), "请输入方法描述");

        // 方法名唯一性校验
        long count = this.count(new LambdaQueryWrapper<TTaskMethodName>()
                .eq(TTaskMethodName::getMethodName, methodName));
        Assert.isTrue(count == 0, "方法名已存在");

        TTaskMethodName entity = new TTaskMethodName();
        entity.setMethodName(methodName);
        entity.setMethodDescription(methodDescription);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTTaskMethodName(String id) {
        Assert.isTrue(StrUtil.isNotBlank(id), "方法名配置ID不能为空");

        TTaskMethodName entity = this.getById(id);
        Assert.notNull(entity, "方法名配置不存在");

        return this.removeById(id);
    }
}
