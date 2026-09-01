package com.wms.rcs.enums;

import com.wms.rcs.model.dto.callback.RcsBanishReportDTO;
import com.wms.rcs.model.dto.callback.RcsBindReportDTO;
import com.wms.rcs.model.dto.callback.RcsEqptReportDTO;
import com.wms.rcs.model.dto.callback.RcsHomingReportDTO;
import com.wms.rcs.model.dto.callback.RcsResourceReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskWarningDTO;
import com.wms.rcs.model.dto.request.AgvBanishZoneDTO;
import com.wms.rcs.model.dto.request.AgvBindCarrierDTO;
import com.wms.rcs.model.dto.request.AgvBindMatlabelDTO;
import com.wms.rcs.model.dto.request.AgvBindSiteDTO;
import com.wms.rcs.model.dto.request.AgvBlockadeZoneDTO;
import com.wms.rcs.model.dto.request.AgvCancelTaskDTO;
import com.wms.rcs.model.dto.request.AgvContinueTaskDTO;
import com.wms.rcs.model.dto.request.AgvGroupTaskDTO;
import com.wms.rcs.model.dto.request.AgvHomingZoneDTO;
import com.wms.rcs.model.dto.request.AgvLockCarrierDTO;
import com.wms.rcs.model.dto.request.AgvLockSiteDTO;
import com.wms.rcs.model.dto.request.AgvNotifyEqptDTO;
import com.wms.rcs.model.dto.request.AgvNotifyGbtEqptDTO;
import com.wms.rcs.model.dto.request.AgvPauseZoneDTO;
import com.wms.rcs.model.dto.request.AgvPreTaskDTO;
import com.wms.rcs.model.dto.request.AgvPriorityTaskDTO;
import com.wms.rcs.model.dto.request.AgvQueryCarrierDTO;
import com.wms.rcs.model.dto.request.AgvQueryRobotDTO;
import com.wms.rcs.model.dto.request.AgvQueryTaskDTO;
import com.wms.rcs.model.dto.request.AgvSubmitTaskDTO;
import com.wms.rcs.model.dto.request.AgvUnbindCarrierDTO;
import com.wms.rcs.model.dto.request.AgvUnbindMatlabelDTO;
import lombok.Getter;

/**
 * RCS 接口统一注册表
 * <p>
 * 统一管理 RCS 全部接口元数据（出站 + 入站），单一事实来源：
 * <ul>
 *     <li><b>出站（OUTBOUND）</b>：WMS 主动调 RCS，path 为相对路径，调用时拼接 {@code wms.rcs.baseurl}；</li>
 *     <li><b>入站（INBOUND）</b>：RCS 主动回调 WMS，path 为完整路径，由 {@link } 单一入口按路径路由。</li>
 * </ul>
 * 出站接口编码沿用 {@code AGV_xxx} 命名，与通用调试入口 {@code /api/v1/agv/commonRequest/{methodName}} 兼容。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-31
 */
@Getter
public enum RcsApiEnum {

    // ============================ 出站（WMS→RCS） ============================

    GROUP_TASK("AGV_groupTask", "api/robot/controller/task/group", "POST", Direction.OUTBOUND, AgvGroupTaskDTO.class),
    SUBMIT_TASK("AGV_submitTask", "api/robot/controller/task/submit", "POST", Direction.OUTBOUND, AgvSubmitTaskDTO.class),
    CONTINUE_TASK("AGV_continueTask", "api/robot/controller/task/extend/continue", "POST", Direction.OUTBOUND, AgvContinueTaskDTO.class),
    CANCEL_TASK("AGV_cancelTask", "api/robot/controller/task/cancel", "POST", Direction.OUTBOUND, AgvCancelTaskDTO.class),
    PRIORITY_TASK("AGV_priorityTask", "api/robot/controller/task/priority", "POST", Direction.OUTBOUND, AgvPriorityTaskDTO.class),
    QUERY_TASK("AGV_queryTask", "api/robot/controller/task/query", "POST", Direction.OUTBOUND, AgvQueryTaskDTO.class),
    PAUSE_ZONE("AGV_pauseZone", "api/robot/controller/zone/pause", "POST", Direction.OUTBOUND, AgvPauseZoneDTO.class),
    HOMING_ZONE("AGV_homingZone", "api/robot/controller/zone/homing", "POST", Direction.OUTBOUND, AgvHomingZoneDTO.class),
    BANISH_ZONE("AGV_banishZone", "api/robot/controller/zone/banish", "POST", Direction.OUTBOUND, AgvBanishZoneDTO.class),
    BLOCKADE_ZONE("AGV_blockadeZone", "api/robot/controller/zone/blockade", "POST", Direction.OUTBOUND, AgvBlockadeZoneDTO.class),
    BIND_CARRIER("AGV_bindCarrier", "api/robot/controller/carrier/bind", "POST", Direction.OUTBOUND, AgvBindCarrierDTO.class),
    UNBIND_CARRIER("AGV_unbindCarrier", "api/robot/controller/carrier/unbind", "POST", Direction.OUTBOUND, AgvUnbindCarrierDTO.class),
    BIND_SITE("AGV_bindSite", "api/robot/controller/site/bind", "POST", Direction.OUTBOUND, AgvBindSiteDTO.class),
    LOCK_CARRIER("AGV_lockCarrier", "api/robot/controller/carrier/lock", "POST", Direction.OUTBOUND, AgvLockCarrierDTO.class),
    LOCK_SITE("AGV_lockSite", "api/robot/controller/site/lock", "POST", Direction.OUTBOUND, AgvLockSiteDTO.class),
    NOTIFY_EQPT("AGV_notifyEqpt", "api/robot/eqpt/notify", "POST", Direction.OUTBOUND, AgvNotifyEqptDTO.class),
    PRE_TASK("AGV_preTask", "api/robot/controller/task/pretask", "POST", Direction.OUTBOUND, AgvPreTaskDTO.class),
    QUERY_ROBOT("AGV_queryRobot", "api/robot/controller/robot/query", "POST", Direction.OUTBOUND, AgvQueryRobotDTO.class),
    QUERY_CARRIER("AGV_queryCarrier", "api/robot/controller/carrier/query", "POST", Direction.OUTBOUND, AgvQueryCarrierDTO.class),
    NOTIFY_GBT_EQPT("AGV_notifyGbtEqpt", "/spi/wcs/robot/eqpt/notifyGbt", "POST", Direction.OUTBOUND, AgvNotifyGbtEqptDTO.class),
    UNBIND_MATLABEL("AGV_unbindMatlabel", "api/robot/controller/matlabel/unbind", "POST", Direction.OUTBOUND, AgvUnbindMatlabelDTO.class),
    BIND_MATLABEL("AGV_bindMatlabel", "api/robot/controller/matlabel/bind", "POST", Direction.OUTBOUND, AgvBindMatlabelDTO.class),

    // ============================ 入站（RCS→WMS 回调） ============================

    TASK_REPORTER("AGV_taskReporter", "/api/robot/reporter/task", "POST", Direction.INBOUND, RcsTaskReportDTO.class),
    TASK_WARNING("AGV_warningTask", "/api/robot/reporter/task/warning", "POST", Direction.INBOUND, RcsTaskWarningDTO.class),
    ROBOT_WARNING("AGV_warningRobot", "/api/robot/reporter/robot/warning", "POST", Direction.INBOUND, null),
    BIND_REPORTER("AGV_bindReporter", "/api/robot/reporter/bind", "POST", Direction.INBOUND, RcsBindReportDTO.class),
    RESOURCE_REPORT("AGV_resourceReporter", "/api/robot/reporter/resource", "POST", Direction.INBOUND, RcsResourceReportDTO.class),
    EQPT_REPORT("AGV_eqptReporter", "/api/robot/reporter/eqpt", "POST", Direction.INBOUND, RcsEqptReportDTO.class),
    HOMING_REPORT("AGV_homingZoneReporter", "/api/robot/reporter/zone/homing", "POST", Direction.INBOUND, RcsHomingReportDTO.class),
    BANISH_REPORT("AGV_banishZoneReporter", "/api/robot/reporter/zone/banish", "POST", Direction.INBOUND, RcsBanishReportDTO.class),

    /** 未匹配到任何已知接口 */
    UNKNOWN(null, null, null, null, null);

    /** 接口编码（日志用，出站沿用 AGV_xxx 命名，与 ApiEnum 对齐） */
    private final String code;

    /** 相对/完整路径（出站相对路径拼接 baseurl；入站完整路径用于路由匹配） */
    private final String path;

    /** 请求方式：POST / GET */
    private final String method;

    /** 方向：出站 / 入站 */
    private final Direction direction;

    /** 参数 DTO 类（入站 ROBOT_WARNING 用 null，承接原始 Map） */
    private final Class<?> paramsClass;

    /** 接口方向 */
    public enum Direction {
        /** 出站：WMS 主动调 RCS */
        OUTBOUND,
        /** 入站：RCS 主动回调 WMS */
        INBOUND
    }

    RcsApiEnum(String code, String path, String method, Direction direction, Class<?> paramsClass) {
        this.code = code;
        this.path = path;
        this.method = method;
        this.direction = direction;
        this.paramsClass = paramsClass;
    }

    /**
     * 按接口编码查找（大小写不敏感），未匹配返回 {@link #UNKNOWN}。
     *
     * @param code 接口编码（如 "AGV_submitTask"）
     */
    public static RcsApiEnum fromCode(String code) {
        if (code == null || code.isBlank()) {
            return UNKNOWN;
        }
        for (RcsApiEnum e : values()) {
            if (e != UNKNOWN && e.code != null && e.code.equalsIgnoreCase(code.trim())) {
                return e;
            }
        }
        return UNKNOWN;
    }

    /**
     * 按路径查找（入站回调路由用，兼容双倍路径归一化），未匹配返回 {@link #UNKNOWN}。
     *
     * @param path 请求 URI（不含 contextPath）
     */
    public static RcsApiEnum fromPath(String path) {
        if (path == null || path.isBlank()) {
            return UNKNOWN;
        }
        String p = path.trim();
        // 1. 完整路径精确匹配
        for (RcsApiEnum e : values()) {
            if (e != UNKNOWN && e.path != null && e.path.equals(p)) {
                return e;
            }
        }
        // 2. 归一化：循环剥离 /api/robot/reporter 前缀（兼容平台把注册地址重复拼接成双倍路径），忽略尾部斜杠
        String prefix = "/api/robot/reporter";
        String suffix = p;
        while (suffix.startsWith(prefix + "/")) {
            suffix = suffix.substring(prefix.length());
        }
        if (suffix.length() > 1 && suffix.endsWith("/")) {
            suffix = suffix.substring(0, suffix.length() - 1);
        }
        // 3. 按接口后缀匹配（/api/robot/reporter/task 归一化为 /task）
        for (RcsApiEnum e : values()) {
            if (e != UNKNOWN && e.path != null && e.path.startsWith(prefix)
                    && e.path.substring(prefix.length()).equals(suffix)) {
                return e;
            }
        }
        return UNKNOWN;
    }
}
