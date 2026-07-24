package com.wms.warehouse.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.wms.warehouse.mapper.WmsAisleMapper;
import com.wms.warehouse.mapper.WmsPointMapper;
import com.wms.warehouse.model.entity.WmsAisle;
import com.wms.warehouse.model.entity.WmsPoint;
import com.wms.warehouse.service.WmsCascadeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 级联操作服务实现
 * <p>
 * 处理库区/巷道/点位之间的级联停用操作。
 * 直接使用 Mapper 层操作数据库，避免 Service 层循环依赖。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-21
 */
@Service
@RequiredArgsConstructor
public class WmsCascadeServiceImpl implements WmsCascadeService {

    private final WmsAisleMapper wmsAisleMapper;
    private final WmsPointMapper wmsPointMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cascadeDisableLocations(List<Long> locationIds) {
        List<Long> aisleIds = wmsAisleMapper.selectList(
                new LambdaQueryWrapper<WmsAisle>()
                        .in(WmsAisle::getLocationId, locationIds)
                        .select(WmsAisle::getId)
        ).stream().map(WmsAisle::getId).collect(java.util.stream.Collectors.toList());

        if (!aisleIds.isEmpty()) {
            WmsAisle aisleUpdate = new WmsAisle();
            aisleUpdate.setStatus(0);
            wmsAisleMapper.update(aisleUpdate,
                    new LambdaUpdateWrapper<WmsAisle>()
                            .in(WmsAisle::getId, aisleIds));

            cascadeDisablePoints(aisleIds);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void cascadeDisableAisles(List<Long> aisleIds) {
        cascadeDisablePoints(aisleIds);
    }

    /**
     * 停用指定巷道下的所有点位
     */
    private void cascadeDisablePoints(List<Long> aisleIds) {
        WmsPoint pointUpdate = new WmsPoint();
        pointUpdate.setStatus(0);
        wmsPointMapper.update(pointUpdate,
                new LambdaUpdateWrapper<WmsPoint>()
                        .in(WmsPoint::getAisleId, aisleIds));
    }
}