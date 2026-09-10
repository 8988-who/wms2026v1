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
 * @CreateTime: 2026-09-01 11:24
 * @Description: PLC信号块配置表
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("t_plc_signal_config")
public class TWmsPlcSignalConfig implements Serializable {
    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @Schema(description = "关联PLC ID")
    private String plcId;

    @Schema(description = "PLC信号地址（读取）")
    private String plcAddress;

    @Schema(description = "信号描述")
    private String description;

    @Schema(description = "是否启用: 1=启用 0=禁用")
    private Integer enabled;

    @Schema(description = "储位id")
    private String pointId;
}
