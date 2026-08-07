package com.wms.rcs.utils;

import com.wms.rcs.enums.RcsTaskPriorityEnum;
import com.wms.rcs.enums.RcsTaskStatusEnum;
import com.wms.rcs.enums.RcsTaskTypeEnum;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.entity.RcsTaskLifecycleEntity;
import com.wms.rcs.model.vo.RcsTaskLifecycleVO;
import com.wms.rcs.model.vo.RcsTaskVO;
import org.mapstruct.AfterMapping;
import org.mapstruct.Mapper;
import org.mapstruct.MappingTarget;

/**
 * RCS任务对象转换器
 * <p>
 * 基于 MapStruct 实现任务实体与 DTO/VO 之间的转换，并在映射后补齐状态/类型/优先级的中文描述。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
@Mapper(componentModel = "spring")
public interface RcsTaskConverter {

    RcsTaskDTO toDTO(RcsTaskEntity entity);

    RcsTaskEntity toEntity(RcsTaskDTO dto);

    RcsTaskVO toVO(RcsTaskEntity entity);

    RcsTaskLifecycleVO toLifecycleVO(RcsTaskLifecycleEntity entity);

    /**
     * 补齐任务 VO 的枚举描述字段
     */
    @AfterMapping
    default void fillTaskLabels(RcsTaskEntity entity, @MappingTarget RcsTaskVO vo) {
        vo.setTaskTypeLabel(RcsTaskTypeEnum.getLabelByValue(entity.getTaskType()));
        vo.setStatusLabel(RcsTaskStatusEnum.getLabelByValue(entity.getStatus()));
        vo.setPriorityLabel(RcsTaskPriorityEnum.getLabelByValue(entity.getPriority()));
    }

    /**
     * 补齐生命周期 VO 的状态描述字段
     */
    @AfterMapping
    default void fillLifecycleLabels(RcsTaskLifecycleEntity entity, @MappingTarget RcsTaskLifecycleVO vo) {
        vo.setStatusFromLabel(RcsTaskStatusEnum.getLabelByValue(entity.getStatusFrom()));
        vo.setStatusToLabel(RcsTaskStatusEnum.getLabelByValue(entity.getStatusTo()));
    }
}
