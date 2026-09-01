package com.wms.rcs.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.wms.common.annotation.Log;
import com.wms.common.constant.RcsConstants;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.rcs.enums.RcsApiEnum;
import com.wms.rcs.model.dto.callback.RcsBanishReportDTO;
import com.wms.rcs.model.dto.callback.RcsBindReportDTO;
import com.wms.rcs.model.dto.callback.RcsEqptReportDTO;
import com.wms.rcs.model.dto.callback.RcsHomingReportDTO;
import com.wms.rcs.model.dto.callback.RcsResourceReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskReportDTO;
import com.wms.rcs.model.dto.callback.RcsTaskWarningDTO;
import com.wms.rcs.service.RcsBindService;
import com.wms.rcs.service.RcsTaskService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.HashMap;
import java.util.Map;

/**
 * RCS 回调入站接口控制器（反向链路，单一入口 + 枚举路由）
 * <p>
 * 接收外部 RCS 系统主动回馈，按 {@link RcsApiEnum} 路由分发到对应处理逻辑：
 * <ul>
 *     <li>{@code /task}：任务执行过程回馈（对应 RCS 出站接口 AGV_taskReporter），按阶段/状态映射本地 6 态；</li>
 *     <li>{@code /task/warning}：任务异常告警（对应 AGV_warningTask），流转为"异常"并记录告警；</li>
 *     <li>{@code /robot/warning}：机器人告警（对应 AGV_warningRobot），当前仅落日志。</li>
 *     <li>{@code /resource}：请求资源分配（对应 AGV_resourceReporter），需在 data 中返回分配的资源，当前为占位实现。</li>
 *     <li>{@code /eqpt}：请求外设控制（对应 AGV_eqptReporter），当前仅落日志。</li>
 *     <li>{@code /zone/homing}：机器人归巢完成回馈（对应 AGV_homingZoneReporter），当前仅落日志。</li>
 *     <li>{@code /zone/banish}：区域驱离完成回馈（对应 AGV_banishZoneReporter），当前仅落日志。</li>
 *     <li>{@code /bind}：绑定解绑通知（对应 AGV_bindReporter），记台账并纯本地同步
 *         cart_inventory 绑定状态（RCS 事实为权威，不回环调 AGV 接口），异常回失败码触发重试。</li>
 * </ul>
 * </p>
 * <p>
 * <b>鉴权说明</b>：本组接口由外部 RCS 调用，<b>暂不纳入前台 {@code @ss} 权限</b>。需在安全放行清单
 * （配置项 {@code security.ignore-urls} 或 {@code security.unsecured-urls}）中放行
 * {@code /api/robot/reporter/**}。后续接入生产时应改为独立 token / 来源 IP 白名单校验
 * （见下方 TODO），与前台鉴权隔离。
 * </p>
 * <p>
 * <b>响应约定</b>：按厂商 SPI 回调文档返回 {@code {"code":"SUCCESS","message":"成功","data":{"extra":null}}}，
 * RCS 读取 code 判定受理结果，非 SUCCESS 触发其重试。处理异常时回非 SUCCESS（见 replyFailure），
 * 数据性问题（点位/料车未匹配）落台账仍回 SUCCESS（重试无意义）。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-07
 */
@Tag(name = "RCS回调入站接口")
@RestController
@RequestMapping("/api/robot/reporter")
@RequiredArgsConstructor
@Slf4j
public class RcsReporterController {

    private final RcsTaskService rcsTaskService;
    private final RcsBindService rcsBindService;
    /** 手动创建的 Jackson 转换器（项目以 fastjson2 为默认 JSON 转换器，容器中无 ObjectMapper Bean），
     *  用于 Map → 回调 DTO 的转换（DTO 使用 Jackson 注解 @JsonProperty/@JsonAlias） */
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();

    // TODO 接入生产前补充回调鉴权：校验固定 token（请求头 X-lr-* 或独立密钥）或来源 IP 白名单

    /**
     * 回调单一入口：按 {@link RcsApiEnum} 按路径路由分发，统一响应/异常兜底/头回显。
     */
    @Operation(summary = "RCS回调统一入口")
    @PostMapping("/**")
    @Log(module = LogModuleEnum.RCS_TASK, value = ActionTypeEnum.OTHER)
    public Map<String, Object> handle(HttpServletRequest request, HttpServletResponse response,
                                      @RequestBody(required = false) Map<String, Object> body) {
        // 1. 提取并归一化请求路径（剥离 contextPath，兼容双倍路径）
        String uri = request.getRequestURI();
        String path = request.getContextPath() == null ? uri
                : uri.substring(request.getContextPath().length());
        RcsApiEnum api = RcsApiEnum.fromPath(path);
        if (api == RcsApiEnum.UNKNOWN) {
            log.warn("收到未识别的RCS回调：path={}, body={}", path, body);
            return replyFailure("未识别的回调路径：" + path, response);
        }
        try {
            switch (api) {
                case TASK_REPORTER: {
                    RcsTaskReportDTO report = convert(body, RcsTaskReportDTO.class);
                    log.info("收到RCS任务执行回馈：{}", report);
                    rcsTaskService.handleTaskReport(report);
                    return reply(true, response);
                }
                case TASK_WARNING: {
                    RcsTaskWarningDTO warning = convert(body, RcsTaskWarningDTO.class);
                    log.warn("收到RCS任务异常告警：{}", warning);
                    rcsTaskService.handleTaskWarning(warning);
                    return reply(true, response);
                }
                case ROBOT_WARNING: {
                    // 机器人告警与具体任务无强绑定，当前仅落日志（后续可扩展为设备告警台账/通知）
                    log.warn("收到RCS机器人异常告警：{}", body);
                    return reply(true, response);
                }
                case RESOURCE_REPORT: {
                    RcsResourceReportDTO report = convert(body, RcsResourceReportDTO.class);
                    log.info("收到RCS请求资源分配：{}", report);
                    // TODO 接入库位/载具分配业务：按 applyType/resourceType 计算并返回可用资源
                    //  当前为占位实现——原样回显 RCS 申请的资源，保证联调链路通畅，不做实际分配决策
                    Map<String, Object> data = new HashMap<>(4);
                    data.put("type", report.getResourceType());
                    data.put("code", report.getResourceCode());
                    return replyWithData(data, response);
                }
                case EQPT_REPORT: {
                    RcsEqptReportDTO report = convert(body, RcsEqptReportDTO.class);
                    // TODO 接入外设（电梯/门禁等）控制：按 method 驱动外设并在到位后回调 RCS 外设执行通知接口
                    log.info("收到RCS请求外设控制：{}", report);
                    return reply(true, response);
                }
                case HOMING_REPORT: {
                    RcsHomingReportDTO report = convert(body, RcsHomingReportDTO.class);
                    // TODO 接入区域归巢台账：按 homingCode 更新归巢指令状态，处理仍在工作的机器人
                    log.info("收到RCS机器人归巢完成回馈：{}", report);
                    return reply(true, response);
                }
                case BANISH_REPORT: {
                    RcsBanishReportDTO report = convert(body, RcsBanishReportDTO.class);
                    // TODO 接入区域驱离台账：按 banishCode 更新驱离指令状态，FAIL 时告警仍停留的机器人
                    log.info("收到RCS区域驱离完成回馈：{}", report);
                    return reply(true, response);
                }
                case BIND_REPORTER: {
                    RcsBindReportDTO report = convert(body, RcsBindReportDTO.class);
                    // 绑定事实以 RCS 为权威：记台账（reqCode 幂等）+ 纯本地同步 cart_inventory，
                    // 不回环调 AGV 绑定/解绑接口；程序异常回失败码触发 RCS 重试（区别于 task 回调的总是成功）
                    log.info("收到RCS绑定解绑通知：{}", report);
                    rcsBindService.handleBindReport(report);
                    return reply(true, response);
                }
                default:
                    return replyFailure("未支持的RCS回调：" + api.getCode(), response);
            }
        } catch (Exception e) {
            log.error("RCS回调处理失败：path={}, body={}", path, body, e);
            return replyFailure("处理失败，请重试", response);
        }
    }

    /**
     * Map → 强类型 DTO（Jackson convertValue，保留 @JsonProperty/@JsonAlias 字段映射）
     */
    private <T> T convert(Map<String, Object> body, Class<T> clazz) {
        return OBJECT_MAPPER.convertValue(body == null ? new HashMap<>(0) : body, clazz);
    }

    /**
     * 构造 RCS 期望的回馈响应体。
     * <p>按厂商接口文档 SPI 回调约定：{@code {"code":"SUCCESS","message":"成功","data":{"extra":null}}}。
     * RCS 会读取 code 判定回调受理结果，非 SUCCESS 会触发其重试；
     * 无论是否匹配到本地任务，均返回成功（数据性问题已在 Service 层落台账），避免重试风暴。</p>
     */
    private Map<String, Object> reply(boolean matched, HttpServletResponse response) {
        return reply(matched, null, response);
    }

    /**
     * 构造 RCS 期望的回馈响应体（附带处理结果说明）
     */
    private Map<String, Object> reply(boolean matched, String message, HttpServletResponse response) {
        setRcsHeaders(response);
        Map<String, Object> resp = new HashMap<>(4);
        resp.put("code", "SUCCESS");
        resp.put("message", message != null ? message : "成功");
        Map<String, Object> data = new HashMap<>(2);
        data.put("extra", null);
        resp.put("data", data);
        return resp;
    }

    /**
     * 构造失败响应体（code 非 SUCCESS，触发 RCS 侧重试；具体错误码取值以联调为准）
     */
    private Map<String, Object> replyFailure(String message, HttpServletResponse response) {
        setRcsHeaders(response);
        Map<String, Object> resp = new HashMap<>(4);
        resp.put("code", "FAIL");
        resp.put("message", message);
        return resp;
    }

    /**
     * 构造带业务数据的 RCS 回馈响应体（用于请求资源等需要返回 data 的回调）。
     */
    private Map<String, Object> replyWithData(Map<String, Object> data, HttpServletResponse response) {
        setRcsHeaders(response);
        Map<String, Object> resp = new HashMap<>(4);
        resp.put("code", "SUCCESS");
        resp.put("message", "成功");
        resp.put("data", data);
        return resp;
    }

    /**
     * 回显 RCS 请求头到响应头（X-lr-request-id / X-lr-trace-id / X-lr-version）
     */
    private void setRcsHeaders(HttpServletResponse response) {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null) {
            return;
        }
        var request = attrs.getRequest();
        String requestId = request.getHeader(RcsConstants.HEADER_REQUEST_ID);
        if (requestId != null) {
            response.setHeader(RcsConstants.HEADER_REQUEST_ID, requestId);
        }
        String traceId = request.getHeader(RcsConstants.HEADER_TRACE_ID);
        if (traceId != null) {
            response.setHeader(RcsConstants.HEADER_TRACE_ID, traceId);
        }
        String version = request.getHeader(RcsConstants.HEADER_VERSION);
        if (version != null) {
            response.setHeader(RcsConstants.HEADER_VERSION, version);
        }
    }
}
