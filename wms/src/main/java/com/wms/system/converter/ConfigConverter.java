package com.wms.system.converter;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.wms.system.model.entity.Config;
import com.wms.system.model.vo.ConfigVO;
import com.wms.system.model.form.ConfigForm;
import org.mapstruct.Mapper;

/**
 * 系统配置对象转换器
 *
 * @author Theo
 * @since 2024-7-29 11:42:49
 */
@Mapper(componentModel = "spring")
public interface ConfigConverter {

    Page<ConfigVO> toPageVo(Page<Config> page);

    Config toEntity(ConfigForm configForm);

    ConfigForm toForm(Config entity);
}
