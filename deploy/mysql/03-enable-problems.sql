-- Ensure all restored 170fcbc problems are visible in the current application.
USE student_oj;

UPDATE problem
SET status = 1
WHERE id BETWEEN 1 AND 323;
