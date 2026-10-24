-- Условие (классическая формулировка):

-- Дана таблица Sales:

-- Column Name	Type
-- sale_id	int
-- product_id	int
-- sale_date	date
-- quantity	int
-- price	int
-- Нужно для каждого месяца определить товар с максимальной выручкой (quantity * price) и вернуть: месяц, product_id, выручку. Если у нескольких товаров одинаковая максимальная выручка — вернуть все такие товары.

WITH monthly_revenue AS (
    SELECT product_id,
           strftime('%m', sale_date) AS month,
           SUM(quantity * price) AS total_revenue
    FROM Sales
    GROUP BY product_id, strftime('%m', sale_date)
),
ranked AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_revenue DESC) AS rnk
    FROM monthly_revenue
)
SELECT month, product_id, total_revenue
FROM ranked
WHERE rnk = 1;

-- через подзапросы 

SELECT month, product_id, total_revenue
FROM (SELECT *,
           DENSE_RANK() OVER (PARTITION BY month ORDER BY total_revenue DESC) AS rnk
    FROM (SELECT product_id,
           strftime('%m', sale_date) AS month,
           SUM(quantity * price) AS total_revenue
    FROM Sales
    GROUP BY product_id, strftime('%m', sale_date)) as monthly_revenue) as ranked
WHERE rnk = 1


-- Задача дня:

-- Найти пользователей, у которых средний чек выше среднего чека по всем пользователям, и вывести их средний чек вместе с количеством заказов.

-- Это задача, где нужно совместить CTE (или подзапрос в FROM) для агрегации по пользователям и подзапрос в WHERE для сравнения со средним по всей таблице.

-- Условие:

-- Дана таблица Orders:

-- Column Name	Type
-- order_id	int
-- user_id	int
-- order_date	date
-- amount	int
-- Нужно вернуть user_id, средний чек пользователя (avg_amount) и количество его заказов (order_count) для тех пользователей, у которых avg_amount строго больше среднего чека по всем пользователям.

-- Отсортировать по avg_amount по убыванию.

with avg_users as (
  select user_id, avg(amount) as avg_amount, count(*) as order_count
  from orders
  group by user_id)
select user_id, avg_amount, order_count
from avg_users
where avg_amount > (select avg(avg_amount) from avg_users)
order by avg_amount desc

-- Ту же логику можно выразить без подзапроса в WHERE:

WITH avg_users AS (
    SELECT user_id, AVG(amount) AS avg_amount, COUNT(*) AS order_count
    FROM Orders
    GROUP BY user_id
)
SELECT user_id, avg_amount, order_count
FROM (
    SELECT *,
           AVG(avg_amount) OVER () AS overall_avg
    FROM avg_users
) AS t
WHERE avg_amount > overall_avg
ORDER BY avg_amount DESC;

-- Задача дня:

-- Найти пользователей, у которых была серия из 3+ дней подряд с ежедневной выручкой выше их собственного среднего дневного значения, и вывести начало серии, конец серии и суммарную выручку за серию.

-- Это задача, где смешиваются все инструменты недель 1–2: агрегация, LAG, SUM OVER, ранжирование и CTE.

-- Условие:

-- Дана таблица Purchases:

-- Column Name	Type
-- purchase_id	int
-- user_id	int
-- purchase_date	date
-- amount	int
-- Нужно для каждого пользователя:

-- Посчитать его среднюю дневную выручку (среднее по дням, где были покупки).

-- Найти непрерывные серии дней, в каждом из которых дневная выручка была строго выше этого среднего.

-- Оставить только серии длиной 3+ дня.

-- Вывести: user_id, streak_start (первый день серии), streak_end (последний день), streak_revenue (суммарная выручка за серию).

with unique_purchase as (select user_id, purchase_date, sum(amount) as amount from purchases group by user_id, purchase_date),

prev_avg as (SELECT *, avg(amount) over (partition by user_id) as user_avg
FROM unique_purchase),

filtered as (select * FROM PREV_AVG
where amount > user_avg),

marked as (select *,
case
  when (lag(purchase_date) over (partition by user_id order by purchase_date) is null) or (julianday(purchase_date) - julianday(lag(purchase_date) over (partition by user_id order by purchase_date)) > 1)
  then 1 
    else 0
  end as series
from filtered),

streaked as (select user_id, purchase_date, amount, sum(series) over (partition by user_id order by purchase_date) as streak from marked)

SELECT user_id,
       MIN(purchase_date) AS streak_start,
       MAX(purchase_date) AS streak_end,
       SUM(amount) AS streak_revenue,
       COUNT(*) AS days_in_streak
FROM streaked
GROUP BY user_id, streak
HAVING COUNT(*) >= 3
ORDER BY user_id, streak_start;
