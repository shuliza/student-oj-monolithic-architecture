<#
.SYNOPSIS
  生成 Student OJ 的 LeetCode SQL 题库初始化脚本。

.DESCRIPTION
  1) -Fetch：调用 LeetCode 中国站 GraphQL，抓取 database 分类下的免费 SQL 题详情
     （中文题面 + mysqlSchemas 建表/造数语句），写入 tools/leetcode-free-details.json。
  2) 结合 tools/answers.json 中的参考答案 SQL，生成 ../leetcode-problems-full.sql。
     输出匹配 student_oj.problem / problem_testcase 两张表，可由 MySQL 容器初始化时执行。

  说明：LeetCode 公开接口不提供官方答案，answers.json 由人工整理；本脚本只负责抓题面与拼装。

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File generate-leetcode-problems-full.ps1 -Fetch

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File generate-leetcode-problems-full.ps1
#>
param(
  [switch]$Fetch,
  [string]$OutFile = (Join-Path (Split-Path -Parent $PSScriptRoot) 'leetcode-problems-full.sql'),
  [string]$GraphqlUrl = 'https://leetcode.cn/graphql'
)

$ErrorActionPreference = 'Stop'
$NL = [char]10
$ToolsDir = $PSScriptRoot
$DetailsPath = Join-Path $ToolsDir 'leetcode-free-details.json'
$AnswersPath = Join-Path $ToolsDir 'answers.json'

# ---------------------------------------------------------------------------
# 1. 抓取（可选）
# ---------------------------------------------------------------------------
if ($Fetch) {
  Write-Host 'Fetching LeetCode database problems ...'
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $headers = @{ 'Referer' = 'https://leetcode.cn/problemset/database/'; 'Accept' = 'application/json'; 'Origin' = 'https://leetcode.cn' }
  $ua = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36'

  function Invoke-Lc([string]$Body) {
    for ($i = 1; $i -le 5; $i++) {
      try { return Invoke-RestMethod -Uri $GraphqlUrl -Method Post -ContentType 'application/json' -Headers $headers -Body $Body -UserAgent $ua -TimeoutSec 30 }
      catch { Start-Sleep -Seconds 2 }
    }
    return $null
  }

  $listQuery = @'
query problemsetQuestionList($categorySlug: String, $limit: Int, $skip: Int, $filters: QuestionFilterInput) {
  problemsetQuestionListV2(categorySlug: $categorySlug, limit: $limit, skip: $skip, filters: $filters) {
    totalLength hasMore questions { title translatedTitle titleSlug difficulty paidOnly }
  }
}
'@
  $detailQuery = @'
query questionData($titleSlug: String!) {
  question(titleSlug: $titleSlug) {
    title translatedTitle titleSlug difficulty translatedContent mysqlSchemas
  }
}
'@

  $slugs = @()
  $skip = 0; $total = [int]::MaxValue
  while ($skip -lt $total) {
    $vars = @{ categorySlug = 'database'; limit = 50; skip = $skip; filters = @{ filterCombineType = 'ALL'; topicFilter = @{ topicSlugs = @('database'); operator = 'IS' } } } | ConvertTo-Json -Depth 6 -Compress
    $r = Invoke-Lc (@{ query = $listQuery; variables = $vars } | ConvertTo-Json -Depth 6 -Compress)
    if ($null -eq $r) { throw ('List page failed at skip=' + $skip) }
    $list = $r.data.problemsetQuestionListV2
    $total = [int]$list.totalLength
    foreach ($q in $list.questions) { if (-not $q.paidOnly) { $slugs += $q.titleSlug } }
    $skip += 50
    Start-Sleep -Milliseconds 600
  }
  Write-Host ('Free SQL problems: ' + $slugs.Count)

  $fetched = @{}
  $n = 0
  foreach ($slug in $slugs) {
    $n++
    $r = Invoke-Lc (@{ query = $detailQuery; variables = @{ titleSlug = $slug } | ConvertTo-Json -Compress } | ConvertTo-Json -Compress)
    if ($null -eq $r -or $null -eq $r.data.question) { Write-Warning ('skip ' + $slug); continue }
    $q = $r.data.question
    $title = if ($q.translatedTitle) { $q.translatedTitle } else { $q.title }
    $schemas = @()
    foreach ($s in $q.mysqlSchemas) { if ($s) { $schemas += $s.Trim() } }
    $fetched[$slug] = @{ title = $title; difficulty = $q.difficulty.ToUpper(); html = $q.translatedContent; schema = (($schemas -join ';') + $NL) }
    Start-Sleep -Milliseconds 400
  }
  ($fetched | ConvertTo-Json -Depth 10) | Set-Content -Path $DetailsPath -Encoding UTF8
  Write-Host ('Wrote ' + $DetailsPath + ' (' + $fetched.Count + ' problems)')
}

if (-not (Test-Path $DetailsPath)) { throw ('Missing ' + $DetailsPath + '; run with -Fetch first.') }
if (-not (Test-Path $AnswersPath)) { throw ('Missing ' + $AnswersPath + '.') }

# ---------------------------------------------------------------------------
# 2. 生成 SQL
# ---------------------------------------------------------------------------
$details = Get-Content -Raw $DetailsPath | ConvertFrom-Json
$ans = Get-Content -Raw $AnswersPath | ConvertFrom-Json

# 参考答案修正：LeetCode 部分题面表名全小写，严格模式下需避免 ONLY_FULL_GROUP_BY。
$answerOverrides = @{}
$answerOverrides['not-boring-movies'] = "SELECT id, movie, description, rating FROM cinema WHERE id % 2 = 1 AND description <> 'boring' ORDER BY rating DESC;"
$answerOverrides['customer-placing-the-largest-number-of-orders'] = "SELECT customer_number FROM orders GROUP BY customer_number ORDER BY COUNT(*) DESC LIMIT 1;"
$answerOverrides['primary-department-for-each-employee'] = "SELECT employee_id, department_id FROM Employee WHERE primary_flag = 'Y' OR employee_id IN (SELECT employee_id FROM Employee GROUP BY employee_id HAVING COUNT(*) = 1);"

# 题面日期修正：LeetCode 少数题样本数据用 M/D/YYYY，MySQL 严格模式会拒绝。
$dateMap = @{
  "'4/1/2006'" = "'2006-04-01'"; "'5/1/2010'" = "'2010-05-01'"; "'12/25/2008'" = "'2008-12-25'"
  "'1/1/2005'" = "'2005-01-01'"; "'2/3/2007'" = "'2007-02-03'"
  "'1/1/2014'" = "'2014-01-01'"; "'2/1/2014'" = "'2014-02-01'"; "'3/1/2014'" = "'2014-03-01'"; "'4/1/2014'" = "'2014-04-01'"
}

function Convert-HtmlToText([string]$html) {
  if (-not $html) { return '' }
  $s = $html
  $s = $s -replace '(?is)<pre[^>]*>', $NL
  $s = $s -replace '(?is)</pre>', $NL
  $s = $s -replace '(?is)<br\s*/?>', $NL
  $s = $s -replace '(?is)</(p|div|li|h[1-6]|tr|ul|ol)>', $NL
  $s = $s -replace '(?is)<[^>]+>', ''
  $s = $s -replace '&nbsp;', ' '
  $s = $s -replace '&lt;', '<'
  $s = $s -replace '&gt;', '>'
  $s = $s -replace '&amp;', '&'
  $s = $s -replace '&quot;', '"'
  $s = $s -replace '&#39;', "'"
  $s = $s -replace '&apos;', "'"
  $s = $s -replace '[ \t]+', ' '
  $s = $s -replace "(\r?\n){3,}", ($NL + $NL)
  return $s.Trim()
}

function ConvertTo-SqlLiteral([string]$Value) {
  if ($null -eq $Value -or $Value -eq '') { return "''" }
  return "'" + ($Value.Replace("'", "''")) + "'"
}

function Get-Schema([string]$Slug) {
  $schema = $details.$Slug.schema
  if ($Slug -eq 'sales-person') { foreach ($k in $dateMap.Keys) { $schema = $schema.Replace($k, $dateMap[$k]) } }
  return $schema
}

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('-- ---------------------------------------------------------------------------')
$lines.Add('-- Student OJ LeetCode SQL 题库（含参考答案）')
$lines.Add('-- 来源：LeetCode 中国站 database 分类，免费题，共 ' + $ans.order.Count + ' 道。')
$lines.Add('-- 含：题目描述(纯文本)、init_sql(建表+造数)、answer_sql(参考答案)、测试用例。')
$lines.Add('-- 表结构匹配 student_oj.problem / problem_testcase，幂等，可与 init.sql 叠加执行。')
$lines.Add('-- 题目 id 段：1001 - ' + (1000 + $ans.order.Count))
$lines.Add('-- 由 tools/generate-leetcode-problems-full.ps1 生成，勿手工修改。')
$lines.Add('-- ---------------------------------------------------------------------------')
$lines.Add('USE student_oj;')
$lines.Add('')
$lines.Add('SET NAMES utf8mb4;')
$lines.Add('SET FOREIGN_KEY_CHECKS = 0;')
$lines.Add('')
$lines.Add('DELETE FROM problem_testcase WHERE problem_id BETWEEN 1001 AND 1100;')
$lines.Add('DELETE FROM problem WHERE id BETWEEN 1001 AND 1100;')
$lines.Add('')
$lines.Add('-- =================== 题目 ===================')

$probId = 1001
foreach ($slug in $ans.order) {
  $d = $details.$slug
  if ($null -eq $d) { Write-Warning ('missing detail: ' + $slug); continue }
  $answer = $ans.answers.$slug
  if ($answerOverrides.ContainsKey($slug)) { $answer = $answerOverrides[$slug] }
  $schema = Get-Schema $slug
  $desc = Convert-HtmlToText $d.html
  $row = '(' + $probId + ', ' + (ConvertTo-SqlLiteral $d.title) + ', ' + (ConvertTo-SqlLiteral $desc) + ', ' + (ConvertTo-SqlLiteral $d.difficulty) + ', ' + (ConvertTo-SqlLiteral '数据库') + ', ' + (ConvertTo-SqlLiteral $schema) + ', ' + (ConvertTo-SqlLiteral $answer) + ", '', '', 1)"
  $lines.Add('INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES')
  $lines.Add($row + ';')
  $probId++
}

$lines.Add('')
$lines.Add('-- =================== 测试用例（每题 1 个数据集 = init_sql） ===================')
$probId = 1001
foreach ($slug in $ans.order) {
  if ($null -eq $details.$slug) { continue }
  $row = '(' + $probId + ', 1, ' + (ConvertTo-SqlLiteral (Get-Schema $slug)) + ')'
  $lines.Add('INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES')
  $lines.Add($row + ';')
  $probId++
}

$lines.Add('')
$lines.Add('SET FOREIGN_KEY_CHECKS = 1;')
$lines.Add('')

Set-Content -Path $OutFile -Value ($lines -join [Environment]::NewLine) -Encoding UTF8
Write-Host ('Wrote ' + $OutFile + ' (' + $lines.Count + ' lines)')
