SET NAMES utf8mb4;
USE student_oj;

SET @column_exists := (SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'user' AND column_name = 'session_version');
SET @ddl := IF(@column_exists = 0, 'ALTER TABLE user ADD COLUMN session_version INT NOT NULL DEFAULT 0', 'SELECT 1');
PREPARE stmt FROM @ddl; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 非空旧会话版本统一提升为 1，使迁移前签发的无版本/零版本 token 失效。
UPDATE user SET session_version = 1 WHERE session_version IS NULL OR session_version < 1;
