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
* @Description: 方法名配置
* @Param:
* @return:
*/
@Data
@EqualsAndHashCode(callSuper = false)
@TableName("t_task_method_name")
public class TTaskMethodName implements Serializable {

  private static final long serialVersionUID = 1L;

  @JsonFormat(shape = JsonFormat.Shape.STRING)
  @TableId(type = IdType.ASSIGN_ID)
  private String id;

  @Schema(description = "方法名")
  private String methodName;

  @Schema(description = "方法描述")
  private String methodDescription;
}
