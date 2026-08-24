package com.wms.inventory.service.impl;

import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.exception.BusinessException;
import com.wms.framework.security.util.SecurityUtils;
import com.wms.inventory.mapper.CartInventoryMapper;
import com.wms.inventory.model.dto.CartInventoryBindDTO;
import com.wms.inventory.model.dto.CartInventoryQueryDTO;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.model.vo.AvailableCartVO;
import com.wms.inventory.model.vo.AvailablePointVO;
import com.wms.inventory.model.vo.CartInventoryVO;
import com.wms.inventory.service.CartInventoryService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 料车库存业务实现
 * <p>
 * 写操作（bind/unbind/lock/unlock）全部采用「条件原子更新 + 影响行数判断」，
 * 不「先查后改」，由数据库唯一索引（uk_inventory_cart）兜底，保证并发安全。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-08-19
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class CartInventoryServiceImpl extends ServiceImpl<CartInventoryMapper, CartInventory>
        implements CartInventoryService {

    private final CartInventoryMapper cartInventoryMapper;

    @Override
    public IPage<CartInventoryVO> page(CartInventoryQueryDTO queryParams) {
        Page<CartInventoryVO> page = new Page<>(queryParams.getPageNum(), queryParams.getPageSize());
        List<CartInventoryVO> list = cartInventoryMapper.selectCartInventoryPage(page, queryParams);
        page.setRecords(list);
        return page;
    }

    @Override
    public List<AvailableCartVO> availableCarts() {
        return cartInventoryMapper.selectAvailableCarts();
    }

    @Override
    public List<AvailablePointVO> availablePoints(Long locationId, Long aisleId) {
        return cartInventoryMapper.selectAvailablePoints(locationId, aisleId);
    }

    @Override
    public Map<String, List<?>> filterOptions() {
        Map<String, List<?>> options = new HashMap<>();
        options.put("locations", cartInventoryMapper.selectLocationOptions());
        options.put("aisles", cartInventoryMapper.selectAisleOptions());
        return options;
    }

    /**
     * 绑定：料车入位。
     * <p>
     * 条件原子更新：仅当点位仍为空位（cart_id IS NULL）时才能绑上；
     * 若并发下两条更新同时命中，唯一索引 uk_inventory_cart 兜底拦截重复绑定。
     * lock_status 置 0：维修重绑时点位已恢复空闲（解绑时已复位），绑定后保持正常态。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void bind(CartInventoryBindDTO dto) {
        Long userId = SecurityUtils.getUserId();

        // 条件原子更新：仅当点位仍为空位时才能绑上；
        //    若该料车已停在其他点位，uk_inventory_cart 唯一索引会在 UPDATE 时立即抛冲突
        try {
            int rows = cartInventoryMapper.update(null,
                    new LambdaUpdateWrapper<CartInventory>()
                            .set(CartInventory::getCartId, dto.getCartId())
                            .set(CartInventory::getArriveTime, LocalDateTime.now())
                            .set(CartInventory::getLockStatus, 0)
                            .set(CartInventory::getUpdateBy, userId)
                            .set(CartInventory::getUpdateTime, LocalDateTime.now())
                            .eq(CartInventory::getPointId, dto.getPointId())
                            .isNull(CartInventory::getCartId));
            if (rows == 0) {
                throw new BusinessException("点位已被占用或不存在，请刷新后重试");
            }
        } catch (DuplicateKeyException e) {
            log.warn("并发绑定料车冲突，cartId={}, pointId={}", dto.getCartId(), dto.getPointId(), e);
            throw new BusinessException("该料车已停在其他点位，请先解绑");
        }
    }

    /**
     * 解绑：料车离位。
     * <p>
     * 显式 set(null) 清除 cart_id/arrive_time（MyBatis-Plus updateById 会跳过 null，必须用 Wrapper 显式置空）。
     * 解绑同时将 lock_status 置回 0（正常）：锁定→解绑→维修→重绑 流程中，料车解下后点位即恢复空闲可重绑。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unbind(Long pointId) {
        int rows = cartInventoryMapper.update(null,
                new LambdaUpdateWrapper<CartInventory>()
                        .set(CartInventory::getCartId, null)
                        .set(CartInventory::getArriveTime, null)
                        .set(CartInventory::getLockStatus, 0)
                        .set(CartInventory::getUpdateBy, SecurityUtils.getUserId())
                        .set(CartInventory::getUpdateTime, LocalDateTime.now())
                        .eq(CartInventory::getPointId, pointId)
                        .isNotNull(CartInventory::getCartId));
        if (rows == 0) {
            throw new BusinessException("该点位当前无料车，无法解绑");
        }
    }

    /**
     * 预绑定：RCS 任务创建时调用，预占点位。
     * <p>
     * 与 bind() 的区别：不写 arrive_time（车还没到），留空表示在途。
     * 容量判断 cart_id IS NOT NULL 天然包含预占，防止在途车辆被漏算。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void preBind(CartInventoryBindDTO dto) {
        Long userId = SecurityUtils.getUserId();
        try {
            int rows = cartInventoryMapper.update(null,
                    new LambdaUpdateWrapper<CartInventory>()
                            .set(CartInventory::getCartId, dto.getCartId())
                            .set(CartInventory::getArriveTime, null)
                            .set(CartInventory::getLockStatus, 0)
                            .set(CartInventory::getUpdateBy, userId)
                            .set(CartInventory::getUpdateTime, LocalDateTime.now())
                            .eq(CartInventory::getPointId, dto.getPointId())
                            .isNull(CartInventory::getCartId));
            if (rows == 0) {
                throw new BusinessException("点位已被占用或不存在，请刷新后重试");
            }
        } catch (DuplicateKeyException e) {
            log.warn("并发预绑定料车冲突，cartId={}, pointId={}", dto.getCartId(), dto.getPointId(), e);
            throw new BusinessException("该料车已停在其他点位，请先解绑");
        }
    }

    /**
     * 确认到达：RCS 回调/车到达时补写 arrive_time。
     * <p>
     * 仅当点位已预绑定（cart_id IS NOT NULL）且 arrive_time 仍为空时才更新，
     * 防止重复回调覆盖已记录的到达时间。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void confirmArrive(Long pointId) {
        int rows = cartInventoryMapper.update(null,
                new LambdaUpdateWrapper<CartInventory>()
                        .set(CartInventory::getArriveTime, LocalDateTime.now())
                        .set(CartInventory::getUpdateBy, SecurityUtils.getUserId())
                        .set(CartInventory::getUpdateTime, LocalDateTime.now())
                        .eq(CartInventory::getPointId, pointId)
                        .isNotNull(CartInventory::getCartId)
                        .isNull(CartInventory::getArriveTime));
        if (rows == 0) {
            throw new BusinessException("该点位无在途料车或已确认到达");
        }
    }

    /**
     * 锁定库存：条件带 lock_status=0 比较，防止覆盖别人的操作。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void lock(Long pointId) {
        int rows = cartInventoryMapper.update(null,
                new LambdaUpdateWrapper<CartInventory>()
                        .set(CartInventory::getLockStatus, 1)
                        .set(CartInventory::getUpdateBy, SecurityUtils.getUserId())
                        .set(CartInventory::getUpdateTime, LocalDateTime.now())
                        .eq(CartInventory::getPointId, pointId)
                        .eq(CartInventory::getLockStatus, 0));
        if (rows == 0) {
            throw new BusinessException("该点位当前不是可锁定状态（已锁定或无记录）");
        }
    }

    /**
     * 解锁库存：条件带 lock_status=1 比较，防止覆盖别人的操作。
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public void unlock(Long pointId) {
        int rows = cartInventoryMapper.update(null,
                new LambdaUpdateWrapper<CartInventory>()
                        .set(CartInventory::getLockStatus, 0)
                        .set(CartInventory::getUpdateBy, SecurityUtils.getUserId())
                        .set(CartInventory::getUpdateTime, LocalDateTime.now())
                        .eq(CartInventory::getPointId, pointId)
                        .eq(CartInventory::getLockStatus, 1));
        if (rows == 0) {
            throw new BusinessException("该点位当前不是可解锁状态（未锁定或无记录）");
        }
    }
}
