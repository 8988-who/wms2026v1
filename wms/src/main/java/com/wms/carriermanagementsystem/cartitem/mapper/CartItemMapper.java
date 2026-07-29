package com.wms.carriermanagementsystem.cartitem.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.carriermanagementsystem.cartitem.model.dto.CartItemQueryDTO;
import com.wms.carriermanagementsystem.cartitem.model.entity.CartItem;
import com.wms.carriermanagementsystem.cartitem.model.vo.CartItemVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 料车物品持久层
 * <p>
 * 继承 Mybatis-Plus BaseMapper，提供基本 CRUD 能力。
 * 分页查询、按料车查询等通过 XML 实现。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
@Mapper
public interface CartItemMapper extends BaseMapper<CartItem> {

    /**
     * 分页查询装载明细（含料车编号、料车状态、创建/更新人）
     */
    List<CartItemVO> getCartItemPage(Page<CartItemVO> page, @Param("query") CartItemQueryDTO query);

    /**
     * 查询指定料车的所有物品（按 sortOrder DESC 排序，供装车时查看当前装载情况）
     */
    List<CartItemVO> getCartItemsByCartId(@Param("cartId") Long cartId);

    /**
     * 获取料车当前最大 sortOrder（新增装车时用，不存在则返回 0）
     */
    Integer getMaxSortOrderByCartId(@Param("cartId") Long cartId);
}
