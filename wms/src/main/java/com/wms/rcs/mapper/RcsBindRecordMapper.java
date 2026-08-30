package com.wms.rcs.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.wms.rcs.model.entity.RcsBindRecordEntity;
import org.apache.ibatis.annotations.Mapper;

/**
 * RCS绑定解绑回调台账持久层接口
 *
 * @author SenyangHe
 * @since 2026-09-01
 */
@Mapper
public interface RcsBindRecordMapper extends BaseMapper<RcsBindRecordEntity> {
}
