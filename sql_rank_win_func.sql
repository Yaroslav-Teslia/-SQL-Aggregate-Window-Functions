-- 1. Присвоєння рейтингу фільмам за рейтингом IMDB у межах жанру
SELECT "Movie Name",
       "Genre",
       "IMDB Rating",
       RANK() OVER (PARTITION BY "Genre" ORDER BY "IMDB Rating" DESC) AS rank_in_genre
FROM movies;

-- 2. Нумерація фільмів у межах кожного року за кількістю голосів
SELECT "Movie Name",
       "Release Year",
       "Votes",
       ROW_NUMBER() OVER (PARTITION BY "Release Year" ORDER BY CAST(REPLACE("Votes", ',', '') AS INTEGER) DESC) AS row_number_in_year
FROM movies;

-- 3. Додавання порядкового номера до фільмів за загальним касовим збором
WITH cte AS (
    SELECT *,
           CAST(REPLACE(REPLACE(REPLACE("Gross", '$', ''), 'M', '0'), '.', '') AS INTEGER) * 1000 AS gross_int
    FROM movies
    WHERE "Gross" != 'NA'
)
SELECT "Movie Name",
       "Gross",
       RANK() OVER (ORDER BY gross_int DESC) AS rank_by_gross
FROM cte;

-- 4. Визначення фільмів із найвищим рейтингом для кожного режисера за допомогою DENSE_RANK
SELECT "Director",
       "Movie Name",
       "IMDB Rating",
       DENSE_RANK() OVER (PARTITION BY "Director" ORDER BY "IMDB Rating" DESC) AS dense_rank_in_director
FROM movies;

-- 5. Визначення жанру, у якому фільми найчастіше займають перші позиції у своєму році
WITH ranked_movies AS (
    SELECT "Genre",
           "Release Year",
           RANK() OVER (PARTITION BY "Release Year", "Genre" ORDER BY "IMDB Rating" DESC) AS rank_in_year_genre
    FROM movies
)
SELECT "Genre",
       COUNT(*) AS first_place_count
FROM ranked_movies
WHERE rank_in_year_genre = 1
GROUP BY "Genre"
ORDER BY first_place_count DESC;

-- 6. Нумерація фільмів за тривалістю у межах жанру
SELECT "Movie Name",
       "Genre",
       "Duration",
       ROW_NUMBER() OVER (PARTITION BY "Genre" ORDER BY "Duration" DESC) AS row_number_by_duration
FROM movies;

-- 7. Визначення порядкового номера режисера за середнім рейтингом його фільмів
WITH director_avg_rating AS (
    SELECT "Director",
           ROUND(AVG("IMDB Rating") OVER (PARTITION BY "Director"), 2) AS avg_rating
    FROM movies
)
SELECT "Director",
       avg_rating,
       RANK() OVER (ORDER BY avg_rating DESC) AS rank_by_avg_rating
FROM director_avg_rating;

-- 8. Пошук року, в якому жанр мав найбільшу кількість голосів (голоси розраховані без форматування)
WITH cte AS (
    SELECT "Release Year",
           "Genre",
           CAST(REPLACE("Votes", ',', '') AS INTEGER) AS votes_int
    FROM movies
)
SELECT "Release Year",
       "Genre",
       SUM(votes_int) AS total_votes,
       RANK() OVER (PARTITION BY "Release Year" ORDER BY SUM(votes_int) DESC) AS rank_genre_by_votes
FROM cte
GROUP BY "Release Year", "Genre";

-- 9. Визначення фільмів, які не є унікальними за тривалістю у межах жанру
WITH cte AS (
    SELECT "Movie Name",
           "Genre",
           "Duration",
           COUNT(*) OVER (PARTITION BY "Genre", "Duration") AS duration_count
    FROM movies
)
SELECT "Movie Name",
       "Genre",
       "Duration"
FROM cte
WHERE duration_count > 1
ORDER BY "Genre", "Duration";
