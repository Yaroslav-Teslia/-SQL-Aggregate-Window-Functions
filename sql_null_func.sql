-- 1. Знайти всі фільми, у яких значення Metascore є NULL
SELECT *
FROM movies
WHERE "Metascore" IS NULL

-- 2. Замінити значення Gross = 'NA' на "0" у новій колонці gross_clean
SELECT *,
	CASE
		WHEN "Gross" = 'NA' THEN '0' 
		ELSE "Gross"
	END AS gross_clean
FROM movies

-- 3. Вивести фільми без вказаних режисерів
SELECT *
FROM movies
WHERE "Director" IS NULL

-- 4. Знайти всі фільми, де значення Votes менше 100000 або є NULL
SELECT *,
	CAST(REPLACE("Votes", ',', '') AS INTEGER) AS votes_int
FROM movies
WHERE CAST(REPLACE("Votes", ',', '') AS INTEGER) < 100000
	OR "Votes" IS NULL

-- 5. Використати COALESCE, щоб замінити значення NULL у Metascore середнім значенням по всіх фільмах
SELECT *,
	COALESCE("Metascore", avg_score) metascore_clean
FROM (
	SELECT *,
		ROUND(AVG("Metascore") OVER(), 1) avg_score
	FROM movies
	)
	
-- 6. Перевірити, які значення IMDB Rating не є NULL і більші за 8
SELECT *
FROM movies
WHERE 1=1
	AND "IMDB Rating" IS NOT NULL
	AND "IMDB Rating" > 8

-- 7. Розрахувати різницю між IMDB Rating і середнім рейтингом жанру, замінивши NULL у IMDB Rating на 0
SELECT *,
	COALESCE("IMDB Rating", 0) rating_clean,
	ROUND(AVG(COALESCE("IMDB Rating", 0)) OVER(PARTITION BY "Genre"), 1) avg_rating,
	"IMDB Rating" - ROUND(AVG(COALESCE("IMDB Rating", 0)) OVER(PARTITION BY "Genre"), 1) diff_rating
FROM movies

-- 8. Вивести список фільмів із NULL у Gross, додавши колонку, яка покаже "Unknown Revenue"
SELECT *,
	COALESCE("Gross", 'Unknown Revenue') new_gross
FROM movies
WHERE "Gross" IS NULL

-- 9. Порахувати кількість фільмів у кожному жанрі, де хоча б одна з колонок (Metascore, Votes, Gross) є NULL
SELECT "Genre", COUNT(*) AS count_by_genre
FROM movies
WHERE "Metascore" IS NULL
   OR "Votes" IS NULL
   OR "Gross" IS NULL
GROUP BY "Genre"



















