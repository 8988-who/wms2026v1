package com.wms.inventory.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.wms.inventory.model.dto.CartInventoryBindDTO;
import com.wms.inventory.model.dto.CartInventoryQueryDTO;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.model.vo.AisleOptionVO;
import com.wms.inventory.model.vo.AvailableCartVO;
import com.wms.inventory.model.vo.AvailablePointVO;
import com.wms.inventory.model.vo.CartInventoryVO;
import com.wms.inventory.model.vo.LocationOptionVO;

import java.util.List;
import java.util.Map;

/**
 * 料车库存业务接口
 * <p>
 * 提供库存分页查询、可用料车/点位下拉、绑定/解绑/锁定/解锁操作。
 * 写操作采用「条件原子更新 + 影响行数判断」实现并发控制，数据库唯一索引兜底。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
public interface CartInventoryService extends IService<CartInventory> {

    /**
     * 分页查询料车库存列表（库存显示/库存管理共用）
     */
    IPage<CartInventoryVO> page(CartInventoryQueryDTO queryParams);

    /**
     * 可用料车下拉（不在任何点位且非维修）
     */
    List<AvailableCartVO> availableCarts();

    /**
     * 可用点位下拉（空位且未锁定），可按区域/巷道联动筛选后局部加载
     */
    List<AvailablePointVO> availablePoints(Long locationId, Long aisleId);

    /**
     * 搜索筛选下拉（区域列表 + 巷道列表）
     */
    Map<String, List<?>> filterOptions();

    /**
     * 绑定：料车入位（并发安全，唯一索引兜底）
     */
    void bind(CartInventoryBindDTO dto);

    /**
     * 解绑：料车离位（清空 cart_id/arrive_time/arrive_quantity）
     */
    void unbind(Long pointId);

    /**
     * 锁定库存（仅正常状态可锁）
     */
    void lock(Long pointId);

    /**
     * 解锁库存（仅锁定状态可解）
     */
    void unlock(Long pointId);
}
