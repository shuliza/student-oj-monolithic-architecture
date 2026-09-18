package com.studentoj.ai.service;

import com.studentoj.ai.client.DeepSeekClient;
import com.studentoj.ai.dto.AiSuggestionRequest;
import com.studentoj.ai.dto.AiSuggestionResponse;
import com.studentoj.ai.entity.AiSuggestionEntity;
import com.studentoj.ai.mapper.AiSuggestionMapper;
import com.studentoj.problem.mapper.ProblemMapper;
import com.studentoj.problem.mapper.SubmissionMapper;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class AiService {

    private static final Logger log = LoggerFactory.getLogger(AiService.class);
    private static final DateTimeFormatter TS_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final AiSuggestionMapper mapper;
    private final RuleSuggestionGenerator generator;
    private final DeepSeekClient deepSeekClient;
    private final SubmissionMapper submissionMapper;
    private final ProblemMapper problemMapper;
    private final String mode;

    public AiService(AiSuggestionMapper mapper,
                     RuleSuggestionGenerator generator,
                     DeepSeekClient deepSeekClient,
                     SubmissionMapper submissionMapper,
                     ProblemMapper problemMapper,
                     @Value("${studentoj.ai.mode:auto}") String mode) {
        this.mapper = mapper;
        this.generator = generator;
        this.deepSeekClient = deepSeekClient;
        this.submissionMapper = submissionMapper;
        this.problemMapper = problemMapper;
        this.mode = mode == null ? "auto" : mode.trim().toLowerCase();
    }

    public AiSuggestionResponse generate(Long userId, AiSuggestionRequest request) {
        if (request == null || request.submissionId() == null || request.submissionId() <= 0) {
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.BAD_REQUEST, "提交记录 ID 不能为空");
        }
        Long safeUserId = userId == null ? 0L : userId;

        // 从后端数据库查询提交快照，不信任前端传入的历史元数据
        com.studentoj.problem.entity.SubmissionEntity submission = submissionMapper.selectById(request.submissionId());
        if (submission == null || !safeUserId.equals(submission.getUserId())) {
            throw new org.springframework.web.server.ResponseStatusException(
                    org.springframework.http.HttpStatus.NOT_FOUND, "提交记录不存在");
        }
        com.studentoj.problem.entity.ProblemEntity problem = problemMapper.selectById(submission.getProblemId());
        String problemTitle = problem == null ? "" : problem.getTitle();
        String studentSql = submission.getSqlContent() == null ? "" : submission.getSqlContent();
        String judgeStatus = submission.getStatus() == null ? "" : submission.getStatus();
        String errorMessage = submission.getMessage() == null ? "" : submission.getMessage();

        // 使用脱敏和限长后的数据生成建议
        AiSuggestionRequest snapshot = new AiSuggestionRequest(
                submission.getId(), submission.getProblemId(),
                truncate(problemTitle, 120), truncate(studentSql, 2000),
                judgeStatus, judgeStatus, truncate(errorMessage, 500), truncate(studentSql, 2000));
        String suggestion = resolveSuggestion(snapshot);

        AiSuggestionEntity entity = new AiSuggestionEntity();
        entity.setUserId(safeUserId);
        entity.setSubmissionId(submission.getId());
        entity.setProblemId(submission.getProblemId());
        entity.setSuggestion(suggestion);
        entity.setCreatedAt(LocalDateTime.now());
        mapper.insert(entity);

        return toResponse(entity);
    }

    /**
     * mode=deepseek 仅用大模型；mode=rule 仅用规则；mode=auto（默认）DeepSeek 优先、失败回退规则。
     */
    private String resolveSuggestion(AiSuggestionRequest request) {
        boolean useDeepSeek = ("deepseek".equals(mode) || "auto".equals(mode)) && deepSeekClient.isConfigured();
        if (useDeepSeek) {
            try {
                return deepSeekClient.generate(request);
            } catch (Exception e) {
                log.warn("DeepSeek 调用失败，回退规则生成器: {}", e.getMessage());
                if ("deepseek".equals(mode)) {
                    return "AI 服务暂时不可用，请稍后重试。系统提示：" + generator.generate(request);
                }
            }
        }
        return generator.generate(request);
    }

    private static String truncate(String value, int maxLength) {
        if (value == null) return "";
        return value.length() <= maxLength ? value : value.substring(0, maxLength);
    }

    public List<AiSuggestionResponse> history(Long userId, Long problemId) {
        if (userId == null || userId <= 0 || problemId == null || problemId <= 0) {
            return List.of();
        }
        return mapper.selectLatestByUserAndProblem(userId, problemId).stream()
                .map(this::toResponse)
                .toList();
    }

    private AiSuggestionResponse toResponse(AiSuggestionEntity entity) {
        return new AiSuggestionResponse(
                entity.getId(),
                entity.getUserId(),
                entity.getSubmissionId(),
                entity.getProblemId(),
                entity.getSuggestion(),
                entity.getCreatedAt() == null ? null : entity.getCreatedAt().format(TS_FMT)
        );
    }
}
