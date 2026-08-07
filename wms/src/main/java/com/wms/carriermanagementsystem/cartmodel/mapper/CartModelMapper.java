package com.wms.carriermanagementsystem.cartmodel.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.carriermanagementsystem.cartmodel.model.dto.CartModelQueryDTO;
import com.wms.carriermanagementsystem.cartmodel.model.entity.CartModel;
import com.wms.carriermanagementsystem.cartmodel.model.vo.CartModelVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * 料车型号持久层
 * <p>
 * 继承 Mybatis-Plus BaseMapper，提供基本 CRUD 能力。
 * 分页查询与关联统计通过 XML 实现。
 * </p>
 *
 * @author SenyangHe
 * @since 2026-07-27
 */
@Mapper
public interface CartModelMapper extends BaseMapper<CartModel> {

    /**
     * 分页查询型号列表（含关联料车数量）
     */
    List<CartModelVO> selectCartModelList(Page<CartModelVO> page, @Param("query") CartModelQueryDTO query);

    /**
     * 查询所有可用型号（表单下拉选项）
     */
    List<CartModelVO> selectFormOptions();
}
