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
@TableName("t_plc_sector_signals")
public class TPlcSectorSignals implements Serializable {
    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @Schema(description = "信号类型")
    private Integer signalType;

    @Schema(description = "信号地址")
    private String signalAddress;

    @Schema(description = "信号描述")
    private String signalDescription;

    @Schema(description = "信号块id")
    private String signalId;

    @Schema(description = "排序号") 
    private Integer number;

}
