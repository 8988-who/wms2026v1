package com.wms.warehouse.service;

import com.wms.common.model.BatchStatusForm;
import com.wms.common.model.entity.WmsAisle;
import com.wms.warehouse.model.dto.WmsAisleDTO;
import com.wms.warehouse.model.dto.WmsAisleQueryDTO;
import com.wms.warehouse.model.vo.WmsAisleVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * 巷道业务服务接口
 * <p>
 * 定义巷道的分页查询、新增、修改、删除、批量状态更新及表单/筛选选项等业务操作。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
public interface WmsAisleService extends IService<WmsAisle> {

    IPage<WmsAisleVO> getWmsAislePage(WmsAisleQueryDTO queryParams);

    WmsAisleDTO getWmsAisleFormData(Long id);

    boolean saveWmsAisle(WmsAisleDTO dto);

    boolean updateWmsAisle(Long id, WmsAisleDTO dto);

    boolean deleteWmsAisles(String ids);

    boolean batchUpdateStatus(BatchStatusForm batchStatusForm);

    java.util.Map<String, java.util.List<?>> getFormOptions();

    java.util.Map<String, java.util.List<?>> getFilterOptions();
}