package com.wms.carriermanagementsystem.cartmodel.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelDTO;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;

import java.util.List;

/**
 * 料车型号业务接口
 * <p>
 * 定义型号配置的 CRUD 操作和列表查询方法。
 * </p>
 *
 * @author Yadmin
 * @since 2026-07-27
 */
public interface CartModelService {

    /**
     * 分页查询型号列表
     */
    IPage<CartModelVO> listCartModel(CartModelQueryDTO queryParams);

    /**
     * 新增型号
     */
    boolean addCartModel(CartModelDTO dto);

    /**
     * 获取型号表单数据
     */
    CartModelDTO formCartModel(Long id);

    /**
     * 编辑型号
     */
    boolean updateCartModel(Long id, CartModelDTO dto);

    /**
     * 批量删除型号
     */
    boolean deleteCartModel(String ids);

    /**
     * 获取表单下拉选项
     */
    List<CartModelVO> formOptions();

    /**
     * 获取筛选下拉选项
     */
    List<CartModelVO> filterOptions();
}
