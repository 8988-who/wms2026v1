package com.wms.plc.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.plc.WmsPlcConnection;
import com.wms.plc.manager.WmsPlcConnectionManager;
import com.wms.plc.mapper.TWmsPlcConnectionMapper;
import com.wms.plc.model.dto.TWmsPlcConnectionCreateDTO;
import com.wms.plc.model.dto.TWmsPlcConnectionQueryDTO;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.common.model.entity.WmsLocation;
import com.wms.plc.model.vo.TWmsPlcConnectionLocationVO;
import com.wms.plc.model.vo.TWmsPlcConnectionVO;
import com.wms.plc.service.TWmsPlcConnectionService;
import com.wms.warehouse.service.WmsLocationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * PLC连接配置业务服务实现
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class TWmsPlcConnectionServiceImpl
        extends ServiceImpl<TWmsPlcConnectionMapper, TWmsPlcConnection>
        implements TWmsPlcConnectionService {

    private static final Set<String> ALLOWED_PLC_TYPES = Set.of(
            "S200",
            "S300",
            "S400",
            "S1200",
            "S1500",
            "S200_SMART",
            "SINUMERIK_828D"
    );

    private final TWmsPlcConnectionMapper tWmsPlcConnectionMapper;
    private final WmsPlcConnectionManager wmsPlcConnectionManager;
    private final WmsLocationService wmsLocationService;

    @Override
    public IPage<TWmsPlcConnectionVO> getTWmsPlcConnectionPage(TWmsPlcConnectionQueryDTO queryParams) {
        Page<TWmsPlcConnectionVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        IPage<TWmsPlcConnectionVO> result = tWmsPlcConnectionMapper.getTWmsPlcConnectionPage(page, queryParams);
        result.getRecords().forEach(item -> {
            WmsPlcConnection connection = wmsPlcConnectionManager.getConnection(item.getId());
            item.setConnected(connection != null && connection.isOnline());
        });
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveTWmsPlcConnection(TWmsPlcConnectionCreateDTO dto) {
        Assert.notNull(dto, "PLC配置不能为空");

        String name = StrUtil.trimToNull(dto.getName());
        String host = StrUtil.trimToNull(dto.getHost());
        String plcType = StrUtil.trimToNull(dto.getPlcType());
        String heartbeatAddr = StrUtil.trimToNull(dto.getHeartbeatAddr());

        Assert.isTrue(StringUtils.hasText(name), "请选择区域");
        Assert.isTrue(StringUtils.hasText(host), "请输入PLC IP地址");
        Assert.isTrue(StringUtils.hasText(plcType), "请选择PLC类型");
        Assert.isTrue(ALLOWED_PLC_TYPES.contains(plcType), "PLC类型不合法");

        WmsLocation location = wmsLocationService.getOne(new LambdaQueryWrapper<WmsLocation>()
                .select(WmsLocation::getLocationName, WmsLocation::getStatus)
                .eq(WmsLocation::getLocationName, name)
                .last("LIMIT 1"));
        Assert.notNull(location, "所选区域不存在");

        TWmsPlcConnection entity = new TWmsPlcConnection();
        entity.setName(name);
        entity.setHost(host);
        entity.setPlcType(plcType);
        entity.setHeartbeatAddr(heartbeatAddr);
        return this.save(entity);
    }

    @Override
    public List<TWmsPlcConnectionLocationVO> getTWmsPlcConnectionLocationOptions() {
        List<WmsLocation> locations = wmsLocationService.list(new LambdaQueryWrapper<WmsLocation>()
                .select(WmsLocation::getLocationName, WmsLocation::getStatus)
                .orderByAsc(WmsLocation::getSortOrder)
                .orderByAsc(WmsLocation::getId));

        List<TWmsPlcConnectionLocationVO> result = new ArrayList<>();
        Set<String> seen = new LinkedHashSet<>();
        for (WmsLocation location : locations) {
            if (!StringUtils.hasText(location.getLocationName()) || !seen.add(location.getLocationName())) {
                continue;
            }
            TWmsPlcConnectionLocationVO item = new TWmsPlcConnectionLocationVO();
            item.setLocationName(location.getLocationName());
            item.setStatus(location.getStatus());
            result.add(item);
        }
        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTWmsPlcConnections(String ids) {
        if (StrUtil.isBlank(ids)) {
            return false;
        }

        List<String> idList = Arrays.stream(ids.split(","))
                .map(String::trim)
                .filter(StrUtil::isNotBlank)
                .toList();
        if (idList.isEmpty()) {
            return false;
        }

        for (String id : idList) {
            TWmsPlcConnection entity = this.getById(id);
            Assert.notNull(entity, "PLC配置不存在");
        }

        for (String id : idList) {
            Assert.isTrue(wmsPlcConnectionManager.closeConnectionForDelete(id), "PLC连接关闭失败");
        }

        return this.removeByIds(idList);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateTWmsPlcConnectionEnabled(String id, Integer enabled) {
        Assert.isTrue(StrUtil.isNotBlank(id), "PLC配置ID不能为空");
        Assert.isTrue(enabled != null && (enabled == 0 || enabled == 1), "启用状态只能是0或1");

        TWmsPlcConnection entity = this.getById(id);
        Assert.notNull(entity, "PLC配置不存在");

        entity.setEnabled(enabled);
        boolean updated = this.updateById(entity);
        if (!updated) {
            return false;
        }

        if (enabled == 0) {
            wmsPlcConnectionManager.stopConnection(id);
            return true;
        }

        Assert.isTrue(wmsPlcConnectionManager.startConnection(id), "启用PLC连接失败");
        return true;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean reconnectTWmsPlcConnection(String id) {
        Assert.isTrue(StrUtil.isNotBlank(id), "PLC配置ID不能为空");

        TWmsPlcConnection entity = this.getById(id);
        Assert.notNull(entity, "PLC配置不存在");
        Assert.isTrue(entity.getEnabled() != null && entity.getEnabled() == 1, "该plc已禁用");

        Assert.isTrue(wmsPlcConnectionManager.reconnectConnection(id), "PLC重连失败");
        return true;
    }
}
