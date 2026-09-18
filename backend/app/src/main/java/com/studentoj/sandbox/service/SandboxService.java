package com.studentoj.sandbox.service;

import com.studentoj.sandbox.dto.SandboxExecuteRequest;
import com.studentoj.sandbox.dto.SandboxExecuteResponse;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.SQLTimeoutException;
import java.sql.Statement;
import java.util.LinkedHashSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.util.regex.Pattern;
import javax.sql.DataSource;
import jakarta.annotation.PostConstruct;
import net.sf.jsqlparser.parser.CCJSqlParserUtil;
import net.sf.jsqlparser.statement.select.Select;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

@Service
public class SandboxService {

    private static final Logger log = LoggerFactory.getLogger(SandboxService.class);

    private static final Pattern DANGEROUS_SELECT = Pattern.compile(
            "\\b(load_file|sleep|benchmark)\\s*\\(|\\binto\\s+(out|dump)file\\b",
            Pattern.CASE_INSENSITIVE);

    private final DataSource dataSource;

    @Value("${studentoj.sandbox.query-timeout-seconds:3}")
    private int queryTimeoutSeconds;

    @Value("${studentoj.sandbox.max-rows:5000}")
    private int maxRows;

    @Value("${studentoj.sandbox.max-concurrent-executions:16}")
    private int maxConcurrentExecutions;

    @Value("${studentoj.sandbox.acquire-timeout-ms:1500}")
    private long acquireTimeoutMs;

    @Value("${studentoj.sandbox.max-sql-bytes:65536}")
    private int maxSqlBytes;

    @Value("${studentoj.sandbox.max-init-statements:64}")
    private int maxInitStatements;

    public SandboxService(@org.springframework.beans.factory.annotation.Qualifier("sandboxDataSource") DataSource dataSource) {
        this.dataSource = dataSource;
    }

    private Semaphore executionSlots;

    @PostConstruct
    void initConcurrencyLimiter() {
        executionSlots = new Semaphore(Math.max(1, maxConcurrentExecutions));
    }

    public SandboxExecuteResponse execute(SandboxExecuteRequest request) {
        boolean acquired = false;
        try {
            acquired = executionSlots.tryAcquire(Math.max(0, acquireTimeoutMs), TimeUnit.MILLISECONDS);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return response("RUNTIME_ERROR", 0, "Sandbox execution interrupted.", false, null);
        }
        if (!acquired) {
            return response("SYSTEM_BUSY", 0, "Sandbox is busy. Please retry later.", false, null);
        }
        try {
            return executeInternal(request);
        } finally {
            executionSlots.release();
        }
    }

    private SandboxExecuteResponse executeInternal(SandboxExecuteRequest request) {
        if (request == null || isBlank(request.studentSql())) {
            return response("RUNTIME_ERROR", 0, "Student SQL must not be empty.", false, null);
        }
        if (isBlank(request.answerSql())) {
            return response("RUNTIME_ERROR", 0, "Reference answer SQL is missing.", false, null);
        }
        if (utf8Length(request.studentSql()) > maxSqlBytes || utf8Length(request.answerSql()) > maxSqlBytes
                || utf8Length(request.initSql()) > maxSqlBytes) {
            return response("REQUEST_TOO_LARGE", 0, "SQL input exceeds the configured limit.", false, null);
        }
        String trustedError = validateTrustedScripts(request.initSql(), request.answerSql());
        if (trustedError != null) return response("RUNTIME_ERROR", 0, trustedError, false, null);

        String studentSql = trimTrailingSemicolon(request.studentSql());
        String validationError = validateStudentSql(studentSql);
        if (validationError != null) {
            return response("RUNTIME_ERROR", 0, validationError, false, null);
        }

        String databaseName = "oj_run_" + UUID.randomUUID().toString().replace("-", "");
        long started = System.currentTimeMillis();
        try (Connection admin = dataSource.getConnection()) {
            createDatabase(admin, databaseName);
            try (Connection runConnection = dataSource.getConnection()) {
                runConnection.setCatalog(databaseName);
                configureRunSession(runConnection);
                runConnection.setAutoCommit(false);
                executeSqlScript(runConnection, request.initSql());
                createTableCaseAliases(runConnection);

                QueryResult studentResult = runQuery(runConnection, studentSql);
                QueryResult expectedResult = runQuery(runConnection, request.answerSql());
                int runtime = Math.toIntExact(Math.min(Integer.MAX_VALUE, System.currentTimeMillis() - started));

                if (studentResult.truncated() || expectedResult.truncated()) {
                    return response("RESULT_LIMIT_EXCEEDED", runtime,
                            "Result exceeds the maximum of " + maxRows + " rows.", false, studentResult);
                }

                boolean orderSensitive = hasOrderBy(request.answerSql());
                boolean match = compare(studentResult, expectedResult, orderSensitive);
                if (match) {
                    return response("ACCEPTED", runtime, "Accepted.", true, studentResult);
                }
                String message = describeMismatch(studentResult, expectedResult);
                return response("WRONG_ANSWER", runtime, message, false, studentResult);
            } finally {
                dropDatabaseQuietly(admin, databaseName);
            }
        } catch (SQLTimeoutException e) {
            log.warn("Sandbox query timeout: {}", e.getMessage());
            return response("TIME_LIMIT_EXCEEDED", queryTimeoutSeconds * 1000, "Query timed out.", false, null);
        } catch (SQLException e) {
            log.warn("Sandbox SQL error: {}", e.getMessage());
            return response("RUNTIME_ERROR", 0, "SQL execution failed: " + e.getMessage(), false, null);
        } catch (Exception e) {
            log.error("Sandbox unexpected error", e);
            return response("RUNTIME_ERROR", 0, "Sandbox execution failed: " + e.getMessage(), false, null);
        }
    }

    private String validateStudentSql(String sql) {
        try {
            var statements = CCJSqlParserUtil.parseStatements(sql).getStatements();
            if (statements.size() != 1) {
                return "Only one SQL statement is allowed.";
            }
            if (!(statements.get(0) instanceof Select)) {
                return "Only SELECT/WITH queries are allowed.";
            }
            return DANGEROUS_SELECT.matcher(stripSqlLiteralsAndComments(sql)).find()
                    ? "Dangerous SQL function or output clause detected."
                    : null;
        } catch (Exception e) {
            return "SQL parse failed: " + e.getMessage();
        }
    }

    private void configureRunSession(Connection conn) throws SQLException {
        try (Statement statement = conn.createStatement()) {
            statement.execute("SET SESSION sql_mode = "
                    + "REPLACE(REPLACE(REPLACE(@@SESSION.sql_mode, 'ONLY_FULL_GROUP_BY,', ''), "
                    + "',ONLY_FULL_GROUP_BY', ''), 'ONLY_FULL_GROUP_BY', '')");
        }
    }

    private void createDatabase(Connection conn, String databaseName) throws SQLException {
        try (Statement statement = conn.createStatement()) {
            statement.execute("CREATE DATABASE `" + databaseName + "` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci");
        }
    }

    private void dropDatabaseQuietly(Connection conn, String databaseName) {
        try (Statement statement = conn.createStatement()) {
            statement.execute("DROP DATABASE IF EXISTS `" + databaseName + "`");
        } catch (Exception e) {
            log.warn("Failed to drop sandbox database {}: {}", databaseName, e.getMessage());
        }
    }

    private String validateTrustedScripts(String initSql, String answerSql) {
        if (isBlank(initSql) || isBlank(answerSql)) return "Trusted testcase SQL is missing.";
        try {
            if (splitStatements(initSql).size() > maxInitStatements) return "Too many initialization statements.";
            var answer = CCJSqlParserUtil.parseStatements(trimTrailingSemicolon(answerSql)).getStatements();
            if (answer.size() != 1 || !(answer.get(0) instanceof Select)) return "Reference answer must be one SELECT/WITH statement.";
            String normalized = stripSqlLiteralsAndComments(answerSql).toLowerCase();
            if (normalized.matches("(?s).*\\b(load_file|sleep|benchmark)\\s*\\(.*") || normalized.contains(" into outfile") || normalized.contains(" into dumpfile")) return "Unsafe reference answer SQL.";
            for (String statement : splitStatements(initSql)) {
                String s = stripSqlLiteralsAndComments(statement).trim().toLowerCase();
                if (!s.matches("(?s)^(create\\s+table|insert\\s+into|alter\\s+table|drop\\s+table|truncate\\s+table)\\b.*")) return "Unsafe initialization statement.";
            }
            return null;
        } catch (Exception e) { return "Trusted testcase SQL validation failed."; }
    }

    private int utf8Length(String value) { return value == null ? 0 : value.getBytes(java.nio.charset.StandardCharsets.UTF_8).length; }

    private void executeSqlScript(Connection conn, String sqlScript) throws SQLException {
        if (isBlank(sqlScript)) {
            return;
        }
        try (Statement statement = conn.createStatement()) {
            statement.setQueryTimeout(queryTimeoutSeconds);
            for (String piece : splitStatements(sqlScript)) {
                String sql = piece.trim();
                if (!sql.isEmpty()) {
                    statement.execute(sql);
                }
            }
        }
    }

    private void createTableCaseAliases(Connection conn) throws SQLException {
        List<String> tableNames = new ArrayList<>();
        try (ResultSet rs = conn.getMetaData().getTables(conn.getCatalog(), null, "%", new String[]{"TABLE"})) {
            while (rs.next()) {
                tableNames.add(rs.getString("TABLE_NAME"));
            }
        }

        try (Statement statement = conn.createStatement()) {
            statement.setQueryTimeout(queryTimeoutSeconds);
            for (String tableName : tableNames) {
                for (String alias : caseAliases(tableName)) {
                    if (!alias.equals(tableName)) {
                        try {
                            statement.execute("CREATE VIEW " + quoteIdentifier(alias)
                                    + " AS SELECT * FROM " + quoteIdentifier(tableName));
                        } catch (SQLException e) {
                            // Ignore aliases that already exist or cannot be created; the original table remains usable.
                            log.debug("Skipped table alias {} for {}: {}", alias, tableName, e.getMessage());
                        }
                    }
                }
            }
        }
    }

    private LinkedHashSet<String> caseAliases(String tableName) {
        LinkedHashSet<String> aliases = new LinkedHashSet<>();
        if (isBlank(tableName)) {
            return aliases;
        }
        aliases.add(tableName);
        aliases.add(tableName.toLowerCase());
        aliases.add(tableName.toUpperCase());
        aliases.add(Character.toUpperCase(tableName.charAt(0)) + tableName.substring(1));
        aliases.add(Character.toLowerCase(tableName.charAt(0)) + tableName.substring(1));
        return aliases;
    }

    private String quoteIdentifier(String identifier) {
        return "`" + identifier.replace("`", "``") + "`";
    }

    private QueryResult runQuery(Connection conn, String sql) throws SQLException {
        try (Statement statement = conn.createStatement()) {
            statement.setQueryTimeout(queryTimeoutSeconds);
            statement.setMaxRows(maxRows == Integer.MAX_VALUE ? maxRows : maxRows + 1);
            try (ResultSet rs = statement.executeQuery(trimTrailingSemicolon(sql))) {
                ResultSetMetaData meta = rs.getMetaData();
                int count = meta.getColumnCount();
                List<String> columns = new ArrayList<>(count);
                for (int i = 1; i <= count; i++) {
                    String label = meta.getColumnLabel(i);
                    columns.add(label == null || label.isBlank() ? meta.getColumnName(i) : label);
                }

                List<Map<String, Object>> rows = new ArrayList<>();
                List<List<Object>> valueRows = new ArrayList<>();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    List<Object> values = new ArrayList<>(count);
                    for (int i = 1; i <= count; i++) {
                        Object value = normalizeValue(rs.getObject(i));
                        values.add(value);
                        row.put(uniqueColumnName(columns.get(i - 1), i, row), value);
                    }
                    rows.add(row);
                    valueRows.add(values);
                }
                boolean truncated = rows.size() > maxRows;
                if (truncated) {
                    rows = new ArrayList<>(rows.subList(0, maxRows));
                    valueRows = new ArrayList<>(valueRows.subList(0, maxRows));
                }
                return new QueryResult(columns, rows, valueRows, truncated);
            }
        }
    }

    private String uniqueColumnName(String label, int position, Map<String, Object> row) {
        if (!row.containsKey(label)) {
            return label;
        }
        String candidate = label + " (" + position + ")";
        while (row.containsKey(candidate)) {
            candidate += "_";
        }
        return candidate;
    }

    /**
     * 判题以「测试用例结果集是否一致」为准，不要求与参考答案的列别名完全相同：
     * 仅比较列数与单元格取值。当参考答案带 ORDER BY 时行序敏感（按序逐行比较），
     * 否则按多重集合（行内容计数）比较，允许学生 SQL 返回不同的行序。
     */
    private boolean compare(QueryResult actual, QueryResult expected, boolean orderSensitive) {
        if (actual.truncated() || expected.truncated()) {
            return false;
        }
        if (actual.columns().size() != expected.columns().size()) {
            return false;
        }
        if (actual.rows().size() != expected.rows().size()) {
            return false;
        }
        List<List<Object>> actualRows = actual.valueRows();
        List<List<Object>> expectedRows = expected.valueRows();
        if (orderSensitive) {
            return actualRows.equals(expectedRows);
        }
        return asMultiset(actualRows).equals(asMultiset(expectedRows));
    }

    private Map<List<Object>, Integer> asMultiset(List<List<Object>> rows) {
        Map<List<Object>, Integer> counts = new HashMap<>();
        for (List<Object> row : rows) {
            counts.merge(row, 1, Integer::sum);
        }
        return counts;
    }

    private boolean hasOrderBy(String sql) {
        if (isBlank(sql)) {
            return false;
        }
        try {
            net.sf.jsqlparser.statement.Statement statement = CCJSqlParserUtil.parse(trimTrailingSemicolon(sql));
            return statement instanceof Select select
                    && select.getOrderByElements() != null
                    && !select.getOrderByElements().isEmpty();
        } catch (Exception e) {
            return false;
        }
    }

    private String stripSqlLiteralsAndComments(String sql) {
        StringBuilder normalized = new StringBuilder(sql.length());
        boolean single = false;
        boolean doubleQuoted = false;
        boolean backtick = false;
        boolean lineComment = false;
        boolean blockComment = false;
        for (int i = 0; i < sql.length(); i++) {
            char ch = sql.charAt(i);
            char next = i + 1 < sql.length() ? sql.charAt(i + 1) : '\0';
            if (lineComment) {
                if (ch == '\n' || ch == '\r') {
                    lineComment = false;
                    normalized.append(' ');
                }
                continue;
            }
            if (blockComment) {
                if (ch == '*' && next == '/') {
                    blockComment = false;
                    i++;
                }
                continue;
            }
            if (!single && !doubleQuoted && !backtick && ch == '-' && next == '-') {
                lineComment = true;
                i++;
                continue;
            }
            if (!single && !doubleQuoted && !backtick && ch == '#') {
                lineComment = true;
                continue;
            }
            if (!single && !doubleQuoted && !backtick && ch == '/' && next == '*') {
                blockComment = true;
                i++;
                continue;
            }
            if (!doubleQuoted && !backtick && ch == '\'') {
                if (single && next == '\'') {
                    i++;
                } else {
                    single = !single;
                }
                normalized.append(' ');
                continue;
            }
            if (!single && !backtick && ch == '"') {
                doubleQuoted = !doubleQuoted;
                normalized.append(' ');
                continue;
            }
            if (!single && !doubleQuoted && ch == '`') {
                backtick = !backtick;
                normalized.append(' ');
                continue;
            }
            normalized.append(single || doubleQuoted || backtick ? ' ' : ch);
        }
        return normalized.toString();
    }

    private String describeMismatch(QueryResult actual, QueryResult expected) {
        if (actual.columns().size() != expected.columns().size()) {
            return "Wrong answer. Your result has " + actual.columns().size()
                    + " column(s), expected " + expected.columns().size() + " column(s).";
        }
        return "Wrong answer. Your result has " + actual.rows().size()
                + " row(s), expected " + expected.rows().size() + " row(s).";
    }

    private Object normalizeValue(Object value) {
        if (value instanceof BigDecimal decimal) {
            return decimal.stripTrailingZeros().toPlainString();
        }
        if (value instanceof Number number) {
            return new BigDecimal(number.toString()).stripTrailingZeros().toPlainString();
        }
        return value;
    }

    private List<String> splitStatements(String sqlScript) {
        List<String> statements = new ArrayList<>();
        StringBuilder current = new StringBuilder();
        boolean singleQuoted = false;
        boolean doubleQuoted = false;
        for (int i = 0; i < sqlScript.length(); i++) {
            char ch = sqlScript.charAt(i);
            if (ch == '\'' && !doubleQuoted) {
                singleQuoted = !singleQuoted;
            } else if (ch == '"' && !singleQuoted) {
                doubleQuoted = !doubleQuoted;
            }
            if (ch == ';' && !singleQuoted && !doubleQuoted) {
                statements.add(current.toString());
                current.setLength(0);
            } else {
                current.append(ch);
            }
        }
        if (!current.isEmpty()) {
            statements.add(current.toString());
        }
        return statements;
    }

    private SandboxExecuteResponse response(String status, int runtimeMs, String message, boolean match, QueryResult result) {
        List<String> columns = result == null ? List.of() : result.columns();
        List<Map<String, Object>> rows = result == null ? List.of() : result.rows();
        return new SandboxExecuteResponse(status, runtimeMs, message, match, columns, rows);
    }

    private String trimTrailingSemicolon(String sql) {
        String trimmed = Objects.toString(sql, "").trim();
        while (trimmed.endsWith(";")) {
            trimmed = trimmed.substring(0, trimmed.length() - 1).trim();
        }
        return trimmed;
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private record QueryResult(List<String> columns, List<Map<String, Object>> rows,
                               List<List<Object>> valueRows, boolean truncated) {
    }
}
