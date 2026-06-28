/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
05 - Time Analysis

Objective:
This script analyses sales and profit performance over time,
including monthly trends, yearly performance, quarterly performance,
running sales total, and month-over-month growth.

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
-- How have monthly sales and profit changed over time?
------------------------------------------------------------

SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY sales_month
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly sales and profit trend over the full reporting period.

Business Insight
----------------
Monthly trend analysis helps management identify growth patterns,
seasonality, and periods of strong or weak performance. This can
support forecasting, campaign planning, and inventory decisions.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- Which year generated the highest sales and profit?
------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_date) AS sales_year,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY sales_year
ORDER BY sales_year;

/*
Expected Output
---------------
Yearly sales, profit, and order volume.

Business Insight
----------------
Yearly performance analysis helps evaluate long-term business
growth. Comparing sales, profit, and order volume across years
shows whether the company is improving over time.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- Which quarter performs best in terms of sales and profit?
------------------------------------------------------------

SELECT
    EXTRACT(YEAR FROM order_date) AS sales_year,
    EXTRACT(QUARTER FROM order_date) AS sales_quarter,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    sales_year,
    sales_quarter
ORDER BY
    sales_year,
    sales_quarter;

/*
Expected Output
---------------
Quarterly sales and profit by year.

Business Insight
----------------
Quarterly analysis helps identify seasonal performance patterns.
Strong quarters may indicate peak demand periods, while weaker
quarters may require additional marketing or sales support.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- What is the monthly order volume trend?
------------------------------------------------------------

SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM orders
GROUP BY sales_month
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly order volume, sales, and average order value.

Business Insight
----------------
Order volume analysis helps determine whether revenue changes are
driven by more orders or higher average order value. This supports
sales planning and customer behaviour analysis.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- What is the cumulative sales trend over time?
------------------------------------------------------------

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS sales_month,
        ROUND(SUM(sales), 2) AS monthly_sales
    FROM orders
    GROUP BY sales_month
)

SELECT
    sales_month,
    monthly_sales,
    ROUND(
        SUM(monthly_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_sales
FROM monthly_sales
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly sales with cumulative sales over time.

Business Insight
----------------
Cumulative sales show how revenue builds over the reporting period.
This is useful for tracking progress against annual targets and
monitoring long-term growth momentum.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- What is the cumulative profit trend over time?
------------------------------------------------------------

WITH monthly_profit AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS sales_month,
        ROUND(SUM(profit), 2) AS monthly_profit
    FROM orders
    GROUP BY sales_month
)

SELECT
    sales_month,
    monthly_profit,
    ROUND(
        SUM(monthly_profit) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_profit
FROM monthly_profit
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly profit with cumulative profit over time.

Business Insight
----------------
Cumulative profit helps management monitor how profitability builds
over time. It provides a clearer view of financial progress than
monthly profit alone.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- What is the month-over-month sales growth rate?
------------------------------------------------------------

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS sales_month,
        ROUND(SUM(sales), 2) AS monthly_sales
    FROM orders
    GROUP BY sales_month
),

monthly_growth AS (
    SELECT
        sales_month,
        monthly_sales,
        LAG(monthly_sales) OVER (ORDER BY sales_month) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    sales_month,
    monthly_sales,
    previous_month_sales,
    ROUND(
        (monthly_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0) * 100,
        2
    ) AS month_over_month_growth_percent
FROM monthly_growth
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly sales, previous month sales, and month-over-month growth rate.

Business Insight
----------------
Month-over-month growth helps identify acceleration or slowdown in
sales performance. This can support management review of recent
business momentum and campaign effectiveness.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- What is the year-over-year sales growth rate?
------------------------------------------------------------

WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS sales_year,
        ROUND(SUM(sales), 2) AS yearly_sales
    FROM orders
    GROUP BY sales_year
),

yearly_growth AS (
    SELECT
        sales_year,
        yearly_sales,
        LAG(yearly_sales) OVER (ORDER BY sales_year) AS previous_year_sales
    FROM yearly_sales
)

SELECT
    sales_year,
    yearly_sales,
    previous_year_sales,
    ROUND(
        (yearly_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0) * 100,
        2
    ) AS year_over_year_growth_percent
FROM yearly_growth
ORDER BY sales_year;

/*
Expected Output
---------------
Yearly sales, previous year sales, and year-over-year growth rate.

Business Insight
----------------
Year-over-year growth provides a high-level view of business expansion.
It helps management understand whether annual sales performance is
improving, declining, or remaining stable.
*/


------------------------------------------------------------
-- Query 9
-- Business Question:
-- Which months have the highest sales across all years?
------------------------------------------------------------

SELECT
    TO_CHAR(order_date, 'Month') AS month_name,
    EXTRACT(MONTH FROM order_date) AS month_number,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    month_name,
    month_number
ORDER BY total_sales DESC;

/*
Expected Output
---------------
Months ranked by total sales across all years.

Business Insight
----------------
This query helps identify seasonal demand patterns. High-performing
months may indicate peak buying periods and can inform marketing,
inventory, and staffing decisions.
*/


------------------------------------------------------------
-- Query 10
-- Business Question:
-- Which month generated the highest sales in each year?
------------------------------------------------------------

WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS sales_year,
        DATE_TRUNC('month', order_date)::DATE AS sales_month,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        sales_year,
        sales_month
),

ranked_months AS (
    SELECT
        sales_year,
        sales_month,
        total_sales,
        total_profit,
        RANK() OVER (
            PARTITION BY sales_year
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM monthly_sales
)

SELECT
    sales_year,
    sales_month,
    total_sales,
    total_profit
FROM ranked_months
WHERE sales_rank = 1
ORDER BY sales_year;

/*
Expected Output
---------------
The highest-sales month for each year.

Business Insight
----------------
Identifying the strongest month in each year helps management
understand peak performance periods. This can support future campaign
timing, demand planning, and revenue forecasting.
*/