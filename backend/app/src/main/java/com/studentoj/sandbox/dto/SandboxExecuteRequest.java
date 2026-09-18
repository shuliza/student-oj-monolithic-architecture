package com.studentoj.sandbox.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/** Internal worker DTO; never deserialize this shape from a student endpoint. */
@JsonIgnoreProperties(ignoreUnknown = false)
public record SandboxExecuteRequest(String initSql, String answerSql, String studentSql) {
}
