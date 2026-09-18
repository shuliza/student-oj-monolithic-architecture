# Student OJ 问题修复报告

版本：基于 reports/project-audit-current.md 编制
日期：2026-09-05
性质：第一阶段修复实施记录与验收报告（仅后端/部署/数据库/后端测试；不处理前端）

## 1. 报告说明

本文件针对当前审计发现的问题，记录第一阶段已实施的后端、部署、数据库和后端测试修复，以及尚未完成的验收项。前端第二阶段及后续教师/AI治理不在本次范围。

“待修复”表示尚未在本次会话中实施；“已验证”仅表示已有代码或测试已验证该问题不存在，不表示本报告已经完成修复。

## 2. 总体修复策略

修复必须按以下顺序进行：

1. 先封住 sandbox 和账号会话安全边界；
2. 再修复前端跨用户、跨题和异步竞态；
3. 再修正教师导入、分组、导出等数据一致性问题；
4. 最后进行文档、部署、性能和测试工程治理。

禁止在没有完成第一阶段验证前直接对外开放 SQL 执行和教师管理接口。

## 3. 修复任务清单

| 编号 | 问题 | 优先级 | 当前状态 | 建议负责人 |
|---|---|---:|---|---|
| A1 | 学生可控制 sandbox initSql/answerSql | P0 | 待修复 | 后端/安全 |
| A2 | 资料更新并发写回可复活会话 | P0 | 待修复 | 后端/鉴权 |
| A3 | 禁用期间并发登录仍可签发 token | P0 | 待修复 | 后端/鉴权 |
| A4 | Redis 撤销竞态误删新会话 | P1 | 待修复 | 后端/鉴权 |
| A5 | 换账号后旧 Pinia 数据和请求回写 | P0 | 待修复 | 前端 |
| A6-A7 | 切题非原子、旧请求污染当前题 | P0 | 待修复 | 前端 |
| A8 | SQL formatter 改变语义 | P1 | 待修复 | 前端 |
| A9-A10 | 教师题目/分组异步乱序 | P1 | 待修复 | 前后端 |
| B1-B5 | 导入密码、分组、格式和失败反馈 | P1 | 待修复 | 教师模块 |
| B6-B8 | 导出格式、文件名和字段契约 | P1 | 待修复 | 教师模块 |
| B9-B14 | 题目计数、草稿、AI、统计和仪表盘问题 | P2 | 待修复 | 前端/后端 |
| C1-C4 | 开发路由、CORS、凭据和爬虫路由 | P1 | 待修复 | 部署/后端 |
| C5-C6 | AI边界和前端大 chunk | P2 | 待治理 | 平台/前端 |

## 4. 第一阶段：安全止血

### 4.1 封闭通用 sandbox 执行入口

涉及范围：

- backend/app/src/main/java/com/studentoj/sandbox/controller/SandboxController.java
- backend/app/src/main/java/com/studentoj/sandbox/dto/SandboxExecuteRequest.java
- backend/app/src/main/java/com/studentoj/sandbox/service/SandboxService.java
- backend/app/src/main/java/com/studentoj/problem/controller/ProblemController.java
- backend/app/src/main/java/com/studentoj/judge/service/JudgeService.java

修复要求：

- 学生接口只能提交 problemId 和 studentSql；
- initSql、answerSql 必须由后端按 problemId 从数据库读取；
- 通用 sandbox execute 不得暴露给学生；
- 如果必须保留内部接口，增加仅内部 worker 可调用的认证方式；
- 后端拒绝客户端传入的 initSql、answerSql 或 testcase 覆盖参数；
- sandbox 账号只能访问 sandbox 数据库和当前运行所需资源；
- 限制单用户提交频率、单请求执行时间、结果行数和资源总量；
- 清理失败的临时数据库必须有异步回收任务。

验收：

- 学生使用任何 problemId 不能控制参考答案和初始化脚本；
- 学生不能访问通用 sandbox execute；
- 篡改请求字段会返回 400/403，而不是执行；
- MySQL grants 测试确认 sandbox 无法读取业务库；
- SQL 注释、多语句、DDL、文件读写和耗时函数测试均被拒绝或隔离；

### 4.2 修复账号状态和会话一致性

涉及范围：

- backend/app/src/main/java/com/studentoj/auth/service/AuthService.java
- backend/app/src/main/java/com/studentoj/auth/service/TokenStore.java
- backend/app/src/main/java/com/studentoj/auth/entity/UserEntity.java
- backend/app/src/main/java/com/studentoj/teacher/service/TeacherService.java
- backend/app/src/main/java/com/studentoj/teacher/mapper/TeacherMapper.java

修复要求：

- 个人资料只更新允许的资料字段，不使用旧 UserEntity 全量 updateById；
- 密码修改只更新 password_hash，不覆盖 status、role、group_id；
- 增加 sessionVersion 或安全版本字段；
- 禁用账号和密码重置时递增版本并撤销旧会话；
- token 解析时校验账号当前状态和版本；
- login 在校验、签发之间增加版本一致性保护；
- Redis 撤销、签发和用户索引更新使用 Lua 原子脚本或等价事务；
- logout 删除索引时必须携带旧 token 条件，不能误删新 token；
- 对账户更新增加乐观锁或条件 UPDATE；
- AuthContext 在 preHandle 返回 false 的路径也必须清理。

验收：

- 禁用后旧 token 立即失效；
- 重置密码后旧 token 和旧密码均失效；
- 并发 profile 更新不能覆盖 status、role、group_id 或 password_hash；
- 旧 logout 不能删除新登录会话；
- 禁用与登录并发时不能签发可用旧版本 token；
- Redis 并发测试和多实例测试通过。

### 4.3 前端会话隔离

涉及范围：

- src/stores/auth.ts
- src/stores/problem.ts
- src/stores/statistics.ts
- src/views/student/SqlEditorView.vue

修复要求：

- logout 时清理所有用户相关 Pinia store；
- login 切换账号时重置题目、提交、统计、AI 和页面缓存；
- 为异步请求保存 session generation；
- 响应返回时确认 generation、userId 和 token 仍匹配；
- 切换账号时取消旧 axios 请求；
- localStorage 草稿 key 至少包含 userId 和 problemId；
- 对历史无用户前缀草稿不要直接迁移给新用户。

验收：

- A 退出、B 登录后页面不能显示 A 的提交和统计；
- A 的慢请求晚于 B 登录返回时不能覆盖 B 的 store；
- A 的草稿不能被 B 读取；
- 多标签切换账号测试不会发生跨用户数据回写。

## 5. 第二阶段：前端并发与编辑器正确性

### 5.1 原子切题和请求代次

涉及范围：SqlEditorView.vue、ProblemManagementView.vue、GroupManagementView.vue、TeacherDashboardView.vue。

修复要求：

- 使用 problemId generation 管理每次切题；
- 详情、提交、运行、AI、成员和统计请求返回时校验 generation；
- 切题期间禁用运行、提交、格式化和 AI；
- 只有 problemId、题目详情和 SQL 草稿全部对应时才替换页面状态；
- 保存时携带明确的 entityId 快照，不能读取可变的当前 editingId；
- 成员移除接口必须使用 WHERE user_id=? AND group_id=?；
- 异步失败时恢复同一题目的旧状态，不留下题目和 SQL 混合状态。

验收：

- 快速 A/B/A 切换后最终页面只显示最后一次选择的题目；
- A 响应晚于 B 返回不能覆盖 B；
- B 页面不能把 SQL 提交到 A；
- A 组成员请求不能改变 B 组或错误清除实际所属组。

### 5.2 替换 SQL 格式化实现

修复要求：

- 不使用只保护单引号的正则格式化；
- 使用经过验证的 SQL lexer/formatter；
- 保留单引号、双引号、反引号、注释、转义字符和 MySQL 方言语义；
- 格式化应作为 Monaco 可撤销编辑，不直接 setValue 清空 undo 栈；
- 格式化失败时保持原 SQL，不生成半格式化结果。

验收用例：

- 字符串包含 SELECT、FROM、DELETE、换行和分号；
- 双引号字符串和反引号标识符；
- 行注释和块注释；
- 字符串内转义引号；
- 窗口函数、CTE、子查询、JSON 和 MySQL 特有语法；
- 格式化前后 AST 或执行结果一致；
- 格式化后 Ctrl+Z 能恢复原 SQL。

## 6. 第三阶段：教师管理和数据契约

### 6.1 导入流程

涉及范围：TeacherService.java、TeacherController.java、TeacherMapper.java 及对应 Vue 页面。

修复要求：

- 空密码统一使用明确的首次登录密码策略，或拒绝该行并返回原因；
- 未知分组名必须作为该行失败，不得静默变成无分组；
- 返回 imported、skipped、failed、errors；
- 全部无效时不能显示“导入成功”；
- UI 只接受后端真正支持的 xlsx；若要支持 xls/csv，必须实现对应解析器；
- 限制上传大小、行数和单元格长度；
- 对 CSV/Excel 单元格做公式注入防护；
- 导入应有事务和重复账号/学号的明确处理策略。

验收：

- 空密码、短密码、重复账号、重复学号、未知分组分别得到明确错误；
- 全部错误文件返回 0 imported 和非空 errors；
- xls/csv 不会被界面接受后再由 XSSFWorkbook 静默失败；
- 导入后新账号可按既定策略登录。

### 6.2 分组与导出

修复要求：

- 列表接口返回 testcaseCount，而不是依赖空 testcases 数组；
- 单学生导出接口要么支持 format，要么隐藏 CSV 选项；
- 文件名、Content-Type 和实际字节格式使用同一份请求快照；
- 导出等待期间锁定格式选择或保存 filename snapshot；
- UI 文案必须与实际列一致；
- 导出的 realName、title 等文本防止公式注入；
- 导出接口增加权限范围校验和审计日志。

## 7. 第四阶段：AI、统计和工程治理

### 7.1 AI 提交上下文

- 后端根据 submissionId 查询 SQL、题目和判题结果；
- 校验 submissionId 属于当前学生；
- 不信任前端同时提交的 status、message 和 studentSql 作为历史事实；
- 对 AI 输入脱敏、限长、限频和缓存；
- 错误响应和日志不得输出 API Key 或完整敏感 SQL。

### 7.2 统计请求一致性

- overview、activity、submissions、todaySolved 使用同一个筛选快照或请求代次；
- 题目难度图进入教师页面时显式加载题目数据；
- 统计日期统一业务时区；
- 后端为统计查询增加索引和分页；
- activeDays、streakDays、submissionCount、acceptedCount 保持字段语义明确。

### 7.3 开发和生产配置

- README 的 npm 开发模式增加 Vite /api proxy，或明确必须通过 Nginx；
- 生产启动拒绝默认数据库密码、sandbox 密码和内部密钥；
- CORS 改为白名单；
- crawler 管理接口放入统一 /api 路由并要求教师/管理员角色；
- 数据库、Redis、后端调试端口只绑定必要网络；
- 生产不使用 mock 数据作为接口失败回退；
- Monaco、ECharts 和大页面按路由/功能拆包。

## 8. 测试计划

### 单元测试

- TokenStore：Redis 原子 revoke、issue、revokeUser 并发；
- AuthService：禁用/重置/资料更新并发；
- Import：空密码、未知分组、重复账号、错误统计；
- CSV：公式前缀、换行、引号和编码；
- Formatter：字符串、注释、标识符和 MySQL 方言；
- Sandbox：initSql 信任边界、危险语句、结果限制。

### 集成测试

- Testcontainers MySQL 8.4 + Redis；
- sandbox 账号 grants；
- Nginx auth_request 和后端内部头；
- 多实例会话撤销；
- 多用户并发提交；
- 真实 xlsx/xls/csv 文件；
- 题目导入后从题目查询到判题的完整链路。

### 前端测试

- A/B 账号切换；
- 快速切题和浏览器前进后退；
- 慢请求逆序返回；
- 格式化/重置/撤销；
- 教师筛选快速变化；
- 导出格式切换；
- 导入错误提示。

## 9. 上线验收清单

- [x] 学生无法控制 initSql、answerSql（sandbox 通用入口已移除，学生只提交 problemId+studentSql）；
- [ ] sandbox 无法访问业务库（需真实 MySQL SHOW GRANTS 验证）；
- [x] 禁用用户旧 token 立即失效（session_version CAS + TokenStore Lua）；
- [ ] Redis 会话竞态测试通过（需真实 Redis 集成并发测试）；
- [x] 多用户和多题异步响应不会串数据（前端 session generation + problem generation + AbortController）；
- [ ] SQL 格式化前后语义一致（Monaco executeEdits 已落地，formatter 仍使用改进型 tokenizer）；
- [x] 导入空密码、错误分组和错误文件有明确反馈（返回 imported/skipped/failed/errors）；
- [x] 导出 Content-Type、文件名和内容一致（单学生导出支持 format，snapshot 锁定）；
- [x] AI submissionId 经过归属校验（后端查 submission 表确认 user_id 匹配）；
- [x] README 本地启动链路已验证（Vite proxy + Nginx 说明已更新）；
- [x] 生产配置不存在默认 Secret（application.yml 空值占位 + StartupValidator prod 拦截）；
- [x] CORS、端口和管理接口经过安全检查（CORS 白名单 + crawler /api + RequireRole）；
- [x] 前后端构建通过（mvn test 9/0/0，npm build 成功并已拆包）；
- [ ] 真实 MySQL/Redis 集成测试、sandbox grants 和回滚验证未完成。

## 10. 回滚和风险控制

- 每个阶段单独提交和发布，避免安全修复与大规模重构混在同一版本；
- 先在隔离环境验证 MySQL grants、Redis Lua 和 Nginx auth_request；
- 数据库增加字段时采用向后兼容迁移，完成应用切换后再清理旧字段；
- 账号会话策略变更应准备强制全员重新登录方案；
- sandbox 变更上线前保留临时库清理任务和人工清理脚本；
- 若前端 generation 改造出现兼容问题，可回滚 UI bundle，但不能回滚已经暴露的 sandbox 权限修复；
- 所有回滚操作必须保留审计日志。

## 11. 当前状态

本报告生成时：

- 代码修改：已实施鉴权会话（TokenStore Lua 原子化、登录版本校验、profile CAS、AuthContext 首行清理）、sandbox 学生入口/校验/限制、学生提交认证边界、教师导入契约与分组条件删除、前端会话代次与异步防护、AI submissionId 归属快照与输入脱敏/限长、crawler 路由移入 /api 并加教师角色；
- 配置修改：已移除 sandbox allowMultiQueries，默认应用凭据/内部 secret 改为空值占位，生产 overlay 增加基础资源限制，CORS 收敛为白名单，Vite 已增加本地 `/api` 代理与 vendor 拆包；
- 数据库修改：已增加 session_version 幂等迁移并挂载到 Compose；sandbox grants 尚未完成最小权限拆分；
- 后端测试：已按要求运行 mvn -f backend/pom.xml test -B，当前 Tests run: 9，Failures: 0，Errors: 0，BUILD SUCCESS；
- 前端构建：已按要求运行 npm run build，当前构建成功，vendor-vue/vendor-element/vendor-charts/vendor-monaco 已拆包，仅 vendor-monaco 超 500KB（Monaco 编辑器本身体积限制）；
- 生产验证：未进行；生产 secret 强校验已通过 StartupValidator 在 prod profile 启动时拦截；
- 实际修复完成度：第一阶段主干、前端会话/切题治理、教师导入契约、AI 归属校验、crawler 角色、部署治理与 chunk 拆分已完成；sandbox 最小 grants 隔离、异步孤儿库回收、真实 MySQL/Redis 集成验证仍待完成。

## 12. 结论

修复工作的第一目标不是增加功能，而是建立可信的安全边界和数据一致性。最重要的三项是：封闭通用 sandbox 输入、解决账号会话并发一致性、隔离前端会话和异步状态。当前版本已在代码与构建层面完成上述三项的主干修复，并补齐了教师导入契约、AI 归属校验、crawler 角色、部署治理与 chunk 拆分；完成真实 MySQL/Redis 集成测试与 sandbox 最小 grants 验证后，才适合继续对外发布。