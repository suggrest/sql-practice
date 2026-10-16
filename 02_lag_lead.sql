-- leetcode #180

-- Table: Logs

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | num         | varchar |
-- +-------------+---------+
-- In SQL, id is the primary key for this table.
-- id is an autoincrement column starting from 1.
 

-- Find all numbers that appear at least three times consecutively.

-- Return the result table in any order.

-- The result format is in the following example.

select distinct num as ConsecutiveNums from
(select num,
       lag(num) over (order by id) as prev_num,
       lead(num) over (order by id) as next_num
from logs as l) as tmp
where num = prev_num and num = next_num

-- distinct Только потому, что требовалось, чтобы каждое число в выводе было только один раз, даже если условие выполняется несколько раз

-- можно сделать через самоджойны

SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
JOIN Logs l2
    ON l1.id = l2.id - 1
JOIN Logs l3
    ON l2.id = l3.id - 1
WHERE l1.num = l2.num
  AND l2.num = l3.num;


--leetcode #197

-- Table: Weather

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | id            | int     |
-- | recordDate    | date    |
-- | temperature   | int     |
-- +---------------+---------+
-- id is the column with unique values for this table.
-- There are no different rows with the same recordDate.
-- This table contains information about the temperature on a certain day.
 

-- Write a solution to find all dates' id with higher temperatures compared to its previous dates (yesterday).

-- Return the result table in any order.

select id from
(select *, 
lag(temperature) over (order by recordDate) as prevDay,
lag(recordDate) over (order by recordDate) as prevDate
from weather) as tmp
where (temperature > prevDay) and (datediff(recordDate, prevDate) = 1)

-- можно сделать через самоджойн

SELECT 
    w1.id
FROM 
    Weather w1
JOIN 
    Weather w2 ON DATEDIFF(w1.recordDate, w2.recordDate) = 1
WHERE 
    w1.temperature > w2.temperature;

-- leetcode #1369

-- Таблица: UserActivity

-- Column Name	Type
-- username	varchar
-- activity	varchar
-- startDate	Date
-- endDate	Date
-- Таблица содержит информацию об активности каждого пользователя за период. У одного пользователя не может быть двух активностей одновременно.

-- Задача: Написать SQL-запрос, который показывает вторую по свежести активность каждого пользователя.

-- Особое условие: Если у пользователя только одна активность — вернуть именно её .

select username, activity, startDate, endDate
from (select *, 
       dense_rank() over (partition by username order by endDate desc) as rnk, 
       count(*) over(partition by username) as cnt
from UserActivity) as tmp
where (rnk = 2) or (cnt < 2)

-- обратить внимание на подсчет общего количества активностей без группировки и размазываением по строкам
