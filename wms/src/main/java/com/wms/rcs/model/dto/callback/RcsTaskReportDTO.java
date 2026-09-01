package com.wms.rcs.model.dto.callback;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonProperty;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;

import java.io.Serializable;
import java.util.Map;

/**
 * RCS 任务执行过程回馈请求体（入站）
 * <p>
 * 对应 RCS 主动回调 {@code POST /api/robot/reporter/task}（RCS 侧接口 AGV_taskReporter）。
 * RCS-2000 V4.x 实际回调格式：
 * <ul>
 *     <li>任务标识：{@code robotTaskCode}（RCS 下发时返回的任务编号），映射到 {@code taskId}（反查 rcsTaskId）；</li>
 *     <li>执行AGV：{@code singleRobotCode}，映射到 {@code agvCode}；</li>
 *     <li>动作/阶段：嵌套在 {@code extra.values.method} 中（如 notifyPodArr/notifyPodLeav），
 *         通过 {@link #resolveMethod()} 统一提取；</li>
 *     <li>无顶层 status 字段，状态语义完全由 method 表达。</li>
 * </ul>
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-07
 */
@Data
@Schema(description = "RCS任务执行回馈请求体")
public class RcsTaskReportDTO implements Serializable {

    private static final long serialVersionUID = 1L;

    /** 请求编号（RCS 可空） */
    @Schema(description = "请求编号（可空）")
    private String reqCode;

    /** WMS任务编号（部分 RCS 版本可能在顶层回传，作为首选反查键） */
    @Schema(description = "WMS任务编号（部分版本回传）")
    private String taskCode;

    /** RCS任务编号（robotTaskCode，映射到本地 rcsTaskId 反查） */
    @JsonProperty("robotTaskCode")
    @JsonAlias({"taskId"})
    @Schema(description = "RCS任务编号（robotTaskCode）")
    private String taskId;

    /** 顶层 method（部分版本使用，RCS-2000 V4.x 嵌套在 extra.values.method 中） */
    @Schema(description = "回馈动作/阶段（顶层，部分版本使用）")
    private String method;

    /** 回馈状态（数值语义，RCS-2000 V4.x 不发送此字段） */
    @Schema(description = "回馈状态码（部分版本使用）")
    private Integer status;

    /** 执行AGV编号（RCS字段名 singleRobotCode） */
    @JsonProperty("singleRobotCode")
    @JsonAlias("agvCode")
    @Schema(description = "执行AGV编号（singleRobotCode）")
    private String agvCode;

    /** 附加信息/备注 */
    @Schema(description = "附加信息")
    private String message;

    /** 扩展字段（含 async、values，method 嵌套在 values 中） */
    @Schema(description = "扩展字段（含async、values，method嵌套在values中）")
    private Map<String, Object> extra;

    /**
     * 从 extra.values 中提取指定字段值。
     */
    @Schema(hidden = true)
    public String getExtraValue(String key) {
        if (extra == null) {
            return null;
        }
        Object values = extra.get("values");
        if (values instanceof Map) {
            Object val = ((Map<?, ?>) values).get(key);
            return val != null ? val.toString() : null;
        }
        return null;
    }

    /**
     * 获取 method：优先顶层 method，其次 extra.values.method。
     */
    @Schema(hidden = true)
    public String resolveMethod() {
        if (method != null && !method.isBlank()) {
            return method;
        }
        return getExtraValue("method");
    }
}
