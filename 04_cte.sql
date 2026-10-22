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

