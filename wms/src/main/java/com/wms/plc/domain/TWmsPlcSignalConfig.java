package com.wms.business.plc.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.wms.common.core.domain.BaseEntity;
import io.swagger.annotations.ApiModelProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

/**
 * PLC 信号监听配置实体
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.domain
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC信号监听配置
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_plc_signal_config")
public class TWmsPlcSignalConfig extends BaseEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @ApiModelProperty(value = "关联PLC ID")
    private String plcId;

    @ApiModelProperty(value = "PLC信号地址（读取）")
    private String plcAddress;

    @ApiModelProperty(value = "MES信号地址（写入-正常）")
    private String mesAddress;

    @ApiModelProperty(value = "异常信号地址（写入-异常）")
    private String exceptionAddress;

    @ApiModelProperty(value = "Handler Bean名称")
    private String handler;

    @ApiModelProperty(value = "信号描述")
    private String description;

    @ApiModelProperty(value = "是否启用: 1=启用 0=禁用")
    private Integer enabled;

    @ApiModelProperty(value = "排序")
    private Integer sort;
}
