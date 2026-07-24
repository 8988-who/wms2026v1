package com.wms.system.enums;

import com.wms.common.base.IBaseEnum;
import lombok.Getter;

/**
 * 字典编码枚举
 *
 * @author Ray.Hao
 * @since 2024/10/30
 */
@Getter
public enum DictCodeEnum implements IBaseEnum<String> {

    GENDER("gender", "性别");

    private final String value;

    private final String label;

    DictCodeEnum(String value, String label) {
        this.value = value;
        this.label = label;
    }

}
