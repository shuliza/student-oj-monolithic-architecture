package com.studentoj.common.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;

@Configuration
public class StartupValidator {

    @Value("${spring.profiles.active:}")
    private String activeProfiles;

    @Value("${spring.datasource.password:}")
    private String dbPassword;

    @Value("${studentoj.sandbox.datasource.password:}")
    private String sandboxPassword;

    @Value("${studentoj.auth.internal-secret:}")
    private String internalSecret;

    @EventListener(ApplicationReadyEvent.class)
    public void validateOnStartup() {
        boolean isProd = activeProfiles != null && activeProfiles.contains("prod");
        if (!isProd) return;

        if (dbPassword == null || dbPassword.isBlank()) {
            throw new IllegalStateException("生产环境必须配置 MYSQL_PASSWORD");
        }
        if (sandboxPassword == null || sandboxPassword.isBlank()) {
            throw new IllegalStateException("生产环境必须配置 SANDBOX_MYSQL_PASSWORD");
        }
        if (internalSecret == null || internalSecret.isBlank()) {
            throw new IllegalStateException("生产环境必须配置 STUDENTOJ_AUTH_INTERNAL_SECRET");
        }
    }
}