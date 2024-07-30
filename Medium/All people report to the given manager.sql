-- Question 55
-- Table: Employees

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | employee_id   | int     |
-- | employee_name | varchar |
-- | manager_id    | int     |
-- +---------------+---------+
-- employee_id is the primary key for this table.
-- Each row of this table indicates that the employee with ID employee_id and name employee_name reports his
-- work to his/her direct manager with manager_id
-- The head of the company is the employee with employee_id = 1.
 

-- Write an SQL query to find employee_id of all employees that directly or indirectly report their work to the head of the company.

-- The indirect relation between managers will not exceed 3 managers as the company is small.

-- Return result table in any order without duplicates.

-- The query result format is in the following example:

-- Employees table:
-- +-------------+---------------+------------+
-- | employee_id | employee_name | manager_id |
-- +-------------+---------------+------------+
-- | 1           | Boss          | 1          |
-- | 3           | Alice         | 3          |
-- | 2           | Bob           | 1          |
-- | 4           | Daniel        | 2          |
-- | 7           | Luis          | 4          |
-- | 8           | Jhon          | 3          |
-- | 9           | Angela        | 8          |
-- | 77          | Robert        | 1          |
-- +-------------+---------------+------------+

-- Result table:
-- +-------------+
-- | employee_id |
-- +-------------+
-- | 2           |
-- | 77          |
-- | 4           |
-- | 7           |
-- +-------------+

-- The head of the company is the employee with employee_id 1.
-- The employees with employee_id 2 and 77 report their work directly to the head of the company.
-- The employee with employee_id 4 report his work indirectly to the head of the company 4 --> 2 --> 1. 
-- The employee with employee_id 7 report his work indirectly to the head of the company 7 --> 4 --> 2 --> 1.
-- The employees with employee_id 3, 8 and 9 don't report their work to head of company directly or indirectly.

-- Solution2
select distinct e1.employee_id 
from employees e1 
inner join employees e2 on e1.manager_id = e2.id 
inner join employees e3 on e2.manager_id = e3.id
inner join employees e4 on e3.manager_id = e4.id
where 1 in (e1.manager_id, e2.manager_id, e3.manager_id, e4.manager_id)

-- Solution 3
WITH RECURSIVE ReportTree AS (
    -- Base case: start with the head of the company
    SELECT 
        employee_id,
        manager_id
    FROM Employees
    WHERE employee_id = 1
    UNION ALL
    -- Recursive case: find employees who report to the current set of employees
    SELECT 
        e.employee_id,
        e.manager_id
    FROM Employees e
    INNER JOIN ReportTree rt ON e.manager_id = rt.employee_id
)
SELECT DISTINCT employee_id
FROM ReportTree
WHERE employee_id != 1;


-- Solution
select employee_id
from employees
where manager_id = 1 and employee_id != 1
union
select employee_id
from employees
where manager_id = any (select employee_id
from employees
where manager_id = 1 and employee_id != 1)
union
select employee_id
from employees
where manager_id = any (select employee_id
from employees
where manager_id = any (select employee_id
from employees
where manager_id = 1 and employee_id != 1))
