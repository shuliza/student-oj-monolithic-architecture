package com.studentoj.problem.controller;

import com.studentoj.common.auth.AuthContext;
import com.studentoj.common.auth.RequireRole;
import com.studentoj.common.auth.Role;
import com.studentoj.problem.dto.ProblemResponse;
import com.studentoj.problem.dto.SandboxExecuteResponse;
import com.studentoj.problem.dto.SubmissionRequest;
import com.studentoj.problem.dto.SubmissionResponse;
import com.studentoj.problem.service.ProblemService;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
public class ProblemController {

    private final ProblemService problemService;

    public ProblemController(ProblemService problemService) {
        this.problemService = problemService;
    }

    @GetMapping("/api/problem/list")
    @RequireRole(Role.STUDENT)
    public List<ProblemResponse> list() {
        return problemService.list(AuthContext.userId());
    }

    @GetMapping("/api/problem/{id}")
    @RequireRole(Role.STUDENT)
    public ProblemResponse detail(@PathVariable("id") Long id) {
        return problemService.detail(id, AuthContext.userId());
    }

    @GetMapping("/api/sql-problems/{id}")
    @RequireRole(Role.STUDENT)
    public ProblemResponse sqlProblemDetail(@PathVariable("id") Long id) {
        return problemService.detail(id, AuthContext.userId());
    }

    @PostMapping("/api/submission/judge")
    @RequireRole(Role.STUDENT)
    public SubmissionResponse submit(@RequestBody SubmissionRequest request) {
        return problemService.submit(new SubmissionRequest(request.problemId(), request.sqlContent()), AuthContext.userId());
    }

    @PostMapping("/api/sql-judge/submit")
    @RequireRole(Role.STUDENT)
    public SubmissionResponse sqlJudgeSubmit(@RequestBody SubmissionRequest request) {
        return submit(request);
    }

    @PostMapping("/api/submission/run")
    @RequireRole(Role.STUDENT)
    public SandboxExecuteResponse run(@RequestBody SubmissionRequest request) {
        return problemService.trialRun(AuthContext.userId(), request.problemId(), request.sqlContent());
    }

    @GetMapping("/api/submission/list")
    @RequireRole(Role.TEACHER)
    public List<SubmissionResponse> list(
            @RequestParam(value = "groupName", required = false) String groupName,
            @RequestParam(value = "studentId", required = false) Long studentId) {
        return problemService.recent(groupName, studentId);
    }

    @GetMapping("/api/submission/mine")
    @RequireRole(Role.STUDENT)
    public List<SubmissionResponse> mine() {
        return problemService.mine(AuthContext.userId());
    }

    @GetMapping("/api/sql-judge/history")
    @RequireRole(Role.STUDENT)
    public List<SubmissionResponse> sqlJudgeHistory() {
        return problemService.mine(AuthContext.userId());
    }

    @GetMapping("/api/submission/{id}")
    @RequireRole({Role.STUDENT, Role.TEACHER})
    public SubmissionResponse one(@PathVariable("id") Long id) {
        SubmissionResponse submission = problemService.getSubmission(id);
        if (!AuthContext.isTeacher() && !AuthContext.userId().equals(submission.userId())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No permission to access this submission");
        }
        return submission;
    }

    @GetMapping("/api/sql-judge/history/{id}")
    @RequireRole({Role.STUDENT, Role.TEACHER})
    public SubmissionResponse sqlJudgeHistoryOne(@PathVariable("id") Long id) {
        return one(id);
    }
}
