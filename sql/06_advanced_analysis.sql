/*
============================================================
Project : Retail Sales Analysis – SQL & Excel
Author  : Victoria Zhang
Database: PostgreSQL
Dataset : Sample Superstore

Module:
06 - Advanced Analysis

Objective:
This script applies advanced SQL techniques to analyse rankings,
sales contribution, regional performance, customer value, rolling
averages, and product profitability.

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
-- What are the top 5 products by sales within each category?
------------------------------------------------------------

WITH product_sales AS (
    SELECT
        category,
        product_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        category,
        product_name
),

ranked_products AS (
    SELECT
        category,
        product_name,
        total_sales,
        total_profit,
        RANK() OVER (
            PARTITION BY category
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM product_sales
)

SELECT
    category,
    product_name,
    total_sales,
    total_profit,
    sales_rank
FROM ranked_products
WHERE sales_rank <= 5
ORDER BY
    category,
    sales_rank;

/*
Expected Output
---------------
The top 5 products by sales within each product category.

Business Insight
----------------
Ranking products within each category helps management identify
the strongest revenue drivers in Furniture, Office Supplies, and
Technology. This supports more targeted inventory planning and
category-level sales strategy.
*/


------------------------------------------------------------
-- Query 2
-- Business Question:
-- What are the top 3 most profitable sub-categories within each category?
------------------------------------------------------------

WITH sub_category_profit AS (
    SELECT
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        category,
        sub_category
),

ranked_sub_categories AS (
    SELECT
        category,
        sub_category,
        total_sales,
        total_profit,
        DENSE_RANK() OVER (
            PARTITION BY category
            ORDER BY total_profit DESC
        ) AS profit_rank
    FROM sub_category_profit
)

SELECT
    category,
    sub_category,
    total_sales,
    total_profit,
    profit_rank
FROM ranked_sub_categories
WHERE profit_rank <= 3
ORDER BY
    category,
    profit_rank;

/*
Expected Output
---------------
The top 3 sub-categories by profit within each category.

Business Insight
----------------
This query helps identify which product groups contribute most to
profitability within each category. High-profit sub-categories should
be prioritised for marketing, stock planning, and business growth.
*/


------------------------------------------------------------
-- Query 3
-- Business Question:
-- How do regions rank by total profit?
------------------------------------------------------------

WITH regional_profit AS (
    SELECT
        region,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS profit_margin_percent
    FROM orders
    GROUP BY region
)

SELECT
    region,
    total_sales,
    total_profit,
    profit_margin_percent,
    RANK() OVER (
        ORDER BY total_profit DESC
    ) AS profit_rank
FROM regional_profit
ORDER BY profit_rank;

/*
Expected Output
---------------
Regions ranked by total profit.

Business Insight
----------------
Regional profit ranking helps management identify which regions are
the strongest contributors to financial performance. Lower-ranked
regions may require pricing, discount, or operational review.
*/


------------------------------------------------------------
-- Query 4
-- Business Question:
-- Which states rank highest by profit within each region?
------------------------------------------------------------

WITH state_profit AS (
    SELECT
        region,
        state_province,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY
        region,
        state_province
),

ranked_states AS (
    SELECT
        region,
        state_province,
        total_sales,
        total_profit,
        RANK() OVER (
            PARTITION BY region
            ORDER BY total_profit DESC
        ) AS state_profit_rank
    FROM state_profit
)

SELECT
    region,
    state_province,
    total_sales,
    total_profit,
    state_profit_rank
FROM ranked_states
WHERE state_profit_rank <= 5
ORDER BY
    region,
    state_profit_rank;

/*
Expected Output
---------------
The top 5 states by profit within each region.

Business Insight
----------------
This query provides a more detailed view of regional performance by
ranking states within each region. It helps identify local markets
that are driving profit in different parts of the country.
*/


------------------------------------------------------------
-- Query 5
-- Business Question:
-- Who are the top customers by sales within each customer segment?
------------------------------------------------------------

WITH customer_sales AS (
    SELECT
        segment,
        customer_id,
        customer_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY
        segment,
        customer_id,
        customer_name
),

ranked_customers AS (
    SELECT
        segment,
        customer_id,
        customer_name,
        total_sales,
        total_profit,
        total_orders,
        RANK() OVER (
            PARTITION BY segment
            ORDER BY total_sales DESC
        ) AS customer_sales_rank
    FROM customer_sales
)

SELECT
    segment,
    customer_id,
    customer_name,
    total_sales,
    total_profit,
    total_orders,
    customer_sales_rank
FROM ranked_customers
WHERE customer_sales_rank <= 5
ORDER BY
    segment,
    customer_sales_rank;

/*
Expected Output
---------------
The top 5 customers by sales within each customer segment.

Business Insight
----------------
Ranking customers within each segment helps identify key accounts
across Consumer, Corporate, and Home Office groups. These customers
may be important targets for retention and relationship management.
*/


------------------------------------------------------------
-- Query 6
-- Business Question:
-- What percentage of total sales does each category contribute?
------------------------------------------------------------

WITH category_sales AS (
    SELECT
        category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY category
)

SELECT
    category,
    total_sales,
    total_profit,
    ROUND(
        total_sales / NULLIF(SUM(total_sales) OVER (), 0) * 100,
        2
    ) AS sales_contribution_percent
FROM category_sales
ORDER BY sales_contribution_percent DESC;

/*
Expected Output
---------------
Sales contribution percentage by category.

Business Insight
----------------
Sales contribution analysis shows how much each category contributes
to total revenue. This helps management understand the company's
revenue mix and prioritise the most important product categories.
*/


------------------------------------------------------------
-- Query 7
-- Business Question:
-- What percentage of category sales does each sub-category contribute?
------------------------------------------------------------

WITH sub_category_sales AS (
    SELECT
        category,
        sub_category,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
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
    ROUND(
        total_sales / NULLIF(
            SUM(total_sales) OVER (PARTITION BY category),
            0
        ) * 100,
        2
    ) AS category_sales_contribution_percent
FROM sub_category_sales
ORDER BY
    category,
    category_sales_contribution_percent DESC;

/*
Expected Output
---------------
Each sub-category's sales contribution within its parent category.

Business Insight
----------------
This query helps management understand which sub-categories drive
sales inside each category. It supports more detailed product mix
analysis and category-level planning.
*/


------------------------------------------------------------
-- Query 8
-- Business Question:
-- Which month ranked highest in sales within each year?
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
        ) AS monthly_sales_rank
    FROM monthly_sales
)

SELECT
    sales_year,
    sales_month,
    total_sales,
    total_profit,
    monthly_sales_rank
FROM ranked_months
WHERE monthly_sales_rank <= 3
ORDER BY
    sales_year,
    monthly_sales_rank;

/*
Expected Output
---------------
The top 3 sales months within each year.

Business Insight
----------------
Monthly ranking helps identify peak sales periods in each year.
This supports campaign timing, inventory preparation, and seasonal
business planning.
*/


------------------------------------------------------------
-- Query 9
-- Business Question:
-- What is the 3-month rolling average of sales?
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
        AVG(monthly_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS rolling_3_month_average_sales
FROM monthly_sales
ORDER BY sales_month;

/*
Expected Output
---------------
Monthly sales with a 3-month rolling average.

Business Insight
----------------
A rolling average smooths monthly fluctuations and provides a clearer
view of sales momentum. This is useful for identifying underlying
growth trends and reducing the impact of short-term volatility.
*/


------------------------------------------------------------
-- Query 10
-- Business Question:
-- How can products be grouped into profit quartiles?
------------------------------------------------------------

WITH product_profit AS (
    SELECT
        product_name,
        ROUND(SUM(sales), 2) AS total_sales,
        ROUND(SUM(profit), 2) AS total_profit
    FROM orders
    GROUP BY product_name
),

profit_quartiles AS (
    SELECT
        product_name,
        total_sales,
        total_profit,
        NTILE(4) OVER (
            ORDER BY total_profit DESC
        ) AS profit_quartile
    FROM product_profit
)

SELECT
    profit_quartile,
    COUNT(*) AS number_of_products,
    ROUND(SUM(total_sales), 2) AS quartile_sales,
    ROUND(SUM(total_profit), 2) AS quartile_profit,
    ROUND(AVG(total_profit), 2) AS average_profit_per_product
FROM profit_quartiles
GROUP BY profit_quartile
ORDER BY profit_quartile;

/*
Expected Output
---------------
Products grouped into four profit quartiles.

Business Insight
----------------
Profit quartile analysis helps separate high-performing products
from lower-performing products. This can support product portfolio
management, pricing review, and discontinuation decisions.
*/