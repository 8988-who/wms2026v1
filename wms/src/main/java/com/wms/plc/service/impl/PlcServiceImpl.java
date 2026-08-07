package com.wms.business.plc.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.business.area.domain.TWmsArea;
import com.wms.business.area.mapper.TWmsAreaMapper;
import com.wms.business.iteminfo.domain.TWmsItemInfo;
import com.wms.business.iteminfo.mapper.TWmsItemInfoMapper;
import com.wms.business.plc.PlcAdapterService;
import com.wms.business.plc.service.PlcService;
import com.wms.business.replenishment.dto.DestinationInfoDTO;
import com.wms.business.roadway.domain.TWmsRoadway;
import com.wms.business.roadway.mapper.TWmsRoadwayMapper;
import com.wms.business.storage.domain.TWmsStorage;
import com.wms.business.storage.mapper.TWmsStorageMapper;
import com.wms.business.suitableonlinetype.mapper.TWmsSuitableOnlineTypeMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.service.impl
 * @Author: YangZheng
 * @CreateTime: 2026-07-20 15:07
 * @Description: plc业务实现
 * @Version: 1.0
 */
@Service
public class PlcServiceImpl implements PlcService {
    @Autowired
    private TWmsSuitableOnlineTypeMapper tWmsSuitableOnlineTypeMapper;
    @Autowired
    private TWmsItemInfoMapper tWmsItemInfoMapper;
    @Autowired
    private PlcAdapterService plcAdapterService;
    @Autowired
    private TWmsStorageMapper tWmsStorageMapper;
    @Autowired
    private TWmsRoadwayMapper tWmsRoadwayMapper;
    @Autowired
    private TWmsAreaMapper tWmsAreaMapper;

    @Override
    public TWmsItemInfo findStart(String onlineType) {
        List<TWmsItemInfo> locationList = tWmsItemInfoMapper.selectList(
                new LambdaQueryWrapper<TWmsItemInfo>()
                        .eq(TWmsItemInfo::getOnlineType, onlineType)
        );

        TWmsItemInfo earliestItem = locationList.stream()
                .min(Comparator.comparing(TWmsItemInfo::getInStockDate))
                .orElse(null);
        return earliestItem;
    }

    @Override
    public TWmsItemInfo findStart(String onlineType, String modelCode) {
        List<TWmsItemInfo> locationList = tWmsItemInfoMapper.selectList(
                new LambdaQueryWrapper<TWmsItemInfo>()
                        .eq(TWmsItemInfo::getOnlineType, onlineType)
                        .eq(TWmsItemInfo::getItemModelCode, modelCode)
        );

        TWmsItemInfo earliestItem = locationList.stream()
                .min(Comparator.comparing(TWmsItemInfo::getInStockDate))
                .orElse(null);
        return earliestItem;
    }

    @Override
    public TWmsStorage findEnd(String onlineType, String modelCode) {
        // 1. 先查是 库区1和库区2 的所有巷道
        List<TWmsRoadway> tWmsRoadways = tWmsRoadwayMapper.selectList(
                new LambdaQueryWrapper<TWmsRoadway>()
                        .select(TWmsRoadway::getId)
                        .in(TWmsRoadway::getAreaId, "2072566742792916994", "2074043138623000578")
        );
        List<String> roadwayIdList = tWmsRoadways.stream()
                .map(TWmsRoadway::getId)
                .filter(code -> code != null && !code.isEmpty())
                .collect(Collectors.toList());
        // 2. 先查是其巷道的储位，且为空
        List<TWmsStorage> tWmsStorages = tWmsStorageMapper.selectList(
                new LambdaQueryWrapper<TWmsStorage>()
                        .isNull(TWmsStorage::getItemCarNo)
                        .in(TWmsStorage::getRoadwayId, roadwayIdList)
        );
        // 3. sort 越大越优先
        return tWmsStorages.stream()
                .max(Comparator.comparing(TWmsStorage::getSort))
                .orElse(null);
    }


}
