package com.wms.carriermanagementsystem.cart.job;

import com.wms.carriermanagementsystem.cartitem.service.CartItemService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * 料车状态定时同步任务
 * <p>定时重新计算所有料车的 current_quantity 和 status，防止事件驱动更新遗漏</p>
 */
@Component
@Slf4j
@RequiredArgsConstructor
@ConditionalOnProperty(prefix = "cart.sync", name = "enabled", havingValue = "true")
public class CartStatusSyncTask {

    private final CartItemService cartItemService;

    @Scheduled(fixedRateString = "${cart.sync.fixed-rate:60000}")
    public void execute() {
        cartItemService.syncAllCartsStatus();
    }
}
