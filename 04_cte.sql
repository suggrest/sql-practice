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
