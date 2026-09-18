package com.studentoj.problem.service;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.studentoj.judge.dto.JudgeRequest;
import com.studentoj.judge.service.JudgeService;
import com.studentoj.common.web.HtmlSanitizer;
import com.studentoj.problem.dto.ProblemResponse;
import com.studentoj.problem.dto.SandboxExecuteResponse;
import com.studentoj.problem.dto.SubmissionRequest;
import com.studentoj.problem.dto.SubmissionResponse;
import com.studentoj.problem.entity.ProblemEntity;
import com.studentoj.problem.entity.SubmissionEntity;
import com.studentoj.problem.mapper.ProblemMapper;
import com.studentoj.problem.mapper.SubmissionMapper;
import com.studentoj.sandbox.dto.SandboxExecuteRequest;
import com.studentoj.sandbox.service.SandboxService;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class ProblemService {

    private static final DateTimeFormatter TS_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final ProblemMapper problemMapper;
    private final SubmissionMapper submissionMapper;
    private final JudgeService judgeService;
    private final SandboxService sandboxService;
    private final RunRateLimiter runRateLimiter;
    private volatile CacheEntry<List<ProblemEntity>> activeProblemsCache;
    private volatile CacheEntry<Map<Long, Map<String, Object>>> statsCache;

    @Value("${studentoj.problem.cache-ttl-ms:15000}")
    private long problemCacheTtlMs;

    public ProblemService(ProblemMapper problemMapper, SubmissionMapper submissionMapper,
                          JudgeService judgeService, SandboxService sandboxService,
                          RunRateLimiter runRateLimiter) {
        this.problemMapper = problemMapper;
        this.submissionMapper = submissionMapper;
        this.judgeService = judgeService;
        this.sandboxService = sandboxService;
        this.runRateLimiter = runRateLimiter;
    }

    public List<ProblemResponse> list(Long viewerUserId) {
        List<ProblemEntity> problems = activeProblems();
        Map<Long, Map<String, Object>> stats = indexStats();
        Map<Long, Integer> userState = userStateMap(viewerUserId);

        return problems.stream().map(p -> toResponse(p, stats.get(p.getId()), userState.get(p.getId()))).toList();
    }

    public ProblemResponse detail(Long id, Long viewerUserId) {
        ProblemEntity entity = problemMapper.selectById(id);
        if (entity == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "题目不存在");
        }
        Map<Long, Map<String, Object>> stats = indexStats();
        Map<Long, Integer> userState = userStateMap(viewerUserId);
        return toResponse(entity, stats.get(entity.getId()), userState.get(entity.getId()));
    }

    public SubmissionResponse submit(SubmissionRequest request, Long authenticatedUserId) {
        if (request == null || request.problemId() == null || request.sqlContent() == null || request.sqlContent().isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "提交内容不完整");
        }
        ProblemEntity problem = problemMapper.selectById(request.problemId());
        if (problem == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "题目不存在");
        }

        if (authenticatedUserId == null || authenticatedUserId <= 0) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "未认证用户不能提交");
        }
        Long userId = authenticatedUserId;
        SubmissionEntity entity = new SubmissionEntity();
        entity.setUserId(userId);
        entity.setProblemId(request.problemId());
        entity.setSqlContent(request.sqlContent());
        entity.setStatus("PENDING");
        entity.setScore(0);
        entity.setRuntimeMs(0);
        entity.setMessage("正在判题");
        entity.setSubmittedAt(LocalDateTime.now());
        submissionMapper.insert(entity);

        // 单体内同步判题：JudgeService 会在执行后直接更新本条 submission 记录及学生活跃度。
        judgeService.judge(new JudgeRequest(entity.getId(), userId, request.problemId(), request.sqlContent()));

        // 重新读取判题后的最终状态返回给前端。
        SubmissionEntity judged = submissionMapper.selectById(entity.getId());
        if (judged == null) {
            judged = entity;
        }
        return new SubmissionResponse(
                judged.getId(),
                judged.getProblemId(),
                problem.getTitle(),
                judged.getUserId(),
                null,
                judged.getStatus(),
                judged.getScore() == null ? 0 : judged.getScore(),
                judged.getRuntimeMs() == null ? 0 : judged.getRuntimeMs(),
                (judged.getSubmittedAt() == null ? entity.getSubmittedAt() : judged.getSubmittedAt()).format(TS_FMT),
                judged.getMessage()
        );
    }

    /**
     * 试运行：同步在沙箱中执行学生 SQL（沙箱仍做白名单/危险拦截），与参考答案比对结果，
     * 不落库、不进 MQ。用于编辑器「运行」按钮，给学生即时反馈。
     */
    public SandboxExecuteResponse trialRun(Long userId, Long problemId, String sqlContent) {
        if (!runRateLimiter.tryAcquire(userId)) {
            long retryMs = runRateLimiter.retryAfter(userId).toMillis();
            throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS,
                    "Run too frequently. Please retry after " + retryMs + " ms.");
        }
        if (problemId == null || sqlContent == null || sqlContent.isBlank()) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "运行内容不完整");
        }
        ProblemEntity problem = problemMapper.selectById(problemId);
        if (problem == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "题目不存在");
        }
        com.studentoj.sandbox.dto.SandboxExecuteResponse resp = sandboxService.execute(
                new SandboxExecuteRequest(problem.getInitSql(), problem.getAnswerSql(), sqlContent));
        return new SandboxExecuteResponse(
                resp.status(), resp.runtimeMs(), resp.message(),
                resp.match(), resp.columns(), resp.rows());
    }

    public List<SubmissionResponse> recent(String groupName, Long studentId) {
        String normalizedGroupName = groupName == null || groupName.isBlank() ? null : groupName.trim();
        Long normalizedStudentId = studentId == null || studentId <= 0 ? null : studentId;
        return submissionMapper.selectRecent(normalizedGroupName, normalizedStudentId).stream().map(this::rowToSubmission).toList();
    }

    public List<SubmissionResponse> mine(Long userId) {
        if (userId == null || userId <= 0) {
            return List.of();
        }
        return submissionMapper.selectByUser(userId).stream().map(this::rowToSubmission).toList();
    }

    public SubmissionResponse getSubmission(Long id) {
        SubmissionEntity entity = submissionMapper.selectById(id);
        if (entity == null) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "提交记录不存在");
        }
        ProblemEntity problem = problemMapper.selectById(entity.getProblemId());
        return new SubmissionResponse(
                entity.getId(),
                entity.getProblemId(),
                problem == null ? null : problem.getTitle(),
                entity.getUserId(),
                null,
                entity.getStatus(),
                entity.getScore(),
                entity.getRuntimeMs(),
                entity.getSubmittedAt() == null ? null : entity.getSubmittedAt().format(TS_FMT),
                entity.getMessage()
        );
    }

    private ProblemResponse toResponse(ProblemEntity entity, Map<String, Object> stats, Integer userState) {
        List<String> tags = entity.getTags() == null || entity.getTags().isBlank()
                ? List.of()
                : Arrays.stream(entity.getTags().split(",")).map(String::trim).filter(s -> !s.isEmpty()).toList();
        int submissions = stats == null ? 0 : ((Number) stats.getOrDefault("submissions", 0)).intValue();
        int passRate = stats == null ? 0 : ((Number) stats.getOrDefault("pass_rate", 0)).intValue();
        String status = "TODO";
        if (userState != null) {
            status = userState == 2 ? "ACCEPTED" : "FAILED";
        }
        return new ProblemResponse(
                entity.getId(),
                entity.getTitle(),
                entity.getDifficulty(),
                tags,
                passRate,
                submissions,
                status,
                HtmlSanitizer.cleanDescription(entity.getDescription()),
                entity.getSampleInput(),
                entity.getSampleOutput()
        );
    }

    private SubmissionResponse rowToSubmission(Map<String, Object> row) {
        Object submittedAt = row.get("submitted_at");
        String submittedStr = null;
        if (submittedAt instanceof LocalDateTime ldt) {
            submittedStr = ldt.format(TS_FMT);
        } else if (submittedAt instanceof java.sql.Timestamp ts) {
            submittedStr = ts.toLocalDateTime().format(TS_FMT);
        } else if (submittedAt != null) {
            submittedStr = submittedAt.toString();
        }
        return new SubmissionResponse(
                ((Number) row.get("id")).longValue(),
                row.get("problem_id") == null ? null : ((Number) row.get("problem_id")).longValue(),
                (String) row.get("problem_title"),
                row.get("user_id") == null ? null : ((Number) row.get("user_id")).longValue(),
                (String) row.get("user_name"),
                (String) row.get("status"),
                row.get("score") == null ? 0 : ((Number) row.get("score")).intValue(),
                row.get("runtime_ms") == null ? 0 : ((Number) row.get("runtime_ms")).intValue(),
                submittedStr,
                (String) row.get("message")
        );
    }

    private Map<Long, Map<String, Object>> indexStats() {
        CacheEntry<Map<Long, Map<String, Object>>> cached = statsCache;
        if (cached != null && !cached.expired()) {
            return cached.value();
        }
        Map<Long, Map<String, Object>> fresh = problemMapper.selectStats().stream().collect(Collectors.toMap(
                row -> ((Number) row.get("problem_id")).longValue(),
                row -> row
        ));
        statsCache = new CacheEntry<>(fresh, System.currentTimeMillis() + Math.max(0, problemCacheTtlMs));
        return fresh;
    }

    private List<ProblemEntity> activeProblems() {
        CacheEntry<List<ProblemEntity>> cached = activeProblemsCache;
        if (cached != null && !cached.expired()) {
            return cached.value();
        }
        List<ProblemEntity> fresh = problemMapper.selectList(
                new QueryWrapper<ProblemEntity>().eq("status", 1).orderByAsc("id"));
        activeProblemsCache = new CacheEntry<>(List.copyOf(fresh), System.currentTimeMillis() + Math.max(0, problemCacheTtlMs));
        return fresh;
    }

    private Map<Long, Integer> userStateMap(Long userId) {
        if (userId == null || userId <= 0) {
            return new HashMap<>();
        }
        return problemMapper.selectUserState(userId).stream().collect(Collectors.toMap(
                row -> ((Number) row.get("problem_id")).longValue(),
                row -> ((Number) row.get("best_state")).intValue()
        ));
    }

    private record CacheEntry<T>(T value, long expiresAt) {
        boolean expired() {
            return System.currentTimeMillis() >= expiresAt;
        }
    }
}
