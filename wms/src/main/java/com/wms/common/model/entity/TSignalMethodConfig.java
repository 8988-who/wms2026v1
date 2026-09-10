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
 * @Description: plc信号值方法配置
 * @Param:
 * @return:
 */
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("t_signal_method_config")
public class TSignalMethodConfig implements Serializable {

  private static final long serialVersionUID = 1L;

  @JsonFormat(shape = JsonFormat.Shape.STRING)
  @TableId(type = IdType.ASSIGN_ID)
  private String id;

  @Schema(description = "信号块id")
  private String signalId;

  @Schema(description = "信号值")
  private String signalCode;

  @Schema(description = "方法id")
  private String methodId;

}
