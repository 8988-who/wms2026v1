package com.wms.framework.web.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.CollectionUtils;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;

import java.util.ArrayList;
import java.util.List;

/**
 * CORS 资源共享配置
 *
 * <p>安全要求：当 {@code allowCredentials(true)} 时，允许来源不得为通配 "*"，
 * 必须使用受信任的域名白名单（从配置项 {@code cors.allowed-origins} 注入，各环境独立配置）。</p>
 *
 * @author haoxr
 * @since 2023/4/17
 */
@Configuration
@ConfigurationProperties(prefix = "cors")
public class CorsConfig {

    /**
     * 允许的跨域来源白名单（支持 {@code setAllowedOriginPatterns} 语法，如 http://localhost:*、https://*.example.com）。
     * 由各环境配置文件注入；生产环境必须配置为受信任域名，禁止使用 "*"。
     */
    private List<String> allowedOrigins = new ArrayList<>();

    public List<String> getAllowedOrigins() {
        return allowedOrigins;
    }

    public void setAllowedOrigins(List<String> allowedOrigins) {
        this.allowedOrigins = allowedOrigins;
    }

    @Bean
    public FilterRegistrationBean<CorsFilter> filterRegistrationBean() {
        CorsConfiguration corsConfiguration = new CorsConfiguration();

        // 1. 允许来源：仅受信任域名白名单（配置为空时兜底为空，等价于不放行任何跨域，避免误配成全放行）
        if (CollectionUtils.isEmpty(allowedOrigins)) {
            throw new IllegalStateException("CORS 配置缺失：请在配置文件中配置 cors.allowed-origins 受信任域名白名单");
        }
        corsConfiguration.setAllowedOriginPatterns(allowedOrigins);

        // 2. 允许任何请求头
        corsConfiguration.addAllowedHeader(CorsConfiguration.ALL);
        // 3. 允许任何方法
        corsConfiguration.addAllowedMethod(CorsConfiguration.ALL);
        // 4. 允许携带凭证（与上面的受信任白名单配合，禁止与 "*" 组合）
        corsConfiguration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);
        CorsFilter corsFilter = new CorsFilter(source);

        FilterRegistrationBean<CorsFilter> filterRegistrationBean = new FilterRegistrationBean<>(corsFilter);
        filterRegistrationBean.setOrder(-101);  // 小于 SpringSecurity Filter的 Order(-100) 即可

        return filterRegistrationBean;
    }
}
