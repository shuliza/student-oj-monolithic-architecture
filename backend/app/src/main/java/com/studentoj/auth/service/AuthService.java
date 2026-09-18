package com.studentoj.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.studentoj.auth.dto.ChangePasswordRequest;
import com.studentoj.auth.dto.LoginRequest;
import com.studentoj.auth.dto.LoginResponse;
import com.studentoj.auth.dto.UpdateProfileRequest;
import com.studentoj.auth.entity.UserEntity;
import com.studentoj.auth.mapper.UserMapper;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class AuthService {

    private final UserMapper userMapper;
    private final PasswordEncoder passwordEncoder;
    private final TokenStore tokenStore;

    public AuthService(UserMapper userMapper, PasswordEncoder passwordEncoder, TokenStore tokenStore) {
        this.userMapper = userMapper;
        this.passwordEncoder = passwordEncoder;
        this.tokenStore = tokenStore;
    }

    @Transactional
    public LoginResponse login(LoginRequest request) {
        if (request == null || request.username() == null || request.password() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "用户名和密码不能为空");
        }

        UserEntity user = userMapper.selectOne(new QueryWrapper<UserEntity>().eq("username", request.username().trim()));
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "用户不存在");
        }
        if (!"ACTIVE".equalsIgnoreCase(user.getStatus()) || user.getSessionVersion() == null
                || user.getRole() == null || user.getRole().isBlank()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "账号状态不可用");
        }
        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "密码错误");
        }
        if (request.role() != null && !request.role().isBlank() && !user.getRole().equalsIgnoreCase(request.role())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "当前账号身份为 " + user.getRole() + "，无法以 " + request.role() + " 身份登录");
        }

        UserEntity locked = userMapper.selectByIdForUpdate(user.getId());
        if (locked == null || !"ACTIVE".equalsIgnoreCase(locked.getStatus())
                || !java.util.Objects.equals(user.getSessionVersion(), locked.getSessionVersion())
                || !java.util.Objects.equals(user.getPasswordHash(), locked.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "账号状态已变化，请重新登录");
        }
        LoginResponse payload = toResponse(null, locked);
        String token = tokenStore.issue(payload);
        return toResponse(token, locked);
    }

    public LoginResponse me(String token) {
        LoginResponse cached = tokenStore.resolve(token);
        if (cached == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "会话已过期");
        }
        UserEntity current = userMapper.selectById(cached.userId());
        int version = current == null || current.getSessionVersion() == null ? 0 : current.getSessionVersion();
        if (current == null || !"ACTIVE".equalsIgnoreCase(current.getStatus()) || version != (cached.sessionVersion() == null ? 0 : cached.sessionVersion())) {
            tokenStore.revoke(token);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "会话已失效");
        }
        return cached;
    }

    public void logout(String token) {
        tokenStore.revoke(token);
    }

    public void changePassword(String token, ChangePasswordRequest request) {
        LoginResponse session = me(token);
        if (request == null || request.oldPassword() == null || request.newPassword() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "旧密码和新密码不能为空");
        }
        if (request.newPassword().trim().length() < 6) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "新密码长度至少 6 位");
        }
        UserEntity user = userMapper.selectById(session.userId());
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "用户不存在");
        }
        if (!passwordEncoder.matches(request.oldPassword(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "原密码错误");
        }
        int updated = userMapper.updatePassword(user.getId(), passwordEncoder.encode(request.newPassword().trim()), user.getSessionVersion() == null ? 0 : user.getSessionVersion());
        if (updated != 1) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "账号状态已变化，请重试");
        }
        tokenStore.revokeUser(user.getId());
    }

    public LoginResponse updateProfile(String token, UpdateProfileRequest request) {
        LoginResponse session = me(token);
        UserEntity user = userMapper.selectById(session.userId());
        if (user == null) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "用户不存在");
        }
        String realName = request != null && request.realName() != null && !request.realName().isBlank() ? request.realName().trim() : user.getRealName();
        String email = request != null && request.email() != null ? request.email().trim() : user.getEmail();
        int updated = userMapper.updateProfileFields(user.getId(), realName, email, user.getSessionVersion() == null ? 0 : user.getSessionVersion());
        if (updated != 1) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "资料已被其他请求修改，请重试");
        }
        user.setRealName(realName);
        user.setEmail(email);
        LoginResponse refreshed = toResponse(session.token(), user);
        tokenStore.update(token, refreshed);
        return refreshed;
    }

    private LoginResponse toResponse(String token, UserEntity user) {
        String groupName = user.getGroupId() == null ? null : userMapper.selectGroupName(user.getGroupId());
        return new LoginResponse(
                token,
                user.getId(),
                user.getUsername(),
                user.getRole(),
                user.getRealName(),
                user.getStudentNo(),
                user.getEmail(),
                groupName,
                user.getStatus(),
                user.getSessionVersion() == null ? 0 : user.getSessionVersion()
        );
    }
}
