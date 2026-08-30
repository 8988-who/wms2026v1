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
     * 解绑：料车离位（清空 cart_id/arrive_time）
     */
    void unbind(Long pointId);

    /**
     * 预绑定：RCS 任务创建时调用，预占点位（arrive_time 留空，车到后调 confirmArrive）
     */
    void preBind(CartInventoryBindDTO dto);

    /**
     * 确认到达：RCS 回调/车到达时补写 arrive_time
     */
    void confirmArrive(Long pointId);

    /**
     * 锁定库存（仅正常状态可锁）
     */
    void lock(Long pointId);

    /**
     * 解锁库存（仅锁定状态可解）
     */
    void unlock(Long pointId);

    /**
     * RCS绑定解绑回调同步：以 RCS 推送的绑定事实修正本地库存（纯本地写库，
     * 绝不回调 AGV_bindCarrier/unbindCarrier，防止 WMS↔RCS 通知回环）。
     *
     * @param pointId   点位ID（由回调 slotCode 坐标反查）
     * @param cartId    料车ID（由回调 carrierCode 反查）
     * @param bind      true=绑定（覆盖式，RCS 事实赢）；false=解绑（条件清空，迟到事件 no-op）
     * @return 处理说明（成功/幂等跳过/覆盖告警等信息，供台账记录）
     */
    String syncExternalBind(Long pointId, Long cartId, boolean bind);
}
