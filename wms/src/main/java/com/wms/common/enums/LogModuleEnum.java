package com.wms.common.enums;

import com.baomidou.mybatisplus.annotation.EnumValue;
import com.fasterxml.jackson.annotation.JsonValue;
import com.wms.common.base.IBaseEnum;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Getter;

/**
 * 日志模块枚举
 *
 * @author Ray
 * @since 2.10.0
 */
@Schema(enumAsRef = true)
@Getter
public enum LogModuleEnum implements IBaseEnum<Integer> {

    LOGIN(1, "登录"),
    USER(2, "用户管理"),
    ROLE(3, "角色管理"),
    DEPT(4, "部门管理"),
    MENU(5, "菜单管理"),
    DICT(6, "字典管理"),
    CONFIG(7, "系统配置"),
    FILE(8, "文件管理"),
    LOG(9, "日志管理"),
    WMS_POINT(81, "点位管理"),
    WMS_AISLE(82, "巷道管理"),
    WMS_LOCATION(83, "库位/区域管理"),
    CART_MODEL(84, "料车型号配置"),
    CART(85, "料车管理"),
    CART_ITEM(86, "料车物品管理"),
    API_REQUEST_LOG(87, "接口请求日志"),
    RCS_AGV(88, "AGV调度管理");

    @EnumValue
    private final Integer value;

    @JsonValue
    private final String label;

    LogModuleEnum(Integer value, String label) {
        this.value = value;
        this.label = label;
    }

    @Override
    public Integer getValue() {
        return this.value;
    }

    @Override
    public String getLabel() {
        return this.label;
    }
}