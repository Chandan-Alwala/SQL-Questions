-- Question 73
-- Table: Actions

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | user_id       | int     |
-- | post_id       | int     |
-- | action_date   | date    |
-- | action        | enum    |
-- | extra         | varchar |
-- +---------------+---------+
-- There is no primary key for this table, it may have duplicate rows.
-- The action column is an ENUM type of ('view', 'like', 'reaction', 'comment', 'report', 'share').
-- The extra column has optional information about the action such as a reason for report or a type of reaction. 
-- Table: Removals

-- +---------------+---------+
-- | Column Name   | Type    |
-- +---------------+---------+
-- | post_id       | int     |
-- | remove_date   | date    | 
-- +---------------+---------+
-- post_id is the primary key of this table.
-- Each row in this table indicates that some post was removed as a result of being reported or as a result of an admin review.
 

-- Write an SQL query to find the average for daily percentage of posts that got removed after being reported as spam, rounded to 2 decimal places.

-- The query result format is in the following example:

-- Actions table:
-- +---------+---------+-------------+--------+--------+
-- | user_id | post_id | action_date | action | extra  |
-- +---------+---------+-------------+--------+--------+
-- | 1       | 1       | 2019-07-01  | view   | null   |
-- | 1       | 1       | 2019-07-01  | like   | null   |
-- | 1       | 1       | 2019-07-01  | share  | null   |
-- | 2       | 2       | 2019-07-04  | view   | null   |
-- | 2       | 2       | 2019-07-04  | report | spam   |
-- | 3       | 4       | 2019-07-04  | view   | null   |
-- | 3       | 4       | 2019-07-04  | report | spam   |
-- | 4       | 3       | 2019-07-02  | view   | null   |
-- | 4       | 3       | 2019-07-02  | report | spam   |
-- | 5       | 2       | 2019-07-03  | view   | null   |
-- | 5       | 2       | 2019-07-03  | report | racism |
-- | 5       | 5       | 2019-07-03  | view   | null   |
-- | 5       | 5       | 2019-07-03  | report | racism |
-- +---------+---------+-------------+--------+--------+

-- Removals table:
-- +---------+-------------+
-- | post_id | remove_date |
-- +---------+-------------+
-- | 2       | 2019-07-20  |
-- | 3       | 2019-07-18  |
-- +---------+-------------+

-- Result table:
-- +-----------------------+
-- | average_daily_percent |
-- +-----------------------+
-- | 75.00                 |
-- +-----------------------+
-- The percentage for 2019-07-04 is 50% because only one post of two spam reported posts was removed.
-- The percentage for 2019-07-02 is 100% because one post was reported as spam and it was removed.
-- The other days had no spam reports so the average is (50 + 100) / 2 = 75%
-- Note that the output is only one number and that we do not care about the remove dates.

-- Solution2
WITH spam_reports AS (
    SELECT 
        action_date,
        post_id
    FROM 
        Actions
    WHERE 
        action = 'report' 
        AND extra = 'spam'
),
daily_stats AS (
    SELECT 
        sr.action_date,
        COUNT(sr.post_id) AS reported_posts,
        COUNT(r.post_id) AS removed_posts
    FROM 
        spam_reports sr
    LEFT JOIN 
        Removals r
    ON 
        sr.post_id = r.post_id
    GROUP BY 
        sr.action_date
)
SELECT 
    ROUND(AVG(CASE 
                WHEN reported_posts = 0 THEN 0
                ELSE (removed_posts * 100.0) / reported_posts 
              END), 2) AS average_daily_percent
FROM 
    daily_stats;



-- Solution
with t1 as(
select a.action_date, (count(distinct r.post_id)+0.0)/(count(distinct a.post_id)+0.0) as result
from (select action_date, post_id
from actions
where extra = 'spam' and action = 'report') a
left join
removals r
on a.post_id = r.post_id
group by a.action_date)

select round(avg(t1.result)*100,2) as  average_daily_percent
from t1
