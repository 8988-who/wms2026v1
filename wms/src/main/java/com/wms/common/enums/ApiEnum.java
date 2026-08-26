package com.wms.common.enums;

import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import lombok.Getter;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.enums
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 10:34
 * @Description: API接口枚举类（统一管理AGV/MES接口配置）
 * @Version: 1.0
 */

/*
* 字段           作用
* code          接口编码（日志用，一般与枚举名一致）
* methodName    拼接 URL： baseurl + "/" + methodName ，也是按方法名查找的键
* name          接口名称（日志、报错提示用）
* desc          描述； 仅 WebService 类型 用它传 SOAPAction,方法名,命名空间 （逗号分隔），其他类型传 null
* method        请求方式： POST / GET / WebService / WebServiceMesCode ，决定走 ApiRequestUtils.java 的哪个分支
* module        所属模块：拼配置键 wms.{module}.baseurl ，同时决定返回值解析逻辑（ agv / mes 有专门处理，其余按 code=0 判断成功）
* paramsClass   参数 DTO 类：非空时请求前会做参数校验，无参数传 null
* */
@Getter
public enum ApiEnum {
    /**
     * AGV 1常用接口 1调度系统提供的接口
     */
    AGV_groupTask("AGV_groupTask", "api/robot/controller/task/group",
            "任务组接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvGroupTaskDTO")),

    AGV_submitTask("AGV_submitTask", "api/robot/controller/task/submit",
            "任务下发接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvSubmitTaskDTO")),

    AGV_continueTask("AGV_continueTask", "api/robot/controller/task/extend/continue",
            "任务继续执行接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvContinueTaskDTO")),

    AGV_cancelTask("AGV_cancelTask", "api/robot/controller/task/cancel",
            "任务取消接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvCancelTaskDTO")),

    AGV_priorityTask("AGV_priorityTask", "api/robot/controller/task/priority",
            "任务优先级设置接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvPriorityTaskDTO")),

    AGV_queryTask("AGV_queryTask", "api/robot/controller/task/query",
            "查询任务状态接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvQueryTaskDTO")),
// 20260805
    AGV_pauseZone("AGV_pauseZone", "api/robot/controller/zone/pause",
            "按区域暂停与恢复机器人接口 ", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvPauseZoneDTO")),

    AGV_homingZone("AGV_homingZone", "api/robot/controller/zone/homing", 
            "区域机器人归巢接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvHomingZoneDTO")),

    AGV_banishZone("AGV_banishZone", "api/robot/controller/zone/banish", 
            "区域驱离机器人接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvBanishZoneDTO")),

    AGV_blockadeZone("AGV_blockadeZone", "api/robot/controller/zone/blockade", 
            "区域封锁机器人接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvBlockadeZoneDTO")),

    AGV_bindCarrier("AGV_bindCarrier", "api/robot/controller/carrier/bind", 
            "载具与站点绑定接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvBindCarrierDTO")),

    AGV_unbindCarrier("AGV_unbindCarrier", "api/robot/controller/carrier/unbind", 
            "载具与站点解绑接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvUnbindCarrierDTO")),

    AGV_bindSite("AGV_bindSite", "/api/robot/controller/site/bind", 
            "存储对象与搬运对象绑定解绑接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvBindSiteDTO")),
    
    AGV_lockCarrier("AGV_lockCarrier", "/api/robot/controller/carrier/lock", 
            "载具禁用与启用接口 ", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvLockCarrierDTO")),

    AGV_lockSite("AGV_lockSite", "api/robot/controller/site/lock", 
            "站点禁用与启用", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvLockSiteDTO")),

    AGV_notifyEqpt("AGV_notifyEqpt", "api/robot/eqpt/notify", 
            "外设执行通知接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvNotifyEqptDTO")),
    
    AGV_preTask("AGV_preTask", "api/robot/controller/task/pretask", 
            "预调度任务下发接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvPreTaskDTO")),

    AGV_queryRobot("AGV_queryRobot", "api/robot/controller/robot/query", 
            "查询机器人状态接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvQueryRobotDTO")),
    
    AGV_queryCarrier("AGV_queryCarrier", "api/robot/controller/carrier/query", 
            "查询载具状态接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvQueryCarrierDTO")),

    /*
     * ===== 以下 8 项为 SPI 回调（RCS→WMS 入站方向），非 WMS 出站接口，不经 ApiEnum/commonRequest 调用 =====
     * 已迁移至入站控制器 RcsReporterController（前缀 /api/v1/rcs/reporter），
     * 使用 com.wms.rcs.model.dto 下的 Rcs*ReportDTO 承接，故从 ApiEnum 出站注册表中注释停用。
     * 保留注释以备回溯，如需恢复请一并恢复 com.wms.business.agv 下对应的占位 DTO。
     *
    AGV_bindReporter("AGV_bindReporter", "/api/robot/reporter/bind",
            "绑定解绑通知", null, "POST", "rcs", AgvBindReporterDTO.class),

    AGV_warningTask("AGV_warningTask", "/api/robot/reporter/task/warning",
            "任务异常告警上报接口", null, "POST", "rcs", AgvWarningTaskDTO.class),

    AGV_warningRobot("AGV_warningRobot", "/api/robot/reporter/robot/warning",
            "机器人异常告警上报接口", null, "POST", "rcs", AgvWarningRobotDTO.class),

    AGV_banishZoneReporter("AGV_banishZoneReporter", "/api/robot/reporter/zone/banish",
            "区域驱离机器人完成回馈接口", null, "POST", "rcs", AgvBanishZoneReporterDTO.class),

    AGV_homingZoneReporter("AGV_homingZoneReporter", "/api/robot/reporter/zone/homing",
            "机器人归巢完成回馈接口", null, "POST", "rcs", AgvHomingZoneReporterDTO.class),

    AGV_eqptReporter("AGV_eqptReporter", "/api/robot/reporter/eqpt",
            "请求外设接口", null, "POST", "rcs", AgvEqptReporterDTO.class),

    AGV_resourceReporter("AGV_resourceReporter", "/api/robot/reporter/resource",
            "请求资源接口", null, "POST", "rcs", AgvResourceReporterDTO.class),

    AGV_taskReporter("AGV_taskReporter", "/api/robot/reporter/task",
            "任务执行过程回馈接口", null, "POST", "rcs", AgvTaskReporterDTO.class),
     */

    AGV_notifyGbtEqpt("AGV_notifyGbtEqpt", "/spi/wcs/robot/eqpt/notifyGbt",
            "外设执行通知接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvNotifyGbtEqptDTO")),

    AGV_unbindMatlabel("AGV_unbindMatlabel", "/api/robot/controller/matlabel/unbind",
            "物料解绑接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvUnbindMatlabelDTO")),

    AGV_bindMatlabel("AGV_bindMatlabel", "/api/robot/controller/matlabel/bind",
            "物料绑定接口", null, "POST", "rcs", loadClass("com.wms.rcs.model.dto.request.AgvBindMatlabelDTO")),


    /**
     * MES常用接口
     */
;



    private final String code;
    private final String methodName;
    private final String name;
    private final String desc;
    private final String method;
    private final String module;
    private final Class paramsClass;

    ApiEnum(String code, String methodName, String name, String desc, String method, String module, Class paramsClass) {
        this.code = code;
        this.methodName = methodName;
        this.name = name;
        this.desc = desc;
        this.method = method;
        this.module = module;
        this.paramsClass = paramsClass;
    }

    public static ApiEnum getApiEnumByMethodName(String methodName) {
        for (ApiEnum e : ApiEnum.values()) {
            if (StringUtils.equals(e.getMethodName(), methodName)) {
                return e;
            }
        }
        throw new RuntimeException("未找到该接口：" + methodName);
    }

    public static ApiEnum getApiEnumByModuleAndMethodName(String module, String methodName) {
        for (ApiEnum e : ApiEnum.values()) {
            if (StringUtils.equals(e.getModule(), module) && StringUtils.equals(e.getMethodName(), methodName)) {
                return e;
            }
        }
        throw new RuntimeException("未找到该接口：" + methodName);
    }

    /**
     * 通过全限定类名加载参数校验 DTO（避免 common 层编译期依赖业务模块，改为运行期反射）
     */
    private static Class<?> loadClass(String className) {
        try {
            return Class.forName(className);
        } catch (ClassNotFoundException e) {
            return null;
        }
    }
}
