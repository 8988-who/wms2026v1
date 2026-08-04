package com.wms.common.util;

import com.wms.common.exception.BusinessException;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Set;

/**
 * 参数校验工具类
 * <p>
 * 使用 Spring 管理的 Validator 单例，支持动态 Locale 切换
 * </p>
 *
 * @author YangZheng
 * @date 2026-07-31
 */
@Component
public class ValidatorUtils {

    private static Validator validator;

    @Autowired
    public void setValidator(Validator validator) {
        ValidatorUtils.validator = validator;
    }

    /**
     * 校验实体
     *
     * @param object 实体对象
     * @param groups 校验分组
     * @throws BusinessException 业务异常
     */
    public static void validateEntity(Object object, Class<?>... groups) throws BusinessException {
        Set<ConstraintViolation<Object>> constraintViolations = validator.validate(object, groups);
        if (!constraintViolations.isEmpty()) {
            ConstraintViolation<Object> constraint = constraintViolations.iterator().next();
            throw new BusinessException(constraint.getMessage());
        }
    }
}
