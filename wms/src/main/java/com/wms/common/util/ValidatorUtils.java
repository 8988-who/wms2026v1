package com.wms.common.util;

import com.wms.common.exception.GlobalException;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import org.hibernate.validator.messageinterpolation.ResourceBundleMessageInterpolator;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.validation.beanvalidation.MessageSourceResourceBundleLocator;

import java.util.Locale;
import java.util.Set;

/**
 * @BelongsProject: wms
 * @BelongsPackage: com.wms.common.util
 * @Author: YangZheng
 * @CreateTime: 2026-07-31 11:27
 * @Description: TODO
 * @Version: 1.0
 */
public class ValidatorUtils {
    private ValidatorUtils() {
    }

    private static ResourceBundleMessageSource getMessageSource() {
        ResourceBundleMessageSource bundleMessageSource = new ResourceBundleMessageSource();
        bundleMessageSource.setDefaultEncoding("UTF-8");
        bundleMessageSource.setBasenames("i18n/validation");
        return bundleMessageSource;
    }

    /**
     * 校验实体
     *
     * @param object 实体对象
     * @param groups 校验分组
     * @throws GlobalException 全局异常
     */
    public static void validateEntity(Object object, Class<?>... groups) throws GlobalException {
        Locale.setDefault(LocaleContextHolder.getLocale());
        Validator validator = Validation.byDefaultProvider().configure().messageInterpolator(new ResourceBundleMessageInterpolator(new MessageSourceResourceBundleLocator(getMessageSource()))).buildValidatorFactory().getValidator();
        Set<ConstraintViolation<Object>> constraintViolations = validator.validate(object, groups);
        if (!constraintViolations.isEmpty()) {
            ConstraintViolation<Object> constraint = constraintViolations.iterator().next();
            throw new GlobalException(constraint.getMessage());
        }
    }
}
