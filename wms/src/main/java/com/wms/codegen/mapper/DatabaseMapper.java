package com.wms.codegen.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.codegen.model.vo.ColumnMetaVO;
import com.wms.codegen.model.vo.TableMetaVO;
import com.wms.codegen.model.query.TableQuery;
import com.wms.codegen.model.vo.TablePageVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;


/**
 * 数据库映射层
 *
 * @author Ray
 * @since 2.9.0
 */
@Mapper
public interface DatabaseMapper extends BaseMapper {

    /**
     * 获取表分页列表
     *
     * @param page
     * @param queryParams
     * @return
     */
    Page<TablePageVO> getTablePage(Page<TablePageVO> page, TableQuery queryParams);

    /**
     * 获取表字段列表
     *
     * @param tableName
     * @return
     */
    List<ColumnMetaVO> getTableColumns(String tableName);

    TableMetaVO getTableMetadata(String tableName);
}
