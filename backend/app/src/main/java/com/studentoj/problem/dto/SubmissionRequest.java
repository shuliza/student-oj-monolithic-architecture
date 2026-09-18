package com.studentoj.problem.dto;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/** Student input intentionally contains no identity or reference SQL fields. */
@JsonIgnoreProperties(ignoreUnknown = false)
public record SubmissionRequest(Long problemId, @JsonAlias({"sql", "sqlContent", "studentSql"}) String sqlContent) {
}
