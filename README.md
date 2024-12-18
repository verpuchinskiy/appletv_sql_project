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

### 1. Count the number of movies vs tv shows in the whole numbers and percentage.

```sql
SELECT 
	type, 
	COUNT(*) AS content_number,
	ROUND(COUNT(*)*100/SUM(COUNT(*)) OVER(), 2) AS percentage
FROM appletv
GROUP BY type
```

**Objective:** Determine the distribution of content types (movies vs TV shows) on Apple TV+ to analyze the balance between the two categories.

### 2. Find the most common IMDb rating for movies and tv shows.

```sql
SELECT
	type,
	PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY imdb_avg_rating) AS median
FROM appletv
GROUP BY type
```

**Objective:** Identify the typical audience reception of movies and TV shows by analyzing the most frequently occurring IMDb ratings.

### 3. List all movies released in 1987.

```sql
SELECT *
FROM appletv
WHERE 	release_year = 1987 
	AND 
	type = 'movie'
```

**Objective:** Analyze the content catalog for a specific year to understand the availability of older movies on Apple TV+.

### 4. Find the top 5 countries with the most content on Apple TV.

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

### 6. Find content added in the last 5 years.

```sql
SELECT *
FROM appletv
WHERE release_year >= EXTRACT(YEAR FROM (CURRENT_DATE - INTERVAL '5 years'))
```

**Objective:** Analyze the recency of Apple TV+ content and identify the size of the library consisting of modern releases.

### 7. Find an average IMDb rating and average number of IMDb votes for each genre.

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(genres, ', ')) AS genre, 
	ROUND(AVG(imdb_avg_rating), 2) AS avg_rating,
	ROUND(AVG(imdb_num_votes)) AS avg_num_of_votes
FROM appletv
GROUP BY genre
HAVING AVG(imdb_avg_rating) IS NOT NULL AND ROUND(AVG(imdb_num_votes)) > 1000
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

### 9. Count the number of content items in each genre.

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

### 11. Find the quantity of TV series and movies that belong to several genres simultaneously and determine their percentage of the overall quantity.

```sql
WITH cte AS (SELECT type, COUNT(*) AS total
FROM appletv
GROUP BY type)

SELECT 
	a.type, 
	COUNT(*) AS multi_genre_count,
	COUNT(*) * 100 / total
FROM appletv a
JOIN cte USING (type)
WHERE genres LIKE '%,%'
GROUP BY type, total
```

**Objective:** Analyze the multi-genre distribution to determine how much content spans multiple genres, appealing to diverse audience preferences.

### 12. Which 5 countries have the highest average IMDb rating of the available content.

```sql
SELECT 
	UNNEST(STRING_TO_ARRAY(available_countries, ', ')) AS country,
	ROUND(AVG(imdb_avg_rating), 2)
FROM appletv
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

**Objective:** Discover which countries have the highest-rated content available, indicating regions with a focus on quality offerings.

### 13. Find the best movie or tv series by imdb rating for each release year.

```sql
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
```

**Objective:** Identify standout content for each release year to showcase year-by-year highlights on Apple TV+.

### 14. Find the years when content with the highest IMDb rating was released.

```sql
SELECT 
	release_year, 
	ROUND(AVG(imdb_avg_rating), 2) AS rating,
	COUNT(*) AS film_count
FROM appletv
GROUP BY release_year
HAVING AVG(imdb_avg_rating) IS NOT NULL AND COUNT(*) > 10
ORDER BY 2 DESC
```

**Objective:** Analyze the timeline of top-rated content to understand when were released the most critically acclaimed movies and TV shows.

### 15. Find top 5 movies and tv series that are available in the biggest number of countries.

```sql
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
```

**Objective:** Determine the global appeal and reach of specific movies and TV shows by analyzing their availability across countries.

## Key Findings

### 1. Content Distribution
- Movies make up 77.68% of the content on Apple TV+, while TV shows account for 22.32%.

### 2. IMDb Rating Insights
- The most common IMDb rating for movies is 6.3, while for TV shows it is 7.3.
- The top 10 movies and top 10 TV series, filtered for more than 10000 votes, revealed critically acclaimed titles such as the movie "The Godfather" (IMDb rating 9.2) and the TV show "Avatar: The Last Airbender" (IMDb rating 9.3).

### 3. Genre and Votes Analysis
- Genres with the highest average IMDb ratings are:
Documentary (7.25 average rating).
History (7.18 average rating).
Biography (6.97 average rating).

- Genres with the most content are:
Drama (8126 items).
Comedy (4638 items).
Romance (2694 items).

### 4. Regional Insights
- The top 5 countries with the most content are:
1. USA
2. Canada
3. Australia
4. India
5. Germany

- The 5 countries with the highest average IMDb ratings of content are:
1. Norway
2. Uganda
3. Belarus
4. Greece
5. Portugal

### 5. Release Year Trends
- The year with the most content released is 2022, with 1159 items added.
- The top 5 years with the highest content availability for Ukraine are 2020, 2021, 2022, 2023, 2024, with 34, 41, 54, 54 and 43 items available in those years.

### 6. Multi-Genre Content
- 68% of movies and 53% of TV series belong to multiple genres.

### 7. Content Reach
- The top 5 movies and TV series available in the most countries include "Little Voice", "Manhunt", and "Sugar", each available in more than 85 countries.

## SQL Techniques Used
To solve the above problems, the following SQL techniques were used:

### 1. Filtering Data
- **WHERE** clause was used extensively to filter data based on specific conditions, like filtering by content type or extracting content added in the last 5 years.

### 2. Aggregation and Grouping
- GROUP BY was used for summarizing data, such as counting the number of movies vs TV shows and calculating the number of content items per genre and per country.
- Aggregate functions like COUNT(), AVG(), SUM() and ROUND() were used to compute summary statistics, like average IMDb ratings and vote counts for each genre.

### 3. Ranking and Window Functions
- RANK() and PERCENTILE_CONT() were applied for such calculations as finding the best movie or TV series for each release year and calculating the median IMDb rating for movies and TV shows.

### 4. Common Table Expressions
- CTEs improved query readability and allowed for intermediate data processing like filtering data before further processing (e.g., IMDb votes > 10000) or joining with CTEs to calculate percetages from totals.

### 5. String Operations
- STRING_TO_ARRAY and UNNEST were used to split lists of countries and genres into individual rows for analysis.
- LIKE was used to identify multi-genre content by searching for commas.

### 6. Sorting and Limiting
- ORDER BY with LIMIT was used to retrieve top results, such as finding the top 5 countries with the most content.
