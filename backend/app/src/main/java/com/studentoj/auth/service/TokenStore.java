package com.studentoj.auth.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.studentoj.auth.dto.LoginResponse;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.stereotype.Component;

@Component
public class TokenStore {
    private static final String KEY_PREFIX = "auth:token:";
    private static final String USER_TOKEN_KEY_PREFIX = "auth:user-token:";
    private static final DefaultRedisScript<Long> ISSUE_SCRIPT = script("""
            local old = redis.call('GET', KEYS[2])
            if old and old ~= ARGV[1] then redis.call('DEL', ARGV[3] .. old) end
            redis.call('SET', KEYS[1], ARGV[2], 'EX', ARGV[3 + 1])
            redis.call('SET', KEYS[2], ARGV[1], 'EX', ARGV[3 + 1])
            return 1
            """);
    private static final DefaultRedisScript<Long> UPDATE_SCRIPT = script("""
            if redis.call('GET', KEYS[2]) ~= ARGV[1] or redis.call('EXISTS', KEYS[1]) == 0 then return 0 end
            local ttl = redis.call('TTL', KEYS[1])
            if ttl <= 0 then ttl = tonumber(ARGV[3]) end
            redis.call('SET', KEYS[1], ARGV[2], 'EX', ttl)
            redis.call('EXPIRE', KEYS[2], ttl)
            return 1
            """);
    private static final DefaultRedisScript<Long> REVOKE_SCRIPT = script("""
            local payload = redis.call('GET', KEYS[1])
            redis.call('DEL', KEYS[1])
            if redis.call('GET', KEYS[2]) == ARGV[1] then redis.call('DEL', KEYS[2]) end
            return payload and 1 or 0
            """);
    private static final DefaultRedisScript<Long> REVOKE_USER_SCRIPT = script("""
            local token = redis.call('GET', KEYS[1])
            if token then redis.call('DEL', ARGV[1] .. token) end
            redis.call('DEL', KEYS[1])
            return token and 1 or 0
            """);

    private final StringRedisTemplate redis;
    private final ObjectMapper mapper = new ObjectMapper();
    private final long ttlSeconds;
    private final ConcurrentHashMap<String, Entry> memory = new ConcurrentHashMap<>();
    private final ConcurrentHashMap<Long, UserTokenEntry> userTokens = new ConcurrentHashMap<>();
    private final Object memoryLock = new Object();

    public TokenStore(@Autowired(required = false) StringRedisTemplate redis,
                      @Value("${studentoj.auth.token.ttl-seconds:86400}") long ttlSeconds) {
        this.redis = redis;
        this.ttlSeconds = ttlSeconds;
    }

    public String issue(LoginResponse user) {
        String token = UUID.randomUUID().toString().replace("-", "");
        String payload = serialize(withToken(user, token));
        if (redis != null) {
            redis.execute(ISSUE_SCRIPT,
                    List.of(KEY_PREFIX + token, userTokenKey(user.userId())),
                    token, payload, KEY_PREFIX, Long.toString(ttlSeconds));
        } else {
            synchronized (memoryLock) {
                Instant expireAt = Instant.now().plusSeconds(ttlSeconds);
                UserTokenEntry old = currentUserToken(user.userId());
                if (old != null) memory.remove(old.token());
                memory.put(token, new Entry(payload, expireAt));
                userTokens.put(user.userId(), new UserTokenEntry(token, expireAt));
            }
        }
        return token;
    }

    public LoginResponse resolve(String token) {
        LoginResponse user = readToken(token);
        if (user == null) return null;
        if (!token.equals(currentToken(user.userId()))) {
            deleteToken(token);
            return null;
        }
        return user;
    }

    public void update(String token, LoginResponse user) {
        if (token == null || token.isBlank()) return;
        String payload = serialize(withToken(user, token));
        if (redis != null) {
            redis.execute(UPDATE_SCRIPT, List.of(KEY_PREFIX + token, userTokenKey(user.userId())),
                    token, payload, Long.toString(ttlSeconds));
        } else {
            synchronized (memoryLock) {
                UserTokenEntry current = currentUserToken(user.userId());
                Entry existing = memory.get(token);
                if (current == null || !token.equals(current.token()) || existing == null) return;
                memory.put(token, new Entry(payload, existing.expireAt()));
            }
        }
    }

    public void revoke(String token) {
        if (token == null || token.isBlank()) return;
        LoginResponse user = readToken(token);
        if (redis != null) {
            if (user != null) redis.execute(REVOKE_SCRIPT,
                    List.of(KEY_PREFIX + token, userTokenKey(user.userId())), token);
            else redis.delete(KEY_PREFIX + token);
        } else {
            synchronized (memoryLock) {
                memory.remove(token);
                if (user != null) userTokens.computeIfPresent(user.userId(),
                        (ignored, current) -> token.equals(current.token()) ? null : current);
            }
        }
    }

    public void revokeUser(Long userId) {
        if (userId == null || userId <= 0) return;
        if (redis != null) {
            redis.execute(REVOKE_USER_SCRIPT, List.of(userTokenKey(userId)), KEY_PREFIX);
        } else {
            synchronized (memoryLock) {
                UserTokenEntry current = userTokens.remove(userId);
                if (current != null) memory.remove(current.token());
            }
        }
    }

    private LoginResponse readToken(String token) {
        if (token == null || token.isBlank()) return null;
        String raw;
        if (redis != null) raw = redis.opsForValue().get(KEY_PREFIX + token);
        else {
            Entry entry = memory.get(token);
            if (entry == null || entry.expireAt().isBefore(Instant.now())) {
                memory.remove(token);
                return null;
            }
            raw = entry.payload();
        }
        if (raw == null) return null;
        try { return mapper.readValue(raw, LoginResponse.class); }
        catch (JsonProcessingException e) { return null; }
    }

    private void deleteToken(String token) {
        if (redis != null) redis.delete(KEY_PREFIX + token); else memory.remove(token);
    }

    private String currentToken(Long userId) {
        if (userId == null) return null;
        if (redis != null) return redis.opsForValue().get(userTokenKey(userId));
        UserTokenEntry current = currentUserToken(userId);
        return current == null ? null : current.token();
    }

    private UserTokenEntry currentUserToken(Long userId) {
        UserTokenEntry current = userTokens.get(userId);
        if (current != null && current.expireAt().isBefore(Instant.now())) {
            userTokens.remove(userId, current);
            memory.remove(current.token());
            return null;
        }
        return current;
    }

    private String serialize(LoginResponse user) {
        try { return mapper.writeValueAsString(user); }
        catch (JsonProcessingException e) { throw new IllegalStateException("Failed to serialize token payload", e); }
    }

    private LoginResponse withToken(LoginResponse user, String token) {
        return new LoginResponse(token, user.userId(), user.username(), user.role(), user.realName(),
                user.studentNo(), user.email(), user.groupName(), user.status(), user.sessionVersion());
    }

    private String userTokenKey(Long userId) { return USER_TOKEN_KEY_PREFIX + userId; }

    private static DefaultRedisScript<Long> script(String source) {
        return new DefaultRedisScript<>(source, Long.class);
    }

    private record Entry(String payload, Instant expireAt) {}
    private record UserTokenEntry(String token, Instant expireAt) {}
}
