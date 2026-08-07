package com.wms.rcs.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.rcs.model.dto.RcsTaskDTO;
import com.wms.rcs.model.dto.RcsTaskQueryDTO;
import com.wms.rcs.model.entity.RcsTaskEntity;
import com.wms.rcs.model.vo.RcsTaskVO;

/**
 * RCS任务业务服务接口
 * <p>
 * 提供任务的分页查询、详情（含状态变更历史时间线）、新增、修改、删除。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-04
 */
public interface RcsTaskService extends IService<RcsTaskEntity> {

    /**
     * 分页查询任务列表
     */
    IPage<RcsTaskVO> getRcsTaskPage(RcsTaskQueryDTO queryParams);

    /**
     * 获取任务详情（含状态变更历史）
     */
    RcsTaskVO getRcsTaskDetail(Long id);

    /**
     * 新增任务（状态默认待执行，自动生成任务编号）
     */
    boolean saveRcsTask(RcsTaskDTO dto);

    /**
     * 修改任务（仅"待执行"状态可修改）
     */
    boolean updateRcsTask(Long id, RcsTaskDTO dto);

    /**
     * 删除任务（支持逗号分隔的多个ID，级联删除生命周期历史由外键保证）
     */
    boolean deleteRcsTasks(String ids);
}
