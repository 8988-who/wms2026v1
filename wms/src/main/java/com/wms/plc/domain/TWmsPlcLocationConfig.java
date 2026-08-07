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
 * <pre>
 * | plcId   | address     | arrIdx | landmarkCode    |
 * | line1   | DB2000.24   | 0      | 123456XY987654  |
 * | line1   | DB2000.24   | 1      | 789012XY345678  |
 * | line1   | DB2000.44   | 0      | 456789XY872934  |
 * </pre>
 *
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.business.plc.domain
 * @Author: YangZheng
 * @CreateTime: 2026-07-21
 * @Description: PLC信号地址 → 储位地标码映射
 * @Version: 1.0
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("t_plc_location_config")
public class TWmsPlcLocationConfig extends BaseEntity implements Serializable {

    private static final long serialVersionUID = 1L;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    @TableId(type = IdType.ASSIGN_ID)
    private String id;

    @ApiModelProperty(value = "关联PLC ID")
    private String plcId;

    @ApiModelProperty(value = "S7信号地址")
    private String address;

    @ApiModelProperty(value = "数组下标（0-based）")
    private Integer arrIdx;

    @ApiModelProperty(value = "储位地标码")
    private String landmarkCode;

    @ApiModelProperty(value = "AGV任务编号")
    private String agvTaskCode;

    @ApiModelProperty(value = "当前信号")
    private Integer triggerValue;

    @ApiModelProperty(value = "备注")
    private String remark;
}
