package com.wms.common.enums;

import com.baomidou.mybatisplus.core.toolkit.StringUtils;
import com.wms.rcs.model.dto.AgvRequestDTO;
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
            "任务组接口", null, "POST", "rcs", null),

    AGV_submitTask("AGV_submitTask", "api/robot/controller/task/submit",
            "任务下发接口", null, "POST", "rcs", null),

    AGV_continueTask("AGV_continueTask", "api/robot/controller/task/extend/continue",
            "任务继续执行接口", null, "POST", "rcs", AgvRequestDTO.class),

    AGV_cancelTask("AGV_cancelTask", "api/robot/controller/task/cancel",
            "任务取消接口", null, "POST", "rcs", AgvRequestDTO.class),

    AGV_priorityTask("AGV_priorityTask", "api/robot/controller/task/priority",
            "任务优先级设置接口", null, "POST", "rcs", AgvRequestDTO.class),

    AGV_queryTask("AGV_queryTask", "api/robot/controller/task/query",
            "查询任务状态接口", null, "POST", "rcs", null),
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
}
