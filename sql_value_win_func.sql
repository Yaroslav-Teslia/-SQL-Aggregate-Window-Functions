-- 1. Визначення значення на наступному рядку (LEAD) для рейтингу IMDB у межах року
SELECT "Movie Name",
       "Release Year",
       "IMDB Rating",
       LEAD("IMDB Rating") OVER (PARTITION BY "Release Year") AS next_imdb_rating
FROM movies;

-- 2. Визначення значення на попередньому рядку (LAG) для тривалості фільмів у межах жанру
SELECT "Movie Name",
       "Genre",
       "Duration",
       LAG("Duration") OVER (PARTITION BY "Genre") AS prev_duration
FROM movies;

-- 3. Пошук першого рейтингу IMDB для кожного жанру
WITH cte AS (
    SELECT *,
           FIRST_VALUE("IMDB Rating") OVER (PARTITION BY "Genre") AS first_movie
    FROM movies
)
SELECT "Movie Name"
FROM cte
WHERE first_movie = "IMDB Rating";

-- 4. Різниця між поточним і наступним рейтингом IMDB у межах жанру
WITH cte AS (
    SELECT *,
           LEAD("IMDB Rating") OVER (PARTITION BY "Genre") AS next_rating
    FROM movies
)
SELECT "Movie Name",
       "IMDB Rating" - next_rating AS diff_rating
FROM cte;

-- 5. Різниця голосів між поточним і наступним фільмом у межах року
WITH cte AS (
    SELECT *,
           LAG(CAST(REPLACE("Votes", ',', '') AS INTEGER)) OVER (PARTITION BY "Release Year") AS next_votes_int
    FROM movies
)
SELECT "Movie Name",
       CAST(REPLACE("Votes", ',', '') AS INTEGER) - next_votes_int AS diff_votes_lag
FROM cte;

-- 6. Пошук першого і останнього значення касових зборів у межах жанру
WITH cte AS (
    SELECT *,
           CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), 'M', '0'), '.', '') AS INTEGER) * 1000 AS gross_int
    FROM movies
    WHERE "Gross" != 'NA'
), cte1 AS (
    SELECT *,
           FIRST_VALUE(gross_int) OVER (PARTITION BY "Genre") AS first_movie,
           LAST_VALUE(gross_int) OVER (PARTITION BY "Genre") AS last_movie
    FROM cte
)
SELECT "Movie Name"
FROM cte1
WHERE gross_int IN (first_movie, last_movie);

-- 7. Пошук максимального приросту касових зборів між фільмами в межах жанру
WITH cte AS (
    SELECT *,
           CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), 'M', '0'), '.', '') AS INTEGER) * 1000 AS gross_int
    FROM movies
    WHERE "Gross" != 'NA'
), cte1 AS (
    SELECT *,
           LAG(gross_int) OVER (PARTITION BY "Genre") AS lag_gross
    FROM cte
), cte2 AS (
    SELECT *,
           gross_int - lag_gross AS diff_gros,
           MAX(gross_int - lag_gross) OVER (PARTITION BY "Genre") AS max_diff_gross
    FROM cte1
)
SELECT "Movie Name"
FROM cte2
WHERE diff_gros = max_diff_gross;

-- 8. Різниця рейтингу IMDB між поточним і першим фільмом у межах режисера
SELECT *,
       "IMDB Rating" - first_value_by_director AS diff_rating
FROM (
    SELECT *,
           FIRST_VALUE("IMDB Rating") OVER (PARTITION BY "Director") AS first_value_by_director
    FROM movies
);

-- 9. Різниця рейтингу IMDB між поточним і останнім фільмом у межах року
SELECT *,
       "IMDB Rating" - last_value_by_year AS diff_rating
FROM (
    SELECT *,
           LAST_VALUE("IMDB Rating") OVER (PARTITION BY "Release Year") AS last_value_by_year
    FROM movies
);


