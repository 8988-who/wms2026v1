package com.wms.auth.controller;

import com.wms.auth.model.form.LoginForm;
import com.wms.common.enums.ActionTypeEnum;
import com.wms.common.enums.LogModuleEnum;
import com.wms.common.result.Result;
import com.wms.auth.service.AuthService;
import com.wms.common.annotation.Log;
import com.wms.common.annotation.RateLimit;
import com.wms.framework.captcha.model.CaptchaInfo;
import com.wms.framework.security.model.AuthenticationToken;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 认证控制层
 *
 * @author Ray.Hao
 * @since 0.0.1
 */
@Tag(name = "01.认证中心")
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Slf4j
public class AuthController {

    private final AuthService authService;

    @Operation(summary = "获取验证码")
    @GetMapping("/captcha")
    public Result<CaptchaInfo> getCaptcha() {
        CaptchaInfo captcha = authService.getCaptcha();
        return Result.success(captcha);
    }

    @Operation(summary = "账号密码登录")
    @PostMapping("/login")
    @Log(module = LogModuleEnum.LOGIN, value = ActionTypeEnum.LOGIN)
    @RateLimit
    public Result<AuthenticationToken> login(@RequestBody @Valid LoginForm request) {
        AuthenticationToken authenticationToken = authService.login(request.getUsername(), request.getPassword());
        return Result.success(authenticationToken);
    }

    // ==================== 短信验证码登录（已下线） ====================
    // 说明：当前未接入厂商短信服务，验证码为固定测试值（见 AuthServiceImpl.sendSmsCode），
    // 若暴露接口会形成任意手机号登录后门，故整体下线接口入口。
    // 启用前置条件：1) 接入真实短信服务；2) 将验证码改为服务端随机生成且发送成功后才写入缓存。
    // 恢复方式：接入短信后取消以下两个方法的注释即可（Service/Provider 相关类已保留）。

    // @Operation(summary = "短信验证码登录")
    // @PostMapping("/login/sms")
    // @Log(module = LogModuleEnum.LOGIN, value = ActionTypeEnum.LOGIN)
    // public Result<AuthenticationToken> loginBySms(
    //         @Parameter(description = "手机号", example = "18888888888") @RequestParam String mobile,
    //         @Parameter(description = "验证码", example = "123456") @RequestParam String code
    // ) {
    //     AuthenticationToken loginResult = authService.loginBySms(mobile, code);
    //     return Result.success(loginResult);
    // }

    // @Operation(summary = "发送登录短信验证码")
    // @PostMapping("/sms/code")
    // @RateLimit(limit = 1, window = 60)
    // public Result<Void> sendSmsCode(
    //         @Parameter(description = "手机号", example = "18888888888") @RequestParam String mobile
    // ) {
    //     authService.sendSmsCode(mobile);
    //     return Result.success();
    // }
    // ================================================================

    @Operation(summary = "退出登录")
    @DeleteMapping("/logout")
    @Log(module = LogModuleEnum.LOGIN, value = ActionTypeEnum.LOGOUT)
    public Result<Void> logout() {
        authService.logout();
        return Result.success();
    }

    @Operation(summary = "刷新令牌")
    @PostMapping("/refresh-token")
    public Result<AuthenticationToken> refreshToken(
            @Parameter(description = "刷新令牌", example = "xxx.xxx.xxx") @RequestParam String refreshToken
    ) {
        AuthenticationToken authenticationToken = authService.refreshToken(refreshToken);
        return Result.success(authenticationToken);
    }

}
