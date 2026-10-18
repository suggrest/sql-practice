-- leetcode #1204

-- Table: Queue

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | person_id   | int     |
-- | person_name | varchar |
-- | weight      | int     |
-- | turn        | int     |
-- +-------------+---------+
-- person_id column contains unique values.
-- This table has the information about all people waiting for a bus.
-- The person_id and turn columns will contain all numbers from 1 to n, where n is the number of rows in the table.
-- turn determines the order of which the people will board the bus, where turn=1 denotes the first person to board and turn=n denotes the last person to board.
-- weight is the weight of the person in kilograms.
 

-- There is a queue of people waiting to board a bus. However, the bus has a weight limit of 1000 kilograms, so there may be some people who cannot board.

-- Write a solution to find the person_name of the last person that can fit on the bus without exceeding the weight limit. The test cases are generated such that the first person does not exceed the weight limit.

-- Note that only one person can board the bus at any given turn.

select person_name from
(select *, sum(weight) over (order by turn) as wght
from queue) as tmp
where wght <= 1000
order by turn desc
limit 1

-- leetcode #1321

-- Table: Customer

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | customer_id   | int     |
-- | name          | varchar |
-- | visited_on    | date    |
-- | amount        | int     |
-- +---------------+---------+
-- In SQL,(customer_id, visited_on) is the primary key for this table.
-- This table contains data about customer transactions in a restaurant.
-- visited_on is the date on which the customer with ID (customer_id) has visited the restaurant.
-- amount is the total paid by a customer.
 

-- You are the restaurant owner and you want to analyze a possible expansion (there will be at least one customer every day).

-- Compute the moving average of how much the customer paid in a seven days window (i.e., current day + 6 days before). average_amount should be rounded to two decimal places.

-- Return the result table ordered by visited_on in ascending order.

select visited_on, amount, average_amount
from (select visited_on,
       sum(amount) over (order by visited_on rows between 6 preceding and current row) as amount,
       round(avg(amount) over (order by visited_on rows between 6 preceding and current row),2) as average_amount,
       row_number() over (order by visited_on) as row_rank
from
(select visited_on, sum(amount) as amount
from customer
group by visited_on) as tmp) as tmp1
where row_rank > 6


-- Задача дня:

-- Задача на streaks — найти пользователей, которые заходили как минимум 3 дня подряд.

-- Условие:

-- Дана таблица Logins:

-- Column Name	Type
-- user_id	int
-- login_date	date
-- Нужно найти всех пользователей, которые заходили как минимум 3 дня подряд. Вернуть user_id без дубликатов.

select distinct user_id from
(select user_id, id, count(*) as len
from
(select user_id, login_date,
       sum(series) over (partition by user_id order by login_date) as id
from
    (select user_id, login_date,
     case
       when (prev_date is null) or (julianday(login_date) - julianday(prev_date) > 1)
         then 1
       else 0
     end as series
     from
        (select *, lag(login_date) over (partition by user_id order by login_date) as prev_date
         from
            (select distinct user_id, login_date
             from logins) as dedup) as prev_table) as mark)
group by user_id, id) as streak_len
where len > 2

-- В SQLite нет DATEDIFF, поэтому разницу в днях считают через JULIANDAY(date1) - JULIANDAY(date2). В PostgreSQL было бы login_date - LAG(...). Это стоит держать в голове, если будете проверять в DB Fiddle на SQLite.

-- 1. SELECT DISTINCT * — рискованно, если в таблице больше двух колонок.
-- В текущей схеме Logins только user_id и login_date, поэтому DISTINCT * работает. Но если бы в таблице были другие поля (например, device_id или session_id), DISTINCT * не убрал бы дубликаты по дате — строки отличались бы по другим полям. Правильнее явно указать: SELECT DISTINCT user_id, login_date.
-- 2. COUNT(*) считает строки, а не уникальные дни.
-- После дедупликации каждая строка — это уникальный день для пользователя, поэтому COUNT(*) корректен. Но если бы дедупликации не было, COUNT(*) посчитал бы входы, а не дни. Стоит проговорить на собеседовании, что дедупликация — обязательный шаг перед подсчётом длины серии.
-- 3. len > 2 — это «как минимум 3 дня».
-- Формулировка «ровно 3» была бы len = 3, «ровно 5» — len = 5. У вас > 2 соответствует условию «как минимум 3», это правильно для текущей задачи.
-- 4. SELECT user_id без DISTINCT во внешнем запросе.
-- Если у пользователя несколько серий длиной 3+, он появится в результате несколько раз. В условии сказано «вернуть user_id без дубликатов», поэтому стоит добавить DISTINCT во внешний SELECT. На данных из примера у user_id = 1 только одна серия, поэтому дубликата не будет — но на других данных это может выстрелить.
-- 5. ORDER BY login_date внутри окна SUM — обязателен.
-- Он задаёт порядок накопления серий. Без него SUM OVER использовал бы произвольный порядок, и номера серий могли бы присваиваться неверно. У вас он есть — это правильно.
