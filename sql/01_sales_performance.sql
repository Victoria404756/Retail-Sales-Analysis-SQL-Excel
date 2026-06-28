/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
01 - Sales Performance Analysis

Objective:
This script analyses overall sales performance, profitability,
sales contribution by product category, customer segment,
and monthly sales trend.

Structure:
Each query includes:
1. Business Question
2. SQL Query
3. Result / Expected Output
4. Business Insight
============================================================
*/


------------------------------------------------------------
-- Query 1
-- Business Question:
-- What is the total sales generated during the reporting period?
------------------------------------------------------------

SELECT
    ROUND(SUM(sales), 2) AS total_sales
FROM orders;

/*
Result
------
Total Sales = $2,326,534.52

Business Insight
----------------
The company generated approximately $2.33M in total sales
during the reporting period. This provides the baseline for
evaluating profitability, product performance, customer segments,
and future business growth.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- What is the total profit generated during the reporting period?
------------------------------------------------------------

SELECT
    ROUND(SUM(profit), 2) AS total_profit
FROM orders;

/*
Result
------
Total Profit = $292,297.57

Business Insight
----------------
The company generated approximately $292K in total profit,
indicating overall positive financial performance. Comparing
profit with total sales helps evaluate business efficiency
and profitability.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- What is the overall profit margin?
------------------------------------------------------------

SELECT
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_percent
FROM orders;

/*
Result
------
Profit Margin = 12.56%

Business Insight
----------------
The company achieved an overall profit margin of 12.56%.
This means that for every $100 in sales, the business generated
approximately $12.56 in profit. Profit margin is an important
indicator of pricing effectiveness and cost control.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- How many unique orders were placed during the reporting period?
------------------------------------------------------------

SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;

/*
Result
------
This query returns the total number of unique orders.

Business Insight
----------------
Counting distinct orders helps measure sales transaction volume.
This metric can be used together with total sales to calculate
average order value and understand customer purchasing activity.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- What is the average order value?
------------------------------------------------------------

SELECT
    ROUND(
        SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0),
        2
    ) AS average_order_value
FROM orders;

/*
Result
------
This query returns the average sales value per order.

Business Insight
----------------
Average order value measures how much revenue is generated
per customer order. A higher average order value may indicate
larger basket sizes, stronger product mix, or successful
cross-selling opportunities.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- Which product category generates the highest sales and profit?
------------------------------------------------------------

SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_percent
FROM orders
GROUP BY category
ORDER BY total_sales DESC;

/*
Result
------
This query ranks product categories by total sales.

Business Insight
----------------
Category-level analysis helps identify which product groups
drive the most revenue and profit. Based on the dashboard results,
Technology is the highest revenue-generating category, making it
a key area for continued business focus.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- Which customer segment contributes the most sales?
------------------------------------------------------------

SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_percent
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

/*
Result
------
This query ranks customer segments by total sales.

Business Insight
----------------
Customer segment analysis helps identify the company's most
valuable customer groups. Based on the dashboard results,
Consumer customers generate the highest sales, suggesting that
this segment should remain a key focus for marketing and sales
strategy.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- How have monthly sales changed over time?
------------------------------------------------------------

SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY sales_month
ORDER BY sales_month;

/*
Result
------
This query returns monthly sales and profit over time.

Business Insight
----------------
Monthly trend analysis helps management understand seasonality,
growth patterns, and periods of strong or weak performance.
The sales trend can be used to support forecasting, inventory
planning, and campaign timing decisions.
*/