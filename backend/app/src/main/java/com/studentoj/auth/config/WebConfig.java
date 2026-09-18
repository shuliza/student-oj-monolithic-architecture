package com.studentoj.auth.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        String configured = java.util.Optional.ofNullable(
                System.getenv().getOrDefault("STUDENTOJ_CORS_ALLOWED_ORIGINS", null)
        ).map(String::trim).orElse("");
        String[] origins = configured.isEmpty()
                ? new String[]{"http://localhost:5173", "http://localhost"}
                : configured.split(",");
        registry.addMapping("/api/**")
                .allowedOrigins(origins)
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("Authorization", "Content-Type", "X-Internal-Auth", "X-Auth-User-Id", "X-Auth-Username", "X-Auth-User-Role")
                .allowCredentials(true);
    }
}
