/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
07 - Business Questions

Objective:
This script answers key management-level business questions
using SQL. It combines sales, profit, customer, product,
regional and discount analysis to support business decisions.

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
-- What are the key executive KPIs for the business?
------------------------------------------------------------

SELECT
    ROUND(SUM(sales), 2) AS total_sales,
    ROUND(SUM(profit), 2) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(SUM(sales) / NULLIF(COUNT(DISTINCT order_id), 0), 2) AS average_order_value
FROM orders;

/*
Expected Output
---------------
A one-row executive KPI summary including sales, profit,
profit margin, order count, customer count and average order value.

Business Insight
----------------
This query provides a high-level overview of business performance.
It allows management to quickly understand revenue scale,
profitability, transaction volume, customer base size and order value.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- Which product categories should management prioritise?
------------------------------------------------------------

WITH category_performance AS (
    SELECT
        category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
    FROM orders
    GROUP BY category
)

SELECT
    category,
    total_sales,
    total_profit,
    profit_margin_percent,
    CASE
        WHEN total_profit > 100000 THEN 'High Priority'
        WHEN total_profit > 50000 THEN 'Medium Priority'
        ELSE 'Review Needed'
    END AS management_priority
FROM category_performance
ORDER BY total_profit DESC;

/*
Expected Output
---------------
Product categories ranked by profit with a management priority label.

Business Insight
----------------
This query helps management identify which product categories deserve
the most attention. Categories with strong sales and profit should be
prioritised for inventory, marketing and strategic investment.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- Which sub-categories require profitability review?
------------------------------------------------------------

WITH sub_category_performance AS (
    SELECT
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
    FROM orders
    GROUP BY
        category,
        sub_category
)

SELECT
    category,
    sub_category,
    total_sales,
    total_profit,
    profit_margin_percent,
    CASE
        WHEN total_profit < 0 THEN 'Immediate Review'
        WHEN profit_margin_percent < 5 THEN 'Margin Review'
        ELSE 'Healthy'
    END AS review_status
FROM sub_category_performance
ORDER BY total_profit ASC;

/*
Expected Output
---------------
Sub-categories classified by profitability review status.

Business Insight
----------------
This query highlights product areas that may be damaging profitability.
Loss-making or low-margin sub-categories should be reviewed for pricing,
discounting, cost structure or potential discontinuation.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- Which states require management attention due to losses?
------------------------------------------------------------

WITH state_performance AS (
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
)

SELECT
    state_province,
    region,
    total_sales,
    total_profit,
    profit_margin_percent,
    CASE
        WHEN total_profit < 0 THEN 'Loss-Making State'
        WHEN profit_margin_percent < 5 THEN 'Low Margin State'
        ELSE 'Profitable State'
    END AS state_performance_status
FROM state_performance
ORDER BY total_profit ASC;

/*
Expected Output
---------------
States ranked from lowest to highest profit with a performance status.

Business Insight
----------------
This query identifies geographic areas requiring attention. Loss-making
states may indicate issues with pricing, discount levels, shipping costs,
customer mix or product mix.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- Are higher discounts reducing profitability?
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
),

discount_summary AS (
    SELECT
        discount_level,
        COUNT(*) AS order_lines,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
    FROM discount_analysis
    GROUP BY discount_level
)

SELECT
    discount_level,
    order_lines,
    total_sales,
    total_profit,
    profit_margin_percent,
    CASE
        WHEN total_profit < 0 THEN 'Discount Strategy Review Needed'
        WHEN profit_margin_percent < 5 THEN 'Margin Pressure'
        ELSE 'Acceptable'
    END AS discount_status
FROM discount_summary
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
Discount levels compared by sales, profit and profit margin.

Business Insight
----------------
This query helps evaluate whether discounting is protecting or reducing
profitability. If high-discount orders have weak or negative margins,
management should review discount policy.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- Which customers should be targeted for retention?
------------------------------------------------------------

WITH customer_summary AS (
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
),

customer_segments AS (
    SELECT
        customer_id,
        customer_name,
        segment,
        total_orders,
        total_sales,
        total_profit,
        CASE
            WHEN total_sales >= 10000 OR total_orders >= 10 THEN 'Retention Priority'
            WHEN total_sales >= 5000 OR total_orders >= 5 THEN 'Growth Opportunity'
            ELSE 'Standard Customer'
        END AS customer_action_group
    FROM customer_summary
)

SELECT
    customer_id,
    customer_name,
    segment,
    total_orders,
    total_sales,
    total_profit,
    customer_action_group
FROM customer_segments
WHERE customer_action_group IN ('Retention Priority', 'Growth Opportunity')
ORDER BY
    CASE
        WHEN customer_action_group = 'Retention Priority' THEN 1
        ELSE 2
    END,
    total_sales DESC;

/*
Expected Output
---------------
Customers grouped into retention and growth opportunity groups.

Business Insight
----------------
This query helps identify customers who may deserve targeted retention
or relationship management. High-value and frequent customers are
important for long-term revenue stability.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- Which products should management review for possible action?
------------------------------------------------------------

WITH product_performance AS (
    SELECT
        product_name,
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent,
        ROUND(AVG(discount) * 100, 2) AS average_discount_percent
    FROM orders
    GROUP BY
        product_name,
        category,
        sub_category
)

SELECT
    product_name,
    category,
    sub_category,
    total_sales,
    total_profit,
    profit_margin_percent,
    average_discount_percent,
    CASE
        WHEN total_profit < 0 THEN 'Loss-Making Product'
        WHEN profit_margin_percent < 5 THEN 'Low Margin Product'
        ELSE 'Healthy Product'
    END AS product_review_status
FROM product_performance
WHERE total_profit < 0
   OR profit_margin_percent < 5
ORDER BY total_profit ASC
LIMIT 20;

/*
Expected Output
---------------
Products with negative profit or low profit margin.

Business Insight
----------------
This query highlights products that may require pricing, discount,
cost or portfolio review. Management can use this output to identify
products that may need corrective action.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- Which regions have the strongest overall business performance?
------------------------------------------------------------

WITH region_performance AS (
    SELECT
        region,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY region
),

region_rankings AS (
    SELECT
        region,
        total_sales,
        total_profit,
        profit_margin_percent,
        total_orders,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
        RANK() OVER (ORDER BY total_profit DESC) AS profit_rank
    FROM region_performance
)

SELECT
    region,
    total_sales,
    total_profit,
    profit_margin_percent,
    total_orders,
    sales_rank,
    profit_rank,
    CASE
        WHEN sales_rank <= 2 AND profit_rank <= 2 THEN 'Strong Region'
        WHEN profit_rank > 2 THEN 'Profit Improvement Needed'
        ELSE 'Moderate Region'
    END AS regional_action_status
FROM region_rankings
ORDER BY profit_rank;

/*
Expected Output
---------------
Regions ranked by sales and profit with an action status.

Business Insight
----------------
This query provides a balanced view of regional performance. A region
with strong sales but weaker profit may require margin improvement,
while strong regions can be prioritised for continued investment.
*/


------------------------------------------------------------
-- Query 9
-- Business Question:
-- Which months should management focus on for sales planning?
------------------------------------------------------------

WITH month_performance AS (
    SELECT
        TO_CHAR(order_date, 'Month') AS month_name,
        EXTRACT(MONTH FROM order_date) AS month_number,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY
        month_name,
        month_number
),

ranked_months AS (
    SELECT
        month_name,
        month_number,
        total_sales,
        total_profit,
        total_orders,
        RANK() OVER (ORDER BY total_sales DESC) AS sales_month_rank
    FROM month_performance
)

SELECT
    month_name,
    total_sales,
    total_profit,
    total_orders,
    sales_month_rank,
    CASE
        WHEN sales_month_rank <= 3 THEN 'Peak Sales Month'
        WHEN sales_month_rank >= 10 THEN 'Low Sales Month'
        ELSE 'Normal Sales Month'
    END AS month_planning_status
FROM ranked_months
ORDER BY sales_month_rank;

/*
Expected Output
---------------
Months ranked by sales with a planning status.

Business Insight
----------------
This query helps identify peak and weaker sales months. Management
can use this information for campaign timing, inventory planning,
staffing decisions and sales forecasting.
*/


------------------------------------------------------------
-- Query 10
-- Business Question:
-- What are the main management recommendations based on SQL analysis?
------------------------------------------------------------

WITH kpi_summary AS (
    SELECT
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
    FROM orders
),

top_category AS (
    SELECT
        category,
        ROUND(SUM(sales), 2) AS total_sales
    FROM orders
    GROUP BY category
    ORDER BY total_sales DESC
    LIMIT 1
),

loss_state AS (
    SELECT
        state_province,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY state_province
    ORDER BY total_profit ASC
    LIMIT 1
),

top_segment AS (
    SELECT
        segment,
        ROUND(SUM(sales), 2) AS total_sales
    FROM orders
    GROUP BY segment
    ORDER BY total_sales DESC
    LIMIT 1
)

SELECT
    'Overall Performance' AS recommendation_area,
    'Monitor total sales, profit and profit margin as executive KPIs.' AS recommendation
FROM kpi_summary

UNION ALL

SELECT
    'Product Strategy' AS recommendation_area,
    'Prioritise the highest revenue-generating category: ' || category || '.' AS recommendation
FROM top_category

UNION ALL

SELECT
    'Regional Strategy' AS recommendation_area,
    'Review loss-making state: ' || state_province || ' for pricing, discount and operational issues.' AS recommendation
FROM loss_state

UNION ALL

SELECT
    'Customer Strategy' AS recommendation_area,
    'Maintain focus on the strongest customer segment: ' || segment || '.' AS recommendation
FROM top_segment;

/*
Expected Output
---------------
A management recommendation summary generated from SQL analysis.

Business Insight
----------------
This query converts analytical findings into business recommendations.
It demonstrates how SQL results can support executive reporting and
decision-making.
*/