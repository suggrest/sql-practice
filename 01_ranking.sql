--leetcode #178

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | score       | decimal |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table contains the score of a game. Score is a floating point value with two decimal places.
 

-- Write a solution to find the rank of the scores. The ranking should be calculated according to the following rules:

-- The scores should be ranked from the highest to the lowest.
-- If there is a tie between two scores, both should have the same ranking.
-- After a tie, the next ranking number should be the next consecutive integer value. In other words, there should be no holes between ranks.
-- Return the result table ordered by score in descending order.

select score,
dense_rank() over (order by score desc) as 'rank'
from scores

-- обратить внимание - часть Partition by нужна только если ранжирование нужно разделить на подмножества, внутри которых в дальнейшем и будет работаь функция ранжирования



--leetcode #184

-- Table: Employee

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | id           | int     |
-- | name         | varchar |
-- | salary       | int     |
-- | departmentId | int     |
-- +--------------+---------+
-- id is the primary key (column with unique values) for this table.
-- departmentId is a foreign key (reference columns) of the ID from the Department table.
-- Each row of this table indicates the ID, name, and salary of an employee. It also contains the ID of their department.
 

-- Table: Department

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | name        | varchar |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table. It is guaranteed that department name is not NULL.
-- Each row of this table indicates the ID of a department and its name.
 

-- Write a solution to find employees who have the highest salary in each of the departments.

-- Return the result table in any order.

-- решение без ранжирующих оконных функций, через подзапрос в where

select d.name Department, e.name Employee, salary Salary
from employee as e inner join department as d on e.departmentId = d.id 
where (departmentId, salary) in 
    (select departmentId, max(salary)
     from employee
     group by departmentId)

-- решение с ранжирующей функцией через подзапрос в from

select department, employee, salary
from(
    select d.name as 'Department', e.name as 'Employee', salary,
           dense_rank() over (partition by d.name order by salary desc) as 'rank'
    from employee as e inner join department as d on e.departmentId = d.id) as tmp
where tmp.rank = 1


-- leetcode #185

-- Table: Employee

-- +--------------+---------+
-- | Column Name  | Type    |
-- +--------------+---------+
-- | id           | int     |
-- | name         | varchar |
-- | salary       | int     |
-- | departmentId | int     |
-- +--------------+---------+
-- id is the primary key (column with unique values) for this table.
-- departmentId is a foreign key (reference column) of the ID from the Department table.
-- Each row of this table indicates the ID, name, and salary of an employee. It also contains the ID of their department.
 

-- Table: Department

-- +-------------+---------+
-- | Column Name | Type    |
-- +-------------+---------+
-- | id          | int     |
-- | name        | varchar |
-- +-------------+---------+
-- id is the primary key (column with unique values) for this table.
-- Each row of this table indicates the ID of a department and its name.
 

-- A company's executives are interested in seeing who earns the most money in each of the company's departments. A high earner in a department is an employee who has a salary in the top three unique salaries for that department.

-- Write a solution to find the employees who are high earners in each of the departments.

-- Return the result table in any order.

select department, employee, salary from(
select d.name as department, e.name as employee, salary,
       dense_rank() over (partition by departmentId order by salary desc) as rnk
from employee as e inner join department as d on e.departmentId = d.id) as tmp
where rnk<=3

-- никаких пояснений по решению писать смысла не имеет, то же самое что и в предыдущей задаче, только число другое
-- нельзя использовать агрегирующие функции, так как нужно найти несколько позиций, нельзя использовать rank из за пропуска позиций
