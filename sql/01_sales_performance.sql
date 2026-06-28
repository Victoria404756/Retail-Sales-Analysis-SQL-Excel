/*
Project: Retail Sales Analysis using SQL & Excel
File: 01_sales_performance.sql

Purpose:
Analyze overall sales performance, profitability, product category performance,
and customer segment contribution using the Sample Superstore dataset.
*/

-- 1. Total Sales
SELECT
    ROUND(SUM(sales), 2) AS total_sales
FROM orders;


-- 2. Total Profit
SELECT
    ROUND(SUM(profit), 2) AS total_profit
FROM orders;


-- 3. Profit Margin
SELECT
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_percent
FROM orders;


-- 4. Sales by Category
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY category
ORDER BY total_sales DESC;


-- 5. Sales by Customer Segment
SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;


-- 6. Monthly Sales Trend
SELECT
    DATE_TRUNC('month', order_date) AS sales_month,
    ROUND(SUM(sales), 2) AS total_sales
FROM orders
GROUP BY sales_month
ORDER BY sales_month;