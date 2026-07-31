package com.wms.business.log.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import org.apache.ibatis.type.JdbcType;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Date;

/**
 * 接口请求日志对象 t_wms_api_request_log
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Data
@TableName("t_wms_api_request_log")
@Schema(description = "接口请求日志实体")
public class TWmsApiRequestLog implements Serializable {
    private static final long serialVersionUID = 1L;

    @Schema(description = "主键ID")
    @JsonFormat(shape = JsonFormat.Shape.STRING) // 转化成String传到前端
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

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
    private Date reqTime;

    @Schema(description = "返回时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date resTime;

    @Schema(description = "http状态码")
    private String httpCode;

    @Schema(description = "返回状态码")
    private String resCode;

    @Schema(description = "创建人ID")
    private String createBy;

    @Schema(description = "创建人名称")
    private String createName;

    @Schema(description = "创建时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createTime;

    @Schema(description = "更新人ID")
    private String updateBy;

    @Schema(description = "更新人名称")
    private String updateName;

    @Schema(description = "更新时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updateTime;

    @Schema(description = "备注")
    private String remark;

}
