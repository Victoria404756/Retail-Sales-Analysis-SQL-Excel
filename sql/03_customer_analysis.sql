/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
03 - Customer Analysis

Objective:
This script analyses customer-level performance, including
customer count, sales by customer segment, top customers,
customer profitability, repeat customer behaviour, and
customer value segmentation.

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
-- How many unique customers are included in the dataset?
------------------------------------------------------------

SELECT
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders;

/*
Expected Output
---------------
The total number of unique customers.

Business Insight
----------------
The number of unique customers helps measure the size of the
customer base. This metric provides a foundation for analysing
customer behaviour, repeat purchases, and segment performance.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- Which customer segment generates the highest sales and profit?
------------------------------------------------------------

SELECT
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

/*
Expected Output
---------------
A ranked list of customer segments by total sales.

Business Insight
----------------
Customer segment analysis helps identify which customer groups
contribute most to revenue and profitability. This supports
marketing prioritisation, customer targeting, and sales strategy.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- What is the average sales value per customer by segment?
------------------------------------------------------------

SELECT
    segment,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT customer_id), 0), 2) AS average_sales_per_customer
FROM orders
GROUP BY segment
ORDER BY average_sales_per_customer DESC;

/*
Expected Output
---------------
Average sales per customer for each customer segment.

Business Insight
----------------
Average sales per customer helps evaluate customer value within
each segment. A segment with fewer customers may still be valuable
if each customer generates high revenue.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- Who are the top 10 customers by total sales?
------------------------------------------------------------

SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY
    customer_id,
    customer_name,
    segment
ORDER BY total_sales DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 customers by total sales.

Business Insight
----------------
Top customers represent important revenue contributors.
These customers may be valuable targets for loyalty programmes,
account management, and retention strategies.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- Who are the top 10 customers by total profit?
------------------------------------------------------------

SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    customer_id,
    customer_name,
    segment
ORDER BY total_profit DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 customers by total profit.

Business Insight
----------------
The most profitable customers are not always the highest-spending
customers. This query helps identify customers who contribute most
to the company's bottom line.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- Which customers generated negative profit?
------------------------------------------------------------

SELECT
    customer_id,
    customer_name,
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY
    customer_id,
    customer_name,
    segment
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

/*
Expected Output
---------------
A list of customers with the largest negative profit.

Business Insight
----------------
Customers with negative profit may require further review.
Losses may be caused by excessive discounts, low-margin products,
shipping costs, or unprofitable buying patterns.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- Which customers placed the most orders?
------------------------------------------------------------

SELECT
    customer_id,
    customer_name,
    segment,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    customer_id,
    customer_name,
    segment
ORDER BY total_orders DESC, total_sales DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of customers by number of unique orders.

Business Insight
----------------
Customers with high order frequency may represent strong repeat
purchase behaviour. These customers are important for retention
and loyalty strategy.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- How can customers be grouped based on total sales value?
------------------------------------------------------------

WITH customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY
        customer_id,
        customer_name,
        segment
),

customer_value_groups AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        total_sales,
        total_profit,
        total_orders,
        CASE
            WHEN total_sales >= 10000 THEN 'High Value Customer'
            WHEN total_sales >= 5000 THEN 'Medium Value Customer'
            ELSE 'Low Value Customer'
        END AS customer_value_group
    FROM customer_summary
)

SELECT
    customer_value_group,
    COUNT(*) AS number_of_customers,
    ROUND(SUM(total_sales), 2) AS group_sales,
    ROUND(SUM(total_profit), 2) AS group_profit,
    ROUND(AVG(total_sales), 2) AS average_sales_per_customer,
    ROUND(AVG(total_orders), 2) AS average_orders_per_customer
FROM customer_value_groups
GROUP BY customer_value_group
ORDER BY
    CASE
        WHEN customer_value_group = 'High Value Customer' THEN 1
        WHEN customer_value_group = 'Medium Value Customer' THEN 2
        ELSE 3
    END;

/*
Expected Output
---------------
A customer value segmentation table based on total sales.

Business Insight
----------------
Customer value segmentation helps management identify high-value,
medium-value, and low-value customer groups. High-value customers
may require retention strategies, while medium-value customers may
represent growth opportunities.
*/


------------------------------------------------------------
-- Query 9
-- Business Question:
-- What is the relationship between order frequency and customer value?
------------------------------------------------------------

WITH customer_summary AS (
    SELECT
        customer_id,
        customer_name,
        COUNT(DISTINCT order_id) AS total_orders,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        customer_id,
        customer_name
),

customer_frequency_groups AS (
    SELECT
        customer_id,
        customer_name,
        total_orders,
        total_sales,
        total_profit,
        CASE
            WHEN total_orders >= 10 THEN 'Frequent Customer'
            WHEN total_orders >= 5 THEN 'Moderate Customer'
            ELSE 'Occasional Customer'
        END AS customer_frequency_group
    FROM customer_summary
)

SELECT
    customer_frequency_group,
    COUNT(*) AS number_of_customers,
    ROUND(SUM(total_sales), 2) AS total_sales,
    ROUND(SUM(total_profit), 2) AS total_profit,
    ROUND(AVG(total_sales), 2) AS average_sales_per_customer
FROM customer_frequency_groups
GROUP BY customer_frequency_group
ORDER BY
    CASE
        WHEN customer_frequency_group = 'Frequent Customer' THEN 1
        WHEN customer_frequency_group = 'Moderate Customer' THEN 2
        ELSE 3
    END;

/*
Expected Output
---------------
A comparison of customer groups based on order frequency.

Business Insight
----------------
Order frequency analysis helps identify whether repeat customers
generate stronger sales and profit performance. This can support
customer retention, loyalty programme design, and targeted
marketing campaigns.
*/