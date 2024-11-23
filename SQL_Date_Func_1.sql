/* 1. Виведіть номер рахунка (invoice_no) та рік із дати транзакції (invoice_date) */
SELECT invoice_no,
	EXTRACT(year FROM invoice_date) AS year
FROM customers

/* 2. Додайте стовпець, який показує, у який день тижня відбулася транзакція */
SELECT *,
	TO_CHAR (invoice_date, 'FMDay') day_name
FROM customers

/* 3. Виберіть усі транзакції, що відбулися у 2023 році */
SELECT *
FROM customers
WHERE EXTRACT(year FROM invoice_date) = 2023

/* 4. Підрахуйте загальну кількість проданих товарів (quantity) для кожного місяця */
WITH cte AS (
	SELECT *,
		TO_CHAR(invoice_date, 'FMMonth') month_name
	FROM customers
)
SELECT SUM(quantity) quan_month,
	month_name
FROM cte
GROUP BY month_name 

/* 5. Додайте стовпець, який показує останній день місяця для кожної транзакції */
SELECT *,
	(DATE_TRUNC('month', invoice_date::DATE) + INTERVAL '1 month' - INTERVAL '1 day')::DATE end_of_month
FROM customers

/* 6. Підрахуйте загальну кількість транзакцій за кожен рік */
SELECT 
	EXTRACT(year FROM invoice_date) AS year,
	COUNT(*)
FROM customers
GROUP BY EXTRACT(year FROM invoice_date)

/* 7. Підрахуйте кількість транзакцій, здійснених у суботу та неділю */
SELECT 
	TO_CHAR(invoice_date, 'FMDay') AS day,
	COUNT(*)
FROM customers
GROUP BY TO_CHAR(invoice_date, 'FMDay')
HAVING TO_CHAR(invoice_date, 'FMDay') IN ('Sunday', 'Saturday')

/* 8. Розрахуйте загальну суму покупок (quantity * price) для кожного кварталу */
SELECT 
	DATE_PART('quarter', invoice_date) AS quarter,
	DATE_PART('year', invoice_date) AS year,
	SUM(quantity * price)
FROM customers
GROUP BY DATE_PART('quarter', invoice_date),
	DATE_PART('year', invoice_date)

/* 9. Знайдіть місяць із найбільшою кількістю транзакцій за весь період */
SELECT 
	TO_CHAR(invoice_date, 'FMMonth') AS month,
	DATE_PART('year', invoice_date) AS year,
	COUNT(*) count_of_month
FROM customers
GROUP BY TO_CHAR(invoice_date, 'FMMonth'),
	DATE_PART('year', invoice_date)
ORDER BY count_of_month DESC
LIMIT 1
