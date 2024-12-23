-- 1. Підрахунок фільмів за роками
SELECT "Movie Name",
       "Release Year",
       COUNT(*) OVER (PARTITION BY "Release Year") AS nmb_in_the_year
FROM movies
ORDER BY nmb_in_the_year DESC;

-- 2. Середня тривалість фільмів за жанром
SELECT "Movie Name",
       ROUND(AVG("Duration") OVER (PARTITION BY "Genre"), 0) AS avg_duration_by_genre
FROM movies;

-- 3. Максимальний рейтинг IMDB у кожному жанрі
SELECT *,
       MAX("IMDB Rating") OVER (PARTITION BY "Genre") AS max_rating_by_genre
FROM movies;

-- 4. Касові збори в жанрі
WITH cte AS (
    SELECT *, 
           CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), 'M', ''), '.', '') AS INTEGER) AS gross_clean
    FROM movies
    WHERE "Gross" != 'NA'
)
SELECT *,
       SUM(gross_clean) OVER (PARTITION BY "Genre") AS sum_gross_by_genre
FROM cte;

-- 5. Середня оцінка Metascore для кожного режисера
SELECT *,
       ROUND(AVG("Metascore") OVER (PARTITION BY "Director"), 2) AS avg_metascore_by_director
FROM movies
WHERE "Metascore" IS NOT NULL;

-- 6. Фільм із мінімальною тривалістю в кожному жанрі
WITH cte AS (
    SELECT * ,
           MIN("Duration") OVER (PARTITION BY "Genre") AS min_duration_by_genre
    FROM movies
)
SELECT "Movie Name",
       "Duration"
FROM cte
WHERE min_duration_by_genre = "Duration";

-- 7. Зростання кількості голосів у межах року
WITH cte AS (
    SELECT *,
           CAST(REPLACE("Votes", ',', '') AS INTEGER) AS votes_int
    FROM movies
)
SELECT *,
       lag_votes - votes_int AS diff_votes
FROM (
    SELECT *,
           LAG(votes_int) OVER (PARTITION BY "Release Year") AS lag_votes
    FROM cte
);

-- 8. Рейтинг IMDB у межах режисера
WITH cte AS (
    SELECT *,
           MAX("IMDB Rating") OVER (PARTITION BY "Director") AS max_director_rating
    FROM movies
)
SELECT "Director",
       "Movie Name",
       "IMDB Rating"
FROM cte
WHERE "IMDB Rating" = max_director_rating;

-- 9. Найбільш прибутковий жанр по роках
WITH cte AS (
    SELECT *,
           CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), 'M', '0'), '.', '') AS INTEGER) * 1000 AS gross_int
    FROM movies
    WHERE "Gross" != 'NA'
)
SELECT "Release Year",
       "Genre",
       gross_int,
       MAX(gross_int) OVER (PARTITION BY "Release Year", "Genre") AS max_gross_by_year_genre
FROM cte;

