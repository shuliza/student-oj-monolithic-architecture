# Student OJ 当前版本只读代码审计报告

审计日期：2026-09-05。目标：只找当前代码、部署配置与项目文档中的错误和漏洞，不修改业务代码或配置。

## 0. 验证边界

本报告以当前工作树源码为准；历史报告只作为线索，已修复问题不重复报告。
已执行：mvn -f backend/pom.xml test -B 通过；npm run build 通过但有超大 chunk 警告；docker compose config --quiet 通过。另用内存 H2/反射探针确认数值 1 与字符串 '1' 会被当前比较逻辑视为相同；没有连接生产数据库、没有发起线上请求、没有修改文件。并发项是代码级时序确认，不声称线上复现。

## 1. 高优先级问题

### A1【高】学生可直接控制沙箱初始化脚本
证据：SandboxController.java:21-23 的 /api/sandbox/sql/execute 没有 RequireRole；SandboxExecuteRequest.java:3 接收 initSql、answerSql、studentSql；SandboxService.java:84-110 只校验 studentSql，179-190 将 initSql 按分号直接执行。application.yml:39-50 允许 sandbox 账号执行 CREATE/DROP DATABASE，并开启 allowMultiQueries。
影响：学生可绕过题目绑定执行任意初始化 DDL/DML，消耗共享 sandbox 资源；具体能否越出 student_oj_sandbox 取决于 MySQL grants，未连接数据库验证。

### A2【高】资料更新并发写回可复活已撤销会话并覆盖安全状态
AuthService.updateProfile 先读取整行用户，再 updateById 写回包含 passwordHash、role、groupId、status 的实体，没有版本或字段级保护，随后无条件 TokenStore.update。一个已读取旧快照的请求可以在管理员禁用/重置或 logout 后写回旧状态并恢复 token；/auth/me 主要从 token store 解析，不重新查询数据库状态。代码级时序确认。

### A3【高】并发旧密码登录可在禁用后签发 token
AuthService.login 读取用户、检查状态和密码后签发 token，中间无锁、版本检查或签发前复核。管理员可在读取和签发之间禁用并 revoke，登录仍使用旧快照成功；application.yml 默认 TTL 为 86400 秒。代码级时序确认。

### A4【高】Redis 撤销操作存在误删新会话竞态
TokenStore.revoke 将旧 token 查询、删除、读取用户当前索引、删除索引分成多个 Redis 操作。旧 logout 在判断后新登录更新索引，旧 logout 仍可删除新索引。测试只覆盖内存顺序行为，没有 Redis 并发测试。

### A5【高】换账号时 Pinia 缓存和迟到请求可泄露旧用户数据
auth.ts:39-47 logout 只清 auth；problem.ts 与 statistics.ts 未随会话清空，异步回写没有 session generation。A 退出登录后 B 登录，旧提交、统计或题目状态可能在新请求完成前显示，迟到响应还会覆盖 B 的数据。

### A6【高】学生切题非原子，可能跨题提交或覆盖草稿
SqlEditorView.vue:237-253 切题时先变更草稿/SQL再异步加载 problem，加载期间没有完整禁用运行和提交；题目和 SQL 不是原子替换。可将 B SQL 提交给 A，或加载失败时产生题目/草稿混配。

### A7【高】编辑器旧请求响应污染当前题目
SqlEditorView.vue:112-215、377-383 的题目、提交、运行、AI 请求没有统一题目代次校验。A 请求晚于切换 B 返回时，仍可写入当前 problem、result、runResult 或 suggestion。

### A8【高】SQL 格式化改变语义
SqlEditorView.vue:276-316 的格式化仅有限保护单引号，不能正确处理注释、双引号、反引号。只读复现：SELECT 1 -- note 换行 + 2 被输出为注释吞掉 + 2；SELECT "from" AS x 的双引号内容被破坏。

### A9【高】教师题目编辑乱序会把 A 表单保存到 B
ProblemManagementView.vue:53-69 在异步详情完成前设置 editingId/form；连续打开 A、B 后 A 迟到响应可写 B 表单，保存 100-101 按当前 editingId 提交。

### A10【高】分组成员乱序可能误移学生
GroupManagementView.vue:84-104 未校验请求对应 groupId；TeacherMapper.java:32-33 remove 只按 user id 清空 group_id，没有 AND group_id=当前组。A 请求覆盖 B 页面时可误清实际所属组。

## 2. 中优先级功能/数据错误

### B1 批量学生导入空密码导致不可登录
TeacherService.java:386-407 对空密码直接 BCrypt 空字符串，未复用单个创建的默认密码；导入显示成功但账号无法按预期登录，启动回填会造成重启前后行为变化。

### B2 CSV 成绩导出存在公式注入
资料 realName 可写入以 =、+、-、@ 开头的内容；TeacherMapper.java:95-100 导出，TeacherService.java:242-260 只处理分隔符/引号。教师用表格软件打开 CSV 时可能执行公式。需用户打开文件，不是无交互远程代码执行。

### B3 未知分组名批量导入被静默当作无分组成功
TeacherService.java:403-408 查询不到组仍插入并计数；单个创建 70-79 会拒绝。

### B4 成员导入全未知学号仍提示成功
TeacherService.java:459-479 跳过未知学生，Controller 只返回 imported；0 条实际导入也可显示成功。

### B5 前端允许 xls/csv，后端只使用 XSSFWorkbook
TeacherService.java:392、457 与 ProblemAdminService.java:236 使用 XSSFWorkbook；前端学生/分组/题目页面接受 xls/csv，真实文件类型契约不一致。

### B6 单学生 CSV 选择无效
ExportCenterView.vue:105-109 显示 CSV；单学生接口 TeacherController.java:110-115 固定返回 xlsx。

### B7 导出期间切换格式会造成内容和后缀不一致
ExportCenterView.vue:41-47 请求开始捕获格式，异步完成后使用当前格式命名。

### B8 导出文案字段与实际内容不一致
ExportCenterView.vue:119-121 承诺活跃天数、正确率、最近提交；TeacherService.java:232、275-289 实际列不含这些字段。

### B9 题目列表用例数恒为 0
ProblemManagementView.vue:195-196 读取 testcases.length；ProblemAdminService.java:45-48 列表使用 toResponse(false)，非详情不填充用例。

### B10 SQL 草稿未按用户隔离
SqlEditorView.vue:36、41-53、246 使用 sql-draft:<problemId>；退出不清理。同一浏览器换账号可读到前一用户草稿。

### B11 Monaco 程序化 setValue 清空 undo
SqlMonacoEditor.vue:36-37 外部 v-model 变化调用 setValue；格式化/重置后 Ctrl-Z 无法恢复。

### B12 AI 可能混用旧提交元数据和当前 SQL
SqlEditorView.vue:129-135 可将历史 submissionId/status/message 与当前 studentSql 一起提交；AiController.java:26-29、AiService.java:37-66 直接使用请求，未按 submissionId 取快照并校验归属。

### B13 教师筛选统计请求跨代混合
TeacherDashboardView.vue:98-132 同时请求多类数据；statistics.ts 与 problem.ts 无请求代次。快速切换学生/分组时，各卡片可能来自不同筛选条件。

### B14 教师难度图冷启动为空
TeacherDashboardView.vue:46-49 读取 problemStore.problems；教师流程未确保 fetchProblems，store 初始为空。

### B15 个人资料/密码整实体更新造成丢失更新
AuthService 的 profile/password 更新基于旧实体写回安全字段和关系字段，无乐观锁；与 A2 同根因，不重复计为独立安全问题。

## 3. 文档和部署契约问题

### C1 README 本地启动无法完成 API 调用
README 要求前端 5173、后端 8080；http.ts 使用同源 /api，而 vite.config.ts 无 proxy，请求不会转发到 8080。直连 8080 仍缺少 AuthInterceptor 要求的内部鉴权头。Docker+Nginx 是另一条正常链路。

### C2 CORS 允许任意 Origin
auth/config/WebConfig.java:10-12 使用 allowedOrigins("*") 和所有方法。当前 token 主要走请求头，不能单独断言可利用会话窃取，但生产策略过宽。

### C3 默认凭据和内部密钥存在错误部署风险
application.yml 与根 Compose 含默认数据库、sandbox、内部鉴权配置；合并 hardening/local 时端口为 127.0.0.1:3307，但未覆盖环境变量的部署仍有风险。不能据此断言公网暴露。

### C4 爬虫管理路由未接入正常网关且无控制器角色注解
CrawlerAdminController.java:10-23 使用 /crawler/leetcode，无 RequireRole；Nginx 只代理 /api/。直接暴露 app 且内部密钥泄露时可触发同步；当前属于路由/权限契约错误，不断言公网未授权。

### C5 前端构建 chunk 过大
npm run build 成功，但 SqlEditorView 约 3.3MB、statistics 约 1.1MB，Vite 报告超过 500KB，影响首屏性能。

## 4. 当前不应再重复报告的问题

判题重复列名、超过 maxRows 截断误判、窗口函数 ORDER BY 误判、题目 HTML 完全未过滤、教师禁用/重置完全不撤销 token、单纯 PENDING 轮询耗尽误报、activeDays 等于 streak，当前均已有修复或证据不足。SandboxService.java:250-261 按列序号保存 valueRows，263-268 检测超限；已有相应测试。HtmlSanitizer 和管理/学生题目响应已有净化链与测试。

## 5. 建议优先级

第一优先级：限制 sandbox 接口只能接受后端按 problemId 加载的 init/answer；为账号状态/token 引入版本和原子撤销；前端引入 session/problem/filter generation；修复 formatter。
第二优先级：修复批量导入密码、分组校验、成员移除条件、导出格式/字段、AI 提交快照和教师统计请求一致性。
第三优先级：Testcontainers MySQL/Redis、Redis 并发测试、sandbox grants/资源隔离测试、README 开发代理、收紧 CORS、生产凭据启动检查、前端拆包。

## 6. 覆盖边界

已阅读或交叉核实：README、package/Vite/TS 配置、Docker/Compose/CI/Nginx；前端 stores/API/路由、学生和教师主要页面、公共组件/样式；后端 auth/common/teacher/statistics、problem 核心、judge、sandbox、AI、crawler 核心及脚本；数据库种子和相关测试。大体量 leetcode-mock.ts 仅抽读首尾并确认是静态数据，未逐条核验 4330 行题目；未审计第三方 node_modules、构建产物和图片。
未连接 MySQL/Redis，未访问生产，未做浏览器多标签慢网或压力测试；因此数据库 grants、线上并发影响范围需隔离环境复核。

## 7. 总结

后端测试与前端构建通过不代表业务安全。当前最重要的真实问题是 sandbox 输入信任边界、账号/token 并发一致性、前端跨用户/跨题异步污染，以及教师导入/分组/导出契约错误。本次没有修改任何代码或配置。