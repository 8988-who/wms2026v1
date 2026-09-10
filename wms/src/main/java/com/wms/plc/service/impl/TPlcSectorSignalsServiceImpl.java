package com.wms.plc.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.Option;
import com.wms.common.model.entity.TPlcSectorSignals;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import com.wms.plc.mapper.TPlcSectorSignalsMapper;
import com.wms.plc.mapper.TWmsPlcConnectionMapper;
import com.wms.plc.mapper.TWmsPlcSignalConfigMapper;
import com.wms.plc.model.dto.TPlcSectorSignalsCreateDTO;
import com.wms.plc.model.dto.TPlcSectorSignalsQueryDTO;
import com.wms.plc.service.TPlcSectorSignalsService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * PLC信号块读写信号配置业务服务实现
 */
@Service
@RequiredArgsConstructor
public class TPlcSectorSignalsServiceImpl
        extends ServiceImpl<TPlcSectorSignalsMapper, TPlcSectorSignals>
        implements TPlcSectorSignalsService {

    private final TWmsPlcSignalConfigMapper tWmsPlcSignalConfigMapper;
    private final TWmsPlcConnectionMapper tWmsPlcConnectionMapper;

    @Override
    public IPage<TPlcSectorSignals> getTPlcSectorSignalsPage(TPlcSectorSignalsQueryDTO queryParams) {
        LambdaQueryWrapper<TPlcSectorSignals> wrapper = new LambdaQueryWrapper<>();
        // id 精确匹配
        wrapper.eq(StrUtil.isNotBlank(queryParams.getId()), TPlcSectorSignals::getId, queryParams.getId());
        // 信号类型精确匹配
        wrapper.eq(queryParams.getSignalType() != null, TPlcSectorSignals::getSignalType, queryParams.getSignalType());
        // 信号地址、信号描述、信号ID模糊匹配
        wrapper.like(StrUtil.isNotBlank(queryParams.getSignalAddress()),
                TPlcSectorSignals::getSignalAddress, queryParams.getSignalAddress());
        wrapper.like(StrUtil.isNotBlank(queryParams.getSignalDescription()),
                TPlcSectorSignals::getSignalDescription, queryParams.getSignalDescription());
        wrapper.like(StrUtil.isNotBlank(queryParams.getSignalId()),
                TPlcSectorSignals::getSignalId, queryParams.getSignalId());
        // 排序号升序(空值沉底)，同排序号按id升序
        wrapper.orderByAsc(TPlcSectorSignals::getNumber);
        wrapper.orderByAsc(TPlcSectorSignals::getId);

        Page<TPlcSectorSignals> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return this.page(page, wrapper);
    }

    @Override
    public List<Option<String>> getSignalConfigOptions() {
        List<TWmsPlcSignalConfig> configs = tWmsPlcSignalConfigMapper.selectList(
                new LambdaQueryWrapper<TWmsPlcSignalConfig>().orderByAsc(TWmsPlcSignalConfig::getId));
        if (configs.isEmpty()) {
            return Collections.emptyList();
        }
        Set<String> plcIds = configs.stream()
                .map(TWmsPlcSignalConfig::getPlcId)
                .filter(StrUtil::isNotBlank)
                .collect(Collectors.toSet());
        Map<String, String> hostMap = plcIds.isEmpty() ? Collections.emptyMap()
                : tWmsPlcConnectionMapper.selectBatchIds(plcIds).stream()
                        .filter(conn -> StrUtil.isNotBlank(conn.getId()) && StrUtil.isNotBlank(conn.getHost()))
                        .collect(Collectors.toMap(TWmsPlcConnection::getId, TWmsPlcConnection::getHost, (a, b) -> a));
        return configs.stream()
                .map(config -> {
                    String host = hostMap.getOrDefault(config.getPlcId(), "");
                    String label = StrUtil.isNotBlank(host) ? host + "," + config.getPlcAddress() : config.getPlcAddress();
                    return new Option<>(config.getId(), label);
                })
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveTPlcSectorSignal(TPlcSectorSignalsCreateDTO dto) {
        Assert.notNull(dto, "PLC信号块读写信号配置不能为空");

        Integer signalType = dto.getSignalType();
        Assert.notNull(signalType, "请选择信号类型");
        Assert.isTrue(signalType >= 1 && signalType <= 3, "信号类型取值只能为1/2/3");

        String signalAddress = StrUtil.trimToNull(dto.getSignalAddress());
        String signalDescription = StrUtil.trimToNull(dto.getSignalDescription());
        String signalId = StrUtil.trimToNull(dto.getSignalId());
        Assert.isTrue(StrUtil.isNotBlank(signalAddress), "请输入信号地址");
        Assert.isTrue(StrUtil.isNotBlank(signalId), "请选择信号块");
        Assert.notNull(tWmsPlcSignalConfigMapper.selectById(signalId), "所选信号块不存在");

        // 排序号：信号类型为1(货架号)时可空，其余类型必填
        Integer number = dto.getNumber();
        if (signalType != 1) {
            Assert.notNull(number, "请填写排序号");
        }

        TPlcSectorSignals entity = new TPlcSectorSignals();
        entity.setSignalType(signalType);
        entity.setSignalAddress(signalAddress);
        entity.setSignalDescription(signalDescription);
        entity.setSignalId(signalId);
        entity.setNumber(number);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTPlcSectorSignals(String id) {
        Assert.isTrue(StrUtil.isNotBlank(id), "PLC信号块读写信号配置ID不能为空");

        TPlcSectorSignals entity = this.getById(id);
        Assert.notNull(entity, "PLC信号块读写信号配置不存在");

        return this.removeById(id);
    }
}
