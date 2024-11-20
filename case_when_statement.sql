-- 1. Категоризація фільмів за тривалістю
SELECT *,
	CASE 
		WHEN "Duration" < 90 THEN 'Short'
		WHEN "Duration" <= 120 THEN 'Medium'
		ELSE 'Large'
	END AS duration_level
FROM movies

-- 2. Позначення популярності за кількістю голосів
SELECT *,
	CASE 
		WHEN CAST(REPLACE("Votes", ',', '') AS INTEGER) < 100000 THEN 'Low Popularity'
		WHEN CAST(REPLACE("Votes", ',', '') AS INTEGER) <= 1000000 THEN 'Moderate Popularity'
		ELSE 'High Popularity'
	END AS nmb_of_population
FROM movies

-- 3. Перевірка наявності касових зборів
SELECT *,
	CASE 
		WHEN "Gross" != 'NA' THEN 'Has Gross'
		ELSE 'No Gross'
	END AS gross_check
FROM movies

-- 4. Категоризація фільмів за рейтингом IMDB
SELECT *,
	CASE 
		WHEN "IMDB Rating" >= 8 THEN 'Excellent'
		WHEN "IMDB Rating" >= 6 THEN 'Good'
		ELSE 'Poor'
	END AS rating_var
FROM movies

-- 5. Порівняння касових зборів з середнім жанру
WITH cte AS (
	SELECT *, 
		CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), '.', ''), 'M', '0000') AS INTEGER) AS gross_int
	FROM movies
	WHERE "Gross" != 'NA'
)
SELECT *,
	CASE 
		WHEN gross_int > AVG(gross_int) OVER (PARTITION BY "Genre")  THEN 'Above Average'
		ELSE 'Below Average'
	END AS gross_var
FROM cte

-- 6. Позначення дебютних фільмів режисера
WITH cte AS (
	SELECT *, 
		FIRST_VALUE("Release Year") OVER(PARTITION BY "Director" ORDER BY "Release Year") AS first_movie_year
	FROM movies
)
SELECT *,
	CASE 
		WHEN first_movie_year = "Release Year" THEN 'Debut'
		ELSE 'Not Debut'
	END AS check_debut
FROM cte

-- 7. Класифікація фільмів за роком випуску
SELECT *,
CASE 
	WHEN "Release Year" < 1980 THEN 'Classic'
	WHEN "Release Year" < 2000 THEN 'Modern'
	ELSE 'Contemporary'
END AS movie_type
FROM movies

-- 8. Позначення успішних фільмів
WITH cte AS (
	SELECT *,
		CAST(REPLACE("Votes", ',', '') AS INTEGER) AS votes_int,
		CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), '.', ''), 'M', '0000') AS INTEGER) AS groos_int
	FROM movies
	WHERE "Gross" != 'NA'
)
SELECT *,
CASE 
	WHEN "IMDB Rating" >= 8 	THEN 'Hit'
	WHEN votes_int > 500000 	THEN 'Hit'
	WHEN groos_int > 100000000 	THEN 'Hit'
	ELSE 'Average'
END AS success_check
FROM cte

-- 9. Підрахунок рейтингу фільмів на основі декількох умов
SELECT *,
       (CASE 
            WHEN "IMDB Rating" >= 8 THEN 2 
            ELSE 0 
        END) +
       (CASE 
            WHEN CAST(REPLACE("Votes", ',', '') AS INTEGER) > 100000 THEN 1 
            ELSE 0 
        END) +
       (CASE 
            WHEN "Duration" < 90 THEN -1 
            ELSE 0 
        END) AS "Movie Score"
FROM movies
