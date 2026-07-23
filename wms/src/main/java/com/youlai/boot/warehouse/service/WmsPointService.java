package com.youlai.boot.warehouse.service;

import com.youlai.boot.warehouse.model.entity.WmsPoint;
import com.youlai.boot.common.model.BatchStatusForm;
import com.youlai.boot.warehouse.model.dto.WmsPointDTO;
import com.youlai.boot.warehouse.model.dto.WmsPointQueryDTO;
import com.youlai.boot.warehouse.model.vo.WmsPointVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 点位业务服务接口
 * <p>
 * 定义点位的分页查询、新增、修改、删除、批量状态更新及表单/筛选选项等业务操作。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-20
 */
public interface WmsPointService extends IService<WmsPoint> {

    IPage<WmsPointVO> getWmsPointPage(WmsPointQueryDTO queryParams);

    WmsPointDTO getWmsPointFormData(Long id);

    boolean saveWmsPoint(WmsPointDTO dto);

    boolean updateWmsPoint(Long id, WmsPointDTO dto);

    boolean deleteWmsPoints(String ids);

    boolean batchUpdateStatus(BatchStatusForm batchStatusForm);

    java.util.Map<String, java.util.List<?>> getFormOptions();

    java.util.List<String> getFilterOptions();
}