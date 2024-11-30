-- 1. Виведіть кількість медалей, виграних кожною країною в певному році
SELECT noc,
	year,
	COUNT(medal)
FROM public.olympics_medals
WHERE medal != 'No medal'
GROUP BY noc,
	year
ORDER BY noc,
	year

-- 2. Підрахуйте загальну кількість медалей для кожного атлета
SELECT athlete_name,
	COUNT(medal)
FROM public.olympics_medals
WHERE medal != 'No medal'
GROUP BY athlete_name
ORDER BY athlete_name

-- 3. Знайдіть країни, які виграли більше 50 медалей за весь час
SELECT noc,
	COUNT(medal)
FROM public.olympics_medals
WHERE medal != 'No medal'
GROUP BY noc
HAVING COUNT(medal) > 50
ORDER BY COUNT(medal) DESC

-- 4. Виведіть роки, в яких певна країна виграла найбільше медалей
WITH country_medals AS (
    SELECT 
        year,
        noc,
        COUNT(medal) AS total_medals
    FROM public.olympics_medals
    WHERE medal != 'No medal'
    GROUP BY year, noc
)
SELECT year, noc, total_medals
FROM country_medals
WHERE noc = 'USA' 
  AND total_medals = (
      SELECT MAX(total_medals)
      FROM country_medals AS cm
      WHERE cm.year = country_medals.year
  )
ORDER BY year

-- 5. Знайдіть атлетів, які вигравали медалі у двох і більше різних видах спорту
WITH cte AS (
	SELECT athlete_name,
		sport
	FROM public.olympics_medals
	WHERE medal != 'No medal'
)
SELECT athlete_name,
	COUNT(DISTINCT sport)
FROM cte
GROUP BY athlete_name
HAVING COUNT(DISTINCT sport) > 1

-- 6. Підрахуйте кількість медалей, виграних країною на "домашніх" Олімпійських іграх
WITH cte AS (
	SELECT *
	FROM public.olympics_medals
	WHERE noc = host_noc
)
SELECT noc,
	COUNT(medal) AS total_medal
FROM cte
WHERE medal != 'No medal'
GROUP BY noc

-- 7. Визначте країну з найбільшим середнім ростом медалей між послідовними Олімпіадами
WITH cte AS (
    SELECT noc,
           year,
           COUNT(medal) AS total_medals
    FROM public.olympics_medals
    WHERE medal != 'No medal'
    GROUP BY noc, year
),
growth AS (
    SELECT noc,
           year,
           total_medals,
           LAG(total_medals) OVER (PARTITION BY noc ORDER BY year) AS prev_medals
    FROM cte
)
SELECT noc,
       AVG(total_medals - prev_medals) AS avg_growth
FROM growth
WHERE prev_medals IS NOT NULL
GROUP BY noc
ORDER BY avg_growth DESC
LIMIT 1


-- 8. Знайдіть атлетів, які вигравали медалі в кожному Олімпійському циклі, у якому брали участь
WITH athlete_years AS (
    SELECT athlete_name,
           COUNT(DISTINCT year) AS total_years
    FROM public.olympics_medals
    GROUP BY athlete_name
),
athlete_medal_years AS (
    SELECT athlete_name,
           COUNT(DISTINCT year) AS medal_years
    FROM public.olympics_medals
    WHERE medal != 'No medal'
    GROUP BY athlete_name
)
SELECT a.athlete_name
FROM athlete_years a
JOIN athlete_medal_years b
  ON a.athlete_name = b.athlete_name
WHERE a.total_years = b.medal_years


-- 9. Виведіть країну, яка показала найбільший спад у кількості медалей між двома послідовними іграми
WITH cte AS (
    SELECT noc,
           year,
           COUNT(medal) AS total_medals
    FROM public.olympics_medals
    WHERE medal != 'No medal'
    GROUP BY noc, year
),
decline AS (
    SELECT noc,
           year,
           total_medals,
           LAG(total_medals) OVER (PARTITION BY noc ORDER BY year) AS prev_medals
    FROM cte
)
SELECT noc,
       MIN(prev_medals - total_medals) AS max_decline
FROM decline
WHERE prev_medals IS NOT NULL
GROUP BY noc
ORDER BY max_decline DESC
LIMIT 1

















