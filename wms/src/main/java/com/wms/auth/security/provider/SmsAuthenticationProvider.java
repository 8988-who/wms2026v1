package com.wms.auth.security.provider;

import cn.hutool.core.util.ObjectUtil;
import cn.hutool.core.util.StrUtil;
import com.wms.common.constant.RedisConstants;
import com.wms.framework.security.model.SecurityUser;
import com.wms.framework.security.model.SecurityUserDetails;
import com.wms.framework.security.port.UserAuthenticationPort;
import com.wms.auth.security.exception.SmsCaptchaException;
import com.wms.auth.security.model.SmsAuthenticationToken;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

/**
 * 短信验证码认证 Provider
 * <p>
 * 认证流程：
 * <ol>
 *   <li>根据手机号查询用户信息</li>
 *   <li>校验用户状态</li>
 *   <li>校验短信验证码（与 Redis 缓存比对）</li>
 *   <li>验证成功后删除验证码</li>
 *   <li>返回已认证的 Authentication</li>
 * </ol>
 *
 * @author Ray.Hao
 * @since 2.17.0
 */
@Slf4j
public class SmsAuthenticationProvider implements AuthenticationProvider {

    private final UserAuthenticationPort userAuthPort;
    private final RedisTemplate<String, Object> redisTemplate;

    public SmsAuthenticationProvider(UserAuthenticationPort userAuthPort, RedisTemplate<String, Object> redisTemplate) {
        this.userAuthPort = userAuthPort;
        this.redisTemplate = redisTemplate;
    }

    @Override
    public Authentication authenticate(Authentication authentication) throws AuthenticationException {
        String mobile = (String) authentication.getPrincipal();
        String inputVerifyCode = (String) authentication.getCredentials();

        if (StrUtil.isBlank(mobile)) {
            log.warn("短信验证码登录失败：手机号为空");
            throw new SmsCaptchaException("手机号不能为空");
        }
        if (StrUtil.isBlank(inputVerifyCode)) {
            log.warn("短信验证码登录失败：验证码为空，手机号={}", mobile);
            throw new SmsCaptchaException("验证码不能为空");
        }

        SecurityUser securityUser = userAuthPort.getAuthInfoByMobile(mobile);

        if (securityUser == null) {
            log.warn("短信验证码登录失败：用户不存在，手机号={}", mobile);
            throw new UsernameNotFoundException("用户不存在");
        }

        if (ObjectUtil.notEqual(securityUser.getStatus(), 1)) {
            log.warn("短信验证码登录失败：用户已禁用，用户名={}", securityUser.getUsername());
            throw new DisabledException("用户已被禁用");
        }

        String cacheKey = StrUtil.format(RedisConstants.Captcha.SMS_LOGIN_CODE, mobile);
        String cachedVerifyCode = (String) redisTemplate.opsForValue().get(cacheKey);

        if (cachedVerifyCode == null) {
            log.warn("短信验证码登录失败：验证码已过期，手机号={}", mobile);
            throw new SmsCaptchaException("验证码已过期，请重新获取");
        }

        if (!StrUtil.equals(inputVerifyCode, cachedVerifyCode)) {
            log.warn("短信验证码登录失败：验证码错误，手机号={}", mobile);
            throw new SmsCaptchaException("验证码错误");
        }

        redisTemplate.delete(cacheKey);

        SecurityUserDetails userDetails = new SecurityUserDetails(securityUser);
        log.info("短信验证码登录成功：用户名={}，手机号={}", securityUser.getUsername(), mobile);
        return SmsAuthenticationToken.authenticated(userDetails, userDetails.getAuthorities());
    }

    @Override
    public boolean supports(Class<?> authentication) {
        return SmsAuthenticationToken.class.isAssignableFrom(authentication);
    }
}
