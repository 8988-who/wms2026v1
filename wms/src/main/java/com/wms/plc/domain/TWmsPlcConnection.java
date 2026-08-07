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
 * PLC 连接配置实体
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.domain
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC连接配置
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_plc_connection")
public class TWmsPlcConnection extends BaseEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @ApiModelProperty(value = "连接名称")
    private String name;

    @ApiModelProperty(value = "PLC IP 地址")
    private String host;

    @ApiModelProperty(value = "PLC 类型: S1200 / S1500 / S300 / S400 / S200_SMART")
    private String plcType;

    @ApiModelProperty(value = "机架号")
    private Integer rack;

    @ApiModelProperty(value = "槽位号")
    private Integer slot;

    @ApiModelProperty(value = "是否启用: 1=启用 0=禁用")
    private Integer enabled;

    @ApiModelProperty(value = "心跳地址")
    private String heartbeatAddr;
}
