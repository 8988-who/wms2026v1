package com.wms.carriermanagementsystem.cart.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.carriermanagementsystem.cart.model.dto.CartDTO;
import com.wms.carriermanagementsystem.cart.model.dto.CartQueryDTO;
import com.wms.carriermanagementsystem.cart.model.entity.Cart;
import com.wms.carriermanagementsystem.cart.model.vo.CartVO;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;

import java.util.List;

/**
 * 料车业务接口
 * <p>
 * 定义料车的 CRUD 操作、状态管理和可用料车查询方法。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
public interface CartService {

    /**
     * 分页查询料车列表
     */
    IPage<CartVO> listCart(CartQueryDTO queryParams);

    /**
     * 新增料车
     */
    boolean addCart(CartDTO dto);

    /**
     * 获取料车表单数据
     */
    CartDTO formCart(Long id);

    /**
     * 编辑料车
     */
    boolean updateCart(Long id, CartDTO dto);

    /**
     * 批量删除料车
     */
    boolean deleteCart(String ids);

    /**
     * 批量修改料车状态
     */
    boolean batchUpdateStatus(List<Long> ids, Integer status);

    /**
     * 获取表单下拉选项（型号列表）
     */
    List<CartModelVO> formOptions();

    /**
     * 获取筛选下拉选项（型号列表 + 区域列表）
     */
    List<CartModelVO> filterOptions();

    /**
     * 获取区域列表（筛选下拉）
     */
    List<String> listAreas();

    /**
     * 获取可用料车列表（未满载且无维修，供装车时选择）
     */
    List<Cart> availableCarts();
}
