-- ---------------------------------------------------------------------------
-- Student OJ LeetCode SQL 题库（含参考答案）
-- 来源：LeetCode 中国站 database 分类，免费题，共 73 道。
-- 含：题目描述(纯文本)、init_sql(建表+造数)、answer_sql(参考答案)、测试用例。
-- 表结构匹配 student_oj.problem / problem_testcase，幂等，可与 init.sql 叠加执行。
-- 题目 id 段：1001 - 1073
-- 由 tools/generate-leetcode-problems-full.ps1 生成，勿手工修改。
-- ---------------------------------------------------------------------------
USE student_oj;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM problem_testcase WHERE problem_id BETWEEN 1001 AND 1100;
DELETE FROM problem WHERE id BETWEEN 1001 AND 1100;

-- =================== 题目 ===================
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1001, '组合两个表', '表: Person

+-------------+---------+
| 列名 | 类型 |
+-------------+---------+
| PersonId | int |
| FirstName | varchar |
| LastName | varchar |
+-------------+---------+
personId 是该表的主键（具有唯一值的列）。
该表包含一些人的 ID 和他们的姓和名的信息。



表: Address

+-------------+---------+
| 列名 | 类型 |
+-------------+---------+
| AddressId | int |
| PersonId | int |
| City | varchar |
| State | varchar |
+-------------+---------+
addressId 是该表的主键（具有唯一值的列）。
该表的每一行都包含一个 ID = PersonId 的人的城市和州的信息。



编写解决方案，报告 Person 表中每个人的姓、名、城市和州。如果 personId 的地址不在 Address 表中，则报告为 null 。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1:

输入:
Person表:
+----------+----------+-----------+
| personId | lastName | firstName |
+----------+----------+-----------+
| 1 | Wang | Allen |
| 2 | Alice | Bob |
+----------+----------+-----------+
Address表:
+-----------+----------+---------------+------------+
| addressId | personId | city | state |
+-----------+----------+---------------+------------+
| 1 | 2 | New York City | New York |
| 2 | 3 | Leetcode | California |
+-----------+----------+---------------+------------+
输出:
+-----------+----------+---------------+----------+
| firstName | lastName | city | state |
+-----------+----------+---------------+----------+
| Allen | Wang | Null | Null |
| Bob | Alice | New York City | New York |
+-----------+----------+---------------+----------+
解释:
地址表中没有 personId = 1 的地址，所以它们的城市和州返回 null。
addressId = 1 包含了 personId = 2 的地址信息。', 'EASY', '数据库', 'Create table If Not Exists Person (personId int, firstName varchar(255), lastName varchar(255));
Create table If Not Exists Address (addressId int, personId int, city varchar(255), state varchar(255));
Truncate table Person;
insert into Person (personId, lastName, firstName) values (''1'', ''Wang'', ''Allen'');
insert into Person (personId, lastName, firstName) values (''2'', ''Alice'', ''Bob'');
Truncate table Address;
insert into Address (addressId, personId, city, state) values (''1'', ''2'', ''New York City'', ''New York'');
insert into Address (addressId, personId, city, state) values (''2'', ''3'', ''Leetcode'', ''California'')', 'SELECT p.firstName, p.lastName, a.city, a.state
FROM Person p
LEFT JOIN Address a ON p.personId = a.personId;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1002, '超过经理收入的员工', '表：Employee

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| name | varchar |
| salary | int |
| managerId | int |
+-------------+---------+
id 是该表的主键（具有唯一值的列）。
该表的每一行都表示雇员的ID、姓名、工资和经理的ID。



编写解决方案，找出收入比经理高的员工。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1:

输入:
Employee 表:
+----+-------+--------+-----------+
| id | name | salary | managerId |
+----+-------+--------+-----------+
| 1 | Joe | 70000 | 3 |
| 2 | Henry | 80000 | 4 |
| 3 | Sam | 60000 | Null |
| 4 | Max | 90000 | Null |
+----+-------+--------+-----------+
输出:
+----------+
| Employee |
+----------+
| Joe |
+----------+
解释: Joe 是唯一挣得比经理多的雇员。', 'EASY', '数据库', 'Create table If Not Exists Employee (id int, name varchar(255), salary int, managerId int);
Truncate table Employee;
insert into Employee (id, name, salary, managerId) values (''1'', ''Joe'', ''70000'', ''3'');
insert into Employee (id, name, salary, managerId) values (''2'', ''Henry'', ''80000'', ''4'');
insert into Employee (id, name, salary, managerId) values (''3'', ''Sam'', ''60000'', NULL);
insert into Employee (id, name, salary, managerId) values (''4'', ''Max'', ''90000'', NULL)', 'SELECT e1.name AS Employee
FROM Employee e1
JOIN Employee e2 ON e1.managerId = e2.id
WHERE e1.salary > e2.salary;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1003, '查找重复的电子邮箱', '表: Person

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| email | varchar |
+-------------+---------+
id 是该表的主键（具有唯一值的列）。
此表的每一行都包含一封电子邮件。电子邮件不包含大写字母。



编写解决方案来报告所有重复的电子邮件。 请注意，可以保证电子邮件字段不为 NULL。

以 任意顺序 返回结果表。

结果格式如下例。



示例 1:

输入:
Person 表:
+----+---------+
| id | email |
+----+---------+
| 1 | a@b.com |
| 2 | c@d.com |
| 3 | a@b.com |
+----+---------+
输出:
+---------+
| Email |
+---------+
| a@b.com |
+---------+
解释: a@b.com 出现了两次。', 'EASY', '数据库', 'Create table If Not Exists Person (id int, email varchar(255));
Truncate table Person;
insert into Person (id, email) values (''1'', ''a@b.com'');
insert into Person (id, email) values (''2'', ''c@d.com'');
insert into Person (id, email) values (''3'', ''a@b.com'')', 'SELECT email AS Email
FROM Person
GROUP BY email
HAVING COUNT(*) > 1;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1004, '从不订购的客户', 'Customers 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| name | varchar |
+-------------+---------+
在 SQL 中，id 是该表的主键。
该表的每一行都表示客户的 ID 和名称。

Orders 表：

+-------------+------+
| Column Name | Type |
+-------------+------+
| id | int |
| customerId | int |
+-------------+------+
在 SQL 中，id 是该表的主键。
customerId 是 Customers 表中 ID 的外键( Pandas 中的连接键)。
该表的每一行都表示订单的 ID 和订购该订单的客户的 ID。



找出所有从不点任何东西的顾客。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1：

输入：
Customers table:
+----+-------+
| id | name |
+----+-------+
| 1 | Joe |
| 2 | Henry |
| 3 | Sam |
| 4 | Max |
+----+-------+
Orders table:
+----+------------+
| id | customerId |
+----+------------+
| 1 | 3 |
| 2 | 1 |
+----+------------+
输出：
+-----------+
| Customers |
+-----------+
| Henry |
| Max |
+-----------+', 'EASY', '数据库', 'Create table If Not Exists Customers (id int, name varchar(255));
Create table If Not Exists Orders (id int, customerId int);
Truncate table Customers;
insert into Customers (id, name) values (''1'', ''Joe'');
insert into Customers (id, name) values (''2'', ''Henry'');
insert into Customers (id, name) values (''3'', ''Sam'');
insert into Customers (id, name) values (''4'', ''Max'');
Truncate table Orders;
insert into Orders (id, customerId) values (''1'', ''3'');
insert into Orders (id, customerId) values (''2'', ''1'')', 'SELECT c.name AS Customers
FROM Customers c
LEFT JOIN Orders o ON c.id = o.customerId
WHERE o.id IS NULL;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1005, '上升的温度', '表： Weather

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| recordDate | date |
| temperature | int |
+---------------+---------+
id 是该表具有唯一值的列。
没有具有相同 recordDate 的不同行。
该表包含特定日期的温度信息



编写解决方案，找出与之前（昨天的）日期相比温度更高的所有日期的 id 。

返回结果 无顺序要求 。

结果格式如下例子所示。



示例 1：

输入：
Weather 表：
+----+------------+-------------+
| id | recordDate | Temperature |
+----+------------+-------------+
| 1 | 2015-01-01 | 10 |
| 2 | 2015-01-02 | 25 |
| 3 | 2015-01-03 | 20 |
| 4 | 2015-01-04 | 30 |
+----+------------+-------------+
输出：
+----+
| id |
+----+
| 2 |
| 4 |
+----+
解释：
2015-01-02 的温度比前一天高（10 -> 25）
2015-01-04 的温度比前一天高（20 -> 30）', 'EASY', '数据库', 'Create table If Not Exists Weather (id int, recordDate date, temperature int);
Truncate table Weather;
insert into Weather (id, recordDate, temperature) values (''1'', ''2015-01-01'', ''10'');
insert into Weather (id, recordDate, temperature) values (''2'', ''2015-01-02'', ''25'');
insert into Weather (id, recordDate, temperature) values (''3'', ''2015-01-03'', ''20'');
insert into Weather (id, recordDate, temperature) values (''4'', ''2015-01-04'', ''30'')', 'SELECT w1.id
FROM Weather w1
JOIN Weather w2 ON w1.recordDate = DATE_ADD(w2.recordDate, INTERVAL 1 DAY)
WHERE w1.temperature > w2.temperature;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1006, '员工奖金', '表：Employee

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| empId | int |
| name | varchar |
| supervisor | int |
| salary | int |
+-------------+---------+
empId 是该表中具有唯一值的列。
该表的每一行都表示员工的 id 和姓名，以及他们经理的 id 和他们的工资。



表：Bonus

+-------------+------+
| Column Name | Type |
+-------------+------+
| empId | int |
| bonus | int |
+-------------+------+
empId 是该表具有唯一值的列。
empId 是 Employee 表中 empId 的外键(reference 列)。
该表的每一行都包含一个员工的 id 和他们各自的奖金。



编写一个解决方案来报告满足以下任一条件的每个员工的姓名和奖金金额：

 奖金 少于 1000 的员工。

 没有任何奖金的员工。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1：

输入：
Employee table:
+-------+--------+------------+--------+
| empId | name | supervisor | salary |
+-------+--------+------------+--------+
| 3 | Brad | null | 4000 |
| 1 | John | 3 | 1000 |
| 2 | Dan | 3 | 2000 |
| 4 | Thomas | 3 | 4000 |
+-------+--------+------------+--------+
Bonus table:
+-------+-------+
| empId | bonus |
+-------+-------+
| 2 | 500 |
| 4 | 2000 |
+-------+-------+
输出：
+------+-------+
| name | bonus |
+------+-------+
| Brad | null |
| John | null |
| Dan | 500 |
+------+-------+', 'EASY', '数据库', 'Create table If Not Exists Employee (empId int, name varchar(255), supervisor int, salary int);
Create table If Not Exists Bonus (empId int, bonus int);
Truncate table Employee;
insert into Employee (empId, name, supervisor, salary) values (''3'', ''Brad'', NULL, ''4000'');
insert into Employee (empId, name, supervisor, salary) values (''1'', ''John'', ''3'', ''1000'');
insert into Employee (empId, name, supervisor, salary) values (''2'', ''Dan'', ''3'', ''2000'');
insert into Employee (empId, name, supervisor, salary) values (''4'', ''Thomas'', ''3'', ''4000'');
Truncate table Bonus;
insert into Bonus (empId, bonus) values (''2'', ''500'');
insert into Bonus (empId, bonus) values (''4'', ''2000'')', 'SELECT e.name, b.bonus
FROM Employee e
LEFT JOIN Bonus b ON e.empId = b.empId
WHERE b.bonus < 1000 OR b.bonus IS NULL;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1007, '寻找用户推荐人', '表: Customer

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| name | varchar |
| referee_id | int |
+-------------+---------+
在 SQL 中，id 是该表的主键列。
该表的每一行表示一个客户的 id、姓名以及推荐他们的客户的 id。

找出以下客户的姓名：

 被任何 id != 2 的用户推荐。

 没有被 任何用户推荐。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1：

输入：
Customer 表:
+----+------+------------+
| id | name | referee_id |
+----+------+------------+
| 1 | Will | null |
| 2 | Jane | null |
| 3 | Alex | 2 |
| 4 | Bill | null |
| 5 | Zack | 1 |
| 6 | Mark | 2 |
+----+------+------------+
输出：
+------+
| name |
+------+
| Will |
| Jane |
| Bill |
| Zack |
+------+', 'EASY', '数据库', 'Create table If Not Exists Customer (id int, name varchar(25), referee_id int);
Truncate table Customer;
insert into Customer (id, name, referee_id) values (''1'', ''Will'', NULL);
insert into Customer (id, name, referee_id) values (''2'', ''Jane'', NULL);
insert into Customer (id, name, referee_id) values (''3'', ''Alex'', ''2'');
insert into Customer (id, name, referee_id) values (''4'', ''Bill'', NULL);
insert into Customer (id, name, referee_id) values (''5'', ''Zack'', ''1'');
insert into Customer (id, name, referee_id) values (''6'', ''Mark'', ''2'')', 'SELECT name
FROM Customer
WHERE referee_id IS NULL OR referee_id <> 2;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1008, '大的国家', 'World 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| name | varchar |
| continent | varchar |
| area | int |
| population | int |
| gdp | bigint |
+-------------+---------+
name 是该表的主键（具有唯一值的列）。
这张表的每一行提供：国家名称、所属大陆、面积、人口和 GDP 值。



如果一个国家满足下述两个条件之一，则认为该国是 大国 ：

 面积至少为 300 万平方公里（即，3000000 km2），或者

 人口至少为 2500 万（即 25000000）

编写解决方案找出 大国 的国家名称、人口和面积。

按 任意顺序 返回结果表。

返回结果格式如下例所示。



示例：

输入：
World 表：
+-------------+-----------+---------+------------+--------------+
| name | continent | area | population | gdp |
+-------------+-----------+---------+------------+--------------+
| Afghanistan | Asia | 652230 | 25500100 | 20343000000 |
| Albania | Europe | 28748 | 2831741 | 12960000000 |
| Algeria | Africa | 2381741 | 37100000 | 188681000000 |
| Andorra | Europe | 468 | 78115 | 3712000000 |
| Angola | Africa | 1246700 | 20609294 | 100990000000 |
+-------------+-----------+---------+------------+--------------+
输出：
+-------------+------------+---------+
| name | population | area |
+-------------+------------+---------+
| Afghanistan | 25500100 | 652230 |
| Algeria | 37100000 | 2381741 |
+-------------+------------+---------+', 'EASY', '数据库', 'Create table If Not Exists World (name varchar(255), continent varchar(255), area int, population int, gdp bigint);
Truncate table World;
insert into World (name, continent, area, population, gdp) values (''Afghanistan'', ''Asia'', ''652230'', ''25500100'', ''20343000000'');
insert into World (name, continent, area, population, gdp) values (''Albania'', ''Europe'', ''28748'', ''2831741'', ''12960000000'');
insert into World (name, continent, area, population, gdp) values (''Algeria'', ''Africa'', ''2381741'', ''37100000'', ''188681000000'');
insert into World (name, continent, area, population, gdp) values (''Andorra'', ''Europe'', ''468'', ''78115'', ''3712000000'');
insert into World (name, continent, area, population, gdp) values (''Angola'', ''Africa'', ''1246700'', ''20609294'', ''100990000000'')', 'SELECT name, population, area
FROM World
WHERE area >= 3000000 OR population >= 25000000;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1009, '销售员', '表: SalesPerson

+-----------------+---------+
| Column Name | Type |
+-----------------+---------+
| sales_id | int |
| name | varchar |
| salary | int |
| commission_rate | int |
| hire_date | date |
+-----------------+---------+
sales_id 是该表的主键列(具有唯一值的列)。
该表的每一行都显示了销售人员的姓名和 ID ，以及他们的工资、佣金率和雇佣日期。



表: Company

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| com_id | int |
| name | varchar |
| city | varchar |
+-------------+---------+
com_id 是该表的主键列(具有唯一值的列)。
该表的每一行都表示公司的名称和 ID ，以及公司所在的城市。



表: Orders

+-------------+------+
| Column Name | Type |
+-------------+------+
| order_id | int |
| order_date | date |
| com_id | int |
| sales_id | int |
| amount | int |
+-------------+------+
order_id 是该表的主键列(具有唯一值的列)。
com_id 是 Company 表中 com_id 的外键（reference 列）。
sales_id 是来自销售员表 sales_id 的外键（reference 列）。
该表的每一行包含一个订单的信息。这包括公司的 ID 、销售人员的 ID 、订单日期和支付的金额。



编写解决方案，找出没有任何与名为 “RED” 的公司相关的订单的所有销售人员的姓名。

以 任意顺序 返回结果表。

返回结果格式如下所示。



示例 1：

输入：
SalesPerson 表:
+----------+------+--------+-----------------+------------+
| sales_id | name | salary | commission_rate | hire_date |
+----------+------+--------+-----------------+------------+
| 1 | John | 100000 | 6 | 4/1/2006 |
| 2 | Amy | 12000 | 5 | 5/1/2010 |
| 3 | Mark | 65000 | 12 | 12/25/2008 |
| 4 | Pam | 25000 | 25 | 1/1/2005 |
| 5 | Alex | 5000 | 10 | 2/3/2007 |
+----------+------+--------+-----------------+------------+
Company 表:
+--------+--------+----------+
| com_id | name | city |
+--------+--------+----------+
| 1 | RED | Boston |
| 2 | ORANGE | New York |
| 3 | YELLOW | Boston |
| 4 | GREEN | Austin |
+--------+--------+----------+
Orders 表:
+----------+------------+--------+----------+--------+
| order_id | order_date | com_id | sales_id | amount |
+----------+------------+--------+----------+--------+
| 1 | 1/1/2014 | 3 | 4 | 10000 |
| 2 | 2/1/2014 | 4 | 5 | 5000 |
| 3 | 3/1/2014 | 1 | 1 | 50000 |
| 4 | 4/1/2014 | 1 | 4 | 25000 |
+----------+------------+--------+----------+--------+
输出：
+------+
| name |
+------+
| Amy |
| Mark |
| Alex |
+------+
解释：
根据表 orders 中的订单 ''3'' 和 ''4'' ，容易看出只有 ''John'' 和 ''Pam'' 两个销售员曾经向公司 ''RED'' 销售过。
所以我们需要输出表 salesperson 中所有其他人的名字。', 'EASY', '数据库', 'Create table If Not Exists SalesPerson (sales_id int, name varchar(255), salary int, commission_rate int, hire_date date);
Create table If Not Exists Company (com_id int, name varchar(255), city varchar(255));
Create table If Not Exists Orders (order_id int, order_date date, com_id int, sales_id int, amount int);
Truncate table SalesPerson;
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''1'', ''John'', ''100000'', ''6'', ''2006-04-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''2'', ''Amy'', ''12000'', ''5'', ''2010-05-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''3'', ''Mark'', ''65000'', ''12'', ''2008-12-25'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''4'', ''Pam'', ''25000'', ''25'', ''2005-01-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''5'', ''Alex'', ''5000'', ''10'', ''2007-02-03'');
Truncate table Company;
insert into Company (com_id, name, city) values (''1'', ''RED'', ''Boston'');
insert into Company (com_id, name, city) values (''2'', ''ORANGE'', ''New York'');
insert into Company (com_id, name, city) values (''3'', ''YELLOW'', ''Boston'');
insert into Company (com_id, name, city) values (''4'', ''GREEN'', ''Austin'');
Truncate table Orders;
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''1'', ''2014-01-01'', ''3'', ''4'', ''10000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''2'', ''2014-02-01'', ''4'', ''5'', ''5000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''3'', ''2014-03-01'', ''1'', ''1'', ''50000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''4'', ''2014-04-01'', ''1'', ''4'', ''25000'')', 'SELECT s.name
FROM SalesPerson s
WHERE s.sales_id NOT IN (
  SELECT o.sales_id
  FROM Orders o
  JOIN Company c ON o.com_id = c.com_id
  WHERE c.name = ''RED''
);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1010, '判断三角形', '表: Triangle

+-------------+------+
| Column Name | Type |
+-------------+------+
| x | int |
| y | int |
| z | int |
+-------------+------+
在 SQL 中，(x, y, z)是该表的主键列。
该表的每一行包含三个线段的长度。



对每三个线段报告它们是否可以形成一个三角形。

以 任意顺序 返回结果表。

查询结果格式如下所示。



示例 1:

输入:
Triangle 表:
+----+----+----+
| x | y | z |
+----+----+----+
| 13 | 15 | 30 |
| 10 | 20 | 15 |
+----+----+----+
输出:
+----+----+----+----------+
| x | y | z | triangle |
+----+----+----+----------+
| 13 | 15 | 30 | No |
| 10 | 20 | 15 | Yes |
+----+----+----+----------+', 'EASY', '数据库', 'Create table If Not Exists Triangle (x int, y int, z int);
Truncate table Triangle;
insert into Triangle (x, y, z) values (''13'', ''15'', ''30'');
insert into Triangle (x, y, z) values (''10'', ''20'', ''15'')', 'SELECT x, y, z,
  CASE WHEN x + y > z AND x + z > y AND y + z > x THEN ''Yes'' ELSE ''No'' END AS triangle
FROM Triangle;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1011, '有趣的电影', '表：cinema

+----------------+----------+
| Column Name | Type |
+----------------+----------+
| id | int |
| movie | varchar |
| description | varchar |
| rating | float |
+----------------+----------+
id 是该表的主键(具有唯一值的列)。
每行包含有关电影名称、类型和评级的信息。
评级为 [0,10] 范围内的小数点后 2 位浮点数。



编写解决方案，找出所有影片描述为 非 boring (不无聊) 的并且 id 为奇数 的影片。

返回结果按 rating 降序排列。

结果格式如下示例。



示例 1：

输入：
+---------+-----------+--------------+-----------+
| id | movie | description | rating |
+---------+-----------+--------------+-----------+
| 1 | War | great 3D | 8.9 |
| 2 | Science | fiction | 8.5 |
| 3 | irish | boring | 6.2 |
| 4 | Ice song | Fantacy | 8.6 |
| 5 | House card| Interesting| 9.1 |
+---------+-----------+--------------+-----------+
输出：
+---------+-----------+--------------+-----------+
| id | movie | description | rating |
+---------+-----------+--------------+-----------+
| 5 | House card| Interesting| 9.1 |
| 1 | War | great 3D | 8.9 |
+---------+-----------+--------------+-----------+
解释：
我们有三部电影，它们的 id 是奇数:1、3 和 5。id = 3 的电影是 boring 的，所以我们不把它包括在答案中。', 'EASY', '数据库', 'Create table If Not Exists cinema (id int, movie varchar(255), description varchar(255), rating float(2, 1));
Truncate table cinema;
insert into cinema (id, movie, description, rating) values (''1'', ''War'', ''great 3D'', ''8.9'');
insert into cinema (id, movie, description, rating) values (''2'', ''Science'', ''fiction'', ''8.5'');
insert into cinema (id, movie, description, rating) values (''3'', ''irish'', ''boring'', ''6.2'');
insert into cinema (id, movie, description, rating) values (''4'', ''Ice song'', ''Fantacy'', ''8.6'');
insert into cinema (id, movie, description, rating) values (''5'', ''House card'', ''Interesting'', ''9.1'')', 'SELECT id, movie, description, rating FROM cinema WHERE id % 2 = 1 AND description <> ''boring'' ORDER BY rating DESC;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1012, '游戏玩法分析 I', '活动表 Activity：

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| player_id | int |
| device_id | int |
| event_date | date |
| games_played | int |
+--------------+---------+
在 SQL 中，表的主键是 (player_id, event_date)。
这张表展示了一些游戏玩家在游戏平台上的行为活动。
每行数据记录了一名玩家在退出平台之前，当天使用同一台设备登录平台后打开的游戏的数目（可能是 0 个）。



查询每位玩家 第一次登录平台的日期。

查询结果的格式如下所示：

Activity 表：
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1 | 2 | 2016-03-01 | 5 |
| 1 | 2 | 2016-05-02 | 6 |
| 2 | 3 | 2017-06-25 | 1 |
| 3 | 1 | 2016-03-02 | 0 |
| 3 | 4 | 2018-07-03 | 5 |
+-----------+-----------+------------+--------------+

Result 表：
+-----------+-------------+
| player_id | first_login |
+-----------+-------------+
| 1 | 2016-03-01 |
| 2 | 2017-06-25 |
| 3 | 2016-03-02 |
+-----------+-------------+', 'EASY', '数据库', 'Create table If Not Exists Activity (player_id int, device_id int, event_date date, games_played int);
Truncate table Activity;
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-01'', ''5'');
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-05-02'', ''6'');
insert into Activity (player_id, device_id, event_date, games_played) values (''2'', ''3'', ''2017-06-25'', ''1'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''1'', ''2016-03-02'', ''0'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''4'', ''2018-07-03'', ''5'')', 'SELECT player_id, MIN(event_date) AS first_login
FROM Activity
GROUP BY player_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1013, '文章浏览 I', 'Views 表：

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| article_id | int |
| author_id | int |
| viewer_id | int |
| view_date | date |
+---------------+---------+
此表可能会存在重复行。（换句话说，在 SQL 中这个表没有主键）
此表的每一行都表示某人在某天浏览了某位作者的某篇文章。
请注意，同一人的 author_id 和 viewer_id 是相同的。



请查询出所有浏览过自己文章的作者。

结果按照作者的 id 升序排列。

查询结果的格式如下所示：



示例 1：

输入：
Views 表：
+------------+-----------+-----------+------------+
| article_id | author_id | viewer_id | view_date |
+------------+-----------+-----------+------------+
| 1 | 3 | 5 | 2019-08-01 |
| 1 | 3 | 6 | 2019-08-02 |
| 2 | 7 | 7 | 2019-08-01 |
| 2 | 7 | 6 | 2019-08-02 |
| 4 | 7 | 1 | 2019-07-22 |
| 3 | 4 | 4 | 2019-07-21 |
| 3 | 4 | 4 | 2019-07-21 |
+------------+-----------+-----------+------------+

输出：
+------+
| id |
+------+
| 4 |
| 7 |
+------+', 'EASY', '数据库', 'Create table If Not Exists Views (article_id int, author_id int, viewer_id int, view_date date);
Truncate table Views;
insert into Views (article_id, author_id, viewer_id, view_date) values (''1'', ''3'', ''5'', ''2019-08-01'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''1'', ''3'', ''6'', ''2019-08-02'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''2'', ''7'', ''7'', ''2019-08-01'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''2'', ''7'', ''6'', ''2019-08-02'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''4'', ''7'', ''1'', ''2019-07-22'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''3'', ''4'', ''4'', ''2019-07-21'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''3'', ''4'', ''4'', ''2019-07-21'')', 'SELECT DISTINCT author_id AS id
FROM Views
WHERE author_id = viewer_id
ORDER BY id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1014, '可回收且低脂的产品', '表：Products

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| product_id | int |
| low_fats | enum |
| recyclable | enum |
+-------------+---------+
product_id 是该表的主键（具有唯一值的列）。
low_fats 是枚举类型，取值为以下两种 (''Y'', ''N'')，其中 ''Y'' 表示该产品是低脂产品，''N'' 表示不是低脂产品。
recyclable 是枚举类型，取值为以下两种 (''Y'', ''N'')，其中 ''Y'' 表示该产品可回收，而 ''N'' 表示不可回收。



编写解决方案找出既是低脂又是可回收的产品编号。

返回结果 无顺序要求 。

返回结果格式如下例所示：



示例 1：

输入：
Products 表：
+-------------+----------+------------+
| product_id | low_fats | recyclable |
+-------------+----------+------------+
| 0 | Y | N |
| 1 | Y | Y |
| 2 | N | Y |
| 3 | Y | Y |
| 4 | N | N |
+-------------+----------+------------+
输出：
+-------------+
| product_id |
+-------------+
| 1 |
| 3 |
+-------------+
解释：
只有产品 id 为 1 和 3 的产品，既是低脂又是可回收的产品。', 'EASY', '数据库', 'Create table If Not Exists Products (product_id int, low_fats ENUM(''Y'', ''N''), recyclable ENUM(''Y'',''N''));
Truncate table Products;
insert into Products (product_id, low_fats, recyclable) values (''0'', ''Y'', ''N'');
insert into Products (product_id, low_fats, recyclable) values (''1'', ''Y'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''2'', ''N'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''3'', ''Y'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''4'', ''N'', ''N'')', 'SELECT product_id
FROM Products
WHERE low_fats = ''Y'' AND recyclable = ''Y'';', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1015, '无效的推文', '表：Tweets

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| tweet_id | int |
| content | varchar |
+----------------+---------+
在 SQL 中，tweet_id 是这个表的主键。
content 只包含字母数字字符，''!''，'' ''，不包含其它特殊字符。
这个表包含某社交媒体 App 中所有的推文。



查询所有无效推文的编号（ID）。当推文内容中的字符数严格大于 15 时，该推文是无效的。

以任意顺序返回结果表。

查询结果格式如下所示：



示例 1：

输入：
Tweets 表：
+----------+----------------------------------+
| tweet_id | content |
+----------+----------------------------------+
| 1 | Vote for Biden |
| 2 | Let us make America great again! |
+----------+----------------------------------+

输出：
+----------+
| tweet_id |
+----------+
| 2 |
+----------+
解释：
推文 1 的长度 length = 14。该推文是有效的。
推文 2 的长度 length = 32。该推文是无效的。', 'EASY', '数据库', 'Create table If Not Exists Tweets(tweet_id int, content varchar(50));
Truncate table Tweets;
insert into Tweets (tweet_id, content) values (''1'', ''Let us Code'');
insert into Tweets (tweet_id, content) values (''2'', ''More than fifteen chars are here!'')', 'SELECT tweet_id
FROM Tweets
WHERE LENGTH(content) > 15;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1016, '修复表中的名字', '表： Users

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| user_id | int |
| name | varchar |
+----------------+---------+
user_id 是该表的主键(具有唯一值的列)。
该表包含用户的 ID 和名字。名字仅由小写和大写字符组成。



编写解决方案，修复名字，使得只有第一个字符是大写的，其余都是小写的。

返回按 user_id 排序的结果表。

返回结果格式示例如下。



示例 1：

输入：
Users table:
+---------+-------+
| user_id | name |
+---------+-------+
| 1 | aLice |
| 2 | bOB |
+---------+-------+
输出：
+---------+-------+
| user_id | name |
+---------+-------+
| 1 | Alice |
| 2 | Bob |
+---------+-------+', 'EASY', '数据库', 'Create table If Not Exists Users (user_id int, name varchar(40));
Truncate table Users;
insert into Users (user_id, name) values (''1'', ''aLice'');
insert into Users (user_id, name) values (''2'', ''bOB'')', 'SELECT user_id, CONCAT(UPPER(LEFT(name, 1)), LOWER(SUBSTRING(name, 2))) AS name
FROM Users
ORDER BY user_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1017, '求关注者的数量', '表： Followers

+-------------+------+
| Column Name | Type |
+-------------+------+
| user_id | int |
| follower_id | int |
+-------------+------+
(user_id, follower_id) 是这个表的主键（具有唯一值的列的组合）。
该表包含一个关注关系中关注者和用户的编号，其中关注者关注用户。



编写解决方案，对于每一个用户，返回该用户的关注者数量。

按 user_id 的顺序返回结果表。

查询结果的格式如下示例所示。



示例 1：

输入：
Followers 表：
+---------+-------------+
| user_id | follower_id |
+---------+-------------+
| 0 | 1 |
| 1 | 0 |
| 2 | 0 |
| 2 | 1 |
+---------+-------------+
输出：
+---------+----------------+
| user_id | followers_count|
+---------+----------------+
| 0 | 1 |
| 1 | 1 |
| 2 | 2 |
+---------+----------------+
解释：
0 的关注者有 {1}
1 的关注者有 {0}
2 的关注者有 {0,1}', 'EASY', '数据库', 'Create table If Not Exists Followers(user_id int, follower_id int);
Truncate table Followers;
insert into Followers (user_id, follower_id) values (''0'', ''1'');
insert into Followers (user_id, follower_id) values (''1'', ''0'');
insert into Followers (user_id, follower_id) values (''2'', ''0'');
insert into Followers (user_id, follower_id) values (''2'', ''1'')', 'SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1018, '查找每个员工花费的总时间', '表: Employees

+-------------+------+
| Column Name | Type |
+-------------+------+
| emp_id | int |
| event_day | date |
| in_time | int |
| out_time | int |
+-------------+------+
在 SQL 中，(emp_id, event_day, in_time) 是这个表的主键。
该表显示了员工在办公室的出入情况。
event_day 是此事件发生的日期，in_time 是员工进入办公室的时间，而 out_time 是他们离开办公室的时间。
in_time 和 out_time 的取值在1到1440之间。
题目保证同一天没有两个事件在时间上是相交的，并且保证 in_time 小于 out_time。



计算每位员工每天在办公室花费的总时间（以分钟为单位）。 请注意，在一天之内，同一员工是可以多次进入和离开办公室的。 在办公室里一次进出所花费的时间为out_time 减去 in_time。

返回结果表单的顺序无要求。

查询结果的格式如下：



示例 1：

输入：
Employees table:
+--------+------------+---------+----------+
| emp_id | event_day | in_time | out_time |
+--------+------------+---------+----------+
| 1 | 2020-11-28 | 4 | 32 |
| 1 | 2020-11-28 | 55 | 200 |
| 1 | 2020-12-03 | 1 | 42 |
| 2 | 2020-11-28 | 3 | 33 |
| 2 | 2020-12-09 | 47 | 74 |
+--------+------------+---------+----------+
输出：
+------------+--------+------------+
| day | emp_id | total_time |
+------------+--------+------------+
| 2020-11-28 | 1 | 173 |
| 2020-11-28 | 2 | 30 |
| 2020-12-03 | 1 | 41 |
| 2020-12-09 | 2 | 27 |
+------------+--------+------------+
解释：
雇员 1 有三次进出: 有两次发生在 2020-11-28 花费的时间为 (32 - 4) + (200 - 55) = 173, 有一次发生在 2020-12-03 花费的时间为 (42 - 1) = 41。
雇员 2 有两次进出: 有一次发生在 2020-11-28 花费的时间为 (33 - 3) = 30, 有一次发生在 2020-12-09 花费的时间为 (74 - 47) = 27。', 'EASY', '数据库', 'Create table If Not Exists Employees(emp_id int, event_day date, in_time int, out_time int);
Truncate table Employees;
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-11-28'', ''4'', ''32'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-11-28'', ''55'', ''200'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-12-3'', ''1'', ''42'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''2'', ''2020-11-28'', ''3'', ''33'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''2'', ''2020-12-9'', ''47'', ''74'')', 'SELECT event_day AS day, emp_id, SUM(out_time - in_time) AS total_time
FROM Employees
GROUP BY event_day, emp_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1019, '每天的领导和合伙人', '表：DailySales

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| date_id | date |
| make_name | varchar |
| lead_id | int |
| partner_id | int |
+-------------+---------+
该表没有主键(具有唯一值的列)。它可能包含重复项。
该表包含日期、产品的名称，以及售给的领导和合伙人的编号。
名称只包含小写英文字母。



对于每一个 date_id 和 make_name，找出 不同 的 lead_id 以及 不同 的 partner_id 的数量。

按 任意顺序 返回结果表。

返回结果格式如下示例所示。



示例 1:

输入：
DailySales 表：
+-----------+-----------+---------+------------+
| date_id | make_name | lead_id | partner_id |
+-----------+-----------+---------+------------+
| 2020-12-8 | toyota | 0 | 1 |
| 2020-12-8 | toyota | 1 | 0 |
| 2020-12-8 | toyota | 1 | 2 |
| 2020-12-7 | toyota | 0 | 2 |
| 2020-12-7 | toyota | 0 | 1 |
| 2020-12-8 | honda | 1 | 2 |
| 2020-12-8 | honda | 2 | 1 |
| 2020-12-7 | honda | 0 | 1 |
| 2020-12-7 | honda | 1 | 2 |
| 2020-12-7 | honda | 2 | 1 |
+-----------+-----------+---------+------------+
输出：
+-----------+-----------+--------------+-----------------+
| date_id | make_name | unique_leads | unique_partners |
+-----------+-----------+--------------+-----------------+
| 2020-12-8 | toyota | 2 | 3 |
| 2020-12-7 | toyota | 1 | 2 |
| 2020-12-8 | honda | 2 | 2 |
| 2020-12-7 | honda | 3 | 2 |
+-----------+-----------+--------------+-----------------+
解释：
在 2020-12-8，丰田（toyota）有领导者 = [0, 1] 和合伙人 = [0, 1, 2] ，同时本田（honda）有领导者 = [1, 2] 和合伙人 = [1, 2]。
在 2020-12-7，丰田（toyota）有领导者 = [0] 和合伙人 = [1, 2] ，同时本田（honda）有领导者 = [0, 1, 2] 和合伙人 = [1, 2]。', 'EASY', '数据库', 'Create table If Not Exists DailySales(date_id date, make_name varchar(20), lead_id int, partner_id int);
Truncate table DailySales;
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''1'', ''0'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''toyota'', ''0'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''toyota'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''honda'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''honda'', ''2'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''2'', ''1'')', 'SELECT date_id, make_name, COUNT(DISTINCT lead_id) AS unique_leads, COUNT(DISTINCT partner_id) AS unique_partners
FROM DailySales
GROUP BY date_id, make_name;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1020, '项目员工 I', '项目表 Project：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| project_id | int |
| employee_id | int |
+-------------+---------+
主键为 (project_id, employee_id)。
employee_id 是员工表 Employee 表的外键。
这张表的每一行表示 employee_id 的员工正在 project_id 的项目上工作。



员工表 Employee：

+------------------+---------+
| Column Name | Type |
+------------------+---------+
| employee_id | int |
| name | varchar |
| experience_years | int |
+------------------+---------+
主键是 employee_id。数据保证 experience_years 非空。
这张表的每一行包含一个员工的信息。



请写一个 SQL 语句，查询每一个项目中员工的 平均 工作年限，精确到小数点后两位。

以 任意 顺序返回结果表。

查询结果的格式如下。



示例 1:

输入：
Project 表：
+-------------+-------------+
| project_id | employee_id |
+-------------+-------------+
| 1 | 1 |
| 1 | 2 |
| 1 | 3 |
| 2 | 1 |
| 2 | 4 |
+-------------+-------------+

Employee 表：
+-------------+--------+------------------+
| employee_id | name | experience_years |
+-------------+--------+------------------+
| 1 | Khaled | 3 |
| 2 | Ali | 2 |
| 3 | John | 1 |
| 4 | Doe | 2 |
+-------------+--------+------------------+

输出：
+-------------+---------------+
| project_id | average_years |
+-------------+---------------+
| 1 | 2.00 |
| 2 | 2.50 |
+-------------+---------------+
解释：第一个项目中，员工的平均工作年限是 (3 + 2 + 1) / 3 = 2.00；第二个项目中，员工的平均工作年限是 (3 + 2) / 2 = 2.50', 'EASY', '数据库', 'Create table If Not Exists Project (project_id int, employee_id int);
Create table If Not Exists Employee (employee_id int, name varchar(10), experience_years int);
Truncate table Project;
insert into Project (project_id, employee_id) values (''1'', ''1'');
insert into Project (project_id, employee_id) values (''1'', ''2'');
insert into Project (project_id, employee_id) values (''1'', ''3'');
insert into Project (project_id, employee_id) values (''2'', ''1'');
insert into Project (project_id, employee_id) values (''2'', ''4'');
Truncate table Employee;
insert into Employee (employee_id, name, experience_years) values (''1'', ''Khaled'', ''3'');
insert into Employee (employee_id, name, experience_years) values (''2'', ''Ali'', ''2'');
insert into Employee (employee_id, name, experience_years) values (''3'', ''John'', ''1'');
insert into Employee (employee_id, name, experience_years) values (''4'', ''Doe'', ''2'')', 'SELECT p.project_id, ROUND(AVG(e.experience_years), 2) AS average_years
FROM Project p
JOIN Employee e ON p.employee_id = e.employee_id
GROUP BY p.project_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1021, '平均售价', '表：Prices

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| product_id | int |
| start_date | date |
| end_date | date |
| price | int |
+---------------+---------+
(product_id，start_date，end_date) 是 prices 表的主键（具有唯一值的列的组合）。
prices 表的每一行表示的是某个产品在一段时期内的价格。
每个产品的对应时间段是不会重叠的，这也意味着同一个产品的价格时段不会出现交叉。



表：UnitsSold

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| product_id | int |
| purchase_date | date |
| units | int |
+---------------+---------+
该表可能包含重复数据。
该表的每一行表示的是每种产品的出售日期，单位和产品 id。



编写解决方案以查找每种产品的平均售价。average_price 应该 四舍五入到小数点后两位。如果产品没有任何售出，则假设其平均售价为 0。

返回结果表 无顺序要求 。

结果格式如下例所示。



示例 1：

输入：
Prices table:
+------------+------------+------------+--------+
| product_id | start_date | end_date | price |
+------------+------------+------------+--------+
| 1 | 2019-02-17 | 2019-02-28 | 5 |
| 1 | 2019-03-01 | 2019-03-22 | 20 |
| 2 | 2019-02-01 | 2019-02-20 | 15 |
| 2 | 2019-02-21 | 2019-03-31 | 30 |
+------------+------------+------------+--------+
UnitsSold table:
+------------+---------------+-------+
| product_id | purchase_date | units |
+------------+---------------+-------+
| 1 | 2019-02-25 | 100 |
| 1 | 2019-03-01 | 15 |
| 2 | 2019-02-10 | 200 |
| 2 | 2019-03-22 | 30 |
+------------+---------------+-------+
输出：
+------------+---------------+
| product_id | average_price |
+------------+---------------+
| 1 | 6.96 |
| 2 | 16.96 |
+------------+---------------+
解释：
平均售价 = 产品总价 / 销售的产品数量。
产品 1 的平均售价 = ((100 * 5)+(15 * 20) )/ 115 = 6.96
产品 2 的平均售价 = ((200 * 15)+(30 * 30) )/ 230 = 16.96', 'EASY', '数据库', 'Create table If Not Exists Prices (product_id int, start_date date, end_date date, price int);
Create table If Not Exists UnitsSold (product_id int, purchase_date date, units int);
Truncate table Prices;
insert into Prices (product_id, start_date, end_date, price) values (''1'', ''2019-02-17'', ''2019-02-28'', ''5'');
insert into Prices (product_id, start_date, end_date, price) values (''1'', ''2019-03-01'', ''2019-03-22'', ''20'');
insert into Prices (product_id, start_date, end_date, price) values (''2'', ''2019-02-01'', ''2019-02-20'', ''15'');
insert into Prices (product_id, start_date, end_date, price) values (''2'', ''2019-02-21'', ''2019-03-31'', ''30'');
Truncate table UnitsSold;
insert into UnitsSold (product_id, purchase_date, units) values (''1'', ''2019-02-25'', ''100'');
insert into UnitsSold (product_id, purchase_date, units) values (''1'', ''2019-03-01'', ''15'');
insert into UnitsSold (product_id, purchase_date, units) values (''2'', ''2019-02-10'', ''200'');
insert into UnitsSold (product_id, purchase_date, units) values (''2'', ''2019-03-22'', ''30'')', 'SELECT p.product_id, ROUND(SUM(u.units * p.price) / SUM(u.units), 2) AS average_price
FROM Prices p
JOIN UnitsSold u ON p.product_id = u.product_id AND u.purchase_date BETWEEN p.start_date AND p.end_date
GROUP BY p.product_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1022, '学生们参加各科测试的次数', '学生表: Students

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| student_id | int |
| student_name | varchar |
+---------------+---------+
在 SQL 中，主键为 student_id（学生ID）。
该表内的每一行都记录有学校一名学生的信息。



科目表: Subjects

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| subject_name | varchar |
+--------------+---------+
在 SQL 中，主键为 subject_name（科目名称）。
每一行记录学校的一门科目名称。



考试表: Examinations

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| student_id | int |
| subject_name | varchar |
+--------------+---------+
这个表可能包含重复数据（换句话说，在 SQL 中，这个表没有主键）。
学生表里的一个学生修读科目表里的每一门科目。
这张考试表的每一行记录就表示学生表里的某个学生参加了一次科目表里某门科目的测试。



查询出每个学生参加每一门科目测试的次数，结果按 student_id 和 subject_name 排序。

查询结构格式如下所示。



示例 1：

输入：
Students table:
+------------+--------------+
| student_id | student_name |
+------------+--------------+
| 1 | Alice |
| 2 | Bob |
| 13 | John |
| 6 | Alex |
+------------+--------------+
Subjects table:
+--------------+
| subject_name |
+--------------+
| Math |
| Physics |
| Programming |
+--------------+
Examinations table:
+------------+--------------+
| student_id | subject_name |
+------------+--------------+
| 1 | Math |
| 1 | Physics |
| 1 | Programming |
| 2 | Programming |
| 1 | Physics |
| 1 | Math |
| 13 | Math |
| 13 | Programming |
| 13 | Physics |
| 2 | Math |
| 1 | Math |
+------------+--------------+
输出：
+------------+--------------+--------------+----------------+
| student_id | student_name | subject_name | attended_exams |
+------------+--------------+--------------+----------------+
| 1 | Alice | Math | 3 |
| 1 | Alice | Physics | 2 |
| 1 | Alice | Programming | 1 |
| 2 | Bob | Math | 1 |
| 2 | Bob | Physics | 0 |
| 2 | Bob | Programming | 1 |
| 6 | Alex | Math | 0 |
| 6 | Alex | Physics | 0 |
| 6 | Alex | Programming | 0 |
| 13 | John | Math | 1 |
| 13 | John | Physics | 1 |
| 13 | John | Programming | 1 |
+------------+--------------+--------------+----------------+
解释：
结果表需包含所有学生和所有科目（即便测试次数为0）：
Alice 参加了 3 次数学测试, 2 次物理测试，以及 1 次编程测试；
Bob 参加了 1 次数学测试, 1 次编程测试，没有参加物理测试；
Alex 啥测试都没参加；
John 参加了数学、物理、编程测试各 1 次。', 'EASY', '数据库', 'Create table If Not Exists Students (student_id int, student_name varchar(20));
Create table If Not Exists Subjects (subject_name varchar(20));
Create table If Not Exists Examinations (student_id int, subject_name varchar(20));
Truncate table Students;
insert into Students (student_id, student_name) values (''1'', ''Alice'');
insert into Students (student_id, student_name) values (''2'', ''Bob'');
insert into Students (student_id, student_name) values (''13'', ''John'');
insert into Students (student_id, student_name) values (''6'', ''Alex'');
Truncate table Subjects;
insert into Subjects (subject_name) values (''Math'');
insert into Subjects (subject_name) values (''Physics'');
insert into Subjects (subject_name) values (''Programming'');
Truncate table Examinations;
insert into Examinations (student_id, subject_name) values (''1'', ''Math'');
insert into Examinations (student_id, subject_name) values (''1'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''1'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''2'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''1'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''1'', ''Math'');
insert into Examinations (student_id, subject_name) values (''13'', ''Math'');
insert into Examinations (student_id, subject_name) values (''13'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''13'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''2'', ''Math'');
insert into Examinations (student_id, subject_name) values (''1'', ''Math'')', 'SELECT s.student_id, s.student_name, sub.subject_name, COUNT(e.subject_name) AS attended_exams
FROM Students s
CROSS JOIN Subjects sub
LEFT JOIN Examinations e ON s.student_id = e.student_id AND sub.subject_name = e.subject_name
GROUP BY s.student_id, s.student_name, sub.subject_name
ORDER BY s.student_id, sub.subject_name;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1023, '查询结果的质量和占比', 'Queries 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| query_name | varchar |
| result | varchar |
| position | int |
| rating | int |
+-------------+---------+
此表可能有重复的行。
此表包含了一些从数据库中收集的查询信息。
“位置”（position）列的值为 1 到 500 。
“评分”（rating）列的值为 1 到 5 。评分小于 3 的查询被定义为质量很差的查询。



将查询结果的质量 quality 定义为：

各查询结果的评分与其位置之间比率的平均值。

将劣质查询百分比 poor_query_percentage 定义为：

评分小于 3 的查询结果占全部查询结果的百分比。

编写解决方案，找出每次的 query_name 、 quality 和 poor_query_percentage。

quality 和 poor_query_percentage 都应 四舍五入到小数点后两位 。

以 任意顺序 返回结果表。

结果格式如下所示：



示例 1：

输入：
Queries table:
+------------+-------------------+----------+--------+
| query_name | result | position | rating |
+------------+-------------------+----------+--------+
| Dog | Golden Retriever | 1 | 5 |
| Dog | German Shepherd | 2 | 5 |
| Dog | Mule | 200 | 1 |
| Cat | Shirazi | 5 | 2 |
| Cat | Siamese | 3 | 3 |
| Cat | Sphynx | 7 | 4 |
+------------+-------------------+----------+--------+
输出：
+------------+---------+-----------------------+
| query_name | quality | poor_query_percentage |
+------------+---------+-----------------------+
| Dog | 2.50 | 33.33 |
| Cat | 0.66 | 33.33 |
+------------+---------+-----------------------+
解释：
Dog 查询结果的质量为 ((5 / 1) + (5 / 2) + (1 / 200)) / 3 = 2.50
Dog 查询结果的劣质查询百分比为 (1 / 3) * 100 = 33.33

Cat 查询结果的质量为 ((2 / 5) + (3 / 3) + (4 / 7)) / 3 = 0.66
Cat 查询结果的劣质查询百分比为 (1 / 3) * 100 = 33.33', 'EASY', '数据库', 'Create table If Not Exists Queries (query_name varchar(30), result varchar(50), position int, rating int);
Truncate table Queries;
insert into Queries (query_name, result, position, rating) values (''Dog'', ''Golden Retriever'', ''1'', ''5'');
insert into Queries (query_name, result, position, rating) values (''Dog'', ''German Shepherd'', ''2'', ''5'');
insert into Queries (query_name, result, position, rating) values (''Dog'', ''Mule'', ''200'', ''1'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Shirazi'', ''5'', ''2'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Siamese'', ''3'', ''3'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Sphynx'', ''7'', ''4'')', 'SELECT query_name,
  ROUND(AVG(rating / position), 2) AS quality,
  ROUND(SUM(rating < 3) / COUNT(*) * 100, 2) AS poor_query_percentage
FROM Queries
GROUP BY query_name;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1024, '使用唯一标识码替换员工ID', 'Employees 表：

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| name | varchar |
+---------------+---------+
在 SQL 中，id 是这张表的主键。
这张表的每一行分别代表了某公司其中一位员工的名字和 ID 。



EmployeeUNI 表：

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| unique_id | int |
+---------------+---------+
在 SQL 中，(id, unique_id) 是这张表的主键。
这张表的每一行包含了该公司某位员工的 ID 和他的唯一标识码（unique ID）。



展示每位用户的 唯一标识码（unique ID ）；如果某位员工没有唯一标识码，使用 null 填充即可。

你可以以 任意 顺序返回结果表。

返回结果的格式如下例所示。



示例 1：

输入：
Employees 表:
+----+----------+
| id | name |
+----+----------+
| 1 | Alice |
| 7 | Bob |
| 11 | Meir |
| 90 | Winston |
| 3 | Jonathan |
+----+----------+
EmployeeUNI 表:
+----+-----------+
| id | unique_id |
+----+-----------+
| 3 | 1 |
| 11 | 2 |
| 90 | 3 |
+----+-----------+
输出：
+-----------+----------+
| unique_id | name |
+-----------+----------+
| null | Alice |
| null | Bob |
| 2 | Meir |
| 3 | Winston |
| 1 | Jonathan |
+-----------+----------+
解释：
Alice and Bob 没有唯一标识码, 因此我们使用 null 替代。
Meir 的唯一标识码是 2 。
Winston 的唯一标识码是 3 。
Jonathan 唯一标识码是 1 。', 'EASY', '数据库', 'Create table If Not Exists Employees (id int, name varchar(20));
Create table If Not Exists EmployeeUNI (id int, unique_id int);
Truncate table Employees;
insert into Employees (id, name) values (''1'', ''Alice'');
insert into Employees (id, name) values (''7'', ''Bob'');
insert into Employees (id, name) values (''11'', ''Meir'');
insert into Employees (id, name) values (''90'', ''Winston'');
insert into Employees (id, name) values (''3'', ''Jonathan'');
Truncate table EmployeeUNI;
insert into EmployeeUNI (id, unique_id) values (''3'', ''1'');
insert into EmployeeUNI (id, unique_id) values (''11'', ''2'');
insert into EmployeeUNI (id, unique_id) values (''90'', ''3'')', 'SELECT eu.unique_id, e.name
FROM Employees e
LEFT JOIN EmployeeUNI eu ON e.id = eu.id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1025, '进店却未进行过交易的顾客', '表：Visits

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| visit_id | int |
| customer_id | int |
+-------------+---------+
visit_id 是该表中具有唯一值的列。
该表包含有关光临过购物中心的顾客的信息。



表：Transactions

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| transaction_id | int |
| visit_id | int |
| amount | int |
+----------------+---------+
transaction_id 是该表中具有唯一值的列。
此表包含 visit_id 期间进行的交易的信息。



有一些顾客可能光顾了购物中心但没有进行交易。请你编写一个解决方案，来查找这些顾客的 ID ，以及他们只光顾不交易的次数。

返回以 任何顺序 排序的结果表。

返回结果格式如下例所示。



示例 1：

输入:
Visits
+----------+-------------+
| visit_id | customer_id |
+----------+-------------+
| 1 | 23 |
| 2 | 9 |
| 4 | 30 |
| 5 | 54 |
| 6 | 96 |
| 7 | 54 |
| 8 | 54 |
+----------+-------------+
Transactions
+----------------+----------+--------+
| transaction_id | visit_id | amount |
+----------------+----------+--------+
| 2 | 5 | 310 |
| 3 | 5 | 300 |
| 9 | 5 | 200 |
| 12 | 1 | 910 |
| 13 | 2 | 970 |
+----------------+----------+--------+
输出:
+-------------+----------------+
| customer_id | count_no_trans |
+-------------+----------------+
| 54 | 2 |
| 30 | 1 |
| 96 | 1 |
+-------------+----------------+
解释:
ID = 23 的顾客曾经逛过一次购物中心，并在 ID = 12 的访问期间进行了一笔交易。
ID = 9 的顾客曾经逛过一次购物中心，并在 ID = 13 的访问期间进行了一笔交易。
ID = 30 的顾客曾经去过购物中心，并且没有进行任何交易。
ID = 54 的顾客三度造访了购物中心。在 2 次访问中，他们没有进行任何交易，在 1 次访问中，他们进行了 3 次交易。
ID = 96 的顾客曾经去过购物中心，并且没有进行任何交易。
如我们所见，ID 为 30 和 96 的顾客一次没有进行任何交易就去了购物中心。顾客 54 也两次访问了购物中心并且没有进行任何交易。', 'EASY', '数据库', 'Create table If Not Exists Visits(visit_id int, customer_id int);
Create table If Not Exists Transactions(transaction_id int, visit_id int, amount int);
Truncate table Visits;
insert into Visits (visit_id, customer_id) values (''1'', ''23'');
insert into Visits (visit_id, customer_id) values (''2'', ''9'');
insert into Visits (visit_id, customer_id) values (''4'', ''30'');
insert into Visits (visit_id, customer_id) values (''5'', ''54'');
insert into Visits (visit_id, customer_id) values (''6'', ''96'');
insert into Visits (visit_id, customer_id) values (''7'', ''54'');
insert into Visits (visit_id, customer_id) values (''8'', ''54'');
Truncate table Transactions;
insert into Transactions (transaction_id, visit_id, amount) values (''2'', ''5'', ''310'');
insert into Transactions (transaction_id, visit_id, amount) values (''3'', ''5'', ''300'');
insert into Transactions (transaction_id, visit_id, amount) values (''9'', ''5'', ''200'');
insert into Transactions (transaction_id, visit_id, amount) values (''12'', ''1'', ''910'');
insert into Transactions (transaction_id, visit_id, amount) values (''13'', ''2'', ''970'')', 'SELECT v.customer_id, COUNT(v.visit_id) AS count_no_trans
FROM Visits v
LEFT JOIN Transactions t ON v.visit_id = t.visit_id
WHERE t.transaction_id IS NULL
GROUP BY v.customer_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1026, '各赛事的用户注册率', '用户表： Users

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| user_id | int |
| user_name | varchar |
+-------------+---------+
user_id 是该表的主键(具有唯一值的列)。
该表中的每行包括用户 ID 和用户名。



注册表： Register

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| contest_id | int |
| user_id | int |
+-------------+---------+
(contest_id, user_id) 是该表的主键(具有唯一值的列的组合)。
该表中的每行包含用户的 ID 和他们注册的赛事。



编写解决方案统计出各赛事的用户注册百分率，保留两位小数。

返回的结果表按 percentage 的 降序 排序，若相同则按 contest_id 的 升序 排序。

返回结果如下示例所示。



示例 1：

输入：
Users 表：
+---------+-----------+
| user_id | user_name |
+---------+-----------+
| 6 | Alice |
| 2 | Bob |
| 7 | Alex |
+---------+-----------+

Register 表：
+------------+---------+
| contest_id | user_id |
+------------+---------+
| 215 | 6 |
| 209 | 2 |
| 208 | 2 |
| 210 | 6 |
| 208 | 6 |
| 209 | 7 |
| 209 | 6 |
| 215 | 7 |
| 208 | 7 |
| 210 | 2 |
| 207 | 2 |
| 210 | 7 |
+------------+---------+
输出：
+------------+------------+
| contest_id | percentage |
+------------+------------+
| 208 | 100.0 |
| 209 | 100.0 |
| 210 | 100.0 |
| 215 | 66.67 |
| 207 | 33.33 |
+------------+------------+
解释：
所有用户都注册了 208、209 和 210 赛事，因此这些赛事的注册率为 100% ，我们按 contest_id 的升序排序加入结果表中。
Alice 和 Alex 注册了 215 赛事，注册率为 ((2/3) * 100) = 66.67%
Bob 注册了 207 赛事，注册率为 ((1/3) * 100) = 33.33%', 'EASY', '数据库', 'Create table If Not Exists Users (user_id int, user_name varchar(20));
Create table If Not Exists Register (contest_id int, user_id int);
Truncate table Users;
insert into Users (user_id, user_name) values (''6'', ''Alice'');
insert into Users (user_id, user_name) values (''2'', ''Bob'');
insert into Users (user_id, user_name) values (''7'', ''Alex'');
Truncate table Register;
insert into Register (contest_id, user_id) values (''215'', ''6'');
insert into Register (contest_id, user_id) values (''209'', ''2'');
insert into Register (contest_id, user_id) values (''208'', ''2'');
insert into Register (contest_id, user_id) values (''210'', ''6'');
insert into Register (contest_id, user_id) values (''208'', ''6'');
insert into Register (contest_id, user_id) values (''209'', ''7'');
insert into Register (contest_id, user_id) values (''209'', ''6'');
insert into Register (contest_id, user_id) values (''215'', ''7'');
insert into Register (contest_id, user_id) values (''208'', ''7'');
insert into Register (contest_id, user_id) values (''210'', ''2'');
insert into Register (contest_id, user_id) values (''207'', ''2'');
insert into Register (contest_id, user_id) values (''210'', ''7'')', 'SELECT r.contest_id, ROUND(COUNT(r.user_id) / (SELECT COUNT(*) FROM Users) * 100, 2) AS percentage
FROM Register r
GROUP BY r.contest_id
ORDER BY percentage DESC, r.contest_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1027, '每台机器的进程平均运行时间', '表: Activity

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| machine_id | int |
| process_id | int |
| activity_type | enum |
| timestamp | float |
+----------------+---------+
该表展示了一家工厂网站的用户活动。
(machine_id, process_id, activity_type) 是当前表的主键（具有唯一值的列的组合）。
machine_id 是一台机器的ID号。
process_id 是运行在各机器上的进程ID号。
activity_type 是枚举类型 (''start'', ''end'')。
timestamp 是浮点类型,代表当前时间(以秒为单位)。
''start'' 代表该进程在这台机器上的开始运行时间戳 , ''end'' 代表该进程在这台机器上的终止运行时间戳。
同一台机器，同一个进程都有一对开始时间戳和结束时间戳，而且开始时间戳永远在结束时间戳前面。



现在有一个工厂网站有几台机器运行，每台机器上运行着 相同数量的进程 。编写解决方案，计算每台机器各自完成一个进程任务的平均耗时。

完成一个进程任务的时间指进程的''end'' 时间戳 减去 ''start'' 时间戳。平均耗时通过计算每台机器上所有进程任务的总耗费时间除以机器上的总进程数量获得。

结果表必须包含machine_id（机器ID） 和对应的 average time（平均耗时） 别名 processing_time，且四舍五入保留3位小数。

以 任意顺序 返回表。

具体参考例子如下。



示例 1:

输入：
Activity table:
+------------+------------+---------------+-----------+
| machine_id | process_id | activity_type | timestamp |
+------------+------------+---------------+-----------+
| 0 | 0 | start | 0.712 |
| 0 | 0 | end | 1.520 |
| 0 | 1 | start | 3.140 |
| 0 | 1 | end | 4.120 |
| 1 | 0 | start | 0.550 |
| 1 | 0 | end | 1.550 |
| 1 | 1 | start | 0.430 |
| 1 | 1 | end | 1.420 |
| 2 | 0 | start | 4.100 |
| 2 | 0 | end | 4.512 |
| 2 | 1 | start | 2.500 |
| 2 | 1 | end | 5.000 |
+------------+------------+---------------+-----------+
输出：
+------------+-----------------+
| machine_id | processing_time |
+------------+-----------------+
| 0 | 0.894 |
| 1 | 0.995 |
| 2 | 1.456 |
+------------+-----------------+
解释：
一共有3台机器,每台机器运行着两个进程.
机器 0 的平均耗时: ((1.520 - 0.712) + (4.120 - 3.140)) / 2 = 0.894
机器 1 的平均耗时: ((1.550 - 0.550) + (1.420 - 0.430)) / 2 = 0.995
机器 2 的平均耗时: ((4.512 - 4.100) + (5.000 - 2.500)) / 2 = 1.456', 'EASY', '数据库', 'Create table If Not Exists Activity (machine_id int, process_id int, activity_type ENUM(''start'', ''end''), timestamp float);
Truncate table Activity;
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''0'', ''start'', ''0.712'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''0'', ''end'', ''1.52'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''1'', ''start'', ''3.14'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''1'', ''end'', ''4.12'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''0'', ''start'', ''0.55'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''0'', ''end'', ''1.55'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''1'', ''start'', ''0.43'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''1'', ''end'', ''1.42'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''0'', ''start'', ''4.1'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''0'', ''end'', ''4.512'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''1'', ''start'', ''2.5'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''1'', ''end'', ''5'')', 'SELECT a1.machine_id, ROUND(AVG(a2.timestamp - a1.timestamp), 3) AS processing_time
FROM Activity a1
JOIN Activity a2 ON a1.machine_id = a2.machine_id AND a1.process_id = a2.process_id
  AND a1.activity_type = ''start'' AND a2.activity_type = ''end''
GROUP BY a1.machine_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1028, '查找拥有有效邮箱的用户', '表: Users

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| user_id | int |
| name | varchar |
| mail | varchar |
+---------------+---------+
user_id 是该表的主键（具有唯一值的列）。
该表包含了网站已注册用户的信息。有一些电子邮件是无效的。



编写一个解决方案，以查找具有有效电子邮件的用户。

一个有效的电子邮件具有前缀名称和域，其中：

 前缀 名称是一个字符串，可以包含字母（大写或小写），数字，下划线 ''_'' ，点 ''.'' 和（或）破折号 ''-'' 。前缀名称 必须 以字母开头。

 域 必须是小写的 ''@leetcode.com''。

以任何顺序返回结果表。

结果的格式如以下示例所示：



示例 1：

输入：
Users 表:
+---------+-----------+-------------------------+
| user_id | name | mail |
+---------+-----------+-------------------------+
| 1 | Winston | winston@leetcode.com |
| 2 | Jonathan | jonathanisgreat |
| 3 | Annabelle | bella-@leetcode.com |
| 4 | Sally | sally.come@leetcode.com |
| 5 | Marwan | quarz#2020@leetcode.com |
| 6 | David | david69@gmail.com |
| 7 | Shapiro | .shapo@leetcode.com |
+---------+-----------+-------------------------+
输出：
+---------+-----------+-------------------------+
| user_id | name | mail |
+---------+-----------+-------------------------+
| 1 | Winston | winston@leetcode.com |
| 3 | Annabelle | bella-@leetcode.com |
| 4 | Sally | sally.come@leetcode.com |
+---------+-----------+-------------------------+
解释：
用户 2 的电子邮件没有域。
用户 5 的电子邮件带有不允许的 ''#'' 符号。
用户 6 的电子邮件没有 leetcode 域。
用户 7 的电子邮件以点开头。', 'EASY', '数据库', 'Create table If Not Exists Users (user_id int, name varchar(30), mail varchar(50));
Truncate table Users;
insert into Users (user_id, name, mail) values (''1'', ''Winston'', ''winston@leetcode.com'');
insert into Users (user_id, name, mail) values (''2'', ''Jonathan'', ''jonathanisgreat'');
insert into Users (user_id, name, mail) values (''3'', ''Annabelle'', ''bella-@leetcode.com'');
insert into Users (user_id, name, mail) values (''4'', ''Sally'', ''sally.come@leetcode.com'');
insert into Users (user_id, name, mail) values (''5'', ''Marwan'', ''quarz#2020@leetcode.com'');
insert into Users (user_id, name, mail) values (''6'', ''David'', ''david69@gmail.com'');
insert into Users (user_id, name, mail) values (''7'', ''Shapiro'', ''.shapo@leetcode.com'')', 'SELECT user_id, name, mail
FROM Users
WHERE mail REGEXP ''^[A-Za-z][A-Za-z0-9_.-]*@leetcode[.]com$'';', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1029, '患某种疾病的患者', '患者信息表： Patients

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| patient_id | int |
| patient_name | varchar |
| conditions | varchar |
+--------------+---------+
在 SQL 中，patient_id （患者 ID）是该表的主键。
''conditions'' （疾病）包含 0 个或以上的疾病代码，以空格分隔。
这个表包含医院中患者的信息。



查询患有 I 类糖尿病的患者 ID （patient_id）、患者姓名（patient_name）以及其患有的所有疾病代码（conditions）。I 类糖尿病的代码总是包含前缀 DIAB1 。

按 任意顺序 返回结果表。

查询结果格式如下示例所示。



示例 1:

输入：
Patients表：
+------------+--------------+--------------+
| patient_id | patient_name | conditions |
+------------+--------------+--------------+
| 1 | Daniel | YFEV COUGH |
| 2 | Alice | |
| 3 | Bob | DIAB100 MYOP |
| 4 | George | ACNE DIAB100 |
| 5 | Alain | DIAB201 |
+------------+--------------+--------------+
输出：
+------------+--------------+--------------+
| patient_id | patient_name | conditions |
+------------+--------------+--------------+
| 3 | Bob | DIAB100 MYOP |
| 4 | George | ACNE DIAB100 |
+------------+--------------+--------------+
解释：Bob 和 George 都患有代码以 DIAB1 开头的疾病。', 'EASY', '数据库', 'Create table If Not Exists Patients (patient_id int, patient_name varchar(30), conditions varchar(100));
Truncate table Patients;
insert into Patients (patient_id, patient_name, conditions) values (''1'', ''Daniel'', ''YFEV COUGH'');
insert into Patients (patient_id, patient_name, conditions) values (''2'', ''Alice'', '''');
insert into Patients (patient_id, patient_name, conditions) values (''3'', ''Bob'', ''DIAB100 MYOP'');
insert into Patients (patient_id, patient_name, conditions) values (''4'', ''George'', ''ACNE DIAB100'');
insert into Patients (patient_id, patient_name, conditions) values (''5'', ''Alain'', ''DIAB201'')', 'SELECT patient_id, patient_name, conditions
FROM Patients
WHERE conditions LIKE ''DIAB1%'' OR conditions LIKE ''% DIAB1%'';', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1030, '员工的直属部门', '表：Employee

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| employee_id | int |
| department_id | int |
| primary_flag | varchar |
+---------------+---------+
这张表的主键为 employee_id, department_id (具有唯一值的列的组合)
employee_id 是员工的ID
department_id 是部门的ID，表示员工与该部门有关系
primary_flag 是一个枚举类型，值分别为(''Y'', ''N''). 如果值为''Y'',表示该部门是员工的直属部门。 如果值是''N'',则否



一个员工可以属于多个部门。当一个员工加入超过一个部门的时候，他需要决定哪个部门是他的直属部门。请注意，当员工只加入一个部门的时候，那这个部门将默认为他的直属部门，虽然表记录的值为''N''.

请编写解决方案，查出员工所属的直属部门。

返回结果 没有顺序要求 。

返回结果格式如下例子所示：



示例 1：

输入：
Employee table:
+-------------+---------------+--------------+
| employee_id | department_id | primary_flag |
+-------------+---------------+--------------+
| 1 | 1 | N |
| 2 | 1 | Y |
| 2 | 2 | N |
| 3 | 3 | N |
| 4 | 2 | N |
| 4 | 3 | Y |
| 4 | 4 | N |
+-------------+---------------+--------------+
输出：
+-------------+---------------+
| employee_id | department_id |
+-------------+---------------+
| 1 | 1 |
| 2 | 1 |
| 3 | 3 |
| 4 | 3 |
+-------------+---------------+
解释：
- 员工 1 的直属部门是 1
- 员工 2 的直属部门是 1
- 员工 3 的直属部门是 3
- 员工 4 的直属部门是 3', 'EASY', '数据库', 'Create table If Not Exists Employee (employee_id int, department_id int, primary_flag ENUM(''Y'',''N''));
Truncate table Employee;
insert into Employee (employee_id, department_id, primary_flag) values (''1'', ''1'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''2'', ''1'', ''Y'');
insert into Employee (employee_id, department_id, primary_flag) values (''2'', ''2'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''3'', ''3'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''2'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''3'', ''Y'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''4'', ''N'')', 'SELECT employee_id, department_id FROM Employee WHERE primary_flag = ''Y'' OR employee_id IN (SELECT employee_id FROM Employee GROUP BY employee_id HAVING COUNT(*) = 1);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1031, '每位经理的下属员工数量', '表：Employees

+-------------+----------+
| Column Name | Type |
+-------------+----------+
| employee_id | int |
| name | varchar |
| reports_to | int |
| age | int |
+-------------+----------+
employee_id 是这个表中具有不同值的列。
该表包含员工以及需要听取他们汇报的上级经理的 ID 的信息。 有些员工不需要向任何人汇报（reports_to 为空）。



对于此问题，我们将至少有一个其他员工需要向他汇报的员工，视为一个经理。

编写一个解决方案来返回需要听取汇报的所有经理的 ID、名称、直接向该经理汇报的员工人数，以及这些员工的平均年龄，其中该平均年龄需要四舍五入到最接近的整数。

返回的结果集需要按照 employee_id 进行排序。

结果的格式如下：



示例 1:

输入：
Employees 表：
+-------------+---------+------------+-----+
| employee_id | name | reports_to | age |
+-------------+---------+------------+-----+
| 9 | Hercy | null | 43 |
| 6 | Alice | 9 | 41 |
| 4 | Bob | 9 | 36 |
| 2 | Winston | null | 37 |
+-------------+---------+------------+-----+
输出：
+-------------+-------+---------------+-------------+
| employee_id | name | reports_count | average_age |
+-------------+-------+---------------+-------------+
| 9 | Hercy | 2 | 39 |
+-------------+-------+---------------+-------------+
解释：
Hercy 有两个需要向他汇报的员工, 他们是 Alice and Bob. 他们的平均年龄是 (41+36)/2 = 38.5, 四舍五入的结果是 39.

示例 2:

输入：
Employees 表：
+-------------+---------+------------+-----+
| employee_id | name | reports_to | age |
|-------------|---------|------------|-----|
| 1 | Michael | null | 45 |
| 2 | Alice | 1 | 38 |
| 3 | Bob | 1 | 42 |
| 4 | Charlie | 2 | 34 |
| 5 | David | 2 | 40 |
| 6 | Eve | 3 | 37 |
| 7 | Frank | null | 50 |
| 8 | Grace | null | 48 |
+-------------+---------+------------+-----+
输出：
+-------------+---------+---------------+-------------+
| employee_id | name | reports_count | average_age |
| ----------- | ------- | ------------- | ----------- |
| 1 | Michael | 2 | 40 |
| 2 | Alice | 2 | 37 |
| 3 | Bob | 1 | 37 |
+-------------+---------+---------------+-------------+', 'EASY', '数据库', 'Create table If Not Exists Employees(employee_id int, name varchar(20), reports_to int, age int);
Truncate table Employees;
insert into Employees (employee_id, name, reports_to, age) values (''9'', ''Hercy'', NULL, ''43'');
insert into Employees (employee_id, name, reports_to, age) values (''6'', ''Alice'', ''9'', ''41'');
insert into Employees (employee_id, name, reports_to, age) values (''4'', ''Bob'', ''9'', ''36'');
insert into Employees (employee_id, name, reports_to, age) values (''2'', ''Winston'', NULL, ''37'')', 'SELECT e1.employee_id, e1.name, COUNT(e2.employee_id) AS reports_count, ROUND(AVG(e2.age)) AS average_age
FROM Employees e1
JOIN Employees e2 ON e1.employee_id = e2.reports_to
GROUP BY e1.employee_id, e1.name
ORDER BY e1.employee_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1032, '合作过至少三次的演员和导演', 'ActorDirector 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| actor_id | int |
| director_id | int |
| timestamp | int |
+-------------+---------+
timestamp 是这张表的主键(具有唯一值的列).



编写解决方案找出合作过至少三次的演员和导演的 id 对 (actor_id, director_id)



示例 1：

输入：
ActorDirector 表：
+-------------+-------------+-------------+
| actor_id | director_id | timestamp |
+-------------+-------------+-------------+
| 1 | 1 | 0 |
| 1 | 1 | 1 |
| 1 | 1 | 2 |
| 1 | 2 | 3 |
| 1 | 2 | 4 |
| 2 | 1 | 5 |
| 2 | 1 | 6 |
+-------------+-------------+-------------+
输出：
+-------------+-------------+
| actor_id | director_id |
+-------------+-------------+
| 1 | 1 |
+-------------+-------------+
解释：
唯一的 id 对是 (1, 1)，他们恰好合作了 3 次。', 'EASY', '数据库', 'Create table If Not Exists ActorDirector (actor_id int, director_id int, timestamp int);
Truncate table ActorDirector;
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''0'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''1'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''2'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''2'', ''3'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''2'', ''4'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''2'', ''1'', ''5'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''2'', ''1'', ''6'')', 'SELECT actor_id, director_id
FROM ActorDirector
GROUP BY actor_id, director_id
HAVING COUNT(*) >= 3;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1033, '产品销售分析 I', '销售表 Sales：

+-------------+-------+
| Column Name | Type |
+-------------+-------+
| sale_id | int |
| product_id | int |
| year | int |
| quantity | int |
| price | int |
+-------------+-------+
(sale_id, year) 是销售表 Sales 的主键（具有唯一值的列的组合）。
product_id 是关联到产品表 Product 的外键（reference 列）。
该表的每一行显示 product_id 在某一年的销售情况。
注意: price 表示每单位价格。

产品表 Product：

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| product_id | int |
| product_name | varchar |
+--------------+---------+
product_id 是表的主键（具有唯一值的列）。
该表的每一行表示每种产品的产品名称。



编写解决方案，以获取 Sales 表中所有 sale_id 对应的 product_name 以及该产品的所有 year 和 price 。

返回结果表 无顺序要求 。

结果格式示例如下。



示例 1：

输入：
Sales 表：
+---------+------------+------+----------+-------+
| sale_id | product_id | year | quantity | price |
+---------+------------+------+----------+-------+
| 1 | 100 | 2008 | 10 | 5000 |
| 2 | 100 | 2009 | 12 | 5000 |
| 7 | 200 | 2011 | 15 | 9000 |
+---------+------------+------+----------+-------+
Product 表：
+------------+--------------+
| product_id | product_name |
+------------+--------------+
| 100 | Nokia |
| 200 | Apple |
| 300 | Samsung |
+------------+--------------+
输出：
+--------------+-------+-------+
| product_name | year | price |
+--------------+-------+-------+
| Nokia | 2008 | 5000 |
| Nokia | 2009 | 5000 |
| Apple | 2011 | 9000 |
+--------------+-------+-------+', 'EASY', '数据库', 'Create table If Not Exists Sales (sale_id int, product_id int, year int, quantity int, price int);
Create table If Not Exists Product (product_id int, product_name varchar(10));
Truncate table Sales;
insert into Sales (sale_id, product_id, year, quantity, price) values (''1'', ''100'', ''2008'', ''10'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''2'', ''100'', ''2009'', ''12'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''7'', ''200'', ''2011'', ''15'', ''9000'');
Truncate table Product;
insert into Product (product_id, product_name) values (''100'', ''Nokia'');
insert into Product (product_id, product_name) values (''200'', ''Apple'');
insert into Product (product_id, product_name) values (''300'', ''Samsung'')', 'SELECT p.product_name, s.year, s.price
FROM Sales s
JOIN Product p ON s.product_id = p.product_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1034, '超过 5 名学生的课', '表: Courses

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| student | varchar |
| class | varchar |
+-------------+---------+
(student, class)是该表的主键（不同值的列的组合）。
该表的每一行表示学生的名字和他们注册的课程。



查询 至少有 5 个学生 的所有课程。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1:

输入:
Courses 表:
+---------+----------+
| student | class |
+---------+----------+
| A | Math |
| B | English |
| C | Math |
| D | Biology |
| E | Math |
| F | Computer |
| G | Math |
| H | Math |
| I | Math |
+---------+----------+
输出:
+---------+
| class |
+---------+
| Math |
+---------+
解释:
-数学课有 6 个学生，所以我们包括它。
-英语课有 1 名学生，所以我们不包括它。
-生物课有 1 名学生，所以我们不包括它。
-计算机课有 1 个学生，所以我们不包括它。', 'EASY', '数据库', 'Create table If Not Exists Courses (student varchar(255), class varchar(255));
Truncate table Courses;
insert into Courses (student, class) values (''A'', ''Math'');
insert into Courses (student, class) values (''B'', ''English'');
insert into Courses (student, class) values (''C'', ''Math'');
insert into Courses (student, class) values (''D'', ''Biology'');
insert into Courses (student, class) values (''E'', ''Math'');
insert into Courses (student, class) values (''F'', ''Computer'');
insert into Courses (student, class) values (''G'', ''Math'');
insert into Courses (student, class) values (''H'', ''Math'');
insert into Courses (student, class) values (''I'', ''Math'')', 'SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(student) >= 5;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1035, '订单最多的客户', '表: Orders

+-----------------+----------+
| Column Name | Type |
+-----------------+----------+
| order_number | int |
| customer_number | int |
+-----------------+----------+
在 SQL 中，Order_number是该表的主键。
此表包含关于订单ID和客户ID的信息。



查找下了 最多订单 的客户的 customer_number 。

测试用例生成后， 恰好有一个客户 比任何其他客户下了更多的订单。

查询结果格式如下所示。



示例 1:

输入:
Orders 表:
+--------------+-----------------+
| order_number | customer_number |
+--------------+-----------------+
| 1 | 1 |
| 2 | 2 |
| 3 | 3 |
| 4 | 3 |
+--------------+-----------------+
输出:
+-----------------+
| customer_number |
+-----------------+
| 3 |
+-----------------+
解释:
customer_number 为 ''3'' 的顾客有两个订单，比顾客 ''1'' 或者 ''2'' 都要多，因为他们只有一个订单。
所以结果是该顾客的 customer_number ，也就是 3 。



进阶： 如果有多位顾客订单数并列最多，你能找到他们所有的 customer_number 吗？', 'EASY', '数据库', 'Create table If Not Exists orders (order_number int, customer_number int);
Truncate table orders;
insert into orders (order_number, customer_number) values (''1'', ''1'');
insert into orders (order_number, customer_number) values (''2'', ''2'');
insert into orders (order_number, customer_number) values (''3'', ''3'');
insert into orders (order_number, customer_number) values (''4'', ''3'')', 'SELECT customer_number FROM orders GROUP BY customer_number ORDER BY COUNT(*) DESC LIMIT 1;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1036, '只出现一次的最大数字', 'MyNumbers 表：

+-------------+------+
| Column Name | Type |
+-------------+------+
| num | int |
+-------------+------+
该表可能包含重复项（换句话说，在SQL中，该表没有主键）。
这张表的每一行都含有一个整数。



单一数字 是在 MyNumbers 表中只出现一次的数字。

找出最大的 单一数字 。如果不存在 单一数字 ，则返回 null 。

查询结果如下例所示。





示例 1：

输入：
MyNumbers 表：
+-----+
| num |
+-----+
| 8 |
| 8 |
| 3 |
| 3 |
| 1 |
| 4 |
| 5 |
| 6 |
+-----+
输出：
+-----+
| num |
+-----+
| 6 |
+-----+
解释：单一数字有 1、4、5 和 6 。
6 是最大的单一数字，返回 6 。

示例 2：

输入：
MyNumbers table:
+-----+
| num |
+-----+
| 8 |
| 8 |
| 7 |
| 7 |
| 3 |
| 3 |
| 3 |
+-----+
输出：
+------+
| num |
+------+
| null |
+------+
解释：输入的表中不存在单一数字，所以返回 null 。', 'EASY', '数据库', 'Create table If Not Exists MyNumbers (num int);
Truncate table MyNumbers;
insert into MyNumbers (num) values (''8'');
insert into MyNumbers (num) values (''8'');
insert into MyNumbers (num) values (''3'');
insert into MyNumbers (num) values (''3'');
insert into MyNumbers (num) values (''1'');
insert into MyNumbers (num) values (''4'');
insert into MyNumbers (num) values (''5'');
insert into MyNumbers (num) values (''6'')', 'SELECT MAX(num) AS num
FROM (
  SELECT num FROM MyNumbers GROUP BY num HAVING COUNT(*) = 1
) t;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1037, '查询近30天活跃用户数', '表：Activity

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| user_id | int |
| session_id | int |
| activity_date | date |
| activity_type | enum |
+---------------+---------+
该表可能包含重复数据。
activity_type 列是 ENUM(category) 类型， 从 (''open_session''， ''end_session''， ''scroll_down''， ''send_message'') 取值。
该表记录社交媒体网站的用户活动。
注意，每个会话只属于一个用户。



编写解决方案，统计截至 2019-07-27（包含2019-07-27），近 30 天的每日活跃用户数（当天只要有一条活动记录，即为活跃用户）。

以 任意顺序 返回结果表。

结果示例如下。

注意：（''open_session''，''end_session''，''scroll_down''，''send_message''）中的任何活动将被视为用户在某一天活跃的有效活动。



示例 1:

输入：
Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1 | 1 | 2019-07-20 | open_session |
| 1 | 1 | 2019-07-20 | scroll_down |
| 1 | 1 | 2019-07-20 | end_session |
| 2 | 4 | 2019-07-20 | open_session |
| 2 | 4 | 2019-07-21 | send_message |
| 2 | 4 | 2019-07-21 | end_session |
| 3 | 2 | 2019-07-21 | open_session |
| 3 | 2 | 2019-07-21 | send_message |
| 3 | 2 | 2019-07-21 | end_session |
| 4 | 3 | 2019-06-25 | open_session |
| 4 | 3 | 2019-06-25 | end_session |
+---------+------------+---------------+---------------+
输出：
+------------+--------------+
| day | active_users |
+------------+--------------+
| 2019-07-20 | 2 |
| 2019-07-21 | 2 |
+------------+--------------+
解释：注意非活跃用户的记录不需要展示。', 'EASY', '数据库', 'Create table If Not Exists Activity (user_id int, session_id int, activity_date date, activity_type ENUM(''open_session'', ''end_session'', ''scroll_down'', ''send_message''));
Truncate table Activity;
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''scroll_down'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-20'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-21'', ''send_message'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-21'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''send_message'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''4'', ''3'', ''2019-06-25'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''4'', ''3'', ''2019-06-25'', ''end_session'')', 'SELECT activity_date AS day, COUNT(DISTINCT user_id) AS active_users
FROM Activity
WHERE activity_date BETWEEN DATE_SUB(''2019-07-27'', INTERVAL 29 DAY) AND ''2019-07-27''
GROUP BY activity_date;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1038, '按日期分组销售产品', '表 Activities：

+-------------+---------+
| 列名 | 类型 |
+-------------+---------+
| sell_date | date |
| product | varchar |
+-------------+---------+
该表没有主键(具有唯一值的列)。它可能包含重复项。
此表的每一行都包含产品名称和在市场上销售的日期。



编写解决方案找出每个日期、销售的不同产品的数量及其名称。

每个日期的销售产品名称应按词典序排列。

返回按 sell_date 排序的结果表。

结果表结果格式如下例所示。



示例 1:

输入：
Activities 表：
+------------+-------------+
| sell_date | product |
+------------+-------------+
| 2020-05-30 | Headphone |
| 2020-06-01 | Pencil |
| 2020-06-02 | Mask |
| 2020-05-30 | Basketball |
| 2020-06-01 | Bible |
| 2020-06-02 | Mask |
| 2020-05-30 | T-Shirt |
+------------+-------------+
输出：
+------------+----------+------------------------------+
| sell_date | num_sold | products |
+------------+----------+------------------------------+
| 2020-05-30 | 3 | Basketball,Headphone,T-shirt |
| 2020-06-01 | 2 | Bible,Pencil |
| 2020-06-02 | 1 | Mask |
+------------+----------+------------------------------+
解释：
对于2020-05-30，出售的物品是 (Headphone, Basketball, T-shirt)，按词典序排列，并用逗号 '','' 分隔。
对于2020-06-01，出售的物品是 (Pencil, Bible)，按词典序排列，并用逗号分隔。
对于2020-06-02，出售的物品是 (Mask)，只需返回该物品名。', 'EASY', '数据库', 'Create table If Not Exists Activities (sell_date date, product varchar(20));
Truncate table Activities;
insert into Activities (sell_date, product) values (''2020-05-30'', ''Headphone'');
insert into Activities (sell_date, product) values (''2020-06-01'', ''Pencil'');
insert into Activities (sell_date, product) values (''2020-06-02'', ''Mask'');
insert into Activities (sell_date, product) values (''2020-05-30'', ''Basketball'');
insert into Activities (sell_date, product) values (''2020-06-01'', ''Bible'');
insert into Activities (sell_date, product) values (''2020-06-02'', ''Mask'');
insert into Activities (sell_date, product) values (''2020-05-30'', ''T-Shirt'')', 'SELECT sell_date, COUNT(DISTINCT product) AS num_sold,
  GROUP_CONCAT(DISTINCT product ORDER BY product SEPARATOR '','') AS products
FROM Activities
GROUP BY sell_date
ORDER BY sell_date;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1039, '排名靠前的旅行者', '表：Users

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| name | varchar |
+---------------+---------+
id 是该表中具有唯一值的列。
name 是用户名字。



表：Rides

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| user_id | int |
| distance | int |
+---------------+---------+
id 是该表中具有唯一值的列。
user_id 是本次行程的用户的 id, 而该用户此次行程距离为 distance 。



编写解决方案，报告每个用户的旅行距离。

返回的结果表单，以 travelled_distance 降序排列 ，如果有两个或者更多的用户旅行了相同的距离, 那么再以 name 升序排列 。

返回结果格式如下例所示。



示例 1：

输入：
Users 表：
+------+-----------+
| id | name |
+------+-----------+
| 1 | Alice |
| 2 | Bob |
| 3 | Alex |
| 4 | Donald |
| 7 | Lee |
| 13 | Jonathan |
| 19 | Elvis |
+------+-----------+

Rides 表：
+------+----------+----------+
| id | user_id | distance |
+------+----------+----------+
| 1 | 1 | 120 |
| 2 | 2 | 317 |
| 3 | 3 | 222 |
| 4 | 7 | 100 |
| 5 | 13 | 312 |
| 6 | 19 | 50 |
| 7 | 7 | 120 |
| 8 | 19 | 400 |
| 9 | 7 | 230 |
+------+----------+----------+
输出：
+----------+--------------------+
| name | travelled_distance |
+----------+--------------------+
| Elvis | 450 |
| Lee | 450 |
| Bob | 317 |
| Jonathan | 312 |
| Alex | 222 |
| Alice | 120 |
| Donald | 0 |
+----------+--------------------+
解释：
Elvis 和 Lee 旅行了 450 英里，Elvis 是排名靠前的旅行者，因为他的名字在字母表上的排序比 Lee 更小。
Bob, Jonathan, Alex 和 Alice 只有一次行程，我们只按此次行程的全部距离对他们排序。
Donald 没有任何行程, 他的旅行距离为 0。', 'EASY', '数据库', 'Create Table If Not Exists Users (id int, name varchar(30));
Create Table If Not Exists Rides (id int, user_id int, distance int);
Truncate table Users;
insert into Users (id, name) values (''1'', ''Alice'');
insert into Users (id, name) values (''2'', ''Bob'');
insert into Users (id, name) values (''3'', ''Alex'');
insert into Users (id, name) values (''4'', ''Donald'');
insert into Users (id, name) values (''7'', ''Lee'');
insert into Users (id, name) values (''13'', ''Jonathan'');
insert into Users (id, name) values (''19'', ''Elvis'');
Truncate table Rides;
insert into Rides (id, user_id, distance) values (''1'', ''1'', ''120'');
insert into Rides (id, user_id, distance) values (''2'', ''2'', ''317'');
insert into Rides (id, user_id, distance) values (''3'', ''3'', ''222'');
insert into Rides (id, user_id, distance) values (''4'', ''7'', ''100'');
insert into Rides (id, user_id, distance) values (''5'', ''13'', ''312'');
insert into Rides (id, user_id, distance) values (''6'', ''19'', ''50'');
insert into Rides (id, user_id, distance) values (''7'', ''7'', ''120'');
insert into Rides (id, user_id, distance) values (''8'', ''19'', ''400'');
insert into Rides (id, user_id, distance) values (''9'', ''7'', ''230'')', 'SELECT u.name, COALESCE(SUM(r.distance), 0) AS travelled_distance
FROM Users u
LEFT JOIN Rides r ON u.id = r.user_id
GROUP BY u.id, u.name
ORDER BY travelled_distance DESC, u.name;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1040, '2020年最后一次登录', '表: Logins

+----------------+----------+
| 列名 | 类型 |
+----------------+----------+
| user_id | int |
| time_stamp | datetime |
+----------------+----------+
(user_id, time_stamp) 是这个表的主键(具有唯一值的列的组合)。
每一行包含的信息是user_id 这个用户的登录时间。



编写解决方案以获取在 2020 年登录过的所有用户的本年度 最后一次 登录时间。结果集 不 包含 2020 年没有登录过的用户。

返回的结果集可以按 任意顺序 排列。

返回结果格式如下例。



示例 1:

输入：
Logins 表:
+---------+---------------------+
| user_id | time_stamp |
+---------+---------------------+
| 6 | 2020-06-30 15:06:07 |
| 6 | 2021-04-21 14:06:06 |
| 6 | 2019-03-07 00:18:15 |
| 8 | 2020-02-01 05:10:53 |
| 8 | 2020-12-30 00:46:50 |
| 2 | 2020-01-16 02:49:50 |
| 2 | 2019-08-25 07:59:08 |
| 14 | 2019-07-14 09:00:00 |
| 14 | 2021-01-06 11:59:59 |
+---------+---------------------+
输出：
+---------+---------------------+
| user_id | last_stamp |
+---------+---------------------+
| 6 | 2020-06-30 15:06:07 |
| 8 | 2020-12-30 00:46:50 |
| 2 | 2020-01-16 02:49:50 |
+---------+---------------------+
解释：
6号用户登录了3次，但是在2020年仅有一次，所以结果集应包含此次登录。
8号用户在2020年登录了2次，一次在2月，一次在12月，所以，结果集应该包含12月的这次登录。
2号用户登录了2次，但是在2020年仅有一次，所以结果集应包含此次登录。
14号用户在2020年没有登录，所以结果集不应包含。', 'EASY', '数据库', 'Create table If Not Exists Logins (user_id int, time_stamp datetime);
Truncate table Logins;
insert into Logins (user_id, time_stamp) values (''6'', ''2020-06-30 15:06:07'');
insert into Logins (user_id, time_stamp) values (''6'', ''2021-04-21 14:06:06'');
insert into Logins (user_id, time_stamp) values (''6'', ''2019-03-07 00:18:15'');
insert into Logins (user_id, time_stamp) values (''8'', ''2020-02-01 05:10:53'');
insert into Logins (user_id, time_stamp) values (''8'', ''2020-12-30 00:46:50'');
insert into Logins (user_id, time_stamp) values (''2'', ''2020-01-16 02:49:50'');
insert into Logins (user_id, time_stamp) values (''2'', ''2019-08-25 07:59:08'');
insert into Logins (user_id, time_stamp) values (''14'', ''2019-07-14 09:00:00'');
insert into Logins (user_id, time_stamp) values (''14'', ''2021-01-06 11:59:59'')', 'SELECT user_id, MAX(time_stamp) AS last_stamp
FROM Logins
WHERE YEAR(time_stamp) = 2020
GROUP BY user_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1041, '丢失信息的雇员', '表: Employees

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| employee_id | int |
| name | varchar |
+-------------+---------+
employee_id 是该表中具有唯一值的列。
每一行表示雇员的 id 和他的姓名。

表: Salaries

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| employee_id | int |
| salary | int |
+-------------+---------+
employee_id 是该表中具有唯一值的列。
每一行表示雇员的 id 和他的薪水。



编写解决方案，找到所有 丢失信息 的雇员 id。当满足下面一个条件时，就被认为是雇员的信息丢失：

 雇员的 姓名 丢失了，或者

 雇员的 薪水信息 丢失了

返回这些雇员的 id employee_id ， 从小到大排序 。

查询结果格式如下面的例子所示。



示例 1：

输入：
Employees table:
+-------------+----------+
| employee_id | name |
+-------------+----------+
| 2 | Crew |
| 4 | Haven |
| 5 | Kristian |
+-------------+----------+
Salaries table:
+-------------+--------+
| employee_id | salary |
+-------------+--------+
| 5 | 76071 |
| 1 | 22517 |
| 4 | 63539 |
+-------------+--------+
输出：
+-------------+
| employee_id |
+-------------+
| 1 |
| 2 |
+-------------+
解释：
雇员 1，2，4，5 都在这个公司工作。
1 号雇员的姓名丢失了。
2 号雇员的薪水信息丢失了。', 'EASY', '数据库', 'Create table If Not Exists Employees (employee_id int, name varchar(30));
Create table If Not Exists Salaries (employee_id int, salary int);
Truncate table Employees;
insert into Employees (employee_id, name) values (''2'', ''Crew'');
insert into Employees (employee_id, name) values (''4'', ''Haven'');
insert into Employees (employee_id, name) values (''5'', ''Kristian'');
Truncate table Salaries;
insert into Salaries (employee_id, salary) values (''5'', ''76071'');
insert into Salaries (employee_id, salary) values (''1'', ''22517'');
insert into Salaries (employee_id, salary) values (''4'', ''63539'')', 'SELECT e.employee_id
FROM Employees e
LEFT JOIN Salaries s ON e.employee_id = s.employee_id
WHERE s.salary IS NULL
UNION
SELECT s.employee_id
FROM Salaries s
LEFT JOIN Employees e ON s.employee_id = e.employee_id
WHERE e.name IS NULL
ORDER BY employee_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1042, '每位教师所教授的科目种类的数量', '表: Teacher

+-------------+------+
| Column Name | Type |
+-------------+------+
| teacher_id | int |
| subject_id | int |
| dept_id | int |
+-------------+------+
在 SQL 中，(subject_id, dept_id) 是该表的主键。
该表中的每一行都表示，该教师(teacher_id)在该系(dept_id)里教授的课程(subject_id)。



查询每位老师在大学里教授的科目种类的数量。

以 任意顺序 返回结果表。

查询结果格式示例如下。



示例 1:

输入:
Teacher 表:
+------------+------------+---------+
| teacher_id | subject_id | dept_id |
+------------+------------+---------+
| 1 | 2 | 3 |
| 1 | 2 | 4 |
| 1 | 3 | 3 |
| 2 | 1 | 1 |
| 2 | 2 | 1 |
| 2 | 3 | 1 |
| 2 | 4 | 1 |
+------------+------------+---------+
输出:
+------------+-----+
| teacher_id | cnt |
+------------+-----+
| 1 | 2 |
| 2 | 4 |
+------------+-----+
解释:
教师 1:
 - 他在 3、4 系教科目 2。
 - 他在 3 系教科目 3。
教师 2:
 - 他在 1 系教科目 1。
 - 他在 1 系教科目 2。
 - 他在 1 系教科目 3。
 - 他在 1 系教科目 4。', 'EASY', '数据库', 'Create table If Not Exists Teacher (teacher_id int, subject_id int, dept_id int);
Truncate table Teacher;
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''2'', ''3'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''2'', ''4'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''3'', ''3'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''1'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''2'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''3'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''4'', ''1'')', 'SELECT teacher_id, COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1043, '销售分析 III', '表： Product

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| product_id | int |
| product_name | varchar |
| unit_price | int |
+--------------+---------+
product_id 是该表的主键（具有唯一值的列）。
该表的每一行显示每个产品的名称和价格。

表：Sales

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| seller_id | int |
| product_id | int |
| buyer_id | int |
| sale_date | date |
| quantity | int |
| price | int |
+------ ------+---------+
这个表可能有重复的行。
product_id 是 Product 表的外键（reference 列）。
该表的每一行包含关于一个销售的一些信息。



编写解决方案，报告 2019年春季 才售出的产品。即 仅 在 2019-01-01 （含）至 2019-03-31 （含）之间出售的商品。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1:

输入：
Product table:
+------------+--------------+------------+
| product_id | product_name | unit_price |
+------------+--------------+------------+
| 1 | S8 | 1000 |
| 2 | G4 | 800 |
| 3 | iPhone | 1400 |
+------------+--------------+------------+
Sales table:
+-----------+------------+----------+------------+----------+-------+
| seller_id | product_id | buyer_id | sale_date | quantity | price |
+-----------+------------+----------+------------+----------+-------+
| 1 | 1 | 1 | 2019-01-21 | 2 | 2000 |
| 1 | 2 | 2 | 2019-02-17 | 1 | 800 |
| 2 | 2 | 3 | 2019-06-02 | 1 | 800 |
| 3 | 3 | 4 | 2019-05-13 | 2 | 2800 |
+-----------+------------+----------+------------+----------+-------+
输出：
+-------------+--------------+
| product_id | product_name |
+-------------+--------------+
| 1 | S8 |
+-------------+--------------+
解释:
id 为 1 的产品仅在 2019 年春季销售。
id 为 2 的产品在 2019 年春季销售，但也在 2019 年春季之后销售。
id 为 3 的产品在 2019 年春季之后销售。
我们只返回 id 为 1 的产品，因为它是 2019 年春季才销售的产品。', 'EASY', '数据库', 'Create table If Not Exists Product (product_id int, product_name varchar(10), unit_price int);
Create table If Not Exists Sales (seller_id int, product_id int, buyer_id int, sale_date date, quantity int, price int);
Truncate table Product;
insert into Product (product_id, product_name, unit_price) values (''1'', ''S8'', ''1000'');
insert into Product (product_id, product_name, unit_price) values (''2'', ''G4'', ''800'');
insert into Product (product_id, product_name, unit_price) values (''3'', ''iPhone'', ''1400'');
Truncate table Sales;
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''1'', ''1'', ''1'', ''2019-01-21'', ''2'', ''2000'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''1'', ''2'', ''2'', ''2019-02-17'', ''1'', ''800'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''2'', ''2'', ''3'', ''2019-06-02'', ''1'', ''800'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''3'', ''3'', ''4'', ''2019-05-13'', ''2'', ''2800'')', 'SELECT p.product_id, p.product_name
FROM Product p
JOIN Sales s ON p.product_id = s.product_id
GROUP BY p.product_id, p.product_name
HAVING MIN(s.sale_date) >= ''2019-01-01'' AND MAX(s.sale_date) <= ''2019-03-31'';', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1044, '列出指定时间段内所有的下单产品', '表: Products

+------------------+---------+
| Column Name | Type |
+------------------+---------+
| product_id | int |
| product_name | varchar |
| product_category | varchar |
+------------------+---------+
product_id 是该表主键(具有唯一值的列)。
该表包含该公司产品的数据。



表: Orders

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| product_id | int |
| order_date | date |
| unit | int |
+---------------+---------+
该表可能包含重复行。
product_id 是表单 Products 的外键（reference 列）。
unit 是在日期 order_date 内下单产品的数目。



写一个解决方案，要求获取在 2020 年 2 月份下单的数量不少于 100 的产品的名字和数目。

返回结果表单的 顺序无要求 。

查询结果的格式如下。



示例 1:

输入：
Products 表:
+-------------+-----------------------+------------------+
| product_id | product_name | product_category |
+-------------+-----------------------+------------------+
| 1 | Leetcode Solutions | Book |
| 2 | Jewels of Stringology | Book |
| 3 | HP | Laptop |
| 4 | Lenovo | Laptop |
| 5 | Leetcode Kit | T-shirt |
+-------------+-----------------------+------------------+
Orders 表:
+--------------+--------------+----------+
| product_id | order_date | unit |
+--------------+--------------+----------+
| 1 | 2020-02-05 | 60 |
| 1 | 2020-02-10 | 70 |
| 2 | 2020-01-18 | 30 |
| 2 | 2020-02-11 | 80 |
| 3 | 2020-02-17 | 2 |
| 3 | 2020-02-24 | 3 |
| 4 | 2020-03-01 | 20 |
| 4 | 2020-03-04 | 30 |
| 4 | 2020-03-04 | 60 |
| 5 | 2020-02-25 | 50 |
| 5 | 2020-02-27 | 50 |
| 5 | 2020-03-01 | 50 |
+--------------+--------------+----------+
输出：
+--------------------+---------+
| product_name | unit |
+--------------------+---------+
| Leetcode Solutions | 130 |
| Leetcode Kit | 100 |
+--------------------+---------+
解释：
2020 年 2 月份下单 product_id = 1 的产品的数目总和为 (60 + 70) = 130 。
2020 年 2 月份下单 product_id = 2 的产品的数目总和为 80 。
2020 年 2 月份下单 product_id = 3 的产品的数目总和为 (2 + 3) = 5 。
2020 年 2 月份 product_id = 4 的产品并没有下单。
2020 年 2 月份下单 product_id = 5 的产品的数目总和为 (50 + 50) = 100 。', 'EASY', '数据库', 'Create table If Not Exists Products (product_id int, product_name varchar(40), product_category varchar(40));
Create table If Not Exists Orders (product_id int, order_date date, unit int);
Truncate table Products;
insert into Products (product_id, product_name, product_category) values (''1'', ''Leetcode Solutions'', ''Book'');
insert into Products (product_id, product_name, product_category) values (''2'', ''Jewels of Stringology'', ''Book'');
insert into Products (product_id, product_name, product_category) values (''3'', ''HP'', ''Laptop'');
insert into Products (product_id, product_name, product_category) values (''4'', ''Lenovo'', ''Laptop'');
insert into Products (product_id, product_name, product_category) values (''5'', ''Leetcode Kit'', ''T-shirt'');
Truncate table Orders;
insert into Orders (product_id, order_date, unit) values (''1'', ''2020-02-05'', ''60'');
insert into Orders (product_id, order_date, unit) values (''1'', ''2020-02-10'', ''70'');
insert into Orders (product_id, order_date, unit) values (''2'', ''2020-01-18'', ''30'');
insert into Orders (product_id, order_date, unit) values (''2'', ''2020-02-11'', ''80'');
insert into Orders (product_id, order_date, unit) values (''3'', ''2020-02-17'', ''2'');
insert into Orders (product_id, order_date, unit) values (''3'', ''2020-02-24'', ''3'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-01'', ''20'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-04'', ''30'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-04'', ''60'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-02-25'', ''50'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-02-27'', ''50'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-03-01'', ''50'')', 'SELECT p.product_name, SUM(o.unit) AS unit
FROM Products p
JOIN Orders o ON p.product_id = o.product_id
WHERE o.order_date BETWEEN ''2020-02-01'' AND ''2020-02-29''
GROUP BY p.product_id, p.product_name
HAVING SUM(o.unit) >= 100;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1045, '计算特殊奖金', '表: Employees

+-------------+---------+
| 列名 | 类型 |
+-------------+---------+
| employee_id | int |
| name | varchar |
| salary | int |
+-------------+---------+
employee_id 是这个表的主键(具有唯一值的列)。
此表的每一行给出了雇员id ，名字和薪水。



编写解决方案，计算每个雇员的奖金。如果一个雇员的 id 是 奇数 并且他的名字不是以 ''M'' 开头，那么他的奖金是他工资的 100% ，否则奖金为 0 。

返回的结果按照 employee_id 排序。

返回结果格式如下面的例子所示。



示例 1:

输入：
Employees 表:
+-------------+---------+--------+
| employee_id | name | salary |
+-------------+---------+--------+
| 2 | Meir | 3000 |
| 3 | Michael | 3800 |
| 7 | Addilyn | 7400 |
| 8 | Juan | 6100 |
| 9 | Kannon | 7700 |
+-------------+---------+--------+
输出：
+-------------+-------+
| employee_id | bonus |
+-------------+-------+
| 2 | 0 |
| 3 | 0 |
| 7 | 7400 |
| 8 | 0 |
| 9 | 7700 |
+-------------+-------+
解释：
因为雇员id是偶数，所以雇员id 是2和8的两个雇员得到的奖金是0。
雇员id为3的因为他的名字以''M''开头，所以，奖金是0。
其他的雇员得到了百分之百的奖金。', 'EASY', '数据库', 'Create table If Not Exists Employees (employee_id int, name varchar(30), salary int);
Truncate table Employees;
insert into Employees (employee_id, name, salary) values (''2'', ''Meir'', ''3000'');
insert into Employees (employee_id, name, salary) values (''3'', ''Michael'', ''3800'');
insert into Employees (employee_id, name, salary) values (''7'', ''Addilyn'', ''7400'');
insert into Employees (employee_id, name, salary) values (''8'', ''Juan'', ''6100'');
insert into Employees (employee_id, name, salary) values (''9'', ''Kannon'', ''7700'')', 'SELECT employee_id,
  CASE WHEN employee_id % 2 = 1 AND name NOT LIKE ''M%'' THEN salary ELSE 0 END AS bonus
FROM Employees
ORDER BY employee_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1046, '每个产品在不同商店的价格', '表：Products

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| product_id | int |
| store1 | int |
| store2 | int |
| store3 | int |
+-------------+---------+
在 SQL 中，这张表的主键是 product_id（产品Id）。
每行存储了这一产品在不同商店 store1, store2, store3 的价格。
如果这一产品在商店里没有出售，则值将为 null。



请你重构 Products 表，查询每个产品在不同商店的价格，使得输出的格式变为(product_id, store, price) 。如果这一产品在商店里没有出售，则不输出这一行。

输出结果表中的 顺序不作要求 。

查询输出格式请参考下面示例。



示例 1：

输入：
Products table:
+------------+--------+--------+--------+
| product_id | store1 | store2 | store3 |
+------------+--------+--------+--------+
| 0 | 95 | 100 | 105 |
| 1 | 70 | null | 80 |
+------------+--------+--------+--------+
输出：
+------------+--------+-------+
| product_id | store | price |
+------------+--------+-------+
| 0 | store1 | 95 |
| 0 | store2 | 100 |
| 0 | store3 | 105 |
| 1 | store1 | 70 |
| 1 | store3 | 80 |
+------------+--------+-------+
解释：
产品 0 在 store1、store2、store3 的价格分别为 95、100、105。
产品 1 在 store1、store3 的价格分别为 70、80。在 store2 无法买到。', 'EASY', '数据库', 'Create table If Not Exists Products (product_id int, store1 int, store2 int, store3 int);
Truncate table Products;
insert into Products (product_id, store1, store2, store3) values (''0'', ''95'', ''100'', ''105'');
insert into Products (product_id, store1, store2, store3) values (''1'', ''70'', NULL, ''80'')', 'SELECT product_id, ''store1'' AS store, store1 AS price FROM Products WHERE store1 IS NOT NULL
UNION
SELECT product_id, ''store2'' AS store, store2 AS price FROM Products WHERE store2 IS NOT NULL
UNION
SELECT product_id, ''store3'' AS store, store3 AS price FROM Products WHERE store3 IS NOT NULL;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1047, '银行账户概要 II', '表: Users

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| account | int |
| name | varchar |
+--------------+---------+
account 是该表的主键(具有唯一值的列)。
该表的每一行都包含银行中每个用户的帐号。
表中不会有两个用户具有相同的名称。



表: Transactions

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| trans_id | int |
| account | int |
| amount | int |
| transacted_on | date |
+---------------+---------+
trans_id 是该表主键(具有唯一值的列)。
该表的每一行包含了所有账户的交易改变情况。
如果用户收到了钱, 那么金额是正的; 如果用户转了钱, 那么金额是负的。
所有账户的起始余额为 0。



编写解决方案, 报告余额高于 10000 的所有用户的名字和余额. 账户的余额等于包含该账户的所有交易的总和。

返回结果表单 无顺序要求 。

查询结果格式如下例所示。



示例 1：

输入：
Users table:
+------------+--------------+
| account | name |
+------------+--------------+
| 900001 | Alice |
| 900002 | Bob |
| 900003 | Charlie |
+------------+--------------+

Transactions table:
+------------+------------+------------+---------------+
| trans_id | account | amount | transacted_on |
+------------+------------+------------+---------------+
| 1 | 900001 | 7000 | 2020-08-01 |
| 2 | 900001 | 7000 | 2020-09-01 |
| 3 | 900001 | -3000 | 2020-09-02 |
| 4 | 900002 | 1000 | 2020-09-12 |
| 5 | 900003 | 6000 | 2020-08-07 |
| 6 | 900003 | 6000 | 2020-09-07 |
| 7 | 900003 | -4000 | 2020-09-11 |
+------------+------------+------------+---------------+
输出：
+------------+------------+
| name | balance |
+------------+------------+
| Alice | 11000 |
+------------+------------+
解释：
Alice 的余额为(7000 + 7000 - 3000) = 11000.
Bob 的余额为1000.
Charlie 的余额为(6000 + 6000 - 4000) = 8000.', 'EASY', '数据库', 'Create table If Not Exists Users (account int, name varchar(20));
Create table If Not Exists Transactions (trans_id int, account int, amount int, transacted_on date);
Truncate table Users;
insert into Users (account, name) values (''900001'', ''Alice'');
insert into Users (account, name) values (''900002'', ''Bob'');
insert into Users (account, name) values (''900003'', ''Charlie'');
Truncate table Transactions;
insert into Transactions (trans_id, account, amount, transacted_on) values (''1'', ''900001'', ''7000'', ''2020-08-01'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''2'', ''900001'', ''7000'', ''2020-09-01'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''3'', ''900001'', ''-3000'', ''2020-09-02'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''4'', ''900002'', ''1000'', ''2020-09-12'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''5'', ''900003'', ''6000'', ''2020-08-07'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''6'', ''900003'', ''6000'', ''2020-09-07'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''7'', ''900003'', ''-4000'', ''2020-09-11'')', 'SELECT u.name, SUM(t.amount) AS balance
FROM Users u
JOIN Transactions t ON u.account = t.account
GROUP BY u.account, u.name
HAVING SUM(t.amount) > 10000;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1048, '按分类统计薪水', '表: Accounts

+-------------+------+
| 列名 | 类型 |
+-------------+------+
| account_id | int |
| income | int |
+-------------+------+
在 SQL 中，account_id 是这个表的主键。
每一行都包含一个银行帐户的月收入的信息。



查询每个工资类别的银行账户数量。 工资类别如下：

 "Low Salary"：所有工资 严格低于 20000 美元。

 "Average Salary"： 包含 范围内的所有工资 [$20000, $50000] 。


 "High Salary"：所有工资 严格大于 50000 美元。



结果表 必须 包含所有三个类别。 如果某个类别中没有帐户，则报告 0 。

按 任意顺序 返回结果表。

查询结果格式如下示例。



示例 1：

输入：
Accounts 表:
+------------+--------+
| account_id | income |
+------------+--------+
| 3 | 108939 |
| 2 | 12747 |
| 8 | 87709 |
| 6 | 91796 |
+------------+--------+
输出：
+----------------+----------------+
| category | accounts_count |
+----------------+----------------+
| Low Salary | 1 |
| Average Salary | 0 |
| High Salary | 3 |
+----------------+----------------+
解释：
低薪: 有一个账户 2.
中等薪水: 没有.
高薪: 有三个账户，他们是 3, 6和 8.', 'MEDIUM', '数据库', 'Create table If Not Exists Accounts (account_id int, income int);
Truncate table Accounts;
insert into Accounts (account_id, income) values (''3'', ''108939'');
insert into Accounts (account_id, income) values (''2'', ''12747'');
insert into Accounts (account_id, income) values (''8'', ''87709'');
insert into Accounts (account_id, income) values (''6'', ''91796'')', 'SELECT ''Low Salary'' AS category, COUNT(*) AS accounts_count FROM Accounts WHERE income < 20000
UNION
SELECT ''Average Salary'', COUNT(*) FROM Accounts WHERE income BETWEEN 20000 AND 50000
UNION
SELECT ''High Salary'', COUNT(*) FROM Accounts WHERE income > 50000;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1049, '第二高的薪水', 'Employee 表：

+-------------+------+
| Column Name | Type |
+-------------+------+
| id | int |
| salary | int |
+-------------+------+
id 是这个表的主键。
表的每一行包含员工的工资信息。



查询并返回 Employee 表中第二高的 不同 薪水 。如果不存在第二高的薪水，查询应该返回 null(Pandas 则返回 None) 。

查询结果如下例所示。



示例 1：

输入：
Employee 表：
+----+--------+
| id | salary |
+----+--------+
| 1 | 100 |
| 2 | 200 |
| 3 | 300 |
+----+--------+
输出：
+---------------------+
| SecondHighestSalary |
+---------------------+
| 200 |
+---------------------+

示例 2：

输入：
Employee 表：
+----+--------+
| id | salary |
+----+--------+
| 1 | 100 |
+----+--------+
输出：
+---------------------+
| SecondHighestSalary |
+---------------------+
| null |
+---------------------+', 'MEDIUM', '数据库', 'Create table If Not Exists Employee (id int, salary int);
Truncate table Employee;
insert into Employee (id, salary) values (''1'', ''100'');
insert into Employee (id, salary) values (''2'', ''200'');
insert into Employee (id, salary) values (''3'', ''300'')', 'SELECT (
  SELECT DISTINCT salary FROM Employee ORDER BY salary DESC LIMIT 1 OFFSET 1
) AS SecondHighestSalary;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1050, '分数排名', '表: Scores

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| score | decimal |
+-------------+---------+
id 是该表的主键（有不同值的列）。
该表的每一行都包含了一场比赛的分数。Score 是一个有两位小数点的浮点值。



编写一个解决方案来查询分数的排名。排名按以下规则计算:

 分数应按从高到低排列。

 如果两个分数相等，那么两个分数的排名应该相同。

 在排名相同的分数后，排名数应该是下一个连续的整数。换句话说，排名之间不应该有空缺的数字。

按 score 降序返回结果表。

查询结果格式如下所示。



示例 1:

输入:
Scores 表:
+----+-------+
| id | score |
+----+-------+
| 1 | 3.50 |
| 2 | 3.65 |
| 3 | 4.00 |
| 4 | 3.85 |
| 5 | 4.00 |
| 6 | 3.65 |
+----+-------+
输出:
+-------+------+
| score | rank |
+-------+------+
| 4.00 | 1 |
| 4.00 | 1 |
| 3.85 | 2 |
| 3.65 | 3 |
| 3.65 | 3 |
| 3.50 | 4 |
+-------+------+', 'MEDIUM', '数据库', 'Create table If Not Exists Scores (id int, score DECIMAL(3,2));
Truncate table Scores;
insert into Scores (id, score) values (''1'', ''3.5'');
insert into Scores (id, score) values (''2'', ''3.65'');
insert into Scores (id, score) values (''3'', ''4.0'');
insert into Scores (id, score) values (''4'', ''3.85'');
insert into Scores (id, score) values (''5'', ''4.0'');
insert into Scores (id, score) values (''6'', ''3.65'')', 'SELECT score, DENSE_RANK() OVER (ORDER BY score DESC) AS `rank`
FROM Scores;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1051, '连续出现的数字', '表：Logs

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| num | varchar |
+-------------+---------+
在 SQL 中，id 是该表的主键。
id 是一个自增列。



找出所有至少连续出现三次的数字。

返回的结果表中的数据可以按 任意顺序 排列。

结果格式如下面的例子所示：



示例 1:

输入：
Logs 表：
+----+-----+
| id | num |
+----+-----+
| 1 | 1 |
| 2 | 1 |
| 3 | 1 |
| 4 | 2 |
| 5 | 1 |
| 6 | 2 |
| 7 | 2 |
+----+-----+
输出：
Result 表：
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1 |
+-----------------+
解释：1 是唯一连续出现至少三次的数字。', 'MEDIUM', '数据库', 'Create table If Not Exists Logs (id int, num int);
Truncate table Logs;
insert into Logs (id, num) values (''1'', ''1'');
insert into Logs (id, num) values (''2'', ''1'');
insert into Logs (id, num) values (''3'', ''1'');
insert into Logs (id, num) values (''4'', ''2'');
insert into Logs (id, num) values (''5'', ''1'');
insert into Logs (id, num) values (''6'', ''2'');
insert into Logs (id, num) values (''7'', ''2'')', 'SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2 ON l1.id = l2.id - 1 AND l1.num = l2.num
JOIN Logs l3 ON l2.id = l3.id - 1 AND l2.num = l3.num;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1052, '部门工资最高的员工', '表： Employee

+--------------+---------+
| 列名 | 类型 |
+--------------+---------+
| id | int |
| name | varchar |
| salary | int |
| departmentId | int |
+--------------+---------+
在 SQL 中，id是此表的主键。
departmentId 是 Department 表中 id 的外键（在 Pandas 中称为 join key）。
此表的每一行都表示员工的 id、姓名和工资。它还包含他们所在部门的 id。



表： Department

+-------------+---------+
| 列名 | 类型 |
+-------------+---------+
| id | int |
| name | varchar |
+-------------+---------+
在 SQL 中，id 是此表的主键列。
此表的每一行都表示一个部门的 id 及其名称。



查找出每个部门中薪资最高的员工。

按 任意顺序 返回结果表。

查询结果格式如下例所示。



示例 1:

输入：
Employee 表:
+----+-------+--------+--------------+
| id | name | salary | departmentId |
+----+-------+--------+--------------+
| 1 | Joe | 70000 | 1 |
| 2 | Jim | 90000 | 1 |
| 3 | Henry | 80000 | 2 |
| 4 | Sam | 60000 | 2 |
| 5 | Max | 90000 | 1 |
+----+-------+--------+--------------+
Department 表:
+----+-------+
| id | name |
+----+-------+
| 1 | IT |
| 2 | Sales |
+----+-------+
输出：
+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT | Jim | 90000 |
| Sales | Henry | 80000 |
| IT | Max | 90000 |
+------------+----------+--------+
解释：Max 和 Jim 在 IT 部门的工资都是最高的，Henry 在销售部的工资最高。', 'MEDIUM', '数据库', 'Create table If Not Exists Employee (id int, name varchar(255), salary int, departmentId int);
Create table If Not Exists Department (id int, name varchar(255));
Truncate table Employee;
insert into Employee (id, name, salary, departmentId) values (''1'', ''Joe'', ''70000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''2'', ''Jim'', ''90000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''3'', ''Henry'', ''80000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''4'', ''Sam'', ''60000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''5'', ''Max'', ''90000'', ''1'');
Truncate table Department;
insert into Department (id, name) values (''1'', ''IT'');
insert into Department (id, name) values (''2'', ''Sales'')', 'SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary
FROM Employee e
JOIN Department d ON e.departmentId = d.id
WHERE (e.departmentId, e.salary) IN (
  SELECT departmentId, MAX(salary) FROM Employee GROUP BY departmentId
);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1053, '至少有5名直接下属的经理', '表: Employee

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| name | varchar |
| department | varchar |
| managerId | int |
+-------------+---------+
id 是此表的主键（具有唯一值的列）。
该表的每一行表示雇员的名字、他们的部门和他们的经理的id。
如果managerId为空，则该员工没有经理。
没有员工会成为自己的管理者。



编写一个解决方案，找出至少有五个直接下属的经理。

以 任意顺序 返回结果表。

查询结果格式如下所示。



示例 1:

输入:
Employee 表:
+-----+-------+------------+-----------+
| id | name | department | managerId |
+-----+-------+------------+-----------+
| 101 | John | A | Null |
| 102 | Dan | A | 101 |
| 103 | James | A | 101 |
| 104 | Amy | A | 101 |
| 105 | Anne | A | 101 |
| 106 | Ron | B | 101 |
+-----+-------+------------+-----------+
输出:
+------+
| name |
+------+
| John |
+------+', 'MEDIUM', '数据库', 'Create table If Not Exists Employee (id int, name varchar(255), department varchar(255), managerId int);
Truncate table Employee;
insert into Employee (id, name, department, managerId) values (''101'', ''John'', ''A'', NULL);
insert into Employee (id, name, department, managerId) values (''102'', ''Dan'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''103'', ''James'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''104'', ''Amy'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''105'', ''Anne'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''106'', ''Ron'', ''B'', ''101'')', 'SELECT e1.name
FROM Employee e1
JOIN Employee e2 ON e1.id = e2.managerId
GROUP BY e1.id, e1.name
HAVING COUNT(*) >= 5;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1054, '树节点', '表：Tree

+-------------+------+
| Column Name | Type |
+-------------+------+
| id | int |
| p_id | int |
+-------------+------+
id 是该表中具有唯一值的列。
该表的每行包含树中节点的 id 及其父节点的 id 信息。
给定的结构总是一个有效的树。



树中的每个节点可以是以下三种类型之一：

 "Leaf"：节点是叶子节点。

 "Root"：节点是树的根节点。

 "Inner"：节点既不是叶子节点也不是根节点。

编写一个解决方案来报告树中每个节点的类型。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1：

输入：
Tree table:
+----+------+
| id | p_id |
+----+------+
| 1 | null |
| 2 | 1 |
| 3 | 1 |
| 4 | 2 |
| 5 | 2 |
+----+------+
输出：
+----+-------+
| id | type |
+----+-------+
| 1 | Root |
| 2 | Inner |
| 3 | Leaf |
| 4 | Leaf |
| 5 | Leaf |
+----+-------+
解释：
节点 1 是根节点，因为它的父节点为空，并且它有子节点 2 和 3。
节点 2 是一个内部节点，因为它有父节点 1 和子节点 4 和 5。
节点 3、4 和 5 是叶子节点，因为它们有父节点而没有子节点。

示例 2：

输入：
Tree table:
+----+------+
| id | p_id |
+----+------+
| 1 | null |
+----+------+
输出：
+----+-------+
| id | type |
+----+-------+
| 1 | Root |
+----+-------+
解释：如果树中只有一个节点，则只需要输出其根属性。



注意：本题与 3054. 二叉树节点 一致。', 'MEDIUM', '数据库', 'Create table If Not Exists Tree (id int, p_id int);
Truncate table Tree;
insert into Tree (id, p_id) values (''1'', NULL);
insert into Tree (id, p_id) values (''2'', ''1'');
insert into Tree (id, p_id) values (''3'', ''1'');
insert into Tree (id, p_id) values (''4'', ''2'');
insert into Tree (id, p_id) values (''5'', ''2'')', 'SELECT id,
  CASE
    WHEN p_id IS NULL THEN ''Root''
    WHEN id IN (SELECT p_id FROM Tree) THEN ''Inner''
    ELSE ''Leaf''
  END AS type
FROM Tree;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1055, '换座位', '表: Seat

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| student | varchar |
+-------------+---------+
id 是该表的主键（唯一值）列。
该表的每一行都表示学生的姓名和 ID。
ID 序列始终从 1 开始并连续增加。



编写解决方案来交换每两个连续的学生的座位号。如果学生的数量是奇数，则最后一个学生的id不交换。

按 id 升序 返回结果表。

查询结果格式如下所示。



示例 1:

输入:
Seat 表:
+----+---------+
| id | student |
+----+---------+
| 1 | Abbot |
| 2 | Doris |
| 3 | Emerson |
| 4 | Green |
| 5 | Jeames |
+----+---------+
输出:
+----+---------+
| id | student |
+----+---------+
| 1 | Doris |
| 2 | Abbot |
| 3 | Green |
| 4 | Emerson |
| 5 | Jeames |
+----+---------+
解释:
请注意，如果学生人数为奇数，则不需要更换最后一名学生的座位。', 'MEDIUM', '数据库', 'Create table If Not Exists Seat (id int, student varchar(255));
Truncate table Seat;
insert into Seat (id, student) values (''1'', ''Abbot'');
insert into Seat (id, student) values (''2'', ''Doris'');
insert into Seat (id, student) values (''3'', ''Emerson'');
insert into Seat (id, student) values (''4'', ''Green'');
insert into Seat (id, student) values (''5'', ''Jeames'')', 'SELECT
  CASE
    WHEN id % 2 = 1 AND id = (SELECT COUNT(*) FROM Seat) THEN id
    WHEN id % 2 = 1 THEN id + 1
    ELSE id - 1
  END AS id,
  student
FROM Seat
ORDER BY id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1056, '买下所有产品的客户', 'Customer 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| customer_id | int |
| product_key | int |
+-------------+---------+
该表可能包含重复的行。
customer_id 不为 NULL。
product_key 是 Product 表的外键(reference 列)。

Product 表：

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| product_key | int |
+-------------+---------+
product_key 是这张表的主键（具有唯一值的列）。



编写解决方案，报告 Customer 表中购买了 Product 表中所有产品的客户的 id。

返回结果表 无顺序要求 。

返回结果格式如下所示。



示例 1：

输入：
Customer 表：
+-------------+-------------+
| customer_id | product_key |
+-------------+-------------+
| 1 | 5 |
| 2 | 6 |
| 3 | 5 |
| 3 | 6 |
| 1 | 6 |
+-------------+-------------+
Product 表：
+-------------+
| product_key |
+-------------+
| 5 |
| 6 |
+-------------+
输出：
+-------------+
| customer_id |
+-------------+
| 1 |
| 3 |
+-------------+
解释：
购买了所有产品（5 和 6）的客户的 id 是 1 和 3 。', 'MEDIUM', '数据库', 'Create table If Not Exists Customer (customer_id int, product_key int);
Create table Product (product_key int);
Truncate table Customer;
insert into Customer (customer_id, product_key) values (''1'', ''5'');
insert into Customer (customer_id, product_key) values (''2'', ''6'');
insert into Customer (customer_id, product_key) values (''3'', ''5'');
insert into Customer (customer_id, product_key) values (''3'', ''6'');
insert into Customer (customer_id, product_key) values (''1'', ''6'');
Truncate table Product;
insert into Product (product_key) values (''5'');
insert into Product (product_key) values (''6'')', 'SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key) = (SELECT COUNT(*) FROM Product);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1057, '游戏玩法分析 IV', 'Table: Activity

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| player_id | int |
| device_id | int |
| event_date | date |
| games_played | int |
+--------------+---------+
（player_id，event_date）是此表的主键（具有唯一值的列的组合）。
这张表显示了某些游戏的玩家的活动情况。
每一行是一个玩家的记录，他在某一天使用某个设备注销之前登录并玩了很多游戏（可能是 0）。

编写解决方案，报告在首次登录的第二天再次登录的玩家的 比率，四舍五入到小数点后两位。换句话说，你需要计算从首次登录后的第二天登录的玩家数量，并将其除以总玩家数。

结果格式如下所示：



示例 1：

输入：
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1 | 2 | 2016-03-01 | 5 |
| 1 | 2 | 2016-03-02 | 6 |
| 2 | 3 | 2017-06-25 | 1 |
| 3 | 1 | 2016-03-02 | 0 |
| 3 | 4 | 2018-07-03 | 5 |
+-----------+-----------+------------+--------------+
输出：
+-----------+
| fraction |
+-----------+
| 0.33 |
+-----------+
解释：
只有 ID 为 1 的玩家在第一天登录后才重新登录，所以答案是 1/3 = 0.33', 'MEDIUM', '数据库', 'Create table If Not Exists Activity (player_id int, device_id int, event_date date, games_played int);
Truncate table Activity;
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-01'', ''5'');
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-02'', ''6'');
insert into Activity (player_id, device_id, event_date, games_played) values (''2'', ''3'', ''2017-06-25'', ''1'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''1'', ''2016-03-02'', ''0'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''4'', ''2018-07-03'', ''5'')', 'SELECT ROUND(COUNT(a2.player_id) / (SELECT COUNT(DISTINCT player_id) FROM Activity), 2) AS fraction
FROM Activity a1
JOIN Activity a2 ON a1.player_id = a2.player_id AND a2.event_date = DATE_ADD(a1.event_date, INTERVAL 1 DAY)
WHERE a1.event_date = (SELECT MIN(event_date) FROM Activity WHERE player_id = a1.player_id);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1058, '2016年的投资', 'Insurance 表：

+-------------+-------+
| Column Name | Type |
+-------------+-------+
| pid | int |
| tiv_2015 | float |
| tiv_2016 | float |
| lat | float |
| lon | float |
+-------------+-------+
pid 是这张表的主键(具有唯一值的列)。
表中的每一行都包含一条保险信息，其中：
pid 是投保人的投保编号。
tiv_2015 是该投保人在 2015 年的总投保金额，tiv_2016 是该投保人在 2016 年的总投保金额。
lat 是投保人所在城市的纬度。题目数据确保 lat 不为空。
lon 是投保人所在城市的经度。题目数据确保 lon 不为空。



编写解决方案报告 2016 年 (tiv_2016) 所有满足下述条件的投保人的投保金额之和：

 他在 2015 年的投保额 (tiv_2015) 至少跟一个其他投保人在 2015 年的投保额相同。

 他所在的城市必须与其他投保人都不同（也就是说 (lat, lon) 不能跟其他任何一个投保人完全相同）。

tiv_2016 四舍五入的 两位小数 。

查询结果格式如下例所示。



示例 1：

输入：
Insurance 表：
+-----+----------+----------+-----+-----+
| pid | tiv_2015 | tiv_2016 | lat | lon |
+-----+----------+----------+-----+-----+
| 1 | 10 | 5 | 10 | 10 |
| 2 | 20 | 20 | 20 | 20 |
| 3 | 10 | 30 | 20 | 20 |
| 4 | 10 | 40 | 40 | 40 |
+-----+----------+----------+-----+-----+
输出：
+----------+
| tiv_2016 |
+----------+
| 45.00 |
+----------+
解释：
表中的第一条记录和最后一条记录都满足两个条件。
tiv_2015 值为 10 与第三条和第四条记录相同，且其位置是唯一的。

第二条记录不符合任何一个条件。其 tiv_2015 与其他投保人不同，并且位置与第三条记录相同，这也导致了第三条记录不符合题目要求。
因此，结果是第一条记录和最后一条记录的 tiv_2016 之和，即 45 。', 'MEDIUM', '数据库', 'Create Table If Not Exists Insurance (pid int, tiv_2015 float, tiv_2016 float, lat float, lon float);
Truncate table Insurance;
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''1'', ''10'', ''5'', ''10'', ''10'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''2'', ''20'', ''20'', ''20'', ''20'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''3'', ''10'', ''30'', ''20'', ''20'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''4'', ''10'', ''40'', ''40'', ''40'')', 'SELECT ROUND(SUM(tiv_2016), 2) AS tiv_2016
FROM Insurance
WHERE tiv_2015 IN (SELECT tiv_2015 FROM Insurance GROUP BY tiv_2015 HAVING COUNT(*) > 1)
  AND (lat, lon) IN (SELECT lat, lon FROM Insurance GROUP BY lat, lon HAVING COUNT(*) = 1);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1059, '好友申请 II ：谁有最多的好友', 'RequestAccepted 表：

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| requester_id | int |
| accepter_id | int |
| accept_date | date |
+----------------+---------+
(requester_id, accepter_id) 是这张表的主键(具有唯一值的列的组合)。
这张表包含发送好友请求的人的 ID ，接收好友请求的人的 ID ，以及好友请求通过的日期。



编写解决方案，找出拥有最多的好友的人和他拥有的好友数目。

生成的测试用例保证拥有最多好友数目的只有 1 个人。

查询结果格式如下例所示。



示例 1：

输入：
RequestAccepted 表：
+--------------+-------------+-------------+
| requester_id | accepter_id | accept_date |
+--------------+-------------+-------------+
| 1 | 2 | 2016/06/03 |
| 1 | 3 | 2016/06/08 |
| 2 | 3 | 2016/06/08 |
| 3 | 4 | 2016/06/09 |
+--------------+-------------+-------------+
输出：
+----+-----+
| id | num |
+----+-----+
| 3 | 3 |
+----+-----+
解释：
编号为 3 的人是编号为 1 ，2 和 4 的人的好友，所以他总共有 3 个好友，比其他人都多。



进阶：在真实世界里，可能会有多个人拥有好友数相同且最多，你能找到所有这些人吗？', 'MEDIUM', '数据库', 'Create table If Not Exists RequestAccepted (requester_id int not null, accepter_id int null, accept_date date null);
Truncate table RequestAccepted;
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''1'', ''2'', ''2016/06/03'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''1'', ''3'', ''2016/06/08'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''2'', ''3'', ''2016/06/08'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''3'', ''4'', ''2016/06/09'')', 'SELECT id, COUNT(*) AS num
FROM (
  SELECT requester_id AS id FROM RequestAccepted
  UNION ALL
  SELECT accepter_id AS id FROM RequestAccepted
) t
GROUP BY id
ORDER BY num DESC
LIMIT 1;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1060, '市场分析 I', '表： Users

+----------------+---------+
| Column Name | Type |
+----------------+---------+
| user_id | int |
| join_date | date |
| favorite_brand | varchar |
+----------------+---------+
user_id 是此表主键（具有唯一值的列）。
表中描述了购物网站的用户信息，用户可以在此网站上进行商品买卖。



表： Orders

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| order_id | int |
| order_date | date |
| item_id | int |
| buyer_id | int |
| seller_id | int |
+---------------+---------+
order_id 是此表主键（具有唯一值的列）。
item_id 是 Items 表的外键（reference 列）。
（buyer_id，seller_id）是 User 表的外键。



表：Items

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| item_id | int |
| item_brand | varchar |
+---------------+---------+
item_id 是此表的主键（具有唯一值的列）。



编写解决方案找出每个用户的注册日期和在 2019 年作为买家的订单总数。

以 任意顺序 返回结果表。

查询结果格式如下。



示例 1:

输入：
Users 表:
+---------+------------+----------------+
| user_id | join_date | favorite_brand |
+---------+------------+----------------+
| 1 | 2018-01-01 | Lenovo |
| 2 | 2018-02-09 | Samsung |
| 3 | 2018-01-19 | LG |
| 4 | 2018-05-21 | HP |
+---------+------------+----------------+
Orders 表:
+----------+------------+---------+----------+-----------+
| order_id | order_date | item_id | buyer_id | seller_id |
+----------+------------+---------+----------+-----------+
| 1 | 2019-08-01 | 4 | 1 | 2 |
| 2 | 2018-08-02 | 2 | 1 | 3 |
| 3 | 2019-08-03 | 3 | 2 | 3 |
| 4 | 2018-08-04 | 1 | 4 | 2 |
| 5 | 2018-08-04 | 1 | 3 | 4 |
| 6 | 2019-08-05 | 2 | 2 | 4 |
+----------+------------+---------+----------+-----------+
Items 表:
+---------+------------+
| item_id | item_brand |
+---------+------------+
| 1 | Samsung |
| 2 | Lenovo |
| 3 | LG |
| 4 | HP |
+---------+------------+
输出：
+-----------+------------+----------------+
| buyer_id | join_date | orders_in_2019 |
+-----------+------------+----------------+
| 1 | 2018-01-01 | 1 |
| 2 | 2018-02-09 | 2 |
| 3 | 2018-01-19 | 0 |
| 4 | 2018-05-21 | 0 |
+-----------+------------+----------------+', 'MEDIUM', '数据库', 'Create table If Not Exists Users (user_id int, join_date date, favorite_brand varchar(10));
Create table If Not Exists Orders (order_id int, order_date date, item_id int, buyer_id int, seller_id int);
Create table If Not Exists Items (item_id int, item_brand varchar(10));
Truncate table Users;
insert into Users (user_id, join_date, favorite_brand) values (''1'', ''2018-01-01'', ''Lenovo'');
insert into Users (user_id, join_date, favorite_brand) values (''2'', ''2018-02-09'', ''Samsung'');
insert into Users (user_id, join_date, favorite_brand) values (''3'', ''2018-01-19'', ''LG'');
insert into Users (user_id, join_date, favorite_brand) values (''4'', ''2018-05-21'', ''HP'');
Truncate table Orders;
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''1'', ''2019-08-01'', ''4'', ''1'', ''2'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''2'', ''2018-08-02'', ''2'', ''1'', ''3'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''3'', ''2019-08-03'', ''3'', ''2'', ''3'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''4'', ''2018-08-04'', ''1'', ''4'', ''2'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''5'', ''2018-08-04'', ''1'', ''3'', ''4'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''6'', ''2019-08-05'', ''2'', ''2'', ''4'');
Truncate table Items;
insert into Items (item_id, item_brand) values (''1'', ''Samsung'');
insert into Items (item_id, item_brand) values (''2'', ''Lenovo'');
insert into Items (item_id, item_brand) values (''3'', ''LG'');
insert into Items (item_id, item_brand) values (''4'', ''HP'')', 'SELECT u.user_id AS buyer_id, u.join_date, COUNT(o.order_id) AS orders_in_2019
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.buyer_id AND YEAR(o.order_date) = 2019
GROUP BY u.user_id, u.join_date;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1061, '指定日期的产品价格', '产品数据表: Products

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| product_id | int |
| new_price | int |
| change_date | date |
+---------------+---------+
(product_id, change_date) 是此表的主键（具有唯一值的列组合）。
这张表的每一行分别记录了 某产品 在某个日期 更改后 的新价格。

一开始，所有产品价格都为 10。

编写一个解决方案，找出在 2019-08-16 所有产品的价格。

以 任意顺序 返回结果表。

结果格式如下例所示。



示例 1:

输入：
Products 表:
+------------+-----------+-------------+
| product_id | new_price | change_date |
+------------+-----------+-------------+
| 1 | 20 | 2019-08-14 |
| 2 | 50 | 2019-08-14 |
| 1 | 30 | 2019-08-15 |
| 1 | 35 | 2019-08-16 |
| 2 | 65 | 2019-08-17 |
| 3 | 20 | 2019-08-18 |
+------------+-----------+-------------+
输出：
+------------+-------+
| product_id | price |
+------------+-------+
| 2 | 50 |
| 1 | 35 |
| 3 | 10 |
+------------+-------+', 'MEDIUM', '数据库', 'Create table If Not Exists Products (product_id int, new_price int, change_date date);
Truncate table Products;
insert into Products (product_id, new_price, change_date) values (''1'', ''20'', ''2019-08-14'');
insert into Products (product_id, new_price, change_date) values (''2'', ''50'', ''2019-08-14'');
insert into Products (product_id, new_price, change_date) values (''1'', ''30'', ''2019-08-15'');
insert into Products (product_id, new_price, change_date) values (''1'', ''35'', ''2019-08-16'');
insert into Products (product_id, new_price, change_date) values (''2'', ''65'', ''2019-08-17'');
insert into Products (product_id, new_price, change_date) values (''3'', ''20'', ''2019-08-18'')', 'SELECT p.product_id, COALESCE(
  (SELECT new_price FROM Products WHERE product_id = p.product_id AND change_date <= ''2019-08-16'' ORDER BY change_date DESC LIMIT 1),
  10
) AS price
FROM (SELECT DISTINCT product_id FROM Products) p;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1062, '每月交易 I', '表：Transactions

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| country | varchar |
| state | enum |
| amount | int |
| trans_date | date |
+---------------+---------+
id 是这个表的主键。
该表包含有关传入事务的信息。
state 列类型为 ["approved", "declined"] 之一。



编写一个 sql 查询来查找每个月和每个国家/地区的事务数及其总金额、已批准的事务数及其总金额。

以 任意顺序 返回结果表。

查询结果格式如下所示。



示例 1:

输入：
Transactions table:
+------+---------+----------+--------+------------+
| id | country | state | amount | trans_date |
+------+---------+----------+--------+------------+
| 121 | US | approved | 1000 | 2018-12-18 |
| 122 | US | declined | 2000 | 2018-12-19 |
| 123 | US | approved | 2000 | 2019-01-01 |
| 124 | DE | approved | 2000 | 2019-01-07 |
+------+---------+----------+--------+------------+
输出：
+----------+---------+-------------+----------------+--------------------+-----------------------+
| month | country | trans_count | approved_count | trans_total_amount | approved_total_amount |
+----------+---------+-------------+----------------+--------------------+-----------------------+
| 2018-12 | US | 2 | 1 | 3000 | 1000 |
| 2019-01 | US | 1 | 1 | 2000 | 2000 |
| 2019-01 | DE | 1 | 1 | 2000 | 2000 |
+----------+---------+-------------+----------------+--------------------+-----------------------+', 'MEDIUM', '数据库', 'Create table If Not Exists Transactions (id int, country varchar(4), state enum(''approved'', ''declined''), amount int, trans_date date);
Truncate table Transactions;
insert into Transactions (id, country, state, amount, trans_date) values (''121'', ''US'', ''approved'', ''1000'', ''2018-12-18'');
insert into Transactions (id, country, state, amount, trans_date) values (''122'', ''US'', ''declined'', ''2000'', ''2018-12-19'');
insert into Transactions (id, country, state, amount, trans_date) values (''123'', ''US'', ''approved'', ''2000'', ''2019-01-01'');
insert into Transactions (id, country, state, amount, trans_date) values (''124'', ''DE'', ''approved'', ''2000'', ''2019-01-07'')', 'SELECT DATE_FORMAT(trans_date, ''%Y-%m'') AS month, country,
  COUNT(*) AS trans_count,
  SUM(state = ''approved'') AS approved_count,
  SUM(amount) AS trans_total_amount,
  SUM(IF(state = ''approved'', amount, 0)) AS approved_total_amount
FROM Transactions
GROUP BY month, country;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1063, '餐馆营业额变化增长', '表: Customer

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| customer_id | int |
| name | varchar |
| visited_on | date |
| amount | int |
+---------------+---------+
在 SQL 中，(customer_id, visited_on) 是该表的主键。
该表包含一家餐馆的顾客交易数据。
visited_on 表示 (customer_id) 的顾客在 visited_on 那天访问了餐馆。
amount 是一个顾客某一天的消费总额。



你是餐馆的老板，现在你想分析一下可能的营业额变化增长（每天至少有一位顾客）。

计算以 7 天（某日期 + 该日期前的 6 天）为一个时间段的顾客消费平均值。average_amount 要 保留两位小数。

结果按 visited_on 升序排序。

返回结果格式的例子如下。



示例 1:

输入：
Customer 表:
+-------------+--------------+--------------+-------------+
| customer_id | name | visited_on | amount |
+-------------+--------------+--------------+-------------+
| 1 | Jhon | 2019-01-01 | 100 |
| 2 | Daniel | 2019-01-02 | 110 |
| 3 | Jade | 2019-01-03 | 120 |
| 4 | Khaled | 2019-01-04 | 130 |
| 5 | Winston | 2019-01-05 | 110 |
| 6 | Elvis | 2019-01-06 | 140 |
| 7 | Anna | 2019-01-07 | 150 |
| 8 | Maria | 2019-01-08 | 80 |
| 9 | Jaze | 2019-01-09 | 110 |
| 1 | Jhon | 2019-01-10 | 130 |
| 3 | Jade | 2019-01-10 | 150 |
+-------------+--------------+--------------+-------------+
输出：
+--------------+--------------+----------------+
| visited_on | amount | average_amount |
+--------------+--------------+----------------+
| 2019-01-07 | 860 | 122.86 |
| 2019-01-08 | 840 | 120 |
| 2019-01-09 | 840 | 120 |
| 2019-01-10 | 1000 | 142.86 |
+--------------+--------------+----------------+
解释：
第一个七天消费平均值从 2019-01-01 到 2019-01-07 是restaurant-growth/restaurant-growth/ (100 + 110 + 120 + 130 + 110 + 140 + 150)/7 = 122.86
第二个七天消费平均值从 2019-01-02 到 2019-01-08 是 (110 + 120 + 130 + 110 + 140 + 150 + 80)/7 = 120
第三个七天消费平均值从 2019-01-03 到 2019-01-09 是 (120 + 130 + 110 + 140 + 150 + 80 + 110)/7 = 120
第四个七天消费平均值从 2019-01-04 到 2019-01-10 是 (130 + 110 + 140 + 150 + 80 + 110 + 130 + 150)/7 = 142.86', 'MEDIUM', '数据库', 'Create table If Not Exists Customer (customer_id int, name varchar(20), visited_on date, amount int);
Truncate table Customer;
insert into Customer (customer_id, name, visited_on, amount) values (''1'', ''Jhon'', ''2019-01-01'', ''100'');
insert into Customer (customer_id, name, visited_on, amount) values (''2'', ''Daniel'', ''2019-01-02'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''3'', ''Jade'', ''2019-01-03'', ''120'');
insert into Customer (customer_id, name, visited_on, amount) values (''4'', ''Khaled'', ''2019-01-04'', ''130'');
insert into Customer (customer_id, name, visited_on, amount) values (''5'', ''Winston'', ''2019-01-05'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''6'', ''Elvis'', ''2019-01-06'', ''140'');
insert into Customer (customer_id, name, visited_on, amount) values (''7'', ''Anna'', ''2019-01-07'', ''150'');
insert into Customer (customer_id, name, visited_on, amount) values (''8'', ''Maria'', ''2019-01-08'', ''80'');
insert into Customer (customer_id, name, visited_on, amount) values (''9'', ''Jaze'', ''2019-01-09'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''1'', ''Jhon'', ''2019-01-10'', ''130'');
insert into Customer (customer_id, name, visited_on, amount) values (''3'', ''Jade'', ''2019-01-10'', ''150'')', 'SELECT visited_on,
  (SELECT SUM(amount) FROM Customer WHERE visited_on BETWEEN DATE_SUB(c.visited_on, INTERVAL 6 DAY) AND c.visited_on) AS amount,
  ROUND((SELECT SUM(amount) FROM Customer WHERE visited_on BETWEEN DATE_SUB(c.visited_on, INTERVAL 6 DAY) AND c.visited_on) / 7, 2) AS average_amount
FROM Customer c
WHERE visited_on >= (SELECT DATE_ADD(MIN(visited_on), INTERVAL 6 DAY) FROM Customer)
GROUP BY visited_on
ORDER BY visited_on;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1064, '电影评分', '表：Movies

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| movie_id | int |
| title | varchar |
+---------------+---------+
movie_id 是这个表的主键(具有唯一值的列)。
title 是电影的名字。
每部电影都有一个唯一的 title。

表：Users

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| user_id | int |
| name | varchar |
+---------------+---------+
user_id 是表的主键(具有唯一值的列)。
''name'' 列具有唯一值。

表：MovieRating

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| movie_id | int |
| user_id | int |
| rating | int |
| created_at | date |
+---------------+---------+
(movie_id, user_id) 是这个表的主键(具有唯一值的列的组合)。
这个表包含用户在其评论中对电影的评分 rating 。
created_at 是用户的点评日期。



请你编写一个解决方案：

 查找评论电影数量最多的用户名。如果出现平局，返回字典序较小的用户名。

 查找在 February 2020 平均评分最高 的电影名称。如果出现平局，返回字典序较小的电影名称。

字典序 ，即按字母在字典中出现顺序对字符串排序，字典序较小则意味着排序靠前。

返回结果格式如下例所示。



示例 1：

输入：
Movies 表：
+-------------+--------------+
| movie_id | title |
+-------------+--------------+
| 1 | Avengers |
| 2 | Frozen 2 |
| 3 | Joker |
+-------------+--------------+
Users 表：
+-------------+--------------+
| user_id | name |
+-------------+--------------+
| 1 | Daniel |
| 2 | Monica |
| 3 | Maria |
| 4 | James |
+-------------+--------------+
MovieRating 表：
+-------------+--------------+--------------+-------------+
| movie_id | user_id | rating | created_at |
+-------------+--------------+--------------+-------------+
| 1 | 1 | 3 | 2020-01-12 |
| 1 | 2 | 4 | 2020-02-11 |
| 1 | 3 | 2 | 2020-02-12 |
| 1 | 4 | 1 | 2020-01-01 |
| 2 | 1 | 5 | 2020-02-17 |
| 2 | 2 | 2 | 2020-02-01 |
| 2 | 3 | 2 | 2020-03-01 |
| 3 | 1 | 3 | 2020-02-22 |
| 3 | 2 | 4 | 2020-02-25 |
+-------------+--------------+--------------+-------------+
输出：
Result 表：
+--------------+
| results |
+--------------+
| Daniel |
| Frozen 2 |
+--------------+
解释：
Daniel 和 Monica 都点评了 3 部电影（"Avengers", "Frozen 2" 和 "Joker"） 但是 Daniel 字典序比较小。
Frozen 2 和 Joker 在 2 月的评分都是 3.5，但是 Frozen 2 的字典序比较小。', 'MEDIUM', '数据库', 'Create table If Not Exists Movies (movie_id int, title varchar(30));
Create table If Not Exists Users (user_id int, name varchar(30));
Create table If Not Exists MovieRating (movie_id int, user_id int, rating int, created_at date);
Truncate table Movies;
insert into Movies (movie_id, title) values (''1'', ''Avengers'');
insert into Movies (movie_id, title) values (''2'', ''Frozen 2'');
insert into Movies (movie_id, title) values (''3'', ''Joker'');
Truncate table Users;
insert into Users (user_id, name) values (''1'', ''Daniel'');
insert into Users (user_id, name) values (''2'', ''Monica'');
insert into Users (user_id, name) values (''3'', ''Maria'');
insert into Users (user_id, name) values (''4'', ''James'');
Truncate table MovieRating;
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''1'', ''3'', ''2020-01-12'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''2'', ''4'', ''2020-02-11'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''3'', ''2'', ''2020-02-12'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''4'', ''1'', ''2020-01-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''1'', ''5'', ''2020-02-17'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''2'', ''2'', ''2020-02-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''3'', ''2'', ''2020-03-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''3'', ''1'', ''3'', ''2020-02-22'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''3'', ''2'', ''4'', ''2020-02-25'')', '(SELECT u.name AS results
 FROM MovieRating mr JOIN Users u ON mr.user_id = u.user_id
 GROUP BY mr.user_id, u.name
 ORDER BY COUNT(*) DESC, u.name LIMIT 1)
UNION ALL
(SELECT m.title AS results
 FROM MovieRating mr JOIN Movies m ON mr.movie_id = m.movie_id
 WHERE mr.created_at BETWEEN ''2020-02-01'' AND ''2020-02-29''
 GROUP BY mr.movie_id, m.title
 ORDER BY AVG(mr.rating) DESC, m.title LIMIT 1);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1065, '股票的资本损益', 'Stocks 表：

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| stock_name | varchar |
| operation | enum |
| operation_day | int |
| price | int |
+---------------+---------+
(stock_name, operation_day) 是这张表的主键(具有唯一值的列的组合)
operation 列使用的是一种枚举类型，包括：(''Sell'',''Buy'')
此表的每一行代表了名为 stock_name 的某支股票在 operation_day 这一天的操作价格。
此表可以保证，股票的每个“卖出”操作在前某一天都有相应的“买入”操作。并且，股票的每个“买入”操作在即将到来的某一天都有相应的“卖出”操作。



编写解决方案报告每只股票的 资本损益。

股票的 资本利得/损失 是指一次或多次买卖该股票后的总收益或损失。

以 任意顺序 返回结果表。

结果格式如下所示。



示例 1：

输入：
Stocks 表:
+---------------+-----------+---------------+--------+
| stock_name | operation | operation_day | price |
+---------------+-----------+---------------+--------+
| Leetcode | Buy | 1 | 1000 |
| Corona Masks | Buy | 2 | 10 |
| Leetcode | Sell | 5 | 9000 |
| Handbags | Buy | 17 | 30000 |
| Corona Masks | Sell | 3 | 1010 |
| Corona Masks | Buy | 4 | 1000 |
| Corona Masks | Sell | 5 | 500 |
| Corona Masks | Buy | 6 | 1000 |
| Handbags | Sell | 29 | 7000 |
| Corona Masks | Sell | 10 | 10000 |
+---------------+-----------+---------------+--------+
输出：
+---------------+-------------------+
| stock_name | capital_gain_loss |
+---------------+-------------------+
| Corona Masks | 9500 |
| Leetcode | 8000 |
| Handbags | -23000 |
+---------------+-------------------+
解释：
Leetcode 股票在第一天以1000美元的价格买入，在第五天以9000美元的价格卖出。资本收益=9000-1000=8000美元。
Handbags 股票在第17天以30000美元的价格买入，在第29天以7000美元的价格卖出。资本损失=7000-30000=-23000美元。
Corona Masks 股票在第1天以10美元的价格买入，在第3天以1010美元的价格卖出。在第4天以1000美元的价格再次购买，在第5天以500美元的价格出售。最后，它在第6天以1000美元的价格被买走，在第10天以10000美元的价格被卖掉。资本损益是每次（’Buy''->''Sell''）操作资本收益或损失的和=（1010-10）+（500-1000）+（10000-1000）=1000-500+9000=9500美元。', 'MEDIUM', '数据库', 'Create Table If Not Exists Stocks (stock_name varchar(15), operation ENUM(''Sell'', ''Buy''), operation_day int, price int);
Truncate table Stocks;
insert into Stocks (stock_name, operation, operation_day, price) values (''Leetcode'', ''Buy'', ''1'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''2'', ''10'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Leetcode'', ''Sell'', ''5'', ''9000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Handbags'', ''Buy'', ''17'', ''30000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''3'', ''1010'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''4'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''5'', ''500'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''6'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Handbags'', ''Sell'', ''29'', ''7000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''10'', ''10000'')', 'SELECT stock_name, SUM(CASE WHEN operation = ''Sell'' THEN price ELSE -price END) AS capital_gain_loss
FROM Stocks
GROUP BY stock_name;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1066, '确认率', '表: Signups

+----------------+----------+
| Column Name | Type |
+----------------+----------+
| user_id | int |
| time_stamp | datetime |
+----------------+----------+
User_id是该表的主键。
每一行都包含ID为user_id的用户的注册时间信息。



表: Confirmations

+----------------+----------+
| Column Name | Type |
+----------------+----------+
| user_id | int |
| time_stamp | datetime |
| action | ENUM |
+----------------+----------+
(user_id, time_stamp)是该表的主键。
user_id是一个引用到注册表的外键。
action是类型为(''confirmed''， ''timeout'')的ENUM
该表的每一行都表示ID为user_id的用户在time_stamp请求了一条确认消息，该确认消息要么被确认(''confirmed'')，要么被过期(''timeout'')。



用户的 确认率 是 ''confirmed'' 消息的数量除以请求的确认消息的总数。没有请求任何确认消息的用户的确认率为 0 。确认率四舍五入到 小数点后两位 。

编写一个SQL查询来查找每个用户的 确认率 。

以 任意顺序 返回结果表。

查询结果格式如下所示。

示例1:

输入：
Signups 表:
+---------+---------------------+
| user_id | time_stamp |
+---------+---------------------+
| 3 | 2020-03-21 10:16:13 |
| 7 | 2020-01-04 13:57:59 |
| 2 | 2020-07-29 23:09:44 |
| 6 | 2020-12-09 10:39:37 |
+---------+---------------------+
Confirmations 表:
+---------+---------------------+-----------+
| user_id | time_stamp | action |
+---------+---------------------+-----------+
| 3 | 2021-01-06 03:30:46 | timeout |
| 3 | 2021-07-14 14:00:00 | timeout |
| 7 | 2021-06-12 11:57:29 | confirmed |
| 7 | 2021-06-13 12:58:28 | confirmed |
| 7 | 2021-06-14 13:59:27 | confirmed |
| 2 | 2021-01-22 00:00:00 | confirmed |
| 2 | 2021-02-28 23:59:59 | timeout |
+---------+---------------------+-----------+
输出:
+---------+-------------------+
| user_id | confirmation_rate |
+---------+-------------------+
| 6 | 0.00 |
| 3 | 0.00 |
| 7 | 1.00 |
| 2 | 0.50 |
+---------+-------------------+
解释:
用户 6 没有请求任何确认消息。确认率为 0。
用户 3 进行了 2 次请求，都超时了。确认率为 0。
用户 7 提出了 3 个请求，所有请求都得到了确认。确认率为 1。
用户 2 做了 2 个请求，其中一个被确认，另一个超时。确认率为 1 / 2 = 0.5。', 'MEDIUM', '数据库', 'Create table If Not Exists Signups (user_id int, time_stamp datetime);
Create table If Not Exists Confirmations (user_id int, time_stamp datetime, action ENUM(''confirmed'',''timeout''));
Truncate table Signups;
insert into Signups (user_id, time_stamp) values (''3'', ''2020-03-21 10:16:13'');
insert into Signups (user_id, time_stamp) values (''7'', ''2020-01-04 13:57:59'');
insert into Signups (user_id, time_stamp) values (''2'', ''2020-07-29 23:09:44'');
insert into Signups (user_id, time_stamp) values (''6'', ''2020-12-09 10:39:37'');
Truncate table Confirmations;
insert into Confirmations (user_id, time_stamp, action) values (''3'', ''2021-01-06 03:30:46'', ''timeout'');
insert into Confirmations (user_id, time_stamp, action) values (''3'', ''2021-07-14 14:00:00'', ''timeout'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-12 11:57:29'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-13 12:58:28'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-14 13:59:27'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''2'', ''2021-01-22 00:00:00'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''2'', ''2021-02-28 23:59:59'', ''timeout'')', 'SELECT s.user_id,
  ROUND(COALESCE(SUM(c.action = ''confirmed'') / COUNT(c.action), 0), 2) AS confirmation_rate
FROM Signups s
LEFT JOIN Confirmations c ON s.user_id = c.user_id
GROUP BY s.user_id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1067, '产品销售分析 III', '销售表 Sales：

+-------------+-------+
| Column Name | Type |
+-------------+-------+
| sale_id | int |
| product_id | int |
| year | int |
| quantity | int |
| price | int |
+-------------+-------+
(sale_id, year) 是这张表的主键（具有唯一值的列的组合）。
这张表的每一行都表示：编号 product_id 的产品在某一年的销售额。
一个产品可能在同一年内有多个销售条目。
请注意，价格是按每单位计的。

编写解决方案，选出每个售出过的产品 第一年 销售的 产品 id、年份、数量 和 价格。

 对每个 product_id，找到其在Sales表中首次出现的最早年份。

 返回该产品在该年度的 所有 销售条目。

返回一张有这些列的表：product_id，first_year，quantity 和 price。

结果表中的条目可以按 任意顺序 排列。



示例 1：

输入：
Sales 表：
+---------+------------+------+----------+-------+
| sale_id | product_id | year | quantity | price |
+---------+------------+------+----------+-------+
| 1 | 100 | 2008 | 10 | 5000 |
| 2 | 100 | 2009 | 12 | 5000 |
| 7 | 200 | 2011 | 15 | 9000 |
+---------+------------+------+----------+-------+
输出：
+------------+------------+----------+-------+
| product_id | first_year | quantity | price |
+------------+------------+----------+-------+
| 100 | 2008 | 10 | 5000 |
| 200 | 2011 | 15 | 9000 |
+------------+------------+----------+-------+', 'MEDIUM', '数据库', 'Create table If Not Exists Sales (sale_id int, product_id int, year int, quantity int, price int);
Truncate table Sales;
insert into Sales (sale_id, product_id, year, quantity, price) values (''1'', ''100'', ''2008'', ''10'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''2'', ''100'', ''2009'', ''12'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''7'', ''200'', ''2011'', ''15'', ''9000'')', 'SELECT product_id, year AS first_year, quantity, price
FROM Sales
WHERE (product_id, year) IN (SELECT product_id, MIN(year) FROM Sales GROUP BY product_id);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1068, '重新格式化部门表', '表 Department：

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| revenue | int |
| month | varchar |
+---------------+---------+
在 SQL 中，(id, month) 是表的联合主键。
这个表格有关于每个部门每月收入的信息。
月份（month）可以取下列值 ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]。



重新格式化表格，使得 每个月 都有一个部门 id 列和一个收入列。

以 任意顺序 返回结果表。

结果格式如以下示例所示。



示例 1：

输入：
Department table:
+------+---------+-------+
| id | revenue | month |
+------+---------+-------+
| 1 | 8000 | Jan |
| 2 | 9000 | Jan |
| 3 | 10000 | Feb |
| 1 | 7000 | Feb |
| 1 | 6000 | Mar |
+------+---------+-------+
输出：
+------+-------------+-------------+-------------+-----+-------------+
| id | Jan_Revenue | Feb_Revenue | Mar_Revenue | ... | Dec_Revenue |
+------+-------------+-------------+-------------+-----+-------------+
| 1 | 8000 | 7000 | 6000 | ... | null |
| 2 | 9000 | null | null | ... | null |
| 3 | null | 10000 | null | ... | null |
+------+-------------+-------------+-------------+-----+-------------+
解释：四月到十二月的收入为空。
请注意，结果表共有 13 列（1 列用于部门 ID，其余 12 列用于各个月份）。', 'EASY', '数据库', 'Create table If Not Exists Department (id int, revenue int, month varchar(5));
Truncate table Department;
insert into Department (id, revenue, month) values (''1'', ''8000'', ''Jan'');
insert into Department (id, revenue, month) values (''2'', ''9000'', ''Jan'');
insert into Department (id, revenue, month) values (''3'', ''10000'', ''Feb'');
insert into Department (id, revenue, month) values (''1'', ''7000'', ''Feb'');
insert into Department (id, revenue, month) values (''1'', ''6000'', ''Mar'')', 'SELECT id,
  SUM(IF(month = ''Jan'', revenue, NULL)) AS Jan_Revenue,
  SUM(IF(month = ''Feb'', revenue, NULL)) AS Feb_Revenue,
  SUM(IF(month = ''Mar'', revenue, NULL)) AS Mar_Revenue,
  SUM(IF(month = ''Apr'', revenue, NULL)) AS Apr_Revenue,
  SUM(IF(month = ''May'', revenue, NULL)) AS May_Revenue,
  SUM(IF(month = ''Jun'', revenue, NULL)) AS Jun_Revenue,
  SUM(IF(month = ''Jul'', revenue, NULL)) AS Jul_Revenue,
  SUM(IF(month = ''Aug'', revenue, NULL)) AS Aug_Revenue,
  SUM(IF(month = ''Sep'', revenue, NULL)) AS Sep_Revenue,
  SUM(IF(month = ''Oct'', revenue, NULL)) AS Oct_Revenue,
  SUM(IF(month = ''Nov'', revenue, NULL)) AS Nov_Revenue,
  SUM(IF(month = ''Dec'', revenue, NULL)) AS Dec_Revenue
FROM Department
GROUP BY id;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1069, '最后一个能进入巴士的人', '表: Queue

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| person_id | int |
| person_name | varchar |
| weight | int |
| turn | int |
+-------------+---------+
person_id 是这个表具有唯一值的列。
该表展示了所有候车乘客的信息。
表中 person_id 和 turn 列将包含从 1 到 n 的所有数字，其中 n 是表中的行数。
turn 决定了候车乘客上巴士的顺序，其中 turn=1 表示第一个上巴士，turn=n 表示最后一个上巴士。
weight 表示候车乘客的体重，以千克为单位。



有一队乘客在等着上巴士。然而，巴士有1000 千克 的重量限制，所以其中一部分乘客可能无法上巴士。

编写解决方案找出 最后一个 上巴士且不超过重量限制的乘客，并报告 person_name 。题目测试用例确保顺位第一的人可以上巴士且不会超重。

返回结果格式如下所示。



示例 1：

输入：
Queue 表
+-----------+-------------+--------+------+
| person_id | person_name | weight | turn |
+-----------+-------------+--------+------+
| 5 | Alice | 250 | 1 |
| 4 | Bob | 175 | 5 |
| 3 | Alex | 350 | 2 |
| 6 | John Cena | 400 | 3 |
| 1 | Winston | 500 | 6 |
| 2 | Marie | 200 | 4 |
+-----------+-------------+--------+------+
输出：
+-------------+
| person_name |
+-------------+
| John Cena |
+-------------+
解释：
为了简化，Queue 表按 turn 列由小到大排序。
+------+----+-----------+--------+--------------+
| Turn | ID | Name | Weight | Total Weight |
+------+----+-----------+--------+--------------+
| 1 | 5 | Alice | 250 | 250 |
| 2 | 3 | Alex | 350 | 600 |
| 3 | 6 | John Cena | 400 | 1000 | (最后一个上巴士)
| 4 | 2 | Marie | 200 | 1200 | (无法上巴士)
| 5 | 4 | Bob | 175 | ___ |
| 6 | 1 | Winston | 500 | ___ |
+------+----+-----------+--------+--------------+', 'MEDIUM', '数据库', 'Create table If Not Exists Queue (person_id int, person_name varchar(30), weight int, turn int);
Truncate table Queue;
insert into Queue (person_id, person_name, weight, turn) values (''5'', ''Alice'', ''250'', ''1'');
insert into Queue (person_id, person_name, weight, turn) values (''4'', ''Bob'', ''175'', ''5'');
insert into Queue (person_id, person_name, weight, turn) values (''3'', ''Alex'', ''350'', ''2'');
insert into Queue (person_id, person_name, weight, turn) values (''6'', ''John Cena'', ''400'', ''3'');
insert into Queue (person_id, person_name, weight, turn) values (''1'', ''Winston'', ''500'', ''6'');
insert into Queue (person_id, person_name, weight, turn) values (''2'', ''Marie'', ''200'', ''4'')', 'SELECT person_name
FROM (
  SELECT person_name, SUM(weight) OVER (ORDER BY turn) AS total_weight
  FROM Queue
) t
WHERE total_weight <= 1000
ORDER BY total_weight DESC
LIMIT 1;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1070, '即时食物配送 II', '配送表: Delivery

+-----------------------------+---------+
| Column Name | Type |
+-----------------------------+---------+
| delivery_id | int |
| customer_id | int |
| order_date | date |
| customer_pref_delivery_date | date |
+-----------------------------+---------+
delivery_id 是该表中具有唯一值的列。
该表保存着顾客的食物配送信息，顾客在某个日期下了订单，并指定了一个期望的配送日期（和下单日期相同或者在那之后）。



如果顾客期望的配送日期和下单日期相同，则该订单称为 「即时订单」，否则称为「计划订单」。

「首次订单」是顾客最早创建的订单。我们保证一个顾客只会有一个「首次订单」。

编写解决方案以获取即时订单在所有用户的首次订单中的比例。保留两位小数。

结果示例如下所示：



示例 1：

输入：
Delivery 表：
+-------------+-------------+------------+-----------------------------+
| delivery_id | customer_id | order_date | customer_pref_delivery_date |
+-------------+-------------+------------+-----------------------------+
| 1 | 1 | 2019-08-01 | 2019-08-02 |
| 2 | 2 | 2019-08-02 | 2019-08-02 |
| 3 | 1 | 2019-08-11 | 2019-08-12 |
| 4 | 3 | 2019-08-24 | 2019-08-24 |
| 5 | 3 | 2019-08-21 | 2019-08-22 |
| 6 | 2 | 2019-08-11 | 2019-08-13 |
| 7 | 4 | 2019-08-09 | 2019-08-09 |
+-------------+-------------+------------+-----------------------------+
输出：
+----------------------+
| immediate_percentage |
+----------------------+
| 50.00 |
+----------------------+
解释：
1 号顾客的 1 号订单是首次订单，并且是计划订单。
2 号顾客的 2 号订单是首次订单，并且是即时订单。
3 号顾客的 5 号订单是首次订单，并且是计划订单。
4 号顾客的 7 号订单是首次订单，并且是即时订单。
因此，一半顾客的首次订单是即时的。', 'MEDIUM', '数据库', 'Create table If Not Exists Delivery (delivery_id int, customer_id int, order_date date, customer_pref_delivery_date date);
Truncate table Delivery;
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''1'', ''1'', ''2019-08-01'', ''2019-08-02'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''2'', ''2'', ''2019-08-02'', ''2019-08-02'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''3'', ''1'', ''2019-08-11'', ''2019-08-12'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''4'', ''3'', ''2019-08-24'', ''2019-08-24'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''5'', ''3'', ''2019-08-21'', ''2019-08-22'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''6'', ''2'', ''2019-08-11'', ''2019-08-13'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''7'', ''4'', ''2019-08-09'', ''2019-08-09'')', 'SELECT ROUND(AVG(order_date = customer_pref_delivery_date) * 100, 2) AS immediate_percentage
FROM Delivery
WHERE (customer_id, order_date) IN (
  SELECT customer_id, MIN(order_date) FROM Delivery GROUP BY customer_id
);', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1071, '部门工资前三高的所有员工', '表: Employee

+--------------+---------+
| Column Name | Type |
+--------------+---------+
| id | int |
| name | varchar |
| salary | int |
| departmentId | int |
+--------------+---------+
id 是该表的主键列(具有唯一值的列)。
departmentId 是 Department 表中 ID 的外键（reference 列）。
该表的每一行都表示员工的ID、姓名和工资。它还包含了他们部门的ID。



表: Department

+-------------+---------+
| Column Name | Type |
+-------------+---------+
| id | int |
| name | varchar |
+-------------+---------+
id 是该表的主键列(具有唯一值的列)。
该表的每一行表示部门ID和部门名。



公司的主管们感兴趣的是公司每个部门中谁赚的钱最多。一个部门的 高收入者 是指一个员工的工资在该部门的 不同 工资中 排名前三 。

编写解决方案，找出每个部门中 收入高的员工 。

以 任意顺序 返回结果表。

返回结果格式如下所示。



示例 1:

输入:
Employee 表:
+----+-------+--------+--------------+
| id | name | salary | departmentId |
+----+-------+--------+--------------+
| 1 | Joe | 85000 | 1 |
| 2 | Henry | 80000 | 2 |
| 3 | Sam | 60000 | 2 |
| 4 | Max | 90000 | 1 |
| 5 | Janet | 69000 | 1 |
| 6 | Randy | 85000 | 1 |
| 7 | Will | 70000 | 1 |
+----+-------+--------+--------------+
Department 表:
+----+-------+
| id | name |
+----+-------+
| 1 | IT |
| 2 | Sales |
+----+-------+
输出:
+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT | Max | 90000 |
| IT | Joe | 85000 |
| IT | Randy | 85000 |
| IT | Will | 70000 |
| Sales | Henry | 80000 |
| Sales | Sam | 60000 |
+------------+----------+--------+
解释:
在IT部门:
- Max的工资最高
- 兰迪和乔都赚取第二高的独特的薪水
- 威尔的薪水是第三高的

在销售部:
- 亨利的工资最高
- 山姆的薪水第二高
- 没有第三高的工资，因为只有两名员工



提示：

 没有姓名、薪资和部门 完全 相同的员工。', 'HARD', '数据库', 'Create table If Not Exists Employee (id int, name varchar(255), salary int, departmentId int);
Create table If Not Exists Department (id int, name varchar(255));
Truncate table Employee;
insert into Employee (id, name, salary, departmentId) values (''1'', ''Joe'', ''85000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''2'', ''Henry'', ''80000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''3'', ''Sam'', ''60000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''4'', ''Max'', ''90000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''5'', ''Janet'', ''69000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''6'', ''Randy'', ''85000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''7'', ''Will'', ''70000'', ''1'');
Truncate table Department;
insert into Department (id, name) values (''1'', ''IT'');
insert into Department (id, name) values (''2'', ''Sales'')', 'SELECT d.name AS Department, e.name AS Employee, e.salary AS Salary
FROM Employee e
JOIN Department d ON e.departmentId = d.id
WHERE (
  SELECT COUNT(DISTINCT e2.salary)
  FROM Employee e2
  WHERE e2.departmentId = e.departmentId AND e2.salary >= e.salary
) <= 3;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1072, '行程和用户', '表：Trips

+-------------+----------+
| Column Name | Type |
+-------------+----------+
| id | int |
| client_id | int |
| driver_id | int |
| city_id | int |
| status | enum |
| request_at | varchar |
+-------------+----------+
id 是这张表的主键（具有唯一值的列）。
这张表中存所有出租车的行程信息。每段行程有唯一 id ，其中 client_id 和 driver_id 是 Users 表中 users_id 的外键。
status 是一个表示行程状态的枚举类型，枚举成员为(‘completed’, ‘cancelled_by_driver’, ‘cancelled_by_client’) 。

表：Users

+-------------+----------+
| Column Name | Type |
+-------------+----------+
| users_id | int |
| banned | enum |
| role | enum |
+-------------+----------+
users_id 是这张表的主键（具有唯一值的列）。
这张表中存所有用户，每个用户都有一个唯一的 users_id ，role 是一个表示用户身份的枚举类型，枚举成员为 (‘client’, ‘driver’, ‘partner’) 。
banned 是一个表示用户是否被禁止的枚举类型，枚举成员为 (‘Yes’, ‘No’) 。

取消率 的计算方式如下：(被司机或乘客取消的非禁止用户生成的订单数量) / (非禁止用户生成的订单总数)。

编写解决方案找出 "2013-10-01" 至 "2013-10-03" 期间有 至少 一次行程的非禁止用户（乘客和司机都必须未被禁止）的 取消率。非禁止用户即 banned 为 No 的用户，禁止用户即 banned 为 Yes 的用户。其中取消率 Cancellation Rate 需要四舍五入保留 两位小数 。

返回结果表中的数据 无顺序要求 。

结果格式如下例所示。



示例 1：

输入：
Trips 表：
+----+-----------+-----------+---------+---------------------+------------+
| id | client_id | driver_id | city_id | status | request_at |
+----+-----------+-----------+---------+---------------------+------------+
| 1 | 1 | 10 | 1 | completed | 2013-10-01 |
| 2 | 2 | 11 | 1 | cancelled_by_driver | 2013-10-01 |
| 3 | 3 | 12 | 6 | completed | 2013-10-01 |
| 4 | 4 | 13 | 6 | cancelled_by_client | 2013-10-01 |
| 5 | 1 | 10 | 1 | completed | 2013-10-02 |
| 6 | 2 | 11 | 6 | completed | 2013-10-02 |
| 7 | 3 | 12 | 6 | completed | 2013-10-02 |
| 8 | 2 | 12 | 12 | completed | 2013-10-03 |
| 9 | 3 | 10 | 12 | completed | 2013-10-03 |
| 10 | 4 | 13 | 12 | cancelled_by_driver | 2013-10-03 |
+----+-----------+-----------+---------+---------------------+------------+
Users 表：
+----------+--------+--------+
| users_id | banned | role |
+----------+--------+--------+
| 1 | No | client |
| 2 | Yes | client |
| 3 | No | client |
| 4 | No | client |
| 10 | No | driver |
| 11 | No | driver |
| 12 | No | driver |
| 13 | No | driver |
+----------+--------+--------+
输出：
+------------+-------------------+
| Day | Cancellation Rate |
+------------+-------------------+
| 2013-10-01 | 0.33 |
| 2013-10-02 | 0.00 |
| 2013-10-03 | 0.50 |
+------------+-------------------+
解释：
2013-10-01：
 - 共有 4 条请求，其中 2 条取消。
 - 然而，id=2 的请求是由禁止用户（user_id=2）发出的，所以计算时应当忽略它。
 - 因此，总共有 3 条非禁止请求参与计算，其中 1 条取消。
 - 取消率为 (1 / 3) = 0.33
2013-10-02：
 - 共有 3 条请求，其中 0 条取消。
 - 然而，id=6 的请求是由禁止用户发出的，所以计算时应当忽略它。
 - 因此，总共有 2 条非禁止请求参与计算，其中 0 条取消。
 - 取消率为 (0 / 2) = 0.00
2013-10-03：
 - 共有 3 条请求，其中 1 条取消。
 - 然而，id=8 的请求是由禁止用户发出的，所以计算时应当忽略它。
 - 因此，总共有 2 条非禁止请求参与计算，其中 1 条取消。
 - 取消率为 (1 / 2) = 0.50', 'HARD', '数据库', 'Create table If Not Exists Trips (id int, client_id int, driver_id int, city_id int, status ENUM(''completed'', ''cancelled_by_driver'', ''cancelled_by_client''), request_at varchar(50));
Create table If Not Exists Users (users_id int, banned varchar(50), role ENUM(''client'', ''driver'', ''partner''));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''1'', ''1'', ''10'', ''1'', ''completed'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''2'', ''2'', ''11'', ''1'', ''cancelled_by_driver'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''3'', ''3'', ''12'', ''6'', ''completed'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''4'', ''4'', ''13'', ''6'', ''cancelled_by_client'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''5'', ''1'', ''10'', ''1'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''6'', ''2'', ''11'', ''6'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''7'', ''3'', ''12'', ''6'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''8'', ''2'', ''12'', ''12'', ''completed'', ''2013-10-03'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''9'', ''3'', ''10'', ''12'', ''completed'', ''2013-10-03'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''10'', ''4'', ''13'', ''12'', ''cancelled_by_driver'', ''2013-10-03'');
Truncate table Users;
insert into Users (users_id, banned, role) values (''1'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''2'', ''Yes'', ''client'');
insert into Users (users_id, banned, role) values (''3'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''4'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''10'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''11'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''12'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''13'', ''No'', ''driver'')', 'SELECT t.request_at AS Day,
  ROUND(SUM(t.status != ''completed'') / COUNT(*), 2) AS `Cancellation Rate`
FROM Trips t
JOIN Users c ON t.client_id = c.users_id AND c.banned = ''No''
JOIN Users d ON t.driver_id = d.users_id AND d.banned = ''No''
WHERE t.request_at BETWEEN ''2013-10-01'' AND ''2013-10-03''
GROUP BY t.request_at;', '', '', 1);
INSERT INTO problem (id, title, description, difficulty, tags, init_sql, answer_sql, sample_input, sample_output, status) VALUES
(1073, '体育馆的人流量', '表：Stadium

+---------------+---------+
| Column Name | Type |
+---------------+---------+
| id | int |
| visit_date | date |
| people | int |
+---------------+---------+
visit_date 是该表中具有唯一值的列。
每日人流量信息被记录在这三列信息中：序号 (id)、日期 (visit_date)、 人流量 (people)
每天只有一行记录，日期随着 id 的增加而增加



编写解决方案找出每行的人数大于或等于 100 且 id 连续的三行或更多行记录。

返回按 visit_date 升序排列 的结果表。

查询结果格式如下所示。



示例 1:

输入：
Stadium 表:
+------+------------+-----------+
| id | visit_date | people |
+------+------------+-----------+
| 1 | 2017-01-01 | 10 |
| 2 | 2017-01-02 | 109 |
| 3 | 2017-01-03 | 150 |
| 4 | 2017-01-04 | 99 |
| 5 | 2017-01-05 | 145 |
| 6 | 2017-01-06 | 1455 |
| 7 | 2017-01-07 | 199 |
| 8 | 2017-01-09 | 188 |
+------+------------+-----------+
输出：
+------+------------+-----------+
| id | visit_date | people |
+------+------------+-----------+
| 5 | 2017-01-05 | 145 |
| 6 | 2017-01-06 | 1455 |
| 7 | 2017-01-07 | 199 |
| 8 | 2017-01-09 | 188 |
+------+------------+-----------+
解释：
id 为 5、6、7、8 的四行 id 连续，并且每行都有 >= 100 的人数记录。
请注意，即使第 7 行和第 8 行的 visit_date 不是连续的，输出也应当包含第 8 行，因为我们只需要考虑 id 连续的记录。
不输出 id 为 2 和 3 的行，因为至少需要三条 id 连续的记录。', 'HARD', '数据库', 'Create table If Not Exists Stadium (id int, visit_date DATE NULL, people int);
Truncate table Stadium;
insert into Stadium (id, visit_date, people) values (''1'', ''2017-01-01'', ''10'');
insert into Stadium (id, visit_date, people) values (''2'', ''2017-01-02'', ''109'');
insert into Stadium (id, visit_date, people) values (''3'', ''2017-01-03'', ''150'');
insert into Stadium (id, visit_date, people) values (''4'', ''2017-01-04'', ''99'');
insert into Stadium (id, visit_date, people) values (''5'', ''2017-01-05'', ''145'');
insert into Stadium (id, visit_date, people) values (''6'', ''2017-01-06'', ''1455'');
insert into Stadium (id, visit_date, people) values (''7'', ''2017-01-07'', ''199'');
insert into Stadium (id, visit_date, people) values (''8'', ''2017-01-09'', ''188'')', 'WITH t AS (
  SELECT id, visit_date, people, id - ROW_NUMBER() OVER (ORDER BY id) AS grp
  FROM Stadium
  WHERE people >= 100
)
SELECT id, visit_date, people
FROM t
WHERE grp IN (
  SELECT grp FROM t GROUP BY grp HAVING COUNT(*) >= 3
)
ORDER BY visit_date;', '', '', 1);

-- =================== 测试用例（每题 1 个数据集 = init_sql） ===================
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1001, 1, 'Create table If Not Exists Person (personId int, firstName varchar(255), lastName varchar(255));
Create table If Not Exists Address (addressId int, personId int, city varchar(255), state varchar(255));
Truncate table Person;
insert into Person (personId, lastName, firstName) values (''1'', ''Wang'', ''Allen'');
insert into Person (personId, lastName, firstName) values (''2'', ''Alice'', ''Bob'');
Truncate table Address;
insert into Address (addressId, personId, city, state) values (''1'', ''2'', ''New York City'', ''New York'');
insert into Address (addressId, personId, city, state) values (''2'', ''3'', ''Leetcode'', ''California'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1002, 1, 'Create table If Not Exists Employee (id int, name varchar(255), salary int, managerId int);
Truncate table Employee;
insert into Employee (id, name, salary, managerId) values (''1'', ''Joe'', ''70000'', ''3'');
insert into Employee (id, name, salary, managerId) values (''2'', ''Henry'', ''80000'', ''4'');
insert into Employee (id, name, salary, managerId) values (''3'', ''Sam'', ''60000'', NULL);
insert into Employee (id, name, salary, managerId) values (''4'', ''Max'', ''90000'', NULL)');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1003, 1, 'Create table If Not Exists Person (id int, email varchar(255));
Truncate table Person;
insert into Person (id, email) values (''1'', ''a@b.com'');
insert into Person (id, email) values (''2'', ''c@d.com'');
insert into Person (id, email) values (''3'', ''a@b.com'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1004, 1, 'Create table If Not Exists Customers (id int, name varchar(255));
Create table If Not Exists Orders (id int, customerId int);
Truncate table Customers;
insert into Customers (id, name) values (''1'', ''Joe'');
insert into Customers (id, name) values (''2'', ''Henry'');
insert into Customers (id, name) values (''3'', ''Sam'');
insert into Customers (id, name) values (''4'', ''Max'');
Truncate table Orders;
insert into Orders (id, customerId) values (''1'', ''3'');
insert into Orders (id, customerId) values (''2'', ''1'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1005, 1, 'Create table If Not Exists Weather (id int, recordDate date, temperature int);
Truncate table Weather;
insert into Weather (id, recordDate, temperature) values (''1'', ''2015-01-01'', ''10'');
insert into Weather (id, recordDate, temperature) values (''2'', ''2015-01-02'', ''25'');
insert into Weather (id, recordDate, temperature) values (''3'', ''2015-01-03'', ''20'');
insert into Weather (id, recordDate, temperature) values (''4'', ''2015-01-04'', ''30'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1006, 1, 'Create table If Not Exists Employee (empId int, name varchar(255), supervisor int, salary int);
Create table If Not Exists Bonus (empId int, bonus int);
Truncate table Employee;
insert into Employee (empId, name, supervisor, salary) values (''3'', ''Brad'', NULL, ''4000'');
insert into Employee (empId, name, supervisor, salary) values (''1'', ''John'', ''3'', ''1000'');
insert into Employee (empId, name, supervisor, salary) values (''2'', ''Dan'', ''3'', ''2000'');
insert into Employee (empId, name, supervisor, salary) values (''4'', ''Thomas'', ''3'', ''4000'');
Truncate table Bonus;
insert into Bonus (empId, bonus) values (''2'', ''500'');
insert into Bonus (empId, bonus) values (''4'', ''2000'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1007, 1, 'Create table If Not Exists Customer (id int, name varchar(25), referee_id int);
Truncate table Customer;
insert into Customer (id, name, referee_id) values (''1'', ''Will'', NULL);
insert into Customer (id, name, referee_id) values (''2'', ''Jane'', NULL);
insert into Customer (id, name, referee_id) values (''3'', ''Alex'', ''2'');
insert into Customer (id, name, referee_id) values (''4'', ''Bill'', NULL);
insert into Customer (id, name, referee_id) values (''5'', ''Zack'', ''1'');
insert into Customer (id, name, referee_id) values (''6'', ''Mark'', ''2'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1008, 1, 'Create table If Not Exists World (name varchar(255), continent varchar(255), area int, population int, gdp bigint);
Truncate table World;
insert into World (name, continent, area, population, gdp) values (''Afghanistan'', ''Asia'', ''652230'', ''25500100'', ''20343000000'');
insert into World (name, continent, area, population, gdp) values (''Albania'', ''Europe'', ''28748'', ''2831741'', ''12960000000'');
insert into World (name, continent, area, population, gdp) values (''Algeria'', ''Africa'', ''2381741'', ''37100000'', ''188681000000'');
insert into World (name, continent, area, population, gdp) values (''Andorra'', ''Europe'', ''468'', ''78115'', ''3712000000'');
insert into World (name, continent, area, population, gdp) values (''Angola'', ''Africa'', ''1246700'', ''20609294'', ''100990000000'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1009, 1, 'Create table If Not Exists SalesPerson (sales_id int, name varchar(255), salary int, commission_rate int, hire_date date);
Create table If Not Exists Company (com_id int, name varchar(255), city varchar(255));
Create table If Not Exists Orders (order_id int, order_date date, com_id int, sales_id int, amount int);
Truncate table SalesPerson;
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''1'', ''John'', ''100000'', ''6'', ''2006-04-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''2'', ''Amy'', ''12000'', ''5'', ''2010-05-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''3'', ''Mark'', ''65000'', ''12'', ''2008-12-25'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''4'', ''Pam'', ''25000'', ''25'', ''2005-01-01'');
insert into SalesPerson (sales_id, name, salary, commission_rate, hire_date) values (''5'', ''Alex'', ''5000'', ''10'', ''2007-02-03'');
Truncate table Company;
insert into Company (com_id, name, city) values (''1'', ''RED'', ''Boston'');
insert into Company (com_id, name, city) values (''2'', ''ORANGE'', ''New York'');
insert into Company (com_id, name, city) values (''3'', ''YELLOW'', ''Boston'');
insert into Company (com_id, name, city) values (''4'', ''GREEN'', ''Austin'');
Truncate table Orders;
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''1'', ''2014-01-01'', ''3'', ''4'', ''10000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''2'', ''2014-02-01'', ''4'', ''5'', ''5000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''3'', ''2014-03-01'', ''1'', ''1'', ''50000'');
insert into Orders (order_id, order_date, com_id, sales_id, amount) values (''4'', ''2014-04-01'', ''1'', ''4'', ''25000'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1010, 1, 'Create table If Not Exists Triangle (x int, y int, z int);
Truncate table Triangle;
insert into Triangle (x, y, z) values (''13'', ''15'', ''30'');
insert into Triangle (x, y, z) values (''10'', ''20'', ''15'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1011, 1, 'Create table If Not Exists cinema (id int, movie varchar(255), description varchar(255), rating float(2, 1));
Truncate table cinema;
insert into cinema (id, movie, description, rating) values (''1'', ''War'', ''great 3D'', ''8.9'');
insert into cinema (id, movie, description, rating) values (''2'', ''Science'', ''fiction'', ''8.5'');
insert into cinema (id, movie, description, rating) values (''3'', ''irish'', ''boring'', ''6.2'');
insert into cinema (id, movie, description, rating) values (''4'', ''Ice song'', ''Fantacy'', ''8.6'');
insert into cinema (id, movie, description, rating) values (''5'', ''House card'', ''Interesting'', ''9.1'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1012, 1, 'Create table If Not Exists Activity (player_id int, device_id int, event_date date, games_played int);
Truncate table Activity;
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-01'', ''5'');
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-05-02'', ''6'');
insert into Activity (player_id, device_id, event_date, games_played) values (''2'', ''3'', ''2017-06-25'', ''1'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''1'', ''2016-03-02'', ''0'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''4'', ''2018-07-03'', ''5'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1013, 1, 'Create table If Not Exists Views (article_id int, author_id int, viewer_id int, view_date date);
Truncate table Views;
insert into Views (article_id, author_id, viewer_id, view_date) values (''1'', ''3'', ''5'', ''2019-08-01'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''1'', ''3'', ''6'', ''2019-08-02'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''2'', ''7'', ''7'', ''2019-08-01'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''2'', ''7'', ''6'', ''2019-08-02'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''4'', ''7'', ''1'', ''2019-07-22'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''3'', ''4'', ''4'', ''2019-07-21'');
insert into Views (article_id, author_id, viewer_id, view_date) values (''3'', ''4'', ''4'', ''2019-07-21'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1014, 1, 'Create table If Not Exists Products (product_id int, low_fats ENUM(''Y'', ''N''), recyclable ENUM(''Y'',''N''));
Truncate table Products;
insert into Products (product_id, low_fats, recyclable) values (''0'', ''Y'', ''N'');
insert into Products (product_id, low_fats, recyclable) values (''1'', ''Y'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''2'', ''N'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''3'', ''Y'', ''Y'');
insert into Products (product_id, low_fats, recyclable) values (''4'', ''N'', ''N'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1015, 1, 'Create table If Not Exists Tweets(tweet_id int, content varchar(50));
Truncate table Tweets;
insert into Tweets (tweet_id, content) values (''1'', ''Let us Code'');
insert into Tweets (tweet_id, content) values (''2'', ''More than fifteen chars are here!'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1016, 1, 'Create table If Not Exists Users (user_id int, name varchar(40));
Truncate table Users;
insert into Users (user_id, name) values (''1'', ''aLice'');
insert into Users (user_id, name) values (''2'', ''bOB'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1017, 1, 'Create table If Not Exists Followers(user_id int, follower_id int);
Truncate table Followers;
insert into Followers (user_id, follower_id) values (''0'', ''1'');
insert into Followers (user_id, follower_id) values (''1'', ''0'');
insert into Followers (user_id, follower_id) values (''2'', ''0'');
insert into Followers (user_id, follower_id) values (''2'', ''1'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1018, 1, 'Create table If Not Exists Employees(emp_id int, event_day date, in_time int, out_time int);
Truncate table Employees;
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-11-28'', ''4'', ''32'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-11-28'', ''55'', ''200'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''1'', ''2020-12-3'', ''1'', ''42'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''2'', ''2020-11-28'', ''3'', ''33'');
insert into Employees (emp_id, event_day, in_time, out_time) values (''2'', ''2020-12-9'', ''47'', ''74'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1019, 1, 'Create table If Not Exists DailySales(date_id date, make_name varchar(20), lead_id int, partner_id int);
Truncate table DailySales;
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''1'', ''0'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''toyota'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''toyota'', ''0'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''toyota'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''honda'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-8'', ''honda'', ''2'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''0'', ''1'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''1'', ''2'');
insert into DailySales (date_id, make_name, lead_id, partner_id) values (''2020-12-7'', ''honda'', ''2'', ''1'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1020, 1, 'Create table If Not Exists Project (project_id int, employee_id int);
Create table If Not Exists Employee (employee_id int, name varchar(10), experience_years int);
Truncate table Project;
insert into Project (project_id, employee_id) values (''1'', ''1'');
insert into Project (project_id, employee_id) values (''1'', ''2'');
insert into Project (project_id, employee_id) values (''1'', ''3'');
insert into Project (project_id, employee_id) values (''2'', ''1'');
insert into Project (project_id, employee_id) values (''2'', ''4'');
Truncate table Employee;
insert into Employee (employee_id, name, experience_years) values (''1'', ''Khaled'', ''3'');
insert into Employee (employee_id, name, experience_years) values (''2'', ''Ali'', ''2'');
insert into Employee (employee_id, name, experience_years) values (''3'', ''John'', ''1'');
insert into Employee (employee_id, name, experience_years) values (''4'', ''Doe'', ''2'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1021, 1, 'Create table If Not Exists Prices (product_id int, start_date date, end_date date, price int);
Create table If Not Exists UnitsSold (product_id int, purchase_date date, units int);
Truncate table Prices;
insert into Prices (product_id, start_date, end_date, price) values (''1'', ''2019-02-17'', ''2019-02-28'', ''5'');
insert into Prices (product_id, start_date, end_date, price) values (''1'', ''2019-03-01'', ''2019-03-22'', ''20'');
insert into Prices (product_id, start_date, end_date, price) values (''2'', ''2019-02-01'', ''2019-02-20'', ''15'');
insert into Prices (product_id, start_date, end_date, price) values (''2'', ''2019-02-21'', ''2019-03-31'', ''30'');
Truncate table UnitsSold;
insert into UnitsSold (product_id, purchase_date, units) values (''1'', ''2019-02-25'', ''100'');
insert into UnitsSold (product_id, purchase_date, units) values (''1'', ''2019-03-01'', ''15'');
insert into UnitsSold (product_id, purchase_date, units) values (''2'', ''2019-02-10'', ''200'');
insert into UnitsSold (product_id, purchase_date, units) values (''2'', ''2019-03-22'', ''30'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1022, 1, 'Create table If Not Exists Students (student_id int, student_name varchar(20));
Create table If Not Exists Subjects (subject_name varchar(20));
Create table If Not Exists Examinations (student_id int, subject_name varchar(20));
Truncate table Students;
insert into Students (student_id, student_name) values (''1'', ''Alice'');
insert into Students (student_id, student_name) values (''2'', ''Bob'');
insert into Students (student_id, student_name) values (''13'', ''John'');
insert into Students (student_id, student_name) values (''6'', ''Alex'');
Truncate table Subjects;
insert into Subjects (subject_name) values (''Math'');
insert into Subjects (subject_name) values (''Physics'');
insert into Subjects (subject_name) values (''Programming'');
Truncate table Examinations;
insert into Examinations (student_id, subject_name) values (''1'', ''Math'');
insert into Examinations (student_id, subject_name) values (''1'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''1'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''2'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''1'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''1'', ''Math'');
insert into Examinations (student_id, subject_name) values (''13'', ''Math'');
insert into Examinations (student_id, subject_name) values (''13'', ''Programming'');
insert into Examinations (student_id, subject_name) values (''13'', ''Physics'');
insert into Examinations (student_id, subject_name) values (''2'', ''Math'');
insert into Examinations (student_id, subject_name) values (''1'', ''Math'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1023, 1, 'Create table If Not Exists Queries (query_name varchar(30), result varchar(50), position int, rating int);
Truncate table Queries;
insert into Queries (query_name, result, position, rating) values (''Dog'', ''Golden Retriever'', ''1'', ''5'');
insert into Queries (query_name, result, position, rating) values (''Dog'', ''German Shepherd'', ''2'', ''5'');
insert into Queries (query_name, result, position, rating) values (''Dog'', ''Mule'', ''200'', ''1'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Shirazi'', ''5'', ''2'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Siamese'', ''3'', ''3'');
insert into Queries (query_name, result, position, rating) values (''Cat'', ''Sphynx'', ''7'', ''4'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1024, 1, 'Create table If Not Exists Employees (id int, name varchar(20));
Create table If Not Exists EmployeeUNI (id int, unique_id int);
Truncate table Employees;
insert into Employees (id, name) values (''1'', ''Alice'');
insert into Employees (id, name) values (''7'', ''Bob'');
insert into Employees (id, name) values (''11'', ''Meir'');
insert into Employees (id, name) values (''90'', ''Winston'');
insert into Employees (id, name) values (''3'', ''Jonathan'');
Truncate table EmployeeUNI;
insert into EmployeeUNI (id, unique_id) values (''3'', ''1'');
insert into EmployeeUNI (id, unique_id) values (''11'', ''2'');
insert into EmployeeUNI (id, unique_id) values (''90'', ''3'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1025, 1, 'Create table If Not Exists Visits(visit_id int, customer_id int);
Create table If Not Exists Transactions(transaction_id int, visit_id int, amount int);
Truncate table Visits;
insert into Visits (visit_id, customer_id) values (''1'', ''23'');
insert into Visits (visit_id, customer_id) values (''2'', ''9'');
insert into Visits (visit_id, customer_id) values (''4'', ''30'');
insert into Visits (visit_id, customer_id) values (''5'', ''54'');
insert into Visits (visit_id, customer_id) values (''6'', ''96'');
insert into Visits (visit_id, customer_id) values (''7'', ''54'');
insert into Visits (visit_id, customer_id) values (''8'', ''54'');
Truncate table Transactions;
insert into Transactions (transaction_id, visit_id, amount) values (''2'', ''5'', ''310'');
insert into Transactions (transaction_id, visit_id, amount) values (''3'', ''5'', ''300'');
insert into Transactions (transaction_id, visit_id, amount) values (''9'', ''5'', ''200'');
insert into Transactions (transaction_id, visit_id, amount) values (''12'', ''1'', ''910'');
insert into Transactions (transaction_id, visit_id, amount) values (''13'', ''2'', ''970'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1026, 1, 'Create table If Not Exists Users (user_id int, user_name varchar(20));
Create table If Not Exists Register (contest_id int, user_id int);
Truncate table Users;
insert into Users (user_id, user_name) values (''6'', ''Alice'');
insert into Users (user_id, user_name) values (''2'', ''Bob'');
insert into Users (user_id, user_name) values (''7'', ''Alex'');
Truncate table Register;
insert into Register (contest_id, user_id) values (''215'', ''6'');
insert into Register (contest_id, user_id) values (''209'', ''2'');
insert into Register (contest_id, user_id) values (''208'', ''2'');
insert into Register (contest_id, user_id) values (''210'', ''6'');
insert into Register (contest_id, user_id) values (''208'', ''6'');
insert into Register (contest_id, user_id) values (''209'', ''7'');
insert into Register (contest_id, user_id) values (''209'', ''6'');
insert into Register (contest_id, user_id) values (''215'', ''7'');
insert into Register (contest_id, user_id) values (''208'', ''7'');
insert into Register (contest_id, user_id) values (''210'', ''2'');
insert into Register (contest_id, user_id) values (''207'', ''2'');
insert into Register (contest_id, user_id) values (''210'', ''7'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1027, 1, 'Create table If Not Exists Activity (machine_id int, process_id int, activity_type ENUM(''start'', ''end''), timestamp float);
Truncate table Activity;
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''0'', ''start'', ''0.712'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''0'', ''end'', ''1.52'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''1'', ''start'', ''3.14'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''0'', ''1'', ''end'', ''4.12'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''0'', ''start'', ''0.55'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''0'', ''end'', ''1.55'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''1'', ''start'', ''0.43'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''1'', ''1'', ''end'', ''1.42'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''0'', ''start'', ''4.1'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''0'', ''end'', ''4.512'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''1'', ''start'', ''2.5'');
insert into Activity (machine_id, process_id, activity_type, timestamp) values (''2'', ''1'', ''end'', ''5'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1028, 1, 'Create table If Not Exists Users (user_id int, name varchar(30), mail varchar(50));
Truncate table Users;
insert into Users (user_id, name, mail) values (''1'', ''Winston'', ''winston@leetcode.com'');
insert into Users (user_id, name, mail) values (''2'', ''Jonathan'', ''jonathanisgreat'');
insert into Users (user_id, name, mail) values (''3'', ''Annabelle'', ''bella-@leetcode.com'');
insert into Users (user_id, name, mail) values (''4'', ''Sally'', ''sally.come@leetcode.com'');
insert into Users (user_id, name, mail) values (''5'', ''Marwan'', ''quarz#2020@leetcode.com'');
insert into Users (user_id, name, mail) values (''6'', ''David'', ''david69@gmail.com'');
insert into Users (user_id, name, mail) values (''7'', ''Shapiro'', ''.shapo@leetcode.com'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1029, 1, 'Create table If Not Exists Patients (patient_id int, patient_name varchar(30), conditions varchar(100));
Truncate table Patients;
insert into Patients (patient_id, patient_name, conditions) values (''1'', ''Daniel'', ''YFEV COUGH'');
insert into Patients (patient_id, patient_name, conditions) values (''2'', ''Alice'', '''');
insert into Patients (patient_id, patient_name, conditions) values (''3'', ''Bob'', ''DIAB100 MYOP'');
insert into Patients (patient_id, patient_name, conditions) values (''4'', ''George'', ''ACNE DIAB100'');
insert into Patients (patient_id, patient_name, conditions) values (''5'', ''Alain'', ''DIAB201'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1030, 1, 'Create table If Not Exists Employee (employee_id int, department_id int, primary_flag ENUM(''Y'',''N''));
Truncate table Employee;
insert into Employee (employee_id, department_id, primary_flag) values (''1'', ''1'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''2'', ''1'', ''Y'');
insert into Employee (employee_id, department_id, primary_flag) values (''2'', ''2'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''3'', ''3'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''2'', ''N'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''3'', ''Y'');
insert into Employee (employee_id, department_id, primary_flag) values (''4'', ''4'', ''N'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1031, 1, 'Create table If Not Exists Employees(employee_id int, name varchar(20), reports_to int, age int);
Truncate table Employees;
insert into Employees (employee_id, name, reports_to, age) values (''9'', ''Hercy'', NULL, ''43'');
insert into Employees (employee_id, name, reports_to, age) values (''6'', ''Alice'', ''9'', ''41'');
insert into Employees (employee_id, name, reports_to, age) values (''4'', ''Bob'', ''9'', ''36'');
insert into Employees (employee_id, name, reports_to, age) values (''2'', ''Winston'', NULL, ''37'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1032, 1, 'Create table If Not Exists ActorDirector (actor_id int, director_id int, timestamp int);
Truncate table ActorDirector;
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''0'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''1'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''1'', ''2'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''2'', ''3'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''1'', ''2'', ''4'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''2'', ''1'', ''5'');
insert into ActorDirector (actor_id, director_id, timestamp) values (''2'', ''1'', ''6'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1033, 1, 'Create table If Not Exists Sales (sale_id int, product_id int, year int, quantity int, price int);
Create table If Not Exists Product (product_id int, product_name varchar(10));
Truncate table Sales;
insert into Sales (sale_id, product_id, year, quantity, price) values (''1'', ''100'', ''2008'', ''10'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''2'', ''100'', ''2009'', ''12'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''7'', ''200'', ''2011'', ''15'', ''9000'');
Truncate table Product;
insert into Product (product_id, product_name) values (''100'', ''Nokia'');
insert into Product (product_id, product_name) values (''200'', ''Apple'');
insert into Product (product_id, product_name) values (''300'', ''Samsung'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1034, 1, 'Create table If Not Exists Courses (student varchar(255), class varchar(255));
Truncate table Courses;
insert into Courses (student, class) values (''A'', ''Math'');
insert into Courses (student, class) values (''B'', ''English'');
insert into Courses (student, class) values (''C'', ''Math'');
insert into Courses (student, class) values (''D'', ''Biology'');
insert into Courses (student, class) values (''E'', ''Math'');
insert into Courses (student, class) values (''F'', ''Computer'');
insert into Courses (student, class) values (''G'', ''Math'');
insert into Courses (student, class) values (''H'', ''Math'');
insert into Courses (student, class) values (''I'', ''Math'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1035, 1, 'Create table If Not Exists orders (order_number int, customer_number int);
Truncate table orders;
insert into orders (order_number, customer_number) values (''1'', ''1'');
insert into orders (order_number, customer_number) values (''2'', ''2'');
insert into orders (order_number, customer_number) values (''3'', ''3'');
insert into orders (order_number, customer_number) values (''4'', ''3'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1036, 1, 'Create table If Not Exists MyNumbers (num int);
Truncate table MyNumbers;
insert into MyNumbers (num) values (''8'');
insert into MyNumbers (num) values (''8'');
insert into MyNumbers (num) values (''3'');
insert into MyNumbers (num) values (''3'');
insert into MyNumbers (num) values (''1'');
insert into MyNumbers (num) values (''4'');
insert into MyNumbers (num) values (''5'');
insert into MyNumbers (num) values (''6'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1037, 1, 'Create table If Not Exists Activity (user_id int, session_id int, activity_date date, activity_type ENUM(''open_session'', ''end_session'', ''scroll_down'', ''send_message''));
Truncate table Activity;
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''scroll_down'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''1'', ''1'', ''2019-07-20'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-20'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-21'', ''send_message'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''2'', ''4'', ''2019-07-21'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''send_message'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''3'', ''2'', ''2019-07-21'', ''end_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''4'', ''3'', ''2019-06-25'', ''open_session'');
insert into Activity (user_id, session_id, activity_date, activity_type) values (''4'', ''3'', ''2019-06-25'', ''end_session'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1038, 1, 'Create table If Not Exists Activities (sell_date date, product varchar(20));
Truncate table Activities;
insert into Activities (sell_date, product) values (''2020-05-30'', ''Headphone'');
insert into Activities (sell_date, product) values (''2020-06-01'', ''Pencil'');
insert into Activities (sell_date, product) values (''2020-06-02'', ''Mask'');
insert into Activities (sell_date, product) values (''2020-05-30'', ''Basketball'');
insert into Activities (sell_date, product) values (''2020-06-01'', ''Bible'');
insert into Activities (sell_date, product) values (''2020-06-02'', ''Mask'');
insert into Activities (sell_date, product) values (''2020-05-30'', ''T-Shirt'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1039, 1, 'Create Table If Not Exists Users (id int, name varchar(30));
Create Table If Not Exists Rides (id int, user_id int, distance int);
Truncate table Users;
insert into Users (id, name) values (''1'', ''Alice'');
insert into Users (id, name) values (''2'', ''Bob'');
insert into Users (id, name) values (''3'', ''Alex'');
insert into Users (id, name) values (''4'', ''Donald'');
insert into Users (id, name) values (''7'', ''Lee'');
insert into Users (id, name) values (''13'', ''Jonathan'');
insert into Users (id, name) values (''19'', ''Elvis'');
Truncate table Rides;
insert into Rides (id, user_id, distance) values (''1'', ''1'', ''120'');
insert into Rides (id, user_id, distance) values (''2'', ''2'', ''317'');
insert into Rides (id, user_id, distance) values (''3'', ''3'', ''222'');
insert into Rides (id, user_id, distance) values (''4'', ''7'', ''100'');
insert into Rides (id, user_id, distance) values (''5'', ''13'', ''312'');
insert into Rides (id, user_id, distance) values (''6'', ''19'', ''50'');
insert into Rides (id, user_id, distance) values (''7'', ''7'', ''120'');
insert into Rides (id, user_id, distance) values (''8'', ''19'', ''400'');
insert into Rides (id, user_id, distance) values (''9'', ''7'', ''230'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1040, 1, 'Create table If Not Exists Logins (user_id int, time_stamp datetime);
Truncate table Logins;
insert into Logins (user_id, time_stamp) values (''6'', ''2020-06-30 15:06:07'');
insert into Logins (user_id, time_stamp) values (''6'', ''2021-04-21 14:06:06'');
insert into Logins (user_id, time_stamp) values (''6'', ''2019-03-07 00:18:15'');
insert into Logins (user_id, time_stamp) values (''8'', ''2020-02-01 05:10:53'');
insert into Logins (user_id, time_stamp) values (''8'', ''2020-12-30 00:46:50'');
insert into Logins (user_id, time_stamp) values (''2'', ''2020-01-16 02:49:50'');
insert into Logins (user_id, time_stamp) values (''2'', ''2019-08-25 07:59:08'');
insert into Logins (user_id, time_stamp) values (''14'', ''2019-07-14 09:00:00'');
insert into Logins (user_id, time_stamp) values (''14'', ''2021-01-06 11:59:59'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1041, 1, 'Create table If Not Exists Employees (employee_id int, name varchar(30));
Create table If Not Exists Salaries (employee_id int, salary int);
Truncate table Employees;
insert into Employees (employee_id, name) values (''2'', ''Crew'');
insert into Employees (employee_id, name) values (''4'', ''Haven'');
insert into Employees (employee_id, name) values (''5'', ''Kristian'');
Truncate table Salaries;
insert into Salaries (employee_id, salary) values (''5'', ''76071'');
insert into Salaries (employee_id, salary) values (''1'', ''22517'');
insert into Salaries (employee_id, salary) values (''4'', ''63539'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1042, 1, 'Create table If Not Exists Teacher (teacher_id int, subject_id int, dept_id int);
Truncate table Teacher;
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''2'', ''3'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''2'', ''4'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''1'', ''3'', ''3'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''1'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''2'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''3'', ''1'');
insert into Teacher (teacher_id, subject_id, dept_id) values (''2'', ''4'', ''1'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1043, 1, 'Create table If Not Exists Product (product_id int, product_name varchar(10), unit_price int);
Create table If Not Exists Sales (seller_id int, product_id int, buyer_id int, sale_date date, quantity int, price int);
Truncate table Product;
insert into Product (product_id, product_name, unit_price) values (''1'', ''S8'', ''1000'');
insert into Product (product_id, product_name, unit_price) values (''2'', ''G4'', ''800'');
insert into Product (product_id, product_name, unit_price) values (''3'', ''iPhone'', ''1400'');
Truncate table Sales;
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''1'', ''1'', ''1'', ''2019-01-21'', ''2'', ''2000'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''1'', ''2'', ''2'', ''2019-02-17'', ''1'', ''800'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''2'', ''2'', ''3'', ''2019-06-02'', ''1'', ''800'');
insert into Sales (seller_id, product_id, buyer_id, sale_date, quantity, price) values (''3'', ''3'', ''4'', ''2019-05-13'', ''2'', ''2800'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1044, 1, 'Create table If Not Exists Products (product_id int, product_name varchar(40), product_category varchar(40));
Create table If Not Exists Orders (product_id int, order_date date, unit int);
Truncate table Products;
insert into Products (product_id, product_name, product_category) values (''1'', ''Leetcode Solutions'', ''Book'');
insert into Products (product_id, product_name, product_category) values (''2'', ''Jewels of Stringology'', ''Book'');
insert into Products (product_id, product_name, product_category) values (''3'', ''HP'', ''Laptop'');
insert into Products (product_id, product_name, product_category) values (''4'', ''Lenovo'', ''Laptop'');
insert into Products (product_id, product_name, product_category) values (''5'', ''Leetcode Kit'', ''T-shirt'');
Truncate table Orders;
insert into Orders (product_id, order_date, unit) values (''1'', ''2020-02-05'', ''60'');
insert into Orders (product_id, order_date, unit) values (''1'', ''2020-02-10'', ''70'');
insert into Orders (product_id, order_date, unit) values (''2'', ''2020-01-18'', ''30'');
insert into Orders (product_id, order_date, unit) values (''2'', ''2020-02-11'', ''80'');
insert into Orders (product_id, order_date, unit) values (''3'', ''2020-02-17'', ''2'');
insert into Orders (product_id, order_date, unit) values (''3'', ''2020-02-24'', ''3'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-01'', ''20'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-04'', ''30'');
insert into Orders (product_id, order_date, unit) values (''4'', ''2020-03-04'', ''60'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-02-25'', ''50'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-02-27'', ''50'');
insert into Orders (product_id, order_date, unit) values (''5'', ''2020-03-01'', ''50'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1045, 1, 'Create table If Not Exists Employees (employee_id int, name varchar(30), salary int);
Truncate table Employees;
insert into Employees (employee_id, name, salary) values (''2'', ''Meir'', ''3000'');
insert into Employees (employee_id, name, salary) values (''3'', ''Michael'', ''3800'');
insert into Employees (employee_id, name, salary) values (''7'', ''Addilyn'', ''7400'');
insert into Employees (employee_id, name, salary) values (''8'', ''Juan'', ''6100'');
insert into Employees (employee_id, name, salary) values (''9'', ''Kannon'', ''7700'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1046, 1, 'Create table If Not Exists Products (product_id int, store1 int, store2 int, store3 int);
Truncate table Products;
insert into Products (product_id, store1, store2, store3) values (''0'', ''95'', ''100'', ''105'');
insert into Products (product_id, store1, store2, store3) values (''1'', ''70'', NULL, ''80'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1047, 1, 'Create table If Not Exists Users (account int, name varchar(20));
Create table If Not Exists Transactions (trans_id int, account int, amount int, transacted_on date);
Truncate table Users;
insert into Users (account, name) values (''900001'', ''Alice'');
insert into Users (account, name) values (''900002'', ''Bob'');
insert into Users (account, name) values (''900003'', ''Charlie'');
Truncate table Transactions;
insert into Transactions (trans_id, account, amount, transacted_on) values (''1'', ''900001'', ''7000'', ''2020-08-01'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''2'', ''900001'', ''7000'', ''2020-09-01'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''3'', ''900001'', ''-3000'', ''2020-09-02'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''4'', ''900002'', ''1000'', ''2020-09-12'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''5'', ''900003'', ''6000'', ''2020-08-07'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''6'', ''900003'', ''6000'', ''2020-09-07'');
insert into Transactions (trans_id, account, amount, transacted_on) values (''7'', ''900003'', ''-4000'', ''2020-09-11'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1048, 1, 'Create table If Not Exists Accounts (account_id int, income int);
Truncate table Accounts;
insert into Accounts (account_id, income) values (''3'', ''108939'');
insert into Accounts (account_id, income) values (''2'', ''12747'');
insert into Accounts (account_id, income) values (''8'', ''87709'');
insert into Accounts (account_id, income) values (''6'', ''91796'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1049, 1, 'Create table If Not Exists Employee (id int, salary int);
Truncate table Employee;
insert into Employee (id, salary) values (''1'', ''100'');
insert into Employee (id, salary) values (''2'', ''200'');
insert into Employee (id, salary) values (''3'', ''300'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1050, 1, 'Create table If Not Exists Scores (id int, score DECIMAL(3,2));
Truncate table Scores;
insert into Scores (id, score) values (''1'', ''3.5'');
insert into Scores (id, score) values (''2'', ''3.65'');
insert into Scores (id, score) values (''3'', ''4.0'');
insert into Scores (id, score) values (''4'', ''3.85'');
insert into Scores (id, score) values (''5'', ''4.0'');
insert into Scores (id, score) values (''6'', ''3.65'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1051, 1, 'Create table If Not Exists Logs (id int, num int);
Truncate table Logs;
insert into Logs (id, num) values (''1'', ''1'');
insert into Logs (id, num) values (''2'', ''1'');
insert into Logs (id, num) values (''3'', ''1'');
insert into Logs (id, num) values (''4'', ''2'');
insert into Logs (id, num) values (''5'', ''1'');
insert into Logs (id, num) values (''6'', ''2'');
insert into Logs (id, num) values (''7'', ''2'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1052, 1, 'Create table If Not Exists Employee (id int, name varchar(255), salary int, departmentId int);
Create table If Not Exists Department (id int, name varchar(255));
Truncate table Employee;
insert into Employee (id, name, salary, departmentId) values (''1'', ''Joe'', ''70000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''2'', ''Jim'', ''90000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''3'', ''Henry'', ''80000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''4'', ''Sam'', ''60000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''5'', ''Max'', ''90000'', ''1'');
Truncate table Department;
insert into Department (id, name) values (''1'', ''IT'');
insert into Department (id, name) values (''2'', ''Sales'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1053, 1, 'Create table If Not Exists Employee (id int, name varchar(255), department varchar(255), managerId int);
Truncate table Employee;
insert into Employee (id, name, department, managerId) values (''101'', ''John'', ''A'', NULL);
insert into Employee (id, name, department, managerId) values (''102'', ''Dan'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''103'', ''James'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''104'', ''Amy'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''105'', ''Anne'', ''A'', ''101'');
insert into Employee (id, name, department, managerId) values (''106'', ''Ron'', ''B'', ''101'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1054, 1, 'Create table If Not Exists Tree (id int, p_id int);
Truncate table Tree;
insert into Tree (id, p_id) values (''1'', NULL);
insert into Tree (id, p_id) values (''2'', ''1'');
insert into Tree (id, p_id) values (''3'', ''1'');
insert into Tree (id, p_id) values (''4'', ''2'');
insert into Tree (id, p_id) values (''5'', ''2'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1055, 1, 'Create table If Not Exists Seat (id int, student varchar(255));
Truncate table Seat;
insert into Seat (id, student) values (''1'', ''Abbot'');
insert into Seat (id, student) values (''2'', ''Doris'');
insert into Seat (id, student) values (''3'', ''Emerson'');
insert into Seat (id, student) values (''4'', ''Green'');
insert into Seat (id, student) values (''5'', ''Jeames'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1056, 1, 'Create table If Not Exists Customer (customer_id int, product_key int);
Create table Product (product_key int);
Truncate table Customer;
insert into Customer (customer_id, product_key) values (''1'', ''5'');
insert into Customer (customer_id, product_key) values (''2'', ''6'');
insert into Customer (customer_id, product_key) values (''3'', ''5'');
insert into Customer (customer_id, product_key) values (''3'', ''6'');
insert into Customer (customer_id, product_key) values (''1'', ''6'');
Truncate table Product;
insert into Product (product_key) values (''5'');
insert into Product (product_key) values (''6'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1057, 1, 'Create table If Not Exists Activity (player_id int, device_id int, event_date date, games_played int);
Truncate table Activity;
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-01'', ''5'');
insert into Activity (player_id, device_id, event_date, games_played) values (''1'', ''2'', ''2016-03-02'', ''6'');
insert into Activity (player_id, device_id, event_date, games_played) values (''2'', ''3'', ''2017-06-25'', ''1'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''1'', ''2016-03-02'', ''0'');
insert into Activity (player_id, device_id, event_date, games_played) values (''3'', ''4'', ''2018-07-03'', ''5'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1058, 1, 'Create Table If Not Exists Insurance (pid int, tiv_2015 float, tiv_2016 float, lat float, lon float);
Truncate table Insurance;
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''1'', ''10'', ''5'', ''10'', ''10'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''2'', ''20'', ''20'', ''20'', ''20'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''3'', ''10'', ''30'', ''20'', ''20'');
insert into Insurance (pid, tiv_2015, tiv_2016, lat, lon) values (''4'', ''10'', ''40'', ''40'', ''40'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1059, 1, 'Create table If Not Exists RequestAccepted (requester_id int not null, accepter_id int null, accept_date date null);
Truncate table RequestAccepted;
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''1'', ''2'', ''2016/06/03'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''1'', ''3'', ''2016/06/08'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''2'', ''3'', ''2016/06/08'');
insert into RequestAccepted (requester_id, accepter_id, accept_date) values (''3'', ''4'', ''2016/06/09'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1060, 1, 'Create table If Not Exists Users (user_id int, join_date date, favorite_brand varchar(10));
Create table If Not Exists Orders (order_id int, order_date date, item_id int, buyer_id int, seller_id int);
Create table If Not Exists Items (item_id int, item_brand varchar(10));
Truncate table Users;
insert into Users (user_id, join_date, favorite_brand) values (''1'', ''2018-01-01'', ''Lenovo'');
insert into Users (user_id, join_date, favorite_brand) values (''2'', ''2018-02-09'', ''Samsung'');
insert into Users (user_id, join_date, favorite_brand) values (''3'', ''2018-01-19'', ''LG'');
insert into Users (user_id, join_date, favorite_brand) values (''4'', ''2018-05-21'', ''HP'');
Truncate table Orders;
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''1'', ''2019-08-01'', ''4'', ''1'', ''2'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''2'', ''2018-08-02'', ''2'', ''1'', ''3'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''3'', ''2019-08-03'', ''3'', ''2'', ''3'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''4'', ''2018-08-04'', ''1'', ''4'', ''2'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''5'', ''2018-08-04'', ''1'', ''3'', ''4'');
insert into Orders (order_id, order_date, item_id, buyer_id, seller_id) values (''6'', ''2019-08-05'', ''2'', ''2'', ''4'');
Truncate table Items;
insert into Items (item_id, item_brand) values (''1'', ''Samsung'');
insert into Items (item_id, item_brand) values (''2'', ''Lenovo'');
insert into Items (item_id, item_brand) values (''3'', ''LG'');
insert into Items (item_id, item_brand) values (''4'', ''HP'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1061, 1, 'Create table If Not Exists Products (product_id int, new_price int, change_date date);
Truncate table Products;
insert into Products (product_id, new_price, change_date) values (''1'', ''20'', ''2019-08-14'');
insert into Products (product_id, new_price, change_date) values (''2'', ''50'', ''2019-08-14'');
insert into Products (product_id, new_price, change_date) values (''1'', ''30'', ''2019-08-15'');
insert into Products (product_id, new_price, change_date) values (''1'', ''35'', ''2019-08-16'');
insert into Products (product_id, new_price, change_date) values (''2'', ''65'', ''2019-08-17'');
insert into Products (product_id, new_price, change_date) values (''3'', ''20'', ''2019-08-18'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1062, 1, 'Create table If Not Exists Transactions (id int, country varchar(4), state enum(''approved'', ''declined''), amount int, trans_date date);
Truncate table Transactions;
insert into Transactions (id, country, state, amount, trans_date) values (''121'', ''US'', ''approved'', ''1000'', ''2018-12-18'');
insert into Transactions (id, country, state, amount, trans_date) values (''122'', ''US'', ''declined'', ''2000'', ''2018-12-19'');
insert into Transactions (id, country, state, amount, trans_date) values (''123'', ''US'', ''approved'', ''2000'', ''2019-01-01'');
insert into Transactions (id, country, state, amount, trans_date) values (''124'', ''DE'', ''approved'', ''2000'', ''2019-01-07'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1063, 1, 'Create table If Not Exists Customer (customer_id int, name varchar(20), visited_on date, amount int);
Truncate table Customer;
insert into Customer (customer_id, name, visited_on, amount) values (''1'', ''Jhon'', ''2019-01-01'', ''100'');
insert into Customer (customer_id, name, visited_on, amount) values (''2'', ''Daniel'', ''2019-01-02'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''3'', ''Jade'', ''2019-01-03'', ''120'');
insert into Customer (customer_id, name, visited_on, amount) values (''4'', ''Khaled'', ''2019-01-04'', ''130'');
insert into Customer (customer_id, name, visited_on, amount) values (''5'', ''Winston'', ''2019-01-05'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''6'', ''Elvis'', ''2019-01-06'', ''140'');
insert into Customer (customer_id, name, visited_on, amount) values (''7'', ''Anna'', ''2019-01-07'', ''150'');
insert into Customer (customer_id, name, visited_on, amount) values (''8'', ''Maria'', ''2019-01-08'', ''80'');
insert into Customer (customer_id, name, visited_on, amount) values (''9'', ''Jaze'', ''2019-01-09'', ''110'');
insert into Customer (customer_id, name, visited_on, amount) values (''1'', ''Jhon'', ''2019-01-10'', ''130'');
insert into Customer (customer_id, name, visited_on, amount) values (''3'', ''Jade'', ''2019-01-10'', ''150'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1064, 1, 'Create table If Not Exists Movies (movie_id int, title varchar(30));
Create table If Not Exists Users (user_id int, name varchar(30));
Create table If Not Exists MovieRating (movie_id int, user_id int, rating int, created_at date);
Truncate table Movies;
insert into Movies (movie_id, title) values (''1'', ''Avengers'');
insert into Movies (movie_id, title) values (''2'', ''Frozen 2'');
insert into Movies (movie_id, title) values (''3'', ''Joker'');
Truncate table Users;
insert into Users (user_id, name) values (''1'', ''Daniel'');
insert into Users (user_id, name) values (''2'', ''Monica'');
insert into Users (user_id, name) values (''3'', ''Maria'');
insert into Users (user_id, name) values (''4'', ''James'');
Truncate table MovieRating;
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''1'', ''3'', ''2020-01-12'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''2'', ''4'', ''2020-02-11'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''3'', ''2'', ''2020-02-12'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''1'', ''4'', ''1'', ''2020-01-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''1'', ''5'', ''2020-02-17'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''2'', ''2'', ''2020-02-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''2'', ''3'', ''2'', ''2020-03-01'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''3'', ''1'', ''3'', ''2020-02-22'');
insert into MovieRating (movie_id, user_id, rating, created_at) values (''3'', ''2'', ''4'', ''2020-02-25'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1065, 1, 'Create Table If Not Exists Stocks (stock_name varchar(15), operation ENUM(''Sell'', ''Buy''), operation_day int, price int);
Truncate table Stocks;
insert into Stocks (stock_name, operation, operation_day, price) values (''Leetcode'', ''Buy'', ''1'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''2'', ''10'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Leetcode'', ''Sell'', ''5'', ''9000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Handbags'', ''Buy'', ''17'', ''30000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''3'', ''1010'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''4'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''5'', ''500'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Buy'', ''6'', ''1000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Handbags'', ''Sell'', ''29'', ''7000'');
insert into Stocks (stock_name, operation, operation_day, price) values (''Corona Masks'', ''Sell'', ''10'', ''10000'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1066, 1, 'Create table If Not Exists Signups (user_id int, time_stamp datetime);
Create table If Not Exists Confirmations (user_id int, time_stamp datetime, action ENUM(''confirmed'',''timeout''));
Truncate table Signups;
insert into Signups (user_id, time_stamp) values (''3'', ''2020-03-21 10:16:13'');
insert into Signups (user_id, time_stamp) values (''7'', ''2020-01-04 13:57:59'');
insert into Signups (user_id, time_stamp) values (''2'', ''2020-07-29 23:09:44'');
insert into Signups (user_id, time_stamp) values (''6'', ''2020-12-09 10:39:37'');
Truncate table Confirmations;
insert into Confirmations (user_id, time_stamp, action) values (''3'', ''2021-01-06 03:30:46'', ''timeout'');
insert into Confirmations (user_id, time_stamp, action) values (''3'', ''2021-07-14 14:00:00'', ''timeout'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-12 11:57:29'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-13 12:58:28'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''7'', ''2021-06-14 13:59:27'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''2'', ''2021-01-22 00:00:00'', ''confirmed'');
insert into Confirmations (user_id, time_stamp, action) values (''2'', ''2021-02-28 23:59:59'', ''timeout'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1067, 1, 'Create table If Not Exists Sales (sale_id int, product_id int, year int, quantity int, price int);
Truncate table Sales;
insert into Sales (sale_id, product_id, year, quantity, price) values (''1'', ''100'', ''2008'', ''10'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''2'', ''100'', ''2009'', ''12'', ''5000'');
insert into Sales (sale_id, product_id, year, quantity, price) values (''7'', ''200'', ''2011'', ''15'', ''9000'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1068, 1, 'Create table If Not Exists Department (id int, revenue int, month varchar(5));
Truncate table Department;
insert into Department (id, revenue, month) values (''1'', ''8000'', ''Jan'');
insert into Department (id, revenue, month) values (''2'', ''9000'', ''Jan'');
insert into Department (id, revenue, month) values (''3'', ''10000'', ''Feb'');
insert into Department (id, revenue, month) values (''1'', ''7000'', ''Feb'');
insert into Department (id, revenue, month) values (''1'', ''6000'', ''Mar'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1069, 1, 'Create table If Not Exists Queue (person_id int, person_name varchar(30), weight int, turn int);
Truncate table Queue;
insert into Queue (person_id, person_name, weight, turn) values (''5'', ''Alice'', ''250'', ''1'');
insert into Queue (person_id, person_name, weight, turn) values (''4'', ''Bob'', ''175'', ''5'');
insert into Queue (person_id, person_name, weight, turn) values (''3'', ''Alex'', ''350'', ''2'');
insert into Queue (person_id, person_name, weight, turn) values (''6'', ''John Cena'', ''400'', ''3'');
insert into Queue (person_id, person_name, weight, turn) values (''1'', ''Winston'', ''500'', ''6'');
insert into Queue (person_id, person_name, weight, turn) values (''2'', ''Marie'', ''200'', ''4'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1070, 1, 'Create table If Not Exists Delivery (delivery_id int, customer_id int, order_date date, customer_pref_delivery_date date);
Truncate table Delivery;
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''1'', ''1'', ''2019-08-01'', ''2019-08-02'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''2'', ''2'', ''2019-08-02'', ''2019-08-02'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''3'', ''1'', ''2019-08-11'', ''2019-08-12'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''4'', ''3'', ''2019-08-24'', ''2019-08-24'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''5'', ''3'', ''2019-08-21'', ''2019-08-22'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''6'', ''2'', ''2019-08-11'', ''2019-08-13'');
insert into Delivery (delivery_id, customer_id, order_date, customer_pref_delivery_date) values (''7'', ''4'', ''2019-08-09'', ''2019-08-09'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1071, 1, 'Create table If Not Exists Employee (id int, name varchar(255), salary int, departmentId int);
Create table If Not Exists Department (id int, name varchar(255));
Truncate table Employee;
insert into Employee (id, name, salary, departmentId) values (''1'', ''Joe'', ''85000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''2'', ''Henry'', ''80000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''3'', ''Sam'', ''60000'', ''2'');
insert into Employee (id, name, salary, departmentId) values (''4'', ''Max'', ''90000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''5'', ''Janet'', ''69000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''6'', ''Randy'', ''85000'', ''1'');
insert into Employee (id, name, salary, departmentId) values (''7'', ''Will'', ''70000'', ''1'');
Truncate table Department;
insert into Department (id, name) values (''1'', ''IT'');
insert into Department (id, name) values (''2'', ''Sales'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1072, 1, 'Create table If Not Exists Trips (id int, client_id int, driver_id int, city_id int, status ENUM(''completed'', ''cancelled_by_driver'', ''cancelled_by_client''), request_at varchar(50));
Create table If Not Exists Users (users_id int, banned varchar(50), role ENUM(''client'', ''driver'', ''partner''));
Truncate table Trips;
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''1'', ''1'', ''10'', ''1'', ''completed'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''2'', ''2'', ''11'', ''1'', ''cancelled_by_driver'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''3'', ''3'', ''12'', ''6'', ''completed'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''4'', ''4'', ''13'', ''6'', ''cancelled_by_client'', ''2013-10-01'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''5'', ''1'', ''10'', ''1'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''6'', ''2'', ''11'', ''6'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''7'', ''3'', ''12'', ''6'', ''completed'', ''2013-10-02'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''8'', ''2'', ''12'', ''12'', ''completed'', ''2013-10-03'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''9'', ''3'', ''10'', ''12'', ''completed'', ''2013-10-03'');
insert into Trips (id, client_id, driver_id, city_id, status, request_at) values (''10'', ''4'', ''13'', ''12'', ''cancelled_by_driver'', ''2013-10-03'');
Truncate table Users;
insert into Users (users_id, banned, role) values (''1'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''2'', ''Yes'', ''client'');
insert into Users (users_id, banned, role) values (''3'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''4'', ''No'', ''client'');
insert into Users (users_id, banned, role) values (''10'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''11'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''12'', ''No'', ''driver'');
insert into Users (users_id, banned, role) values (''13'', ''No'', ''driver'')');
INSERT INTO problem_testcase (problem_id, ordinal, init_sql) VALUES
(1073, 1, 'Create table If Not Exists Stadium (id int, visit_date DATE NULL, people int);
Truncate table Stadium;
insert into Stadium (id, visit_date, people) values (''1'', ''2017-01-01'', ''10'');
insert into Stadium (id, visit_date, people) values (''2'', ''2017-01-02'', ''109'');
insert into Stadium (id, visit_date, people) values (''3'', ''2017-01-03'', ''150'');
insert into Stadium (id, visit_date, people) values (''4'', ''2017-01-04'', ''99'');
insert into Stadium (id, visit_date, people) values (''5'', ''2017-01-05'', ''145'');
insert into Stadium (id, visit_date, people) values (''6'', ''2017-01-06'', ''1455'');
insert into Stadium (id, visit_date, people) values (''7'', ''2017-01-07'', ''199'');
insert into Stadium (id, visit_date, people) values (''8'', ''2017-01-09'', ''188'')');

SET FOREIGN_KEY_CHECKS = 1;
