/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
08 - Excel Export Views

Objective:
Create SQL views that will be exported to Excel for KPI reporting,
pivot tables, charts, and management summary.

These views are designed as clean output tables for Excel analysis.
============================================================
*/


------------------------------------------------------------
-- View 1
-- Executive KPI Summary
------------------------------------------------------------

DROP VIEW IF EXISTS excel_01_kpi_summary;

CREATE VIEW excel_01_kpi_summary AS
SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM orders;


------------------------------------------------------------
-- View 2
-- Sales and Profit by Category
------------------------------------------------------------

DROP VIEW IF EXISTS excel_02_category_analysis;

CREATE VIEW excel_02_category_analysis AS
SELECT
    category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY category
ORDER BY total_sales DESC;


------------------------------------------------------------
-- View 3
-- Sales and Profit by Customer Segment
------------------------------------------------------------

DROP VIEW IF EXISTS excel_03_segment_analysis;

CREATE VIEW excel_03_segment_analysis AS
SELECT
    segment,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;


------------------------------------------------------------
-- View 4
-- Monthly Sales Trend
------------------------------------------------------------

DROP VIEW IF EXISTS excel_04_monthly_trend;

CREATE VIEW excel_04_monthly_trend AS
SELECT
    DATE_TRUNC('month', order_date)::DATE AS sales_month,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY sales_month
ORDER BY sales_month;


------------------------------------------------------------
-- View 5
-- Regional Performance
------------------------------------------------------------

DROP VIEW IF EXISTS excel_05_regional_analysis;

CREATE VIEW excel_05_regional_analysis AS
SELECT
    region,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


------------------------------------------------------------
-- View 6
-- State Profitability
------------------------------------------------------------

DROP VIEW IF EXISTS excel_06_state_profitability;

CREATE VIEW excel_06_state_profitability AS
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
ORDER BY total_profit ASC;


------------------------------------------------------------
-- View 7
-- Top 10 Products by Sales
------------------------------------------------------------

DROP VIEW IF EXISTS excel_07_top_products;

CREATE VIEW excel_07_top_products AS
SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit
FROM orders
GROUP BY
    product_name,
    category,
    sub_category
ORDER BY total_sales DESC
LIMIT 10;


------------------------------------------------------------
-- View 8
-- Loss-Making Products
------------------------------------------------------------

DROP VIEW IF EXISTS excel_08_loss_making_products;

CREATE VIEW excel_08_loss_making_products AS
SELECT
    product_name,
    category,
    sub_category,
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(AVG(discount) * 100, 2) AS average_discount_percent
FROM orders
GROUP BY
    product_name,
    category,
    sub_category
HAVING SUM(profit) < 0
ORDER BY total_profit ASC
LIMIT 20;