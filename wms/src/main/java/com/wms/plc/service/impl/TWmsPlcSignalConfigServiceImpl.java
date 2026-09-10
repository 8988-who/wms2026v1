package com.wms.plc.service.impl;

import cn.hutool.core.lang.Assert;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.model.entity.TWmsPlcConnection;
import com.wms.common.model.entity.TWmsPlcSignalConfig;
import com.wms.common.model.entity.WmsPoint;
import com.wms.plc.mapper.TWmsPlcConnectionMapper;
import com.wms.plc.mapper.TWmsPlcSignalConfigMapper;
import com.wms.plc.model.dto.TWmsPlcSignalConfigCreateDTO;
import com.wms.plc.model.dto.TWmsPlcSignalConfigQueryDTO;
import com.wms.plc.model.vo.TWmsPlcConnectionOptionVO;
import com.wms.plc.model.vo.TWmsPlcPointOptionVO;
import com.wms.plc.model.vo.TWmsPlcSignalConfigVO;
import com.wms.plc.service.TWmsPlcSignalConfigService;
import com.wms.warehouse.mapper.WmsPointMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * PLC信号块配置业务服务实现
 */
@Service
@RequiredArgsConstructor
public class TWmsPlcSignalConfigServiceImpl
        extends ServiceImpl<TWmsPlcSignalConfigMapper, TWmsPlcSignalConfig>
        implements TWmsPlcSignalConfigService {

    private final TWmsPlcSignalConfigMapper tWmsPlcSignalConfigMapper;
    private final TWmsPlcConnectionMapper tWmsPlcConnectionMapper;
    private final WmsPointMapper wmsPointMapper;

    @Override
    public IPage<TWmsPlcSignalConfigVO> getTWmsPlcSignalConfigPage(TWmsPlcSignalConfigQueryDTO queryParams) {
        Page<TWmsPlcSignalConfigVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        return tWmsPlcSignalConfigMapper.getTWmsPlcSignalConfigPage(page, queryParams);
    }

    @Override
    public List<TWmsPlcConnectionOptionVO> getTWmsPlcConnectionOptions() {
        return tWmsPlcConnectionMapper.selectList(new LambdaQueryWrapper<TWmsPlcConnection>()
                        .select(TWmsPlcConnection::getId, TWmsPlcConnection::getHost)
                        .orderByAsc(TWmsPlcConnection::getId))
                .stream()
                .map(item -> {
                    TWmsPlcConnectionOptionVO vo = new TWmsPlcConnectionOptionVO();
                    vo.setId(item.getId());
                    vo.setHost(item.getHost());
                    return vo;
                })
                .toList();
    }

    @Override
    public List<TWmsPlcPointOptionVO> getWmsPointOptions() {
        return wmsPointMapper.selectList(new LambdaQueryWrapper<WmsPoint>()
                        .select(WmsPoint::getId, WmsPoint::getPointName)
                        .orderByAsc(WmsPoint::getId))
                .stream()
                .map(item -> {
                    TWmsPlcPointOptionVO vo = new TWmsPlcPointOptionVO();
                    vo.setId(String.valueOf(item.getId()));
                    vo.setPointName(item.getPointName());
                    return vo;
                })
                .toList();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean saveTWmsPlcSignalConfig(TWmsPlcSignalConfigCreateDTO dto) {
        Assert.notNull(dto, "PLC信号块配置不能为空");

        String plcId = StrUtil.trimToNull(dto.getPlcId());
        String plcAddress = StrUtil.trimToNull(dto.getPlcAddress());
        String description = StrUtil.trimToNull(dto.getDescription());
        String pointId = StrUtil.trimToNull(dto.getPointId());

        Assert.isTrue(StrUtil.isNotBlank(plcId), "请选择PLC");
        Assert.isTrue(StrUtil.isNotBlank(plcAddress), "请输入板块地址");
        Assert.isTrue(StrUtil.isNotBlank(pointId), "请选择储位");
        Assert.notNull(tWmsPlcConnectionMapper.selectById(plcId), "所选PLC不存在");

        // 所选储位必须存在（wms_point.id 为数值型主键，需转换为数值后按主键查询）
        Long pointIdVal;
        try {
            pointIdVal = Long.valueOf(pointId);
        } catch (NumberFormatException e) {
            pointIdVal = null;
        }
        Assert.notNull(pointIdVal, "所选储位不存在");
        Long pointCount = wmsPointMapper.selectCount(new LambdaQueryWrapper<WmsPoint>()
                .eq(WmsPoint::getId, pointIdVal));
        Assert.isTrue(pointCount != null && pointCount > 0, "所选储位不存在");

        TWmsPlcSignalConfig entity = new TWmsPlcSignalConfig();
        entity.setPlcId(plcId);
        entity.setPlcAddress(plcAddress);
        entity.setDescription(description);
        entity.setPointId(pointId);
        return this.save(entity);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean deleteTWmsPlcSignalConfig(String id) {
        Assert.isTrue(StrUtil.isNotBlank(id), "PLC信号块配置ID不能为空");

        TWmsPlcSignalConfig entity = this.getById(id);
        Assert.notNull(entity, "PLC信号块配置不存在");

        return this.removeById(id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public boolean updateTWmsPlcSignalConfigEnabled(String id, Integer enabled) {
        Assert.isTrue(StrUtil.isNotBlank(id), "PLC信号块配置ID不能为空");
        Assert.isTrue(enabled != null && (enabled == 0 || enabled == 1), "启用状态只能是0或1");

        TWmsPlcSignalConfig entity = this.getById(id);
        Assert.notNull(entity, "PLC信号块配置不存在");

        entity.setEnabled(enabled);
        return this.updateById(entity);
    }
}
