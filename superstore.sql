SELECT * FROM superstore_sales;
-- Case Study Questions

-- 1. What is the total amount each customer spent?
SELECT
	customer_id,
    ROUND(SUM(sales)) AS total_spend
FROM superstore_sales
GROUP BY Customer_ID
ORDER BY total_spend DESC;

-- 2. What is total order, sales, profit, and margin for each year?
SELECT
	YEAR(STR_TO_DATE(order_date, '%d/%m/%Y')) AS year,
    COUNT(*) AS num_order,
    ROUND(SUM(sales)) AS sales,
    ROUND(SUM(profit)) AS profit,
    ROUND(SUM(profit) / SUM(sales),4) as profit_margin
FROM superstore_sales
GROUP BY year
ORDER BY year;

-- 3. What is the percentage of revenue share by segment?
SELECT 
	segment, 
    ROUND(SUM(sales)) AS sales,
    ROUND(SUM(sales) * 100/(SELECT SUM(sales) from superstore_sales),2) AS percentage
FROM superstore_sales
GROUP BY segment;

-- 4. What is the number of customers purchase every month?
SELECT
	YEAR(STR_TO_DATE(order_date, '%d/%m/%Y')) AS year,
    MONTH(STR_TO_DATE(order_date, '%d/%m/%Y')) AS month,
    COUNT(customer_id) AS total_customers
FROM superstore_sales
GROUP BY year, month
ORDER BY year, month;

-- 5. Which year and month has most sales?
SELECT
	YEAR(STR_TO_DATE(order_date, '%d/%m/%Y')) AS year,
    MONTH(STR_TO_DATE(order_date, '%d/%m/%Y')) AS month,
    ROUND(SUM(sales)) AS total_sales
FROM superstore_sales
GROUP BY year, month
ORDER BY total_sales DESC
LIMIT 1;

-- 6. What is the top 3 states has highest sales?
SELECT
	state,
    ROUND(SUM(sales)) AS total_sales
FROM superstore_sales
GROUP BY state
ORDER BY total_sales DESC
LIMIT 3;

-- 7. What is the top 3 subcategory has most revenue?
SELECT
	sub_category,
    ROUND(SUM(sales)) AS total_sales
FROM superstore_sales
GROUP BY Sub_Category
ORDER BY total_sales DESC
LIMIT 3;