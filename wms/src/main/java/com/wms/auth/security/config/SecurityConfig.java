package com.wms.auth.security.config;

import cn.hutool.core.util.ArrayUtil;
import com.wms.framework.captcha.service.CaptchaService;
import com.wms.framework.security.config.SecurityProperties;
import com.wms.framework.security.filter.TokenAuthenticationFilter;
import com.wms.framework.security.port.UserAuthenticationPort;
import com.wms.framework.security.service.SecurityUserDetailsService;
import com.wms.framework.security.token.TokenManager;
import com.wms.auth.security.filter.CaptchaValidationFilter;
import com.wms.auth.security.handler.JsonAccessDeniedHandler;
import com.wms.auth.security.handler.JsonAuthenticationEntryPoint;
import com.wms.auth.security.provider.SmsAuthenticationProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.annotation.web.configurers.HeadersConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.access.intercept.AuthorizationFilter;

/**
 * Spring Security 配置类。
 * <p>
 * 归使用方（auth 模块），安全规则（放行路径、CORS、Provider 装配、响应格式）
 * 因项目而异，不应由框架层强制装配。
 *
 * @author Ray.Hao
 * @since 4.3.1
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final RedisTemplate<String, Object> redisTemplate;
    private final PasswordEncoder passwordEncoder;
    private final TokenManager tokenManager;
    private final SecurityUserDetailsService userDetailsService;
    private final CaptchaService captchaService;
    private final SecurityProperties securityProperties;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        return http
                .authorizeHttpRequests(requestMatcherRegistry -> {
                            String[] ignoreUrls = securityProperties.getIgnoreUrls();
                            if (ArrayUtil.isNotEmpty(ignoreUrls)) {
                                requestMatcherRegistry.requestMatchers(ignoreUrls).permitAll();
                            }
                            requestMatcherRegistry.anyRequest().authenticated();
                        }
                )
                .exceptionHandling(configurer ->
                        configurer
                                .authenticationEntryPoint(new JsonAuthenticationEntryPoint())
                                .accessDeniedHandler(new JsonAccessDeniedHandler())
                )
                .sessionManagement(configurer ->
                        configurer.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .csrf(AbstractHttpConfigurer::disable)
                .formLogin(AbstractHttpConfigurer::disable)
                .httpBasic(AbstractHttpConfigurer::disable)
                .headers(headers -> headers.frameOptions(HeadersConfigurer.FrameOptionsConfig::disable))
                // 验证码校验（使用方过滤器，直接写 JSON 响应）
                .addFilterBefore(new CaptchaValidationFilter(captchaService), UsernamePasswordAuthenticationFilter.class)
                // Token 认证（Starter 过滤器，抛 AuthenticationException 交给 ExceptionTranslationFilter 处理）
                .addFilterBefore(new TokenAuthenticationFilter(tokenManager), AuthorizationFilter.class)
                .build();
    }

    @Bean
    public WebSecurityCustomizer webSecurityCustomizer() {
        return (web) -> {
            String[] unsecuredUrls = securityProperties.getUnsecuredUrls();
            if (ArrayUtil.isNotEmpty(unsecuredUrls)) {
                web.ignoring().requestMatchers(unsecuredUrls);
            }
        };
    }

    @Bean
    public DaoAuthenticationProvider daoAuthenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder);
        return provider;
    }

    @Bean
    public SmsAuthenticationProvider smsAuthenticationProvider(UserAuthenticationPort userAuthPort) {
        return new SmsAuthenticationProvider(userAuthPort, redisTemplate);
    }

    @Bean
    public AuthenticationManager authenticationManager(
            DaoAuthenticationProvider daoAuthenticationProvider,
            SmsAuthenticationProvider smsAuthenticationProvider
    ) {
        return new ProviderManager(
                daoAuthenticationProvider,
                smsAuthenticationProvider
        );
    }
}
