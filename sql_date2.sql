-- 1. Перетворіть дату на текст у форматі YYYY-MM-DD HH24:MI:SS
SELECT invoice_no,
	CAST(invoice_date AS TEXT)
FROM customers

-- 2. Відобразіть різницю у днях між invoice_date та сьогоднішньою датою
SELECT *,
	CURRENT_DATE - invoice_date AS diff_days
FROM customers

-- 3. Перевірте, чи є значення в колонці invoice_date валідною датою
SELECT *,
CASE
    WHEN invoice_date ~ '^\d{4}-\d{2}-\d{2}$' 
         AND invoice_date::DATE IS NOT NULL THEN 'is_valid_date'
    ELSE 'not_valid_date'
END AS valid_date
FROM customers

-- 4. Визначте, в якому кварталі сталася транзакція
SELECT invoice_no,
	invoice_date,
	DATE_PART('quarter', invoice_date) 
FROM customers

-- 5. Підрахуйте різницю у місяцях між двома датами
SELECT *,
EXTRACT(YEAR FROM AGE(invoice_date, '2023-01-01'::DATE)) * 12 +
EXTRACT(MONTH FROM AGE(invoice_date, '2023-01-01'::DATE)) AS diff_months
FROM customers

-- 6. Додайте 30 днів до кожної транзакції
SELECT *,
	invoice_date + INTERVAL '30 days' AS new_date
FROM customers

-- 7. Знайдіть усі транзакції, які відбулися в останній тиждень місяця
WITH cte AS (
	SELECT *,
		DATE_TRUNC('month', invoice_date) + INTERVAL '1 month' - INTERVAL '1 day' AS last_day_month
	FROM customers
)
SELECT *
FROM cte
WHERE invoice_date BETWEEN last_day_month -  INTERVAL '6 days' AND last_day_month 

-- 8. Підрахуйте кількість днів між транзакціями для кожного рахунка
SELECT invoice_no,
	LAG(invoice_date) OVER(PARTITION BY invoice_no ORDER BY invoice_date),
	invoice_date - LAG(invoice_date) OVER(PARTITION BY invoice_no ORDER BY invoice_date)
FROM customers

-- 9. Перетворіть текстовий формат дати на стандартний формат дати
SELECT '2024/11/16'::DATE









