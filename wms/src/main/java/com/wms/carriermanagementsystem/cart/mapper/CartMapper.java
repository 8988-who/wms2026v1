package com.wms.carriermanagementsystem.cart.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.carriermanagementsystem.cart.model.dto.CartQueryDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cart.model.vo.CartVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 料车持久层
 * <p>
 * 继承 Mybatis-Plus BaseMapper，提供基本 CRUD 能力。
 * 分页查询、可用料车列表等通过 XML 实现。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Mapper
public interface CartMapper extends BaseMapper<Cart> {

    /**
     * 分页查询料车列表（含型号信息、有效容量、创建/更新人）
     */
    List<CartVO> selectCartList(Page<CartVO> page, @Param("query") CartQueryDTO query);

    /**
     * 查询区域内不同的区域值（筛选下拉）
     */
    List<String> selectDistinctAreas();
}
