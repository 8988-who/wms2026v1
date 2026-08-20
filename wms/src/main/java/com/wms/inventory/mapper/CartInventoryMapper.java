package com.wms.inventory.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.inventory.model.dto.CartInventoryQueryDTO;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.model.vo.AisleOptionVO;
import com.wms.inventory.model.vo.AvailableCartVO;
import com.wms.inventory.model.vo.AvailablePointVO;
import com.wms.inventory.model.vo.CartInventoryVO;
import com.wms.inventory.model.vo.LocationOptionVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 料车库存持久层
 * <p>
 * 继承 Mybatis-Plus BaseMapper，提供基本 CRUD 能力。
 * 分页查询（JOIN 区域/巷道/点位/料车/用户 + 实时装载聚合）、下拉选项等通过 XML 实现。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Mapper
public interface CartInventoryMapper extends BaseMapper<CartInventory> {

    /**
     * 分页查询料车库存列表（含区域/巷道/点位/料车名称、实时装载量、最后更新者）
     */
    List<CartInventoryVO> selectCartInventoryPage(Page<CartInventoryVO> page,
                                                  @Param("query") CartInventoryQueryDTO query);

    /**
     * 可用料车下拉：不在任何点位且非维修状态的料车
     */
    List<AvailableCartVO> selectAvailableCarts();

    /**
     * 可用点位下拉：空位且未锁定的点位（含区域/巷道名称），可按区域/巷道联动筛选，点位量大时局部加载
     */
    List<AvailablePointVO> selectAvailablePoints(@Param("locationId") Long locationId,
                                                 @Param("aisleId") Long aisleId);

    /**
     * 区域筛选下拉（id + 名称）
     */
    List<LocationOptionVO> selectLocationOptions();

    /**
     * 巷道筛选下拉（id + 名称 + 所属区域）
     */
    List<AisleOptionVO> selectAisleOptions();
}
