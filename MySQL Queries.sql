create database coffee_database;
use coffee_database;
SELECT 
    *
FROM
    coffee_table;

-- data cleaning

UPDATE coffee_table 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

alter table coffee_table 
modify column transaction_date date;

UPDATE coffee_table 
SET 
    transaction_time = STR_TO_DATE(transaction_time, '%H:%m:%s');

alter table coffee_table 
modify column transaction_time time;

describe coffee_table;

alter table coffee_table
change column ï»¿transaction_id transaction_id int ;

-- total sales analysis

select round(sum(unit_price * transaction_qty)) as total_sales
from coffee_table
-- where month(transaction_date) = 5        -- remove the bars to use filter your data by month
;

select month(transaction_date) as month,
round(sum(unit_price * transaction_qty)) as total_sales,
(sum(unit_price * transaction_qty) - lag(sum(unit_price * transaction_qty),1) over (order by month(transaction_date))) 
/ 
lag(sum(unit_price * transaction_qty),1) over (order by month(transaction_date)) * 100 as total_sales_mom

from coffee_table
where month(transaction_date) in (3,4,5)
group by month
order by month
;

-- total order analysis

select count(transaction_id) as total_order
from coffee_table
-- where month(transaction_date) = 5        -- remove the bars to use filter your data by month
;

select month(transaction_date) as month,
count(transaction_id) as total_order,
(count(transaction_id) - lag(count(transaction_id),1) over (order by month(transaction_date))) 
/ 
lag(count(transaction_id),1) over (order by month(transaction_date)) * 100 as total_order_mom
from coffee_table
where month(transaction_date) in (3,4,5)
group by month
order by month
;

-- total qunatity sold analysis

select sum(transaction_qty) as total_quantity
from coffee_table
-- where month(transaction_date) = 5        -- remove the bars to use filter your data by month
;

select month(transaction_date) as month,
sum(transaction_qty) as total_quantity,
(sum(transaction_qty) - lag(sum(transaction_qty),1) over (order by month(transaction_date))) 
/ 
lag(sum(transaction_qty),1) over (order by month(transaction_date)) * 100 as total_quantity_mom
from coffee_table
where month(transaction_date) in (3,4,5)
group by month
order by month
;

-- other analysis for chart and visualizations

select
round(sum(unit_price * transaction_qty)) as total_sales,
round(count(transaction_id)) as total_orders,
round(sum(transaction_qty)) as total_quantity_sold
from coffee_table
where transaction_date = '2023-01-01';   -- use where clause as a filter

SELECT 
    AVG(total_sales) AS avg_sales
FROM
    (SELECT 
        ROUND(SUM(unit_price * transaction_qty)) AS total_sales
    FROM
        coffee_table
    WHERE
        MONTH(transaction_date) = 5
    GROUP BY transaction_date) AS internal_query

-- the below one is generated by chatgpt-4o

SELECT AVG(daily_sales) AS average_daily_sales
FROM (
    SELECT transaction_date, SUM(transaction_qty * unit_price) AS daily_sales
    FROM coffee_table
    WHERE transaction_date BETWEEN '2023-05-01' AND '2023-05-31'
    GROUP BY transaction_date
) AS daily_sales_table;

-- daily sales when month selected

SELECT 
    DAY(transaction_date) AS day_of_month,
    SUM(transaction_qty * unit_price) AS daily_sales
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
GROUP BY transaction_date
ORDER BY transaction_date
;

-- comparing analysis
-- this one generated by chatgpt

WITH average_sales AS (
    SELECT AVG(daily_sales) AS avg_daily_sales
    FROM (
        SELECT transaction_date, SUM(transaction_qty * unit_price) AS daily_sales
        FROM coffee_table
        WHERE transaction_date BETWEEN '2023-05-01' AND '2023-05-31'
        GROUP BY transaction_date
    ) AS daily_sales_table
),
daily_sales AS (
    SELECT transaction_date, SUM(transaction_qty * unit_price) AS daily_sales
    FROM coffee_table
    WHERE transaction_date BETWEEN '2023-05-01' AND '2023-05-31'
    GROUP BY transaction_date
)
SELECT 
    ds.transaction_date, 
    ds.daily_sales, 
    CASE 
        WHEN ds.daily_sales > avg_sales.avg_daily_sales THEN 'ABOVE AVERAGE'
        ELSE 'BELOW AVERAGE'
    END AS sales_comparison
FROM daily_sales ds
CROSS JOIN average_sales avg_sales;

-- this one is by instractor

select 
day_of_month,
daily_sales,
case when daily_sales > avg_sales then 'Above Average'
	 when daily_sales < avg_sales then 'Below Average'
     else 'average'
     end as sales_status
from
(
select 
	day(transaction_date) as day_of_month,
	SUM(transaction_qty * unit_price) AS daily_sales,
    avg(sum(transaction_qty * unit_price)) over() as avg_sales
from coffee_table
where month(transaction_date) = 5
group by day(transaction_date)
)
as sales_data
order by day_of_month;

-- other analysis

SELECT 
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekend'
        ELSE 'weekday'
    END AS day_type,
    SUM(transaction_qty * unit_price) AS daily_sales
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
GROUP BY CASE
    WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekend'
    ELSE 'weekday'
END
;

SELECT 
    store_location,
    ROUND(SUM(transaction_qty * unit_price)) AS daily_sales
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
GROUP BY store_location
ORDER BY ROUND(SUM(transaction_qty * unit_price));


SELECT 
    product_category,
    ROUND(SUM(transaction_qty * unit_price)) AS daily_sales
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_category
ORDER BY ROUND(SUM(transaction_qty * unit_price)) DESC;


SELECT 
    product_type,
    ROUND(SUM(transaction_qty * unit_price)) AS daily_sales
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY ROUND(SUM(transaction_qty * unit_price)) DESC
LIMIT 10;


SELECT 
    ROUND(SUM(transaction_qty * unit_price)) AS daily_sales,
    SUM(transaction_qty) AS total_quantity,
    COUNT(transaction_id) AS total_orders
FROM
    coffee_table
WHERE
    MONTH(transaction_date) = 5
        AND WEEKDAY(transaction_date) = 1
        AND HOUR(transaction_time) = 9;
    

SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_table
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;


select 
hour(transaction_time) as hour_of_day,
ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
from coffee_table
where  MONTH(transaction_date) = 5
GROUP BY 
    HOUR(transaction_time)
ORDER BY 
    HOUR(transaction_time);


