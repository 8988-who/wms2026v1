package com.wms.warehouse.service;

import com.wms.common.model.BatchStatusForm;
import com.wms.warehouse.model.entity.WmsLocation;
import com.wms.warehouse.model.dto.WmsLocationDTO;
import com.wms.warehouse.model.dto.WmsLocationQueryDTO;
import com.wms.warehouse.model.vo.WmsLocationVO;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;

import java.util.List;
import java.util.Map;

/**
 * 库位/区域业务服务接口
 * <p>
 * 定义库位/区域的分页查询、新增、修改、删除、批量状态更新及筛选选项等业务操作。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-20
 */
public interface WmsLocationService extends IService<WmsLocation> {

    IPage<WmsLocationVO> getWmsLocationPage(WmsLocationQueryDTO queryParams);

    WmsLocationDTO getWmsLocationFormData(Long id);

    boolean saveWmsLocation(WmsLocationDTO dto);

    boolean updateWmsLocation(Long id, WmsLocationDTO dto);

    boolean deleteWmsLocations(String ids);

    boolean batchUpdateStatus(BatchStatusForm batchStatusForm);

    Map<String, List<String>> getFilterOptions(String plantCode, String floor);

    Map<String, List<?>> getFormOptions();

}