CREATE DATABASE Churn;
SELECT * FROM customer_churn;

-- 1. Number of registered new customer each month
SELECT 
	DATE_FORMAT(`reg date`, '%Y') AS reg_year,
    DATE_FORMAT(`reg date`, '%m') AS reg_month,
    COUNT(*) AS customer_reg
FROM customer_churn
GROUP BY reg_year, reg_month
ORDER BY reg_year, reg_month;

-- 2. Most churn reason
SELECT `churn reason`, COUNT(*) AS total
FROM customer_churn
WHERE `Churn Label` = "Yes"
GROUP BY `churn reason`
ORDER BY total DESC;

-- 3. Total churn by month
SELECT
    DATE_FORMAT(`reg date`, '%Y-%m') AS month,
    SUM(
        CASE
            WHEN `churn label` = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_churn
FROM customer_churn
GROUP BY month
ORDER BY month;

-- 4. Churn rate by monthly charge bin
SELECT
	CASE
		WHEN `monthly charge` < 10 THEN 'Less Than $10'
        WHEN `monthly charge` BETWEEN 10 AND 20 THEN '$10 to $20'
        WHEN `monthly charge` BETWEEN 20 AND 30 THEN '$20 to $30'
        WHEN `monthly charge` BETWEEN 30 AND 40 THEN '$30 to $40'
        WHEN `monthly charge` > 40 THEN 'More Than $40'
	END AS charge_bin,
    SUM(
        CASE
            WHEN `churn label` = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_churn,
COUNT(*) AS total_customer,

    ROUND(
        SUM(CASE WHEN `churn label` = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY charge_bin;

-- 5. Churn rate by monthly comsumption in GB
SELECT
	CASE
		WHEN `avg monthly gb download` < 10 THEN 'Less Than 10 GB'
        WHEN `avg monthly gb download` BETWEEN 10 AND 20 THEN '10 GB to 20 GB'
        WHEN `avg monthly gb download` BETWEEN 20 AND 30 THEN '20 GB to 30 GB'
        WHEN `avg monthly gb download` BETWEEN 30 AND 40 THEN '30 GB to 40 GB'
        WHEN `avg monthly gb download` > 40 THEN 'More Than 40 GB'
	END AS gb_bin,
	SUM(
        CASE
            WHEN `churn label` = 'Yes' THEN 1
            ELSE 0
        END
    ) AS total_churn,
	COUNT(*) AS total_customer,
	ROUND(
        SUM(CASE WHEN `churn label` = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS churn_rate
FROM customer_churn
GROUP BY gb_bin;

-- 6. Churn rate by state
SELECT
	State,
    SUM(
        CASE
            WHEN `churn label` = 'Yes' THEN 1
            ELSE 0
        END
    ) AS `Total Churn`,
	COUNT(*) AS `Total Customer`,
	ROUND(
        SUM(CASE WHEN `churn label` = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS `Churn Rate (%)`
FROM customer_churn
GROUP BY state
ORDER BY `Total Customer` DESC;

-- 7. Monthly revenue
WITH RECURSIVE monthly_revenue AS (
    -- Pendapatan sejak bulan registrasi
    SELECT
        `customer id`,
        `monthly charge`,
        `reg date`,
        `churn date`,
        `churn label`,
        DATE_FORMAT(`reg date`, '%Y-%m-01') AS revenue_month
    FROM customer_churn

    UNION ALL

    -- Membuat baris untuk bulan berikutnya
    SELECT
        `customer id`,
        `monthly charge`,
        `reg date`,
        `churn date`,
        `churn label`,
        DATE_ADD(revenue_month, INTERVAL 1 MONTH)
    FROM monthly_revenue
    WHERE DATE_ADD(revenue_month, INTERVAL 1 MONTH)
          < DATE_FORMAT(CURDATE(), '%Y-%m-01')
      AND (
          `churn label` = 'No'
          OR DATE_ADD(revenue_month, INTERVAL 1 MONTH)
             < DATE_FORMAT(`churn date`, '%Y-%m-01')
      )
)

SELECT
    DATE_FORMAT(revenue_month, '%Y-%m') AS month,
    SUM(`monthly charge`) AS monthly_revenue
FROM monthly_revenue
GROUP BY revenue_month
ORDER BY revenue_month;

-- 8. Revenue for a specific month prorated
SELECT
    '2025-01' AS month,

    ROUND(
        SUM(
            `monthly charge` *
            (
                DATEDIFF(
                    LEAST(
                        COALESCE(`churn date`, '2025-02-01'),
                        '2025-02-01'
                    ),
                    GREATEST(`reg date`, '2025-01-01')
                )
                / DAY(LAST_DAY('2025-01-01'))
            )
        ),
        2
    ) AS prorated_revenue

FROM customer_churn

WHERE
    `reg date` < '2025-02-01'
    AND (
        `churn label` = 'No'
        OR `churn date` > '2025-01-01'
    ); 
