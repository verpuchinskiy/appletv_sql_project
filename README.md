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
