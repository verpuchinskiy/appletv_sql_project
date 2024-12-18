# Apple TV+ Movies and TV Shows Data Analysis with SQL

![](https://github.com/verpuchinskiy/appletv_sql_project/blob/main/logo.jpg)

## Overview
This project involves a comprehensive analysis of Apple TV+ content data using SQL. Its goal is to extract meaningful insights and answer various business questions regarding content distribution, audience preferences and platform reach. By diving into this dataset, the project uncovers trends in IMDb ratings, genre popularity, content availability across countries and much more.
This README outlines the project's objectives, business questions, solutions, key findings and conclusions.

## Objectives
The primary objectives of this project are:
1. To analyze the distribution and trends in content types (movies vs TV shows) on Apple TV+.
2. To explore IMDb ratings, votes, and genres for identifying the most popular and critically acclaimed content.
3. To study regional availability and popularity trends.
4. To uncover patterns in multi-genre content, release trends, and top-rated items by various criteria.

## Dataset
The data for this project is taken from the Kaggle dataset:
- **Dataset Link:** [Apple TV+ Dataset](https://www.kaggle.com/datasets/octopusteam/full-apple-tv-dataset)

## Schema

```sql
DROP TABLE IF EXISTS appletv;
CREATE TABLE appletv
(
    title               VARCHAR(150),
    type                VARCHAR(6),
    genres              VARCHAR(50),
    release_year        INT,
    imdb_id             VARCHAR(10),
    imdb_avg_rating     NUMERIC,
    imdb_num_votes      INT,
    available_countries VARCHAR(350)
);
```

## Problems and Solutions

### 1. Count the number of movies vs tv shows

```sql
SELECT 
	type, 
	COUNT(*) AS content_number
FROM appletv
GROUP BY type
```

**Objective:** Determine the distribution of content types (movies vs TV shows) on Apple TV+ to analyze the balance between the two categories.

### 2. Find the most common IMDb rating for movies and tv shows

```sql
SELECT
	type,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY imdb_avg_rating) AS median
FROM appletv
GROUP BY type
```

**Objective:** Identify the typical audience reception of movies and TV shows by analyzing the most frequently occurring IMDb ratings.

### 3. List all movies released in 1987

```sql
SELECT *
FROM appletv
WHERE 	release_year = 1987 
	AND 
	type = 'movie'
```

**Objective:** Analyze the content catalog for a specific year to understand the availability of older movies on Apple TV+.

### 4. Find the top 5 countries with the most content on Apple TV

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country, 
	COUNT(*) AS content_number
FROM appletv
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

**Objective:** Determine which countries have the largest Apple TV+ libraries, providing insight into the platform's geographic reach and focus.

### 5. Find 10 movies and 10 TV series with the highest IMDb rating among those, that have more than 10000 votes.

```sql
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
```

**Objective:** Highlight the top-performing movies and TV shows in terms of IMDb ratings to showcase critically acclaimed and audience-approved content.

### 6. Find content added in the last 5 years

```sql
SELECT *
FROM appletv
WHERE release_year >= EXTRACT(YEAR FROM (CURRENT_DATE - INTERVAL '5 years'))
```

**Objective:** Analyze the recency of Apple TV+ content and identify the size of the library consisting of modern releases.

### 7. Find an average IMDb rating and average number of IMDb votes for each genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(genres, ', ')) AS genre, 
	ROUND(AVG(imdb_avg_rating), 2) AS avg_rating,
	ROUND(AVG(imdb_num_votes)) AS avg_num_of_votes
FROM appletv
GROUP BY genre
HAVING AVG(imdb_avg_rating) IS NOT NULL
ORDER BY 2 DESC, 3 DESC
```

**Objective:** Understand the performance of different genres by comparing their average IMDb ratings and audience engagement.

### 8. How much content was released each year from the perspective of type?

```sql
SELECT 
	type, 
	release_year, 
	COUNT(*) AS content_count
FROM appletv
WHERE release_year IS NOT NULL
GROUP BY type, release_year
ORDER BY release_year
```

**Objective:** Explore release trends over time and identify whether Apple TV+ focuses more on movies or TV shows in specific years.

### 9. Count the number of content items in each genre

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(genres, ', ')) AS genre, 
	COUNT(*) AS count
FROM appletv
WHERE genres IS NOT NULL
GROUP BY 1
ORDER BY 2 DESC
```

**Objective:** Assess the platform's genre diversity by calculating the number of content items in each genre.

### 10. Find each release year and the number of content available for Ukraine on Apple TV. Return top 5 years with the highest content availability.

```sql
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
```

**Objective:** Evaluate the growth of Apple TV+ content availability in Ukraine and identify the most content-rich years.
