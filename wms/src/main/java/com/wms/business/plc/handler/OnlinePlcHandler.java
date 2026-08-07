//package com.wms.business.plc.handler.replenishment;
//
//import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
//import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
//import com.baomidou.mybatisplus.core.toolkit.IdWorker;
//import com.wms.business.agv.domain.TWmsAgvTask;
//import com.wms.business.agv.dto.AgvCancelTaskDTO;
//import com.wms.business.agv.dto.AgvContinueTaskDTO;
//import com.wms.business.agv.enums.AgvCallBackEnum;
//import com.wms.business.agv.mapper.TWmsAgvTaskMapper;
//import com.wms.business.agv.service.IAgvService;
//import com.wms.business.area.mapper.TWmsAreaMapper;
//import com.wms.business.iteminfo.domain.TWmsItemInfo;
//import com.wms.business.log.enums.ApiEnum;
//import com.wms.business.pda.dto.AgvPosstionCodePathDTO;
//import com.wms.business.pda.dto.CreateAgvTaskDTO;
//import com.wms.business.pda.enums.AgvCreateTaskEnum;
//import com.wms.business.plc.PlcAdapterService;
//import com.wms.business.plc.domain.TWmsPlcLocationConfig;
//import com.wms.business.plc.domain.TWmsPlcReplenishmentConfig;
//import com.wms.business.plc.handler.PlcSignalHandler;
//import com.wms.business.plc.mapper.TWmsPlcLocationConfigMapper;
//import com.wms.business.plc.service.PlcLocationConfigService;
//import com.wms.business.plc.service.PlcReplenishmentConfigService;
//import com.wms.business.plc.service.PlcService;
//
//import com.wms.business.roadway.domain.TWmsRoadway;
//import com.wms.business.roadway.mapper.TWmsRoadwayMapper;
//import com.wms.business.storage.domain.TWmsStorage;
//import com.wms.business.storage.mapper.TWmsStorageMapper;
//import com.wms.common.core.domain.R;
//import com.wms.common.utils.OrikaUtils;
//import com.wms.common.utils.SecurityUtils;
//import lombok.extern.slf4j.Slf4j;
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.data.redis.core.RedisTemplate;
//import org.springframework.stereotype.Component;
//
//import java.util.ArrayList;
//import java.util.List;
//import java.util.Map;
//import java.util.concurrent.TimeUnit;
//import java.util.stream.Collectors;
//
//
///**
// * @BelongsProject: wms
// * @BelongsPackage: com.wms.business.plc.handler.replenishment
// * @Author: YangZheng
// * @CreateTime: 2026-07-22 10:27
// * @Description: 补货任务handler
// * @Version: 1.0
// */
//@Slf4j
//@Component("onlinePlcHandler")
//public class OnlinePlcHandler implements PlcSignalHandler {
//    @Autowired
//    private PlcReplenishmentConfigService pcs;
//    @Autowired
//    private PlcService plcService;
//    @Autowired
//    private PlcLocationConfigService plcs;
//    // 工位配置Mapper
//    @Autowired
//    private TWmsPlcLocationConfigMapper plcm;
//
//    // 库区巷道储位Mapper
//    @Autowired
//    private TWmsRoadwayMapper tWmsRoadwayMapper;
//    @Autowired
//    private TWmsStorageMapper tWmsStorageMapper;
//    @Autowired
//    private TWmsAreaMapper tWmsAreaMapper;
//
//    // AGV任务相关
//    @Autowired
//    private TWmsAgvTaskMapper tWmsAgvTaskMapper;
//    @Autowired
//    private IAgvService iAgvService;
//
//    // redis
//    @Autowired
//    private RedisTemplate<String, String> redisTemplate;
//    @Autowired
//    private PlcAdapterService plcAdapterService;
//
//    /**
//    * @Description: 信号监听分发
//    * @Param: [plcId, plcAddress, mesAddress, exceptionAddress, newVal]
//    * @return: void
//    */
//    @Override
//    public void onSignal(String plcId, String plcAddress, String mesAddress, String exceptionAddress, short newVal) {
//        switch (newVal) {
//            case 0:
//                noStatus(plcAddress);
//                break;
//            case 10:
//                // 创建任务并获取任务单号
//                String agvTaskCode10 = stockUp(plcId, plcAddress, mesAddress, exceptionAddress, 10);
//                // 更新plcLocationConfig表的任务编号和当前信号
//                updateLocationConfigAgvTaskCode(plcId, plcAddress, agvTaskCode10, 10);
//                // 给PLC回写信号
//                if (agvTaskCode10 != null && !agvTaskCode10.isEmpty()) {
//                    // WMS调度AGV成功，送料中
//                    plcAdapterService.writeUInt16(plcId, mesAddress, 11);
//                }
//                break;
//            case 20:
//                // 创建任务并获取任务单号
//                String agvTaskCode20 = takeEmptyShelf(plcId, plcAddress, mesAddress, exceptionAddress, 20);
//                // 更新plcLocationConfig表的任务编号和当前信号
//                updateLocationConfigAgvTaskCode(plcId, plcAddress, agvTaskCode20, 20);
//                // 给PLC回写信号
//                if (agvTaskCode20 != null && !agvTaskCode20.isEmpty()) {
//                    plcAdapterService.writeUInt16(plcId, mesAddress, 21);
//                }
//                break;
//            case 21:
//                continueAgvTask(plcId, plcAddress);
//                break;
//            case 30:
//                // 创建任务并获取任务单号
//                String agvTaskCode30 = stockUp(plcId, plcAddress, mesAddress, exceptionAddress, 30);
//                // 更新plcLocationConfig表的任务编号和当前信号
//                updateLocationConfigAgvTaskCode(plcId, plcAddress, agvTaskCode30, 30);
//                // 给PLC回写信号
//                if (agvTaskCode30 != null && !agvTaskCode30.isEmpty()) {
//                    // WMS调度AGV成功，送料中
//                    plcAdapterService.writeUInt16(plcId, mesAddress, 11);
//                }
//                break;
//            case 40:
//                // 创建任务并获取任务单号
//                String agvTaskCode40 = takeEmptyShelf(plcId, plcAddress, mesAddress, exceptionAddress, 40);
//                // 更新plcLocationConfig表的任务编号和当前信号
//                updateLocationConfigAgvTaskCode(plcId, plcAddress, agvTaskCode40, 40);
//                // 给PLC回写信号
//                if (agvTaskCode40 != null && !agvTaskCode40.isEmpty()) {
//                    plcAdapterService.writeUInt16(plcId, mesAddress, 21);
//                }
//                break;
//            case 50:
//                if (plcAdapterService.readUInt16(plcId, mesAddress) == 22) {
//                    cancelAgvTask(plcId, plcAddress);
//                }
//                break;
//            default:
//                log.error("未知信号");
//                break;
//        }
//    }
//
//    private void cancelAgvTask(String plcId, String plcAddress) {
//        // 拿配置信息
//        TWmsPlcLocationConfig locationConfig = plcs.findByAddress(plcId, plcAddress);
//        if (locationConfig == null || locationConfig.getAgvTaskCode() == null) {
//            log.error("未找到工位任务配置: plcId={}, address={}", plcId, plcAddress);
//            return;
//        }
//        // 提取AgvTaskCode
//        AgvCancelTaskDTO agvCancelTaskDTO = new AgvCancelTaskDTO();
//        agvCancelTaskDTO.setAgvTaskCodeCancel(locationConfig.getAgvTaskCode());
//        // 取消任务
//        iAgvService.cancelTask(agvCancelTaskDTO);
//    }
//
//    public void noStatus(String address) {
//        log.info("PLC当前无状态,IP:{}", address);
//    }
//
//    /**
//     * TaskTyp = PLC10
//     *
//     * @Description: PLC请求上位机送料
//     * @Param: [plcId, address, triggerValue]
//     * @return: void
//     */
//    public String stockUp(String plcId, String plcAddress, String mesAddress, String exceptionAddress, int triggerValue) {
//        // 反馈WMS任务下发成功
//        plcAdapterService.writeUInt16(plcId, mesAddress, 10);
//        log.info("收到信号{}, 开始查找配置", triggerValue);
//        TWmsPlcReplenishmentConfig config = pcs.findByAddressAndTriggerValue(plcId, plcAddress, triggerValue);
//        if (config == null) {
//            log.error("未找到补料配置: plcId={}, address={}, triggerValue={}", plcId, plcAddress, triggerValue);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 20);
//            return null;
//        }
//        log.info("查找起点");
//        TWmsItemInfo start;
//        if (config.getItemModelCode() == null || config.getItemModelCode().isEmpty()) {
//            start = plcService.findStart(config.getOnlineType());
//        } else {
//            start = plcService.findStart(config.getOnlineType(), config.getItemModelCode());
//        }
//        if (start == null) {
//            log.error("未找到可用物料: onlineType={}, itemModelCode={}", config.getOnlineType(), config.getItemModelCode());
//            // WMS满车任务没料
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 10);
//            return null;
//        }
//        log.info("查找终点");
//        TWmsPlcLocationConfig end = plcs.findByAddress(plcId, plcAddress);
//        if (end == null) {
//            log.error("未找到工位地标码: plcId={}, address={}", plcId, plcAddress);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 20);
//            return null;
//        }
//        // 防重：检查工位上是否已有未完成的任务
//        if (end.getAgvTaskCode() != null && !end.getAgvTaskCode().isEmpty()) {
//            TWmsAgvTask existingTask = tWmsAgvTaskMapper.selectOne(
//                    new LambdaQueryWrapper<TWmsAgvTask>()
//                            .eq(TWmsAgvTask::getTaskNo, end.getAgvTaskCode())
//            );
//            if (existingTask != null
//                    && !AgvCallBackEnum.AGV_TASK_STATUS_END.getCode().equals(existingTask.getTaskStatus())
//                    && !AgvCallBackEnum.AGV_TASK_STATUS_CANCEL.getCode().equals(existingTask.getTaskStatus())) {
//                log.warn("工位已有未完成任务: taskNo={}, status={}", end.getAgvTaskCode(), existingTask.getTaskStatus());
//                return null;
//            }
//        }
//        // PLC工位分布式锁，防止并发创建同一PLC工位的任务
//        String landmarkLockKey = "replenishment:landmark:" + end.getLandmarkCode();
//        Boolean landmarkLocked = redisTemplate.opsForValue()
//                .setIfAbsent(landmarkLockKey, "1", 5, TimeUnit.MINUTES);
//        if (Boolean.FALSE.equals(landmarkLocked)) {
//            log.warn("PLC工位 {} 已被锁定，跳过", end.getLandmarkCode());
//            return null;
//        }
//        // 创建任务
//        try {
//            return createAgvTask(start.getAgvCode(), end.getLandmarkCode(), start.getItemCarNo(), "PLC10", plcId, mesAddress, exceptionAddress);
//        } catch (Exception e) {
//            log.error("创建AGV送料任务失败", e);
//            redisTemplate.delete(landmarkLockKey);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 20);
//        }
//        return null;
//    }
//
//    /**
//     * TaskTyp = PLC20
//     *
//     * @Description: PLC请求上位机取走空板(预叫)
//     * @Param: [plcId, address, triggerValue]
//     * @return: void
//     */
//    public String takeEmptyShelf(String plcId, String plcAddress, String mesAddress, String exceptionAddress, int triggerValue) {
//        // 反馈WMS任务下发成功
//        plcAdapterService.writeUInt16(plcId, mesAddress, 20);
//        // 起点PLC工位
//        TWmsPlcLocationConfig start = plcs.findByAddress(plcId, plcAddress);
//        if (start == null) {
//            log.error("未找到工位地标码: plcId={}, address={}", plcId, plcAddress);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 40);
//            return null;
//        }
//        // 防重：检查工位上是否已有未完成的任务
//        if (start.getAgvTaskCode() != null && !start.getAgvTaskCode().isEmpty()) {
//            TWmsAgvTask existingTask = tWmsAgvTaskMapper.selectOne(
//                    new LambdaQueryWrapper<TWmsAgvTask>()
//                            .eq(TWmsAgvTask::getTaskNo, start.getAgvTaskCode())
//            );
//            if (existingTask != null
//                    && !AgvCallBackEnum.AGV_TASK_STATUS_END.getCode().equals(existingTask.getTaskStatus())
//                    && !AgvCallBackEnum.AGV_TASK_STATUS_CANCEL.getCode().equals(existingTask.getTaskStatus())) {
//                log.warn("工位已有未完成任务: taskNo={}, status={}", start.getAgvTaskCode(), existingTask.getTaskStatus());
//                return null;
//            }
//        }
//        // 终点库区
//        TWmsPlcReplenishmentConfig endArea = pcs.findByAddressAndTriggerValue(plcId, plcAddress, triggerValue);
//        if (endArea == null) {
//            log.error("未找到取空板配置: plcId={}, address={}, triggerValue={}", plcId, plcAddress, triggerValue);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 40);
//            return null;
//        }
//        // 终点详情
//        TWmsStorage end = findEmptyEnd(endArea.getAreaId());
//        if (end == null) {
//            log.error("未找到空储位: areaId={}", endArea.getAreaId());
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 40);
//            return null;
//        }
//        // PLC工位分布式锁，防止并发创建同一PLC工位的任务
//        String storageCodeLockKey = "replenishment:storageCode:" + end.getAgvStorageCode();
//        Boolean storageCodeLocked = redisTemplate.opsForValue()
//                .setIfAbsent(storageCodeLockKey, "1", 5, TimeUnit.MINUTES);
//        if (Boolean.FALSE.equals(storageCodeLocked)) {
//            log.warn("PLC工位 {} 已被锁定，跳过", end.getAgvStorageCode());
//            return null;
//        }
//        // 创建AGV任务
//        try {
//            return createAgvTask(start.getLandmarkCode(), end.getAgvStorageCode(), null, "PLC20", plcId, mesAddress, exceptionAddress);
//        } catch (Exception e) {
//            log.error("创建AGV取空板任务失败", e);
//            redisTemplate.delete(storageCodeLockKey);
//            plcAdapterService.writeUInt16(plcId, exceptionAddress, 40);
//        }
//        return null;
//    }
//
//    public void continueAgvTask(String plcId, String plcAddress) {
//        // 拿配置信息
//        TWmsPlcLocationConfig locationConfig = plcs.findByAddress(plcId, plcAddress);
//        if (locationConfig == null || locationConfig.getAgvTaskCode() == null) {
//            log.error("未找到工位任务配置: plcId={}, address={}", plcId, plcAddress);
//            return;
//        }
//        // 提取AgvTaskCode
//        AgvContinueTaskDTO agvContinueTaskDTO = new AgvContinueTaskDTO();
//        agvContinueTaskDTO.setAgvTaskCode(locationConfig.getAgvTaskCode());
//        // 继续任务
//        iAgvService.continueTask(agvContinueTaskDTO);
//    }
//
//
//    /**
//     * 创建PLC AGV任务
//     *
//     * @param sourcePositionCode 起点地标码
//     * @param targetPositionCode 终点地标码
//     * @param shelfCode          货架号（可选）
//     * @param taskTyp            任务类型(例: PJ36)
//     * @return 创建成功返回任务单号，失败返回null
//     */
//    public String createAgvTask(String sourcePositionCode, String targetPositionCode, String shelfCode, String taskTyp, String plcId, String plcMessAddress, String plcExceptionAddr) {
//        try {
//            // ==================== ① 构建 CreateAgvTaskDTO ====================
//            CreateAgvTaskDTO dto = new CreateAgvTaskDTO();
//            dto.setReqCode(IdWorker.get32UUID());
//            dto.setTaskCode("101PLC::AGV" + IdWorker.get32UUID());
//            dto.setTaskTyp(taskTyp);
//
//            // 货架号（可选）
//            if (com.wms.common.utils.StringUtils.isNotEmpty(shelfCode)) {
//                dto.setPodCode(shelfCode);
//            }
//
//            // 位置路径：起点 → 终点（均使用地标码）
//            List<AgvPosstionCodePathDTO> pathList = new ArrayList<>();
//
//            // 起点：外部库区地标码 — 类型00
//            AgvPosstionCodePathDTO start = new AgvPosstionCodePathDTO();
//            start.setPositionCode(sourcePositionCode);
//            start.setType(AgvCreateTaskEnum.POSITIONCODEPATH_TYPE_00.getCode());
//            pathList.add(start);
//
//            // 终点：目标地标码 — 类型00
//            AgvPosstionCodePathDTO end = new AgvPosstionCodePathDTO();
//            end.setPositionCode(targetPositionCode);
//            end.setType(AgvCreateTaskEnum.POSITIONCODEPATH_TYPE_00.getCode());
//            pathList.add(end);
//
//            dto.setPositionCodePath(pathList);
//
//            // ==================== ② 调用 AGV 接口 ====================
//            Map<String, Object> params = OrikaUtils.mapBeanToMap(dto);
//            R<Object> r = iAgvService.commonRequest(ApiEnum.AGV_genAgvSchedulingTask, params);
//            if (R.SUCCESS != r.getCode()) {
//                log.error("[101PLC::AGV] 创建AGV任务失败: source={}, target={}, msg={}",
//                        sourcePositionCode, targetPositionCode, r.getMsg());
//                return null;
//            }
//
//            // ==================== ③ 保存 t_wms_agv_task 记录 ====================
//            TWmsAgvTask agvTask = new TWmsAgvTask();
//            agvTask.setId(IdWorker.getIdStr());
//            agvTask.setCompany(SecurityUtils.getLoginUser().getUser().getCompany());
//            agvTask.setTaskMode(AgvCallBackEnum.AGV_TASK_MODE12.getCode()); // mode=12 补货
//            agvTask.setTaskNo(dto.getTaskCode());
//            agvTask.setTaskTemplateCode(taskTyp);
//            agvTask.setShelfCode(shelfCode);
//            agvTask.setStartPositionCode(sourcePositionCode);
//            agvTask.setStartPositionType(AgvCreateTaskEnum.POSITIONCODEPATH_TYPE_00.getCode());
//            agvTask.setEndPositionCode(targetPositionCode);
//            agvTask.setEndPositionType(AgvCreateTaskEnum.POSITIONCODEPATH_TYPE_00.getCode());
//            agvTask.setTaskStatus(AgvCallBackEnum.AGV_TASK_STATUS_CREATE.getCode());
//            agvTask.setAreaId("PLC");
//            agvTask.setRoadwayId("PLC");
//            agvTask.setPlcId(plcId);
//            agvTask.setPlcMesAddress(plcMessAddress);
//            agvTask.setPlcExceptionAddr(plcExceptionAddr);
//
//            // 站点集合
//            String startInfo = start.getPositionCode() + "$" + start.getType();
//            String endInfo = end.getPositionCode() + "$" + end.getType();
//            agvTask.setTaskPosittionGather("[" + startInfo + "," + endInfo + "]");
//            tWmsAgvTaskMapper.insert(agvTask);
//
//            log.info("[101PLC::AGV] AGV任务创建成功: taskNo={}, source={}, target={}",
//                    agvTask.getTaskNo(), sourcePositionCode, targetPositionCode);
//            return agvTask.getTaskNo();
//
//        } catch (Exception e) {
//            log.error("[101PLC::AGV] 创建AGV任务异常: source={}, target={}",
//                    sourcePositionCode, targetPositionCode, e);
//            return null;
//        }
//    }
//
//    /**
//     * @Description: 查空货架终点
//     * @Param: [areaId]
//     * @return: java.util.List<com.wms.business.replenishment.dto.DestinationInfoDTO>
//     */
//    public TWmsStorage findEmptyEnd(String areaId) {
//        // 1. 先查是 库区1和库区2 的所有巷道
//        List<TWmsRoadway> tWmsRoadways = tWmsRoadwayMapper.selectList(
//                new LambdaQueryWrapper<TWmsRoadway>()
//                        .select(TWmsRoadway::getId)
//                        .eq(TWmsRoadway::getAreaId, areaId)
//        );
//        if (tWmsRoadways == null || tWmsRoadways.isEmpty()) {
//            log.warn("未找到areaId={}下的巷道,跳过空储位查询", areaId);
//            return null;
//        }
//        List<String> roadwayIdList = tWmsRoadways.stream()
//                .map(TWmsRoadway::getId)
//                .filter(code -> code != null && !code.isEmpty())
//                .collect(Collectors.toList());
//        if (roadwayIdList.isEmpty()) {
//            log.warn("巷道ID列表为空,跳过空储位查询: areaId={}", areaId);
//            return null;
//        }
//        // 2. 先查是其巷道的储位，且为空
//        List<TWmsStorage> tWmsStorages = tWmsStorageMapper.selectList(
//                new LambdaQueryWrapper<TWmsStorage>()
//                        .isNull(TWmsStorage::getItemCarNo)
//                        .in(TWmsStorage::getRoadwayId, roadwayIdList)
//                        .orderByDesc(TWmsStorage::getSort)
//                        .last("limit 1")
//        );
//        return tWmsStorages.isEmpty() ? null : tWmsStorages.get(0);
//    }
//
//    /**
//     * @Description: 更新工位任务编号
//     * @Param: [plcId, address, agvTaskCode]
//     * @return: void
//     */
//    public void updateLocationConfigAgvTaskCode(String plcId, String address, String agvTaskCode, int triggerValue) {
//        TWmsPlcLocationConfig plcLocationConfig = plcs.findByAddress(plcId, address);
//        if (plcLocationConfig == null) {
//            log.warn("未找到工位地标码配置: plcId={}, address={}", plcId, address);
//            return;
//        }
//        plcLocationConfig.setAgvTaskCode(agvTaskCode);
//        plcLocationConfig.setTriggerValue(triggerValue);
//        plcm.update(plcLocationConfig,
//                new LambdaUpdateWrapper<TWmsPlcLocationConfig>()
//                        .eq(TWmsPlcLocationConfig::getPlcId, plcId)
//                        .eq(TWmsPlcLocationConfig::getAddress, address)
//        );
//    }
//
//
//}
