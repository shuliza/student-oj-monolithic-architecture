# MySQL 初始化脚本

MySQL 容器首次启动时，会按文件名顺序执行挂载到 `/docker-entrypoint-initdb.d/` 下的 `.sql` 文件。脚本只会在数据卷为空时执行。

| 执行顺序 | 容器内文件名 | 源文件 | 作用 |
| --- | --- | --- | --- |
| 1 | `01-init.sql` | `init.sql` | 建库建表、沙箱库与账号、班级/用户/示例题等基础种子 |
| 2 | `02-problems.sql` | `leetcode-problems-full.sql` | LeetCode SQL 题库（73 题，含 init_sql 与参考答案）与测试用例 |

`leetcode-problems-full.sql` 以题目 id 段 1001–1073 幂等写入 `problem` 与 `problem_testcase`，不会影响 `init.sql` 的示例题（101–104）。

重新初始化：

```bash
docker compose down -v
docker compose up -d --build
```

## LeetCode SQL 题库（leetcode-problems-full.sql）

收录 LeetCode 中国站 database 分类下的 73 道免费 SQL 题，每题包含：

- `description`：中文题面（HTML 转纯文本，含示例表格）
- `init_sql`：建表 + 造数脚本，判题时作为数据集
- `answer_sql`：参考答案，判题基准（与学生 SQL 在同一数据集上比对结果集）
- `problem_testcase`：每题 1 个数据集，内容即 `init_sql`

题目 id 为 `1001`–`1073`，脚本执行时先删除该区间再写入，可重复执行。

重新生成（使用 `tools/` 下已抓取的题面与答案）：

```powershell
powershell -ExecutionPolicy Bypass -File tools/generate-leetcode-problems-full.ps1
```

从 LeetCode 重新抓题面（会覆盖 `tools/leetcode-free-details.json`）：

```powershell
powershell -ExecutionPolicy Bypass -File tools/generate-leetcode-problems-full.ps1 -Fetch
```

`tools/answers.json` 保存每题的参考答案（LeetCode 公开接口不提供官方答案，需人工整理）。
生成脚本会做两处必要修正，以适配本项目沙箱（仅关闭 `ONLY_FULL_GROUP_BY`，保留严格模式）：

- 表名大小写：`not-boring-movies`、`customer-placing-the-largest-number-of-orders` 的题面表名为全小写；
- 日期格式：`sales-person` 题面样本日期为 `M/D/YYYY`，改写为 `YYYY-MM-DD`。

## 重新生成 02-problems.sql

如果运行中的数据库里更新了题目，可以用 `mysqldump` 重新导出：

```bash
{
  cat <<'HEADER'
-- ---------------------------------------------------------------------------
-- Student OJ 题库种子：SQL 题目 + 测试用例
-- ---------------------------------------------------------------------------
USE student_oj;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM problem_testcase;
DELETE FROM problem;

HEADER
  docker exec student-oj-mysql-1 mysqldump -uroot -proot \
    --default-character-set=utf8mb4 \
    --no-create-info --complete-insert --skip-extended-insert \
    --skip-comments --single-transaction \
    student_oj problem problem_testcase
  printf '\nSET FOREIGN_KEY_CHECKS = 1;\n'
} > deploy/mysql/02-problems.sql
```
