--15 Business Problems

-- 1. Count the number of movies vs tv shows
SELECT 
	type, 
	COUNT(*) AS content_number
FROM appletv
GROUP BY type

-- 2. Find the most common imdb rating for movies and tv shows
SELECT
	type,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY imdb_avg_rating) AS median
FROM appletv
GROUP BY type

-- 3. List all movies released in 1987
SELECT *
FROM appletv
WHERE release_year = 1987 
	  AND 
	  type = 'movie'

-- 4. Find the top 5 countries with the most content on Apple TV
SELECT 
	UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country, 
	COUNT(*) AS content_number
FROM appletv
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 5. Find 10 movies and 10 TV series with the highest IMDB rating among those, that have more than 10000 votes.
WITH filtered_data AS (
	SELECT *
	FROM appletv
	WHERE imdb_num_votes > 10000
),
top_ten_movies AS (
	SELECT *
	FROM filtered_data
	WHERE type = 'movie'
	ORDER BY imdb_avg_rating DESC
	LIMIT 10
),
top_ten_tv AS (
	SELECT *
	FROM filtered_data
	WHERE type = 'tv'
	ORDER BY imdb_avg_rating DESC
	LIMIT 10
)

SELECT *
FROM top_ten_movies
UNION ALL
SELECT * 
FROM top_ten_tv
ORDER BY type, imdb_avg_rating DESC

-- 6. Find content added in the last 5 years
SELECT *
FROM appletv
WHERE release_year >= EXTRACT(YEAR FROM (CURRENT_DATE - INTERVAL '5 years'))

-- 7. Find an average IMDB rating and average number of IMDB votes for each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(genres, ', ')) AS genre, 
	ROUND(AVG(imdb_avg_rating), 2) AS avg_rating,
	ROUND(AVG(imdb_num_votes)) AS avg_num_of_votes
FROM appletv
GROUP BY genre
HAVING AVG(imdb_avg_rating) IS NOT NULL
ORDER BY 2 DESC, 3 DESC

-- 8. How much content was released each year from the perspective of type?
SELECT 
	type, 
	release_year, 
	COUNT(*) AS content_count
FROM appletv
WHERE release_year IS NOT NULL
GROUP BY type, release_year
ORDER BY release_year

-- 9. Count the number of content items in each genre
SELECT 
	UNNEST(STRING_TO_ARRAY(genres, ', ')) AS genre, 
	COUNT(*) AS count
FROM appletv
WHERE genres IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC

-- 10. Find each release year and the number of content available for Ukraine on Apple TV. Return top 5 years with the highest content availability.
WITH country_split AS (
	SELECT 
		*, 
		UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country
	FROM appletv)
SELECT 
	country, 
	release_year, 
	COUNT(*) AS available_content
FROM country_split
WHERE country = 'UA'
GROUP BY country, release_year
ORDER BY available_content DESC
LIMIT 5

-- 11. Find the quantity of TV series and movies that belong to several genres simultaneously
SELECT 
	type, 
	COUNT(*) AS multi_genre_count
FROM appletv
WHERE genres LIKE '%,%'
GROUP BY type

-- 12. Which 5 countries have the highest average IMDb rating of the available content.
SELECT 
	UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country,
	ROUND(AVG(imdb_avg_rating), 2)
FROM appletv
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- 13. Find the best movie or tv series by imdb rating for each release year
WITH ranks AS (
	SELECT 
	title, 
	type, 
	release_year, 
	imdb_avg_rating,
	RANK() OVER(PARTITION BY release_YEAR ORDER BY imdb_avg_rating DESC)
FROM appletv
WHERE imdb_avg_rating IS NOT NULL
)

SELECT *
FROM ranks
WHERE rank = 1

-- 14. Find the years when content with the highest IMDb rating was released.
SELECT 
	release_year, 
	ROUND(AVG(imdb_avg_rating), 2) AS rating,
	COUNT(*) AS film_count
FROM appletv
GROUP BY release_year
HAVING AVG(imdb_avg_rating) IS NOT NULL AND COUNT(*) > 10
ORDER BY 2 DESC

-- 15. Find top 5 movies and tv series that are available in the biggest number of countries.
WITH films_countries AS (
	SELECT 
		UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country,
		title
	FROM appletv
)

SELECT 
	title, 
	COUNT(country) AS countries_count
FROM films_countries
WHERE title IS NOT NULL
GROUP BY title
ORDER BY 2 DESC
LIMIT 5