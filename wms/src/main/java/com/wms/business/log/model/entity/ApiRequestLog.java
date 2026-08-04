package com.wms.business.log.model.entity;

import com.baomidou.mybatisplus.annotation.FieldFill;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableName;
import com.wms.common.base.BaseEntity;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonInclude;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;
import org.apache.ibatis.type.JdbcType;

import java.time.LocalDateTime;

/**
 * 接口请求日志对象
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Data
@TableName("api_request_log")
@EqualsAndHashCode(callSuper = true)
@Schema(description = "接口请求日志实体")
public class ApiRequestLog extends BaseEntity {

    @Schema(description = "接口编码")
    private String apiCode;

    @Schema(description = "接口方法名")
    private String apiMethodName;

    @Schema(description = "接口地址")
    private String apiUrl;

    @Schema(description = "接口名称")
    private String apiName;

    @Schema(description = "请求参数")
    @TableField(jdbcType = JdbcType.CLOB)
    private String reqParams;

    @Schema(description = "返回参数")
    @TableField(jdbcType = JdbcType.CLOB)
    private String resParams;

    @Schema(description = "是否成功")
    private String isSuccess;

    @Schema(description = "错误信息")
    private String errMsg;

    @Schema(description = "所属模块")
    private String module;

    @Schema(description = "请求时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime reqTime;

    @Schema(description = "返回时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime resTime;

    @Schema(description = "http状态码")
    private String httpCode;

    @Schema(description = "返回状态码")
    private String resCode;

    @Schema(description = "耗时（毫秒）")
    private Long duration;

    @Schema(description = "重试次数")
    private Integer retryCount;

    @Schema(description = "链路追踪ID")
    private String traceId;

    @Schema(description = "创建人ID")
    @TableField(value = "created_by", fill = FieldFill.INSERT)
    private Long createBy;

    @Schema(description = "创建人名称")
    private String createName;

    @Schema(description = "创建时间")
    @TableField(value = "created_time", fill = FieldFill.INSERT)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @Schema(description = "更新人ID")
    @TableField(value = "updated_by", fill = FieldFill.INSERT_UPDATE)
    private Long updateBy;

    @Schema(description = "更新人名称")
    private String updateName;

    @Schema(description = "更新时间")
    @TableField(value = "updated_time", fill = FieldFill.INSERT_UPDATE)
    @JsonInclude(value = JsonInclude.Include.NON_NULL)
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    @Schema(description = "备注")
    private String remark;

}
