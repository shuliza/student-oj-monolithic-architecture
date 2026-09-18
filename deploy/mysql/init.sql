-- ---------------------------------------------------------------------------
-- Student OJ 初始化脚本：业务库 student_oj + 沙箱库 student_oj_sandbox
-- 容器首次启动时由 MySQL 镜像自动执行（挂在 /docker-entrypoint-initdb.d/）。
-- ---------------------------------------------------------------------------

SET NAMES utf8mb4;

CREATE DATABASE IF NOT EXISTS student_oj         DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS student_oj_sandbox DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

-- =================== 业务库 ===================
USE student_oj;

CREATE TABLE IF NOT EXISTS class_group (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  name          VARCHAR(64)  NOT NULL,
  teacher_name  VARCHAR(64)  NOT NULL DEFAULT '',
  description   VARCHAR(255) NOT NULL DEFAULT '',
  student_count INT          NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_class_group_name (name)
);

CREATE TABLE IF NOT EXISTS user (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  username      VARCHAR(64)  NOT NULL,
  password_hash VARCHAR(255) NOT NULL DEFAULT '',
  real_name     VARCHAR(64)  NOT NULL DEFAULT '',
  email         VARCHAR(128) NOT NULL DEFAULT '',
  role          VARCHAR(16)  NOT NULL DEFAULT 'STUDENT',
  student_no    VARCHAR(32)  NOT NULL DEFAULT '',
  group_id      BIGINT       DEFAULT NULL,
  status        VARCHAR(16)  NOT NULL DEFAULT 'ACTIVE',
  session_version INT NOT NULL DEFAULT 0,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_username (username),
  KEY idx_user_group (group_id)
);

CREATE TABLE IF NOT EXISTS problem (
  id            BIGINT       NOT NULL AUTO_INCREMENT,
  title         VARCHAR(128) NOT NULL,
  description   TEXT,
  difficulty    VARCHAR(16)  NOT NULL DEFAULT 'EASY',
  tags          VARCHAR(255) NOT NULL DEFAULT '',
  init_sql      TEXT,
  answer_sql    TEXT,
  sample_input  TEXT,
  sample_output TEXT,
  status        INT          NOT NULL DEFAULT 1,
  created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

-- 题目测试用例：每条 = 一个独立数据集（建表 + 造数据）。
-- 判题时对每个用例分别执行「学生 SQL vs 参考 answer_sql」，全部通过才判 ACCEPTED。
-- 没有任何用例行时，judge 回退到 problem.init_sql 作为单一数据集。
CREATE TABLE IF NOT EXISTS problem_testcase (
  id         BIGINT   NOT NULL AUTO_INCREMENT,
  problem_id BIGINT   NOT NULL,
  ordinal    INT      NOT NULL DEFAULT 1,
  init_sql   TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_testcase_problem (problem_id, ordinal)
);

CREATE TABLE IF NOT EXISTS submission (
  id           BIGINT       NOT NULL AUTO_INCREMENT,
  user_id      BIGINT       NOT NULL,
  problem_id   BIGINT       NOT NULL,
  sql_content  TEXT,
  status       VARCHAR(32)  NOT NULL DEFAULT 'PENDING',
  score        INT          NOT NULL DEFAULT 0,
  runtime_ms   INT          NOT NULL DEFAULT 0,
  message      TEXT,
  submitted_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_submission_user (user_id),
  KEY idx_submission_problem (problem_id),
  KEY idx_submission_time (submitted_at),
  KEY idx_submission_user_problem_status_time (user_id, problem_id, status, submitted_at),
  KEY idx_submission_problem_status_user (problem_id, status, user_id),
  KEY idx_submission_user_time (user_id, submitted_at)
);

CREATE TABLE IF NOT EXISTS student_activity (
  id               BIGINT     NOT NULL AUTO_INCREMENT,
  user_id          BIGINT     NOT NULL,
  activity_date    DATE       NOT NULL,
  submission_count INT        NOT NULL DEFAULT 0,
  accepted_count   INT        NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uk_user_date (user_id, activity_date)
);

CREATE TABLE IF NOT EXISTS processed_judge_event (
  submission_id BIGINT   NOT NULL,
  processed_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (submission_id)
);

CREATE TABLE IF NOT EXISTS ai_suggestion (
  id            BIGINT   NOT NULL AUTO_INCREMENT,
  user_id       BIGINT   NOT NULL,
  submission_id BIGINT   NOT NULL,
  problem_id    BIGINT   NOT NULL,
  suggestion    TEXT,
  created_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ai_user_problem_time (user_id, problem_id, created_at),
  KEY idx_ai_submission (submission_id)
);

CREATE TABLE IF NOT EXISTS sql_problem (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(255),
    title_slug VARCHAR(255) UNIQUE,
    difficulty VARCHAR(20),
    content LONGTEXT,
    content_text LONGTEXT,
    example LONGTEXT,
    schema_info LONGTEXT,
    sample_data LONGTEXT,
    expected_output LONGTEXT,
    test_cases LONGTEXT,
    hint LONGTEXT,
    tags VARCHAR(500),
    source VARCHAR(50),
    source_url VARCHAR(500),
    create_time DATETIME,
    update_time DATETIME,
    KEY idx_sql_problem_difficulty (difficulty),
    KEY idx_sql_problem_source (source),
    KEY idx_sql_problem_update_time (update_time)
);

CREATE TABLE IF NOT EXISTS sql_problem_answer (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    problem_id BIGINT NOT NULL,
    answer_sql LONGTEXT,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY idx_sql_problem_answer_problem (problem_id)
);

CREATE TABLE IF NOT EXISTS sql_problem_testcase (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    problem_id BIGINT NOT NULL,
    case_name VARCHAR(255),
    schema_sql LONGTEXT,
    init_sql LONGTEXT,
    expected_sql LONGTEXT,
    expected_result LONGTEXT,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sql_problem_testcase_problem (problem_id)
);

CREATE TABLE IF NOT EXISTS sql_submission (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    problem_id BIGINT,
    submit_sql LONGTEXT,
    status VARCHAR(50),
    execute_time BIGINT,
    result_message TEXT,
    create_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY idx_sql_submission_user (user_id),
    KEY idx_sql_submission_problem (problem_id),
    KEY idx_sql_submission_time (create_time)
);

DROP TRIGGER IF EXISTS trg_sql_problem_after_insert;
DROP TRIGGER IF EXISTS trg_sql_problem_after_update;
DROP TRIGGER IF EXISTS trg_sql_problem_after_delete;
DROP TRIGGER IF EXISTS trg_sql_problem_answer_after_insert;
DROP TRIGGER IF EXISTS trg_sql_problem_answer_after_update;
DROP TRIGGER IF EXISTS trg_sql_problem_answer_after_delete;
DELIMITER //
CREATE TRIGGER trg_sql_problem_after_insert
AFTER INSERT ON sql_problem
FOR EACH ROW
BEGIN
  INSERT INTO problem(id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status, created_at, updated_at)
  SELECT
    200000 + NEW.id,
    LEFT(NEW.title, 128),
    COALESCE(NULLIF(NEW.content, ''), NEW.content_text, ''),
    CASE UPPER(NEW.difficulty)
      WHEN 'EASY' THEN 'EASY'
      WHEN 'MEDIUM' THEN 'MEDIUM'
      WHEN 'HARD' THEN 'HARD'
      ELSE 'EASY'
    END,
    LEFT(COALESCE(NEW.tags, 'Database'), 255),
    COALESCE(NULLIF(NEW.schema_info, ''), NULLIF(NEW.sample_data, ''), ''),
    (SELECT a.answer_sql FROM sql_problem_answer a WHERE a.problem_id = NEW.id ORDER BY a.id DESC LIMIT 1),
    COALESCE(NULLIF(NEW.schema_info, ''), NULLIF(NEW.sample_data, ''), ''),
    COALESCE(NEW.expected_output, ''),
    1,
    COALESCE(NEW.create_time, NOW()),
    COALESCE(NEW.update_time, NOW())
  WHERE NOT EXISTS (SELECT 1 FROM problem p WHERE p.id = 200000 + NEW.id OR p.title = NEW.title);
END//
CREATE TRIGGER trg_sql_problem_after_update
AFTER UPDATE ON sql_problem
FOR EACH ROW
BEGIN
  UPDATE problem
  SET title = LEFT(NEW.title, 128),
      description = COALESCE(NULLIF(NEW.content, ''), NEW.content_text, ''),
      difficulty = CASE UPPER(NEW.difficulty)
        WHEN 'EASY' THEN 'EASY'
        WHEN 'MEDIUM' THEN 'MEDIUM'
        WHEN 'HARD' THEN 'HARD'
        ELSE 'EASY'
      END,
      tags = LEFT(COALESCE(NEW.tags, 'Database'), 255),
      init_sql = COALESCE(NULLIF(NEW.schema_info, ''), NULLIF(NEW.sample_data, ''), ''),
      answer_sql = COALESCE(
        (SELECT a.answer_sql FROM sql_problem_answer a WHERE a.problem_id = NEW.id ORDER BY a.id DESC LIMIT 1),
        answer_sql
      ),
      sample_input = COALESCE(NULLIF(NEW.schema_info, ''), NULLIF(NEW.sample_data, ''), ''),
      sample_output = COALESCE(NEW.expected_output, ''),
      updated_at = COALESCE(NEW.update_time, NOW())
  WHERE id = 200000 + NEW.id;
END//
CREATE TRIGGER trg_sql_problem_after_delete
AFTER DELETE ON sql_problem
FOR EACH ROW
BEGIN
  DELETE FROM problem WHERE id = 200000 + OLD.id;
END//
CREATE TRIGGER trg_sql_problem_answer_after_insert
AFTER INSERT ON sql_problem_answer
FOR EACH ROW
BEGIN
  UPDATE problem
  SET answer_sql = NEW.answer_sql,
      updated_at = NOW()
  WHERE id = 200000 + NEW.problem_id;
END//
CREATE TRIGGER trg_sql_problem_answer_after_update
AFTER UPDATE ON sql_problem_answer
FOR EACH ROW
BEGIN
  UPDATE problem
  SET answer_sql = NEW.answer_sql,
      updated_at = NOW()
  WHERE id = 200000 + NEW.problem_id;
END//
CREATE TRIGGER trg_sql_problem_answer_after_delete
AFTER DELETE ON sql_problem_answer
FOR EACH ROW
BEGIN
  UPDATE problem
  SET answer_sql = (
        SELECT a.answer_sql
        FROM sql_problem_answer a
        WHERE a.problem_id = OLD.problem_id
        ORDER BY a.id DESC
        LIMIT 1
      ),
      updated_at = NOW()
  WHERE id = 200000 + OLD.problem_id;
END//
DELIMITER ;

INSERT INTO sql_problem_answer(problem_id, answer_sql)
SELECT 23, 'WITH high_traffic AS (
  SELECT id, visit_date, people, id - ROW_NUMBER() OVER (ORDER BY id) AS streak_key
  FROM Stadium
  WHERE people >= 100
)
SELECT id, visit_date, people
FROM high_traffic
WHERE streak_key IN (
  SELECT streak_key
  FROM high_traffic
  GROUP BY streak_key
  HAVING COUNT(*) >= 3
)
ORDER BY visit_date'
WHERE EXISTS (SELECT 1 FROM sql_problem p WHERE p.id = 23 AND p.title_slug = 'human-traffic-of-stadium')
  AND NOT EXISTS (SELECT 1 FROM sql_problem_answer a WHERE a.problem_id = 23);

UPDATE problem p
JOIN sql_problem sp ON p.id = 200000 + sp.id
LEFT JOIN sql_problem_answer a ON a.problem_id = sp.id
SET p.init_sql = COALESCE(NULLIF(sp.schema_info, ''), NULLIF(sp.sample_data, ''), p.init_sql),
    p.answer_sql = COALESCE(a.answer_sql, p.answer_sql),
    p.sample_input = COALESCE(NULLIF(sp.schema_info, ''), NULLIF(sp.sample_data, ''), p.sample_input),
    p.sample_output = COALESCE(sp.expected_output, p.sample_output),
    p.updated_at = NOW()
WHERE p.id >= 200000;
-- 班级
INSERT INTO class_group(id, name, teacher_name, description, student_count) VALUES
  (1, '数据库 1 班', '王老师', '周一 1-2 节实验班',     6),
  (2, '数据库 2 班', '王老师', '周三 3-4 节实验班',     6),
  (3, '期末强化组', '王老师', '低通过率题目专项练习', 0)
ON DUPLICATE KEY UPDATE student_count = VALUES(student_count);

-- 用户：password_hash 留空，由单体应用启动时用 BCrypt(123456) 回填
INSERT INTO user(id, username, password_hash, real_name, email, role, student_no, group_id, status) VALUES
  (1, 'teacher01', '', '王老师', 'teacher01@example.edu', 'TEACHER', '',         NULL, 'ACTIVE')
ON DUPLICATE KEY UPDATE real_name = VALUES(real_name);

INSERT INTO user(id, username, password_hash, real_name, email, role, student_no, group_id, status) VALUES
  (2,  'student01', '', '林同学', 'student01@example.edu', 'STUDENT', '20260001', 1, 'ACTIVE'),
  (3,  'student02', '', '陈同学', 'student02@example.edu', 'STUDENT', '20260002', 1, 'ACTIVE'),
  (4,  'student03', '', '周同学', 'student03@example.edu', 'STUDENT', '20260003', 1, 'ACTIVE'),
  (5,  'student04', '', '李同学', 'student04@example.edu', 'STUDENT', '20260004', 1, 'ACTIVE'),
  (6,  'student05', '', '赵同学', 'student05@example.edu', 'STUDENT', '20260005', 1, 'ACTIVE'),
  (7,  'student06', '', '吴同学', 'student06@example.edu', 'STUDENT', '20260006', 1, 'ACTIVE'),
  (8,  'student07', '', '林同学', 'student07@example.edu', 'STUDENT', '20260007', 2, 'ACTIVE'),
  (9,  'student08', '', '陈同学', 'student08@example.edu', 'STUDENT', '20260008', 2, 'ACTIVE'),
  (10, 'student09', '', '周同学', 'student09@example.edu', 'STUDENT', '20260009', 2, 'DISABLED'),
  (11, 'student10', '', '李同学', 'student10@example.edu', 'STUDENT', '20260010', 2, 'ACTIVE'),
  (12, 'student11', '', '赵同学', 'student11@example.edu', 'STUDENT', '20260011', 2, 'ACTIVE'),
  (13, 'student12', '', '吴同学', 'student12@example.edu', 'STUDENT', '20260012', 2, 'ACTIVE')
ON DUPLICATE KEY UPDATE real_name = VALUES(real_name);

-- 题目种子
INSERT INTO problem(id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
  (101, '查询高分学生名单',
   '从 student 与 score 表中查询成绩不低于 80 分的学生姓名、课程名和成绩，按成绩从高到低排序。',
   'EASY', 'SELECT,WHERE',
   'CREATE TABLE student(id INT PRIMARY KEY, name VARCHAR(32)); CREATE TABLE score(student_id INT, course VARCHAR(32), score INT); INSERT INTO student VALUES (1,''林同学''),(2,''陈同学''),(3,''周同学''); INSERT INTO score VALUES (1,''数据库'',92),(2,''数据库'',75),(3,''数据库'',88);',
   'SELECT s.name, c.course, c.score FROM student s JOIN score c ON s.id = c.student_id WHERE c.score >= 80 ORDER BY c.score DESC;',
   'student(id, name), score(student_id, course, score)',
   'name | course | score', 1),
  (102, '统计每门课程平均分',
   '按课程统计平均分，结果列含 course 和 avg_score，按平均分从高到低排序。',
   'MEDIUM', 'GROUP BY,AVG',
   'CREATE TABLE score(student_id INT, course VARCHAR(32), score INT); INSERT INTO score VALUES (1,''数据库'',92),(2,''数据库'',75),(3,''数据库'',88),(1,''操作系统'',85),(2,''操作系统'',70);',
   'SELECT course, AVG(score) AS avg_score FROM score GROUP BY course ORDER BY avg_score DESC;',
   'score(course, score)',
   'course | avg_score', 1),
  (103, '查询没有选课的学生',
   '找出 student 表中没有任何选课记录的学生，返回 id 与 name。',
   'MEDIUM', 'LEFT JOIN,NULL',
   'CREATE TABLE student(id INT PRIMARY KEY, name VARCHAR(32)); CREATE TABLE enroll(student_id INT, course_id INT); INSERT INTO student VALUES (1,''林同学''),(2,''陈同学''),(3,''周同学''); INSERT INTO enroll VALUES (1,101),(2,102);',
   'SELECT s.id, s.name FROM student s LEFT JOIN enroll e ON s.id = e.student_id WHERE e.student_id IS NULL;',
   'student(id, name), enroll(student_id, course_id)',
   'id | name', 1),
  (104, '窗口函数排名',
   '使用窗口函数计算每门课程内的成绩排名，结果列含 student_id, course, score, rank_no。',
   'HARD', 'WINDOW,RANK',
   'CREATE TABLE score(student_id INT, course VARCHAR(32), score INT); INSERT INTO score VALUES (1,''数据库'',92),(2,''数据库'',75),(3,''数据库'',88),(1,''操作系统'',85),(2,''操作系统'',70);',
   'SELECT student_id, course, score, RANK() OVER (PARTITION BY course ORDER BY score DESC) AS rank_no FROM score;',
   'score(student_id, course, score)',
   'student_id | course | score | rank_no', 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);

-- 题目测试用例种子：用每道种子题已有的 init_sql 作为其第 1 个数据集。
-- 仅当该题尚无任何用例行时插入，避免容器重启重复灌入。
INSERT INTO problem_testcase(problem_id, ordinal, init_sql)
SELECT p.id, 1, p.init_sql
FROM problem p
WHERE p.id IN (101, 102, 103, 104)
  AND NOT EXISTS (SELECT 1 FROM problem_testcase t WHERE t.problem_id = p.id);

-- 历史提交（供 dashboard 立刻有数据）
INSERT INTO submission(id, user_id, problem_id, sql_content, status, score, runtime_ms, message, submitted_at) VALUES
  (1001, 2, 101, 'SELECT s.name, c.course, c.score FROM student s JOIN score c ON s.id = c.student_id WHERE c.score >= 80', 'ACCEPTED', 100, 32, 'Result set matched.',         NOW() - INTERVAL 2 DAY),
  (1002, 2, 102, 'SELECT course, AVG(score) FROM score GROUP BY course',                                                  'WRONG_ANSWER', 40, 41, '列别名缺失 avg_score',           NOW() - INTERVAL 1 DAY),
  (1003, 3, 103, 'SELECT s.id, s.name FROM student s LEFT JOIN enroll e ON s.id = e.student_id WHERE e.student_id IS NULL', 'TIME_LIMIT', 0, 3000, '查询执行超过时间限制',            NOW() - INTERVAL 6 HOUR),
  (1004, 4, 104, 'SELECT student_id, course, score, ROW_NUMBER() OVER () AS rank_no FROM score',                            'RUNTIME_ERROR', 0, 59, '排序未指定 PARTITION BY',         NOW() - INTERVAL 3 HOUR)
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- 活跃记录种子
INSERT INTO student_activity(user_id, activity_date, submission_count, accepted_count) VALUES
  (2, CURDATE() - INTERVAL 2 DAY, 1, 1),
  (2, CURDATE() - INTERVAL 1 DAY, 1, 0),
  (3, CURDATE(),                  1, 0),
  (4, CURDATE(),                  1, 0)
ON DUPLICATE KEY UPDATE submission_count = VALUES(submission_count);

-- =================== 沙箱库 ===================
-- 沙箱执行用账户：可读可写自己的库，不能访问主业务库。
-- 这里只是预留一个空库，单体应用中的 sandbox 模块会按题目的 init_sql 临时建表执行。
USE student_oj_sandbox;

CREATE USER IF NOT EXISTS 'sandbox'@'%' IDENTIFIED BY 'sandbox123';
GRANT ALL PRIVILEGES ON student_oj_sandbox.* TO 'sandbox'@'%';
GRANT ALL PRIVILEGES ON `oj\_run\_%`.* TO 'sandbox'@'%';
FLUSH PRIVILEGES;
