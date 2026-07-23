package com.wms.framework.captcha.exception;

import com.wms.common.result.ResultCode;
import lombok.Getter;

/**
 * 验证码异常
 */
@Getter
public class CaptchaException extends RuntimeException {

    private final ResultCode resultCode;

    public CaptchaException(ResultCode resultCode) {
        super(resultCode.getMsg());
        this.resultCode = resultCode;
    }

}
