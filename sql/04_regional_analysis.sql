/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
04 - Regional Analysis

Objective:
This script analyses regional sales and profitability,
including performance by region, state, city, and category.
It also identifies high-performing and loss-making geographic areas.

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
-- Which region generates the highest sales and profit?
------------------------------------------------------------

SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

/*
Expected Output
---------------
A ranked list of regions by total sales, profit, and profit margin.

Business Insight
----------------
Regional performance analysis helps management understand which
geographic markets drive revenue and profitability. Strong regions
may deserve continued investment, while weaker regions may require
pricing, marketing, or operational review.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- Which states generate the highest sales?
------------------------------------------------------------

SELECT
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    state_province,
    region
ORDER BY total_sales DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 states by total sales.

Business Insight
----------------
State-level sales analysis helps identify major revenue markets.
High-sales states may represent strong demand and can be prioritised
for sales campaigns, inventory planning, and customer retention.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- Which states generate the highest profit?
------------------------------------------------------------

SELECT
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    state_province,
    region
ORDER BY total_profit DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 states by total profit.

Business Insight
----------------
The most profitable states are important contributors to overall
business performance. These markets may offer opportunities for
continued investment and expansion.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- Which states are generating losses?
------------------------------------------------------------

SELECT
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    state_province,
    region
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

/*
Expected Output
---------------
A list of states with negative total profit.

Business Insight
----------------
Loss-making states require management attention. Negative profit may
be caused by high discounts, low-margin products, shipping costs,
or inefficient regional operations.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- Which cities generate the highest sales?
------------------------------------------------------------

SELECT
    city,
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    city,
    state_province,
    region
ORDER BY total_sales DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 cities by total sales.

Business Insight
----------------
City-level analysis provides more detailed geographic insight than
state-level analysis. High-performing cities may be key local markets
for sales and marketing strategy.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- Which cities generate the highest profit?
------------------------------------------------------------

SELECT
    city,
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    city,
    state_province,
    region
ORDER BY total_profit DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 cities by total profit.

Business Insight
----------------
The most profitable cities may represent strong local markets with
efficient pricing, product mix, or customer demand. These areas can
be prioritised for business growth.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- Which cities are generating the largest losses?
------------------------------------------------------------

SELECT
    city,
    state_province,
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    city,
    state_province,
    region
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of cities with the largest negative profit.

Business Insight
----------------
Loss-making cities should be reviewed to understand whether losses
are driven by excessive discounting, weak product mix, shipping cost,
or local market conditions.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- How does product category performance vary by region?
------------------------------------------------------------

SELECT
    region,
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    region,
    category
ORDER BY
    region,
    total_sales DESC;

/*
Expected Output
---------------
Sales and profit performance by region and product category.

Business Insight
----------------
This query helps identify which product categories perform best
within each region. Regional category analysis supports more targeted
inventory, marketing, and sales strategies.
*/


------------------------------------------------------------
-- Query 9
-- Business Question:
-- Which region has the highest average order value?
------------------------------------------------------------

SELECT
    region,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM orders
GROUP BY region
ORDER BY average_order_value DESC;

/*
Expected Output
---------------
Average order value by region.

Business Insight
----------------
Average order value helps compare customer purchasing behaviour
across regions. A higher average order value may indicate larger
basket sizes, stronger product mix, or better regional sales quality.
*/


------------------------------------------------------------
-- Query 10
-- Business Question:
-- How can states be grouped based on profitability?
------------------------------------------------------------

WITH state_summary AS (
    SELECT
        state_province,
        region,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        state_province,
        region
),

state_profit_groups AS (
    SELECT
        state_province,
        region,
        total_sales,
        total_profit,
        CASE
            WHEN total_profit >= 10000 THEN 'High Profit State'
            WHEN total_profit >= 0 THEN 'Low Profit State'
            ELSE 'Loss-Making State'
        END AS state_profit_group
    FROM state_summary
)

SELECT
    state_profit_group,
    COUNT(*) AS number_of_states,
    ROUND(SUM(total_sales), 2) AS group_sales,
    ROUND(SUM(total_profit), 2) AS group_profit,
    ROUND(AVG(total_profit), 2) AS average_profit_per_state
FROM state_profit_groups
GROUP BY state_profit_group
ORDER BY
    CASE
        WHEN state_profit_group = 'High Profit State' THEN 1
        WHEN state_profit_group = 'Low Profit State' THEN 2
        ELSE 3
    END;

/*
Expected Output
---------------
A summary of states grouped by profitability level.

Business Insight
----------------
Grouping states by profitability helps management quickly identify
strong markets, moderate markets, and loss-making markets. This can
support regional prioritisation and performance improvement planning.
*/