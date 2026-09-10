package com.wms.plc.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TSignalMethodConfig;
import com.wms.common.model.entity.TTaskMethodName;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import com.wms.plc.mapper.TSignalMethodConfigMapper;
import com.wms.plc.mapper.TTaskMethodNameMapper;
import com.wms.plc.mapper.TWmsPlcConnectionMapper;
import com.wms.plc.mapper.TWmsPlcSignalConfigMapper;
import com.wms.plc.model.dto.TSignalMethodConfigCreateDTO;
import com.wms.plc.model.dto.TSignalMethodConfigQueryDTO;
import com.wms.plc.service.TSignalMethodConfigService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;

/**
 * 信号值方法配置业务服务实现
 */
@Service
@RequiredArgsConstructor
public class TSignalMethodConfigServiceImpl
        extends ServiceImpl<TSignalMethodConfigMapper, TSignalMethodConfig>
        implements TSignalMethodConfigService {

    private final TWmsPlcConnectionMapper tWmsPlcConnectionMapper;
    private final TWmsPlcSignalConfigMapper tWmsPlcSignalConfigMapper;
    private final TTaskMethodNameMapper tTaskMethodNameMapper;

    @Override
    public IPage<TSignalMethodConfig> getTSignalMethodConfigPage(TSignalMethodConfigQueryDTO queryParams) {
        LambdaQueryWrapper<TSignalMethodConfig> wrapper = new LambdaQueryWrapper<>();
        // id、信号块id、信号值、方法id 模糊匹配
        wrapper.like(StrUtil.isNotBlank(queryParams.getId()),
                TSignalMethodConfig::getId, queryParams.getId());
        wrapper.like(StrUtil.isNotBlank(queryParams.getSignalId()),
                TSignalMethodConfig::getSignalId, queryParams.getSignalId());
        wrapper.like(StrUtil.isNotBlank(queryParams.getSignalCode()),
                TSignalMethodConfig::getSignalCode, queryParams.getSignalCode());
        wrapper.like(StrUtil.isNotBlank(queryParams.getMethodId()),
                TSignalMethodConfig::getMethodId, queryParams.getMethodId());
        wrapper.orderByAsc(TSignalMethodConfig::getId);

        Page<TSignalMethodConfig> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.page(page, wrapper);
    }

    @Override
    public List<Option<String>> getPlcOptions() {
        return tWmsPlcConnectionMapper.selectList(new LambdaQueryWrapper<TWmsPlcConnection>()
                        .select(TWmsPlcConnection::getId, TWmsPlcConnection::getHost)
                        .orderByAsc(TWmsPlcConnection::getId))
                .stream()
                .map(item -> new Option<>(item.getId(), StrUtil.nullToEmpty(item.getHost())))
                .toList();
    }

    @Override
    public List<Option<String>> getSignalConfigOptions(String plcId) {
        if (StrUtil.isBlank(plcId)) {
            return Collections.emptyList();
        }
        return tWmsPlcSignalConfigMapper.selectList(new LambdaQueryWrapper<TWmsPlcSignalConfig>()
                        .select(TWmsPlcSignalConfig::getId, TWmsPlcSignalConfig::getPlcAddress)
                        .eq(TWmsPlcSignalConfig::getPlcId, plcId)
                        .orderByAsc(TWmsPlcSignalConfig::getId))
                .stream()
                .map(item -> new Option<>(item.getId(), StrUtil.nullToEmpty(item.getPlcAddress())))
                .toList();
    }

    @Override
    public List<Option<String>> getMethodOptions() {
        return tTaskMethodNameMapper.selectList(new LambdaQueryWrapper<TTaskMethodName>()
                        .select(TTaskMethodName::getId,
                                TTaskMethodName::getMethodName,
                                TTaskMethodName::getMethodDescription)
                        .orderByAsc(TTaskMethodName::getId))
                .stream()
                .map(item -> {
                    String label = StrUtil.isNotBlank(item.getMethodDescription())
                            ? item.getMethodDescription() : item.getMethodName();
                    return new Option<>(item.getId(), label);
                })
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveTSignalMethodConfig(TSignalMethodConfigCreateDTO dto) {
        Assert.notNull(dto, "信号值方法配置不能为空");

        String signalId = StrUtil.trimToNull(dto.getSignalId());
        String signalCode = StrUtil.trimToNull(dto.getSignalCode());
        String methodId = StrUtil.trimToNull(dto.getMethodId());

        Assert.isTrue(StrUtil.isNotBlank(signalId), "请选择信号块地址");
        Assert.isTrue(StrUtil.isNotBlank(signalCode), "请输入信号值");
        Assert.isTrue(StrUtil.isNotBlank(methodId), "请选择方法");
        Assert.notNull(tWmsPlcSignalConfigMapper.selectById(signalId), "所选信号块不存在");
        Assert.notNull(tTaskMethodNameMapper.selectById(methodId), "所选方法不存在");

        // 同一信号块下，同一信号值不允许重复配置
        long sameSignalCodeCount = this.count(new LambdaQueryWrapper<TSignalMethodConfig>()
                .eq(TSignalMethodConfig::getSignalId, signalId)
                .eq(TSignalMethodConfig::getSignalCode, signalCode));
        Assert.isTrue(sameSignalCodeCount == 0, "该信号块下已存在相同信号值的配置");

        // 同一信号块下，同一方法不允许重复绑定
        long sameMethodCount = this.count(new LambdaQueryWrapper<TSignalMethodConfig>()
                .eq(TSignalMethodConfig::getSignalId, signalId)
                .eq(TSignalMethodConfig::getMethodId, methodId));
        Assert.isTrue(sameMethodCount == 0, "该信号块下已绑定该方法，请勿重复配置");

        TSignalMethodConfig entity = new TSignalMethodConfig();
        entity.setSignalId(signalId);
        entity.setSignalCode(signalCode);
        entity.setMethodId(methodId);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTSignalMethodConfig(String id) {
        Assert.isTrue(StrUtil.isNotBlank(id), "信号值方法配置ID不能为空");

        TSignalMethodConfig entity = this.getById(id);
        Assert.notNull(entity, "信号值方法配置不存在");

        return this.removeById(id);
    }
}
