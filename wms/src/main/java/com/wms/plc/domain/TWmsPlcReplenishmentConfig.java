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
 * PLC 信号 → 补料和送货参数映射配置
 * <p>
 * 键为 PLC 信号地址（如 DB2000.24），
 * 对应该地址触发时要执行的补料任务参数。
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.domain
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC补料映射
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_plc_replenishment_config")
public class TWmsPlcReplenishmentConfig extends BaseEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @ApiModelProperty(value = "关联PLC ID")
    private String plcId;

    @ApiModelProperty(value = "S7信号地址")
    private String address;

    @ApiModelProperty(value = "触发值")
    private Integer triggerValue;

    @ApiModelProperty(value = "库区id")
    private String areaId;

    @ApiModelProperty(value = "上线类型")
    private String onlineType;

    @ApiModelProperty(value = "物料型号编码")
    private String itemModelCode;

    @ApiModelProperty(value = "补料数量")
    private Integer quantity;

    @ApiModelProperty(value = "是否启用: 1=启用 0=禁用")
    private Integer enabled;

    @ApiModelProperty(value = "备注")
    private String remark;
}
