package com.studentoj.common.auth;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.lang.reflect.Method;
import java.util.Arrays;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.HandlerInterceptor;

public class AuthInterceptor implements HandlerInterceptor {
    private static final String INTERNAL_AUTH_HEADER = "X-Internal-Auth";
    private static final String USER_ID_HEADER = "X-Auth-User-Id";
    private static final String USERNAME_HEADER = "X-Auth-Username";
    private static final String ROLE_HEADER = "X-Auth-User-Role";

    private final String internalSecret;

    public AuthInterceptor(@Value("${studentoj.auth.internal-secret:student-oj-internal-v1}") String internalSecret) {
        this.internalSecret = internalSecret;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        AuthContext.clear();
        if ("OPTIONS".equalsIgnoreCase(request.getMethod()) || request.getRequestURI().startsWith("/actuator/")) {
            return true;
        }
        // 公开端点：登录与 token 自省（introspect 用 Bearer token 自行校验，等价于原网关的 auth_request 目标）。
        // 单体下这些请求不经过外部网关注入内部头，必须放行，否则会自我拦截。
        if (isPublicEndpoint(request.getRequestURI())) {
            return true;
        }
        if (!internalSecret.equals(request.getHeader(INTERNAL_AUTH_HEADER))) {
            response.sendError(HttpStatus.UNAUTHORIZED.value(), "Missing internal auth");
            return false;
        }

        Long userId = parseUserId(request.getHeader(USER_ID_HEADER));
        String role = trimToNull(request.getHeader(ROLE_HEADER));
        if (userId == null || role == null) {
            response.sendError(HttpStatus.UNAUTHORIZED.value(), "Missing authenticated user");
            return false;
        }

        CurrentUser user = new CurrentUser(userId, trimToNull(request.getHeader(USERNAME_HEADER)), role.toUpperCase());
        AuthContext.set(user);
        if (!hasRequiredRole(handler, user.role())) {
            response.sendError(HttpStatus.FORBIDDEN.value(), "Forbidden");
            AuthContext.clear();
            return false;
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        AuthContext.clear();
    }

    private boolean hasRequiredRole(Object handler, String actualRole) {
        if (!(handler instanceof HandlerMethod handlerMethod)) {
            return true;
        }
        RequireRole required = findRequireRole(handlerMethod);
        if (required == null || required.value().length == 0) {
            return true;
        }
        return Arrays.stream(required.value()).anyMatch(role -> role.allows(actualRole));
    }

    private RequireRole findRequireRole(HandlerMethod handlerMethod) {
        Method method = handlerMethod.getMethod();
        RequireRole onMethod = method.getAnnotation(RequireRole.class);
        if (onMethod != null) {
            return onMethod;
        }
        return handlerMethod.getBeanType().getAnnotation(RequireRole.class);
    }

    private boolean isPublicEndpoint(String uri) {
        if (uri == null) {
            return false;
        }
        return uri.equals("/api/auth/login") || uri.equals("/api/auth/introspect");
    }

    private Long parseUserId(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            long value = Long.parseLong(raw.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String trimToNull(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        return raw.trim();
    }
}
