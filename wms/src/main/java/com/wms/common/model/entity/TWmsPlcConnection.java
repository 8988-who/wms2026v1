package com.wms.common.model.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import lombok.EqualsAndHashCode;

import java.io.Serializable;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.model.entity
 * @Author: 邵煜晨
 * @CreateTime: 2026-09-01 10:26
 * @Description: plc连接配置实体类
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("t_plc_connection")
public class TWmsPlcConnection implements Serializable {
    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @Schema(description = "连接名称")
    private String name;

    @Schema(description = "PLC IP 地址")
    private String host;

    @Schema(description = "PLC 类型: S1200 / S1500 / S300 / S400 / S200_SMART")
    private String plcType;

    @Schema(description = "机架号")
    private Integer rack;

    @Schema(description = "槽位号")
    private Integer slot;

    @Schema(description = "是否启用: 1=启用 0=禁用")
    private Integer enabled;

    @Schema(description = "心跳地址")
    private String heartbeatAddr;
}
