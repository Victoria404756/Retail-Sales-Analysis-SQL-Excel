/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
02 - Product Analysis

Objective:
This script analyses product-level and sub-category-level
performance, including top-selling products, most profitable
products, loss-making products, and discount impact.

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
-- What are the top 10 products by total sales?
------------------------------------------------------------

SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY product_name
ORDER BY total_sales DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 products by sales.

Business Insight
----------------
Top-selling products identify the strongest revenue drivers.
These products may deserve priority in inventory planning,
marketing campaigns, and sales strategy.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- What are the top 10 most profitable products?
------------------------------------------------------------

SELECT
    product_name,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the top 10 products by total profit.

Business Insight
----------------
The most profitable products are not always the highest-selling
products. This query helps identify products that contribute most
to the company's bottom line and should be protected or promoted.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- Which products generated the largest losses?
------------------------------------------------------------

SELECT
    product_name,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 10;

/*
Expected Output
---------------
A ranked list of the 10 products with the largest negative profit.

Business Insight
----------------
Loss-making products require further investigation. Negative profit
may be caused by high discounts, low pricing, high costs, or weak
product demand. These products may need pricing review or
discontinuation consideration.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- Which product sub-categories generate the highest sales?
------------------------------------------------------------

SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY sub_category
ORDER BY total_sales DESC;

/*
Expected Output
---------------
A ranked list of product sub-categories by total sales.

Business Insight
----------------
Sub-category analysis provides a more detailed view than category
analysis. It helps management understand which specific product
groups are driving revenue.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- Which product sub-categories generate the highest profit?
------------------------------------------------------------

SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY sub_category
ORDER BY total_profit DESC;

/*
Expected Output
---------------
A ranked list of product sub-categories by total profit.

Business Insight
----------------
This query identifies the sub-categories that contribute most
to profitability. High-profit sub-categories should be prioritized
for marketing, inventory allocation, and future business growth.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- Which sub-categories are unprofitable?
------------------------------------------------------------

SELECT
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC;

/*
Expected Output
---------------
A list of sub-categories with negative total profit.

Business Insight
----------------
Unprofitable sub-categories may indicate pricing issues, excessive
discounting, or cost inefficiencies. These areas should be reviewed
to improve overall profitability.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- What is the average discount by sub-category?
------------------------------------------------------------

SELECT
    sub_category,
    ROUND(AVG(discount) * 100, 2) AS average_discount_percent,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY sub_category
ORDER BY average_discount_percent DESC;

/*
Expected Output
---------------
A list of sub-categories ranked by average discount percentage.

Business Insight
----------------
Discount analysis helps determine whether certain product groups
rely heavily on promotions. High discount levels should be compared
with profit performance to identify possible margin pressure.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- How does discount level affect profitability?
------------------------------------------------------------

WITH discount_analysis AS (
    SELECT
        CASE
            WHEN discount = 0 THEN 'No Discount'
            WHEN discount > 0 AND discount <= 0.10 THEN 'Low Discount'
            WHEN discount > 0.10 AND discount <= 0.30 THEN 'Medium Discount'
            ELSE 'High Discount'
        END AS discount_level,
        sales,
        profit
    FROM orders
)

SELECT
    discount_level,
    COUNT(*) AS order_lines,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM discount_analysis
GROUP BY discount_level
ORDER BY
    CASE
        WHEN discount_level = 'No Discount' THEN 1
        WHEN discount_level = 'Low Discount' THEN 2
        WHEN discount_level = 'Medium Discount' THEN 3
        ELSE 4
    END;

/*
Expected Output
---------------
A comparison of sales, profit, and profit margin across discount levels.

Business Insight
----------------
This query helps evaluate whether higher discounts reduce profitability.
If high-discount orders show low or negative margins, management should
review discount strategy to protect profit.
*/