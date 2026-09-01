package com.wms.inventory.service.impl;

import cn.hutool.core.util.IdUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.common.exception.BusinessException;
import com.wms.rcs.enums.RcsApiEnum;
import com.wms.common.result.Result;
import com.wms.common.result.ResultCode;
import com.wms.framework.security.util.SecurityUtils;
import com.wms.inventory.mapper.CartInventoryMapper;
import com.wms.inventory.model.dto.CartInventoryBindDTO;
import com.wms.inventory.model.dto.CartInventoryQueryDTO;
import com.wms.inventory.model.entity.CartInventory;
import com.wms.inventory.model.vo.AvailableCartVO;
import com.wms.inventory.model.vo.AvailablePointVO;
import com.wms.inventory.model.vo.CartInventoryVO;
import com.wms.inventory.service.CartInventoryService;
import com.wms.rcs.model.dto.request.AgvBindCarrierDTO;
import com.wms.rcs.model.dto.request.AgvUnbindCarrierDTO;
import com.wms.rcs.service.AgvService;
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
 * 绑定/解绑同步 RCS 载具（carrier/bind、carrier/unbind），RCS 调用均在数据库事务外发起。
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

    private final AgvService agvService;

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
     * 绑定：料车入位（同步 RCS 载具绑定）。
     * <p>
     * 强一致方案：RCS 绑定成功才算绑定成功。
     * 流程：本地状态预检 → RCS carrier/bind（carrierCode=料车编码, siteCode=点位地图坐标）→
     * 本地条件原子更新（仅空位可绑）→ 本地失败（并发被占）补偿 RCS carrier/unbind 释放。
     * RCS 调用在数据库事务外（本方法不开启事务），本地更新为单条原子语句。
     * </p>
     */
    @Override
    public void bind(CartInventoryBindDTO dto) {
        Long userId = SecurityUtils.getUserId();

        // 1. 本地状态预检：避免无效 RCS 调用（幂等：同一料车已在位直接返回）
        CartInventory inv = cartInventoryMapper.selectOne(
                new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, dto.getPointId()));
        if (inv == null) {
            throw new BusinessException("点位不存在");
        }
        if (inv.getCartId() != null) {
            if (inv.getCartId().equals(dto.getCartId())) {
                return;
            }
            throw new BusinessException("点位已被占用，请刷新后重试");
        }
        String cartCode = cartInventoryMapper.selectCartCodeByCartId(dto.getCartId());
        if (cartCode == null) {
            throw new BusinessException("料车不存在");
        }
        // RCS 站点编码以地图坐标为准（wms_point.coordinate），而非 wms_cart_inventory.point_code
        String siteCode = cartInventoryMapper.selectCoordinateByPointId(inv.getPointId());

        // 2. RCS 绑定（事务外）：RCS 绑定成功才算绑定成功
        rcsBind(cartCode, siteCode);

        // 3. 本地条件原子更新：仅当点位仍为空位时才能绑上；
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
                // 区分"RCS回环先写了同一料车"和"真正被别的车占了"
                CartInventory current = cartInventoryMapper.selectOne(
                        new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, dto.getPointId()));
                if (current != null && dto.getCartId().equals(current.getCartId())) {
                    // RCS 回调已先于本地更新写入同一料车，幂等返回，不补偿解绑
                    log.info("RCS回环：绑定回调已先写入，本地幂等跳过：pointId={}, cartId={}", dto.getPointId(), dto.getCartId());
                    return;
                }
                // 真正的竞争失败：补偿 RCS 解绑，保持两侧一致
                rcsUnbindQuietly(cartCode, siteCode);
                throw new BusinessException("点位已被占用或不存在，请刷新后重试");
            }
        } catch (DuplicateKeyException e) {
            log.warn("并发绑定料车冲突，cartId={}, pointId={}", dto.getCartId(), dto.getPointId(), e);
            // 该料车已停在其他点位：补偿 RCS 解绑，保持两侧一致
            rcsUnbindQuietly(cartCode, siteCode);
            throw new BusinessException("该料车已停在其他点位，请先解绑");
        }
    }

    /**
     * 解绑：料车离位（同步 RCS 载具解绑）。
     * <p>
     * 顺序：先 RCS carrier/unbind（失败则本地不动、可重试）→ 本地条件原子更新清空 cart_id/arrive_time。
     * RCS 调用在数据库事务外（本方法不开启事务），本地更新为单条原子语句。
     * </p>
     */
    @Override
    public void unbind(Long pointId) {
        // 1. 读取当前占用信息，组装 RCS 解绑参数
        CartInventory inv = cartInventoryMapper.selectOne(
                new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, pointId));
        if (inv == null || inv.getCartId() == null) {
            throw new BusinessException("该点位当前无料车，无法解绑");
        }
        String cartCode = cartInventoryMapper.selectCartCodeByCartId(inv.getCartId());
        if (cartCode == null) {
            throw new BusinessException("料车不存在，无法同步解绑");
        }
        // RCS 站点编码以地图坐标为准（wms_point.coordinate），而非 wms_cart_inventory.point_code
        String siteCode = cartInventoryMapper.selectCoordinateByPointId(inv.getPointId());

        // 2. 先 RCS 解绑（事务外）：失败则本地不动，可重试
        rcsUnbind(cartCode, siteCode);

        // 3. 本地条件原子更新：清空 cart_id/arrive_time，并将 lock_status 复位为 0
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
            // 区分"RCS回环已清空"和"真正无料车"
            CartInventory current = cartInventoryMapper.selectOne(
                    new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, pointId));
            if (current != null && current.getCartId() == null) {
                // RCS 回调已先于本地更新清空，幂等返回
                log.info("RCS回环：解绑回调已先清空，本地幂等跳过：pointId={}", pointId);
                return;
            }
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

    /**
     * 调 RCS 载具绑定（carrier/bind）：失败抛业务异常
     * <p>
     * 请求体仅 carrierCode/siteCode（可选 carrierDir），不携带 reqCode——
     * 幂等由请求头 X-lr-request-id 保证，RCS 实测成功包无 reqCode 字段。
     * </p>
     */
    private void rcsBind(String cartCode, String siteCode) {
        AgvBindCarrierDTO dto = new AgvBindCarrierDTO();
        dto.setCarrierCode(cartCode);
        dto.setSiteCode(siteCode);
        log.info("同步RCS绑定载具：carrierCode={}, siteCode={}", cartCode, siteCode);
        Result<Object> result = agvService.commonRequest(RcsApiEnum.BIND_CARRIER, dto);
        if (result == null || !ResultCode.SUCCESS.getCode().equals(result.getCode())) {
            String msg = result == null ? "RCS返回空结果" : result.getMsg();
            throw new BusinessException("RCS绑定失败：{}", msg);
        }
    }

    /**
     * 调 RCS 载具解绑（carrier/unbind）：失败抛业务异常
     */
    private void rcsUnbind(String cartCode, String siteCode) {
        AgvUnbindCarrierDTO dto = new AgvUnbindCarrierDTO();
        dto.setReqCode(buildRcsReqCode("UNBIND"));
        dto.setCarrierCode(cartCode);
        dto.setSiteCode(siteCode);
        log.info("同步RCS解绑载具：carrierCode={}, siteCode={}, reqCode={}", cartCode, siteCode, dto.getReqCode());
        Result<Object> result = agvService.commonRequest(RcsApiEnum.UNBIND_CARRIER, dto);
        if (result == null || !ResultCode.SUCCESS.getCode().equals(result.getCode())) {
            String msg = result == null ? "RCS返回空结果" : result.getMsg();
            throw new BusinessException("RCS解绑失败：{}", msg);
        }
    }

    /**
     * 补偿性 RCS 解绑：本地绑定失败后释放 RCS 侧绑定，异常仅记录不向上抛出
     */
    private void rcsUnbindQuietly(String cartCode, String siteCode) {
        try {
            rcsUnbind(cartCode, siteCode);
        } catch (Exception e) {
            log.error("补偿RCS解绑失败，请人工核对：carrierCode={}, siteCode={}", cartCode, siteCode, e);
        }
    }

    /**
     * 生成 RCS 请求编号（每次唯一，作为幂等键，不落库）
     */
    private String buildRcsReqCode(String prefix) {
        return prefix + "_" + IdUtil.fastSimpleUUID();
    }

    /**
     * RCS绑定解绑回调同步（纯本地写库，零 RCS 调用）。
     * <p>
     * 与 bind()/unbind() 的区别：本方法由 RCS /bind 回调驱动，RCS 是绑定事实的权威方，
     * 本地无条件服从——因此<b>绝不回环调用 AGV_bindCarrier/unbindCarrier</b>，避免通知死循环。
     * 写入均带条件天然幂等：主动链路（bind()/unbind()）与回调链路先后到达时
     * 写同一最终状态，后到者 no-op；迟到的旧事件被条件过滤。
     * lock_status 语义与 unbind() 一致：车走后空位复位为 0；绑定时不触碰人工锁定。
     * 注意：回调线程无登录上下文，不回填 update_by（保留原值），仅刷新 updated_time。
     * </p>
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public String syncExternalBind(Long pointId, Long cartId, boolean bind) {
        LocalDateTime now = LocalDateTime.now();
        if (bind) {
            // 1. 清该车在其他点位的旧绑定（一车一位：RCS 事实覆盖本地全部历史落点）
            cartInventoryMapper.update(null,
                    new LambdaUpdateWrapper<CartInventory>()
                            .set(CartInventory::getCartId, null)
                            .set(CartInventory::getArriveTime, null)
                            .set(CartInventory::getLockStatus, 0)
                            .set(CartInventory::getUpdateTime, now)
                            .eq(CartInventory::getCartId, cartId)
                            .ne(CartInventory::getPointId, pointId));

            // 2. 目标点位覆盖写入（RCS 事实赢）；预占被顶掉时告警（该预占任务将走异常路径）。
            //    此处读取仅为产生告警信息，写入仍为按点位单条覆盖，不受读改竞态影响。
            CartInventory existing = cartInventoryMapper.selectOne(
                    new LambdaQueryWrapper<CartInventory>().eq(CartInventory::getPointId, pointId));
            String warnMsg = "";
            if (existing != null && existing.getCartId() != null
                    && !existing.getCartId().equals(cartId) && existing.getArriveTime() == null) {
                warnMsg = "，原在途预占(料车ID=" + existing.getCartId() + ")被RCS事实顶掉，相关任务将走异常路径";
                log.warn("RCS绑定回调覆盖在途预占：pointId={}, 原料车={}, 新料车={}",
                        pointId, existing.getCartId(), cartId);
            }
            cartInventoryMapper.update(null,
                    new LambdaUpdateWrapper<CartInventory>()
                            .set(CartInventory::getCartId, cartId)
                            .set(CartInventory::getArriveTime, now)
                            .set(CartInventory::getUpdateTime, now)
                            .eq(CartInventory::getPointId, pointId));
            return "绑定已同步" + warnMsg;
        }

        // 解绑：条件清空（点位+料车均匹配才生效），迟到事件 0 行命中自动 no-op
        int rows = cartInventoryMapper.update(null,
                new LambdaUpdateWrapper<CartInventory>()
                        .set(CartInventory::getCartId, null)
                        .set(CartInventory::getArriveTime, null)
                        .set(CartInventory::getLockStatus, 0)
                        .set(CartInventory::getUpdateTime, now)
                        .eq(CartInventory::getPointId, pointId)
                        .eq(CartInventory::getCartId, cartId));
        return rows > 0 ? "解绑已同步" : "解绑幂等跳过（本地已无该绑定，疑似迟到事件）";
    }
}
