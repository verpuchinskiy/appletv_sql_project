DROP TABLE IF EXISTS appletv;
CREATE TABLE appletv
(
    title					VARCHAR(150),
    type         			VARCHAR(6),
    genres        			VARCHAR(50),
    release_year     		INT,
    imdb_id        			VARCHAR(10),
    imdb_avg_rating			NUMERIC,
    imdb_num_votes   		INT,
    available_countries 	VARCHAR(350)
);