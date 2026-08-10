package com.wms.common.validator;

import com.wms.common.annotation.ValidField;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

import java.util.Arrays;

/**
 * 字段校验器
 *
 * @author Ray.Hao
 * @since 2024/11/18
 */
public class FieldValidator implements ConstraintValidator<ValidField, String> {

    private String[] allowedValues;

    private boolean ignoreCase;

    @Override
    public void initialize(ValidField constraintAnnotation) {
        this.allowedValues = constraintAnnotation.allowedValues();
        this.ignoreCase = constraintAnnotation.ignoreCase();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (value == null) {
            return true;
        }
        if (ignoreCase) {
            return Arrays.stream(allowedValues).anyMatch(allowed -> allowed.equalsIgnoreCase(value));
        }
        return Arrays.asList(allowedValues).contains(value);
    }
}
