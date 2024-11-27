-- 1. Знайдіть країну, яка виграла найбільше золотих медалей у конкретному році
SELECT year,
	noc,
	SUM(gold) AS total_gold
FROM ( SELECT *,
		CASE 
			WHEN medal = 'Gold' THEN 1 
			ELSE 0
		END AS gold
FROM public.olympics_medals
)
GROUP BY year,
		noc
ORDER BY total_gold DESC

-- 2. Виведіть атлетів, які виграли більше ніж одну медаль у певному році
SELECT *
FROM ( 
	SELECT year,
	athlete_name,
		COUNT(medal) athl_medals
	FROM public.olympics_medals
	WHERE medal != 'No medal'
	GROUP BY year,
		athlete_name
	ORDER BY athl_medals DESC
)
WHERE athl_medals > 1

-- 3. Виведіть перелік років, коли хоча б одна країна-господар не виграла жодної медалі
SELECT year
FROM (
	SELECT year,
		noc,
		COUNT(medal) noc_medals
	FROM public.olympics_medals
	WHERE medal != 'No medal'
		AND noc = host_noc
	GROUP BY year,
		noc
	ORDER BY noc_medals DESC
)
WHERE noc_medals = 0

-- 4. Знайдіть топ-3 країни з найбільшою кількістю медалей за всі роки
SELECT *
FROM (
	SELECT 	noc,
		COUNT(medal) noc_medals
	FROM public.olympics_medals
	WHERE medal != 'No medal'
	GROUP BY noc
)
ORDER BY noc_medals DESC
LIMIT 3	

-- 5. Знайдіть атлетів, які виграли медалі в декількох видах спорту
SELECT DISTINCT athlete_name
FROM public.olympics_medals od1
WHERE (
    SELECT COUNT(DISTINCT sport)
    FROM public.olympics_medals od2
    WHERE od1.athlete_name = od2.athlete_name
      AND od2.medal != 'No medal'
) > 1
ORDER BY athlete_name

-- 6. Виведіть країну, яка виграла найбільше медалей у певному виді спорту у всій історії Олімпіад
SELECT noc
FROM ( 
	SELECT noc,
		sport,
		COUNT(medal)
	FROM public.olympics_medals
	WHERE medal != 'No medal'
	GROUP BY noc,
		sport
	ORDER BY COUNT(medal) DESC
)
LIMIT 1

-- 7. Знайдіть атлетів, які виграли медалі і в своїй країні, і за кордоном
SELECT DISTINCT athlete_name
FROM public.olympics_medals od1
WHERE EXISTS (
    SELECT 1
    FROM public.olympics_medals od2
    WHERE od1.athlete_name = od2.athlete_name
      AND od2.medal != 'No medl'
      AND od2.noc = od2.host_noc
)
AND EXISTS (
    SELECT 1
    FROM public.olympics_medals od3
    WHERE od1.athlete_name = od3.athlete_name
      AND od3.medal != 'No medl'
      AND od3.noc != od3.host_noc
)
ORDER BY athlete_name

-- 8. Виведіть перелік країн, які ніколи не вигравали золотих медалей, але мають срібні та бронзові
SELECT noc
FROM ( 
	SELECT noc,
		SUM(CASE WHEN medal = 'Gold' THEN 1 ELSE 0 END) AS total_gold,
		SUM(CASE WHEN medal = 'Silver' THEN 1 ELSE 0 END) AS total_silver,
		SUM(CASE WHEN medal = 'Bronze' THEN 1 ELSE 0 END) AS total_bronze
	FROM public.olympics_medals
	GROUP BY noc
)
WHERE total_gold = 0
	AND total_silver > 0
	AND total_bronze > 0

-- 9. Визначте країну, яка показала найбільший ріст у загальній кількості медалей між двома послідовними іграми
SELECT noc
FROM (
	SELECT *,
		LAG(noc_medals_by_year) OVER(PARTITION BY noc) AS lag_medals,
		noc_medals_by_year - LAG(noc_medals_by_year) OVER(PARTITION BY noc) AS diff
	FROM (
		SELECT year,
			noc,
			COUNT(medal) AS noc_medals_by_year
		FROM public.olympics_medals
		WHERE medal != 'No medal'
		GROUP BY year,
			noc
		ORDER BY noc, year
	)
	ORDER BY diff DESC
)
WHERE diff IS NOT NULL
LIMIT 1











	





