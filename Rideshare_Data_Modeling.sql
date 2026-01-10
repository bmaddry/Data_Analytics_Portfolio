-- Creating warehouses for loading and querying
CREATE OR REPLACE WAREHOUSE ridesharing_loading_wh;
CREATE OR REPLACE WAREHOUSE ridesharing_query_wh;

-- Making a new database
CREATE DATABASE IF NOT EXISTS ridesharing;

-- Creating a stage to access the data files
CREATE OR REPLACE STAGE ridesharing_stage
    URL = 's3://ridesharing-7369/';

-- Looking at files in the S3 stage
LIST @ridesharing_stage;

-- Previewing files inside the stage
SELECT $1 FROM @ridesharing_stage/cities LIMIT 100;
SELECT $1, $2, $3, $4 FROM @ridesharing_stage/payouts LIMIT 100;
SELECT $1, $2, $3, $4, $5, $6, $7 FROM @ridesharing_stage/rides LIMIT 100;

-- Creating and loading the cities data (JSON)
CREATE OR REPLACE TABLE cities_json (v variant);

COPY INTO cities_json
FROM @ridesharing_stage/cities
file_format = (type = json
               strip_outer_array = TRUE);

-- Creating and loading the payouts table
CREATE TABLE IF NOT EXISTS payouts( 
    driver_id varchar(45) not null,
    week_start date,
    total_hours number(8,2),
    total_payout number(8,2)
);

COPY INTO payouts
FROM @ridesharing_stage/payouts
file_format = (type = 'csv'
               field_delimiter = ','
               skip_header = 0
               null_if = (''));

-- Creating and loading the rides table
CREATE TABLE IF NOT EXISTS rides (
    ride_id varchar(45) not null,
    driver_id varchar(45) not null,
    city varchar(45) not null,
    ride_date timestamp,
    distance_mi number(8,2),
    fare_amount number(8,2),
    canceled varchar(45)
);

COPY INTO rides
FROM @ridesharing_stage/rides
file_format = (type = 'csv'
               field_delimiter = ','
               skip_header = 1
               null_if = (''));

-- Creating the drivers table, to manually load data
CREATE TABLE IF NOT EXISTS drivers (
    driver_id varchar(45) not null,
    signup_date date,
    city varchar(45) not null,
    rating number(8,3),
    status varchar(45)
);

-- Creating a view for the cities_json table
CREATE OR REPLACE VIEW cities_view AS
SELECT 
    v:city_name::varchar(45) AS city,
    v:airport_factor::number(8,2) AS airport_factor,
    v:congestion_level::number(8,2) AS congestion_level,
    v:eventfulness::number(8,2) AS eventfulness,
    v:nightlife_score::number(8,2) AS nightlife_score
FROM cities_json;

-- Previewing loaded data from the tables
SELECT * FROM cities_view LIMIT 100;
SELECT * FROM payouts LIMIT 100;
SELECT * FROM rides LIMIT 100;
SELECT * FROM drivers LIMIT 100;

-- Switching our warehouse to perform queries
USE WAREHOUSE ridesharing_query_wh;

-- Looking at the count of active, and inactive drivers
SELECT
    status,
    COUNT(driver_id) AS num_drivers
FROM drivers
GROUP BY status
ORDER BY num_drivers DESC;

-- Checking the amount of active drivers in each city
SELECT
    city,
    COUNT(driver_id) AS num_drivers
FROM drivers
WHERE status = 'active'
GROUP BY city
ORDER BY num_drivers DESC;

-- Finding the average rating for active drivers
SELECT
    status,
    ROUND(AVG(rating),2) AS avg_rating
FROM drivers
WHERE status = 'active'
GROUP BY status;

-- Looking at new driver growth by year
SELECT
    EXTRACT(YEAR FROM signup_date) AS year,
    COUNT(driver_id) AS num_new_drivers,
    LAG(num_new_drivers) OVER(ORDER BY year) AS ly_new_drivers,
    ROUND(((num_new_drivers-ly_new_drivers)/ly_new_drivers)*100,0) AS pct_growth
FROM drivers
GROUP BY year
ORDER BY year;

-- Finding the date range for the rides data
SELECT
    MIN(ride_date) AS first_ride,
    MAX(ride_date) AS last_ride
FROM rides;

-- Looking at total fares collected and commision for drivers
SELECT
    SUM(fare_amount) AS total_fares,
    ROUND((total_fares * .17),0) AS commission
FROM rides;

-- Finding the amount of rides that were cancelled
SELECT
    SUM(CASE 
            WHEN canceled = 'Y' THEN 1
            ELSE 0
        END) AS num_cancelled,
    COUNT(ride_id) AS num_rides,
    ROUND(num_cancelled/(num_cancelled+num_rides)*100,2) AS percent_cancelled
FROM rides;

-- Looking at the number of rides by city
SELECT
    city,
    COUNT(ride_id) AS num_rides
FROM rides
WHERE canceled = 'N'
GROUP BY city
ORDER BY num_rides DESC;

-- Finding the monthly rides for each year
SELECT
    EXTRACT(YEAR FROM ride_date) AS year,
    EXTRACT(MONTH FROM ride_date) AS month,
    COUNT(ride_id) AS num_rides,
    SUM(num_rides) OVER (PARTITION BY year 
                         ORDER BY year, month 
                         ROWS UNBOUNDED PRECEDING) AS cumulative_yearly_total
FROM rides
WHERE canceled = 'N'
GROUP BY year, month
ORDER BY year, month;

-- Looking at total rides by hour of day
SELECT
    EXTRACT(HOUR FROM ride_date) AS hour,
    COUNT(ride_id) AS num_rides
FROM rides
WHERE canceled = 'N'
GROUP BY hour
ORDER BY hour;

-- Finding total rides by day of week
WITH rides_by_day AS (
    SELECT
        DAYOFWEEK(ride_date) AS day,
        CASE 
            WHEN day = 0 THEN 'Sunday'
            WHEN day = 1 THEN 'Monday'
            WHEN day = 2 THEN 'Tuesday'
            WHEN day = 3 THEN 'Wednesday'
            WHEN day = 4 THEN 'Thursday'
            WHEN day = 5 THEN 'Friday'
            WHEN day = 6 THEN 'Saturday'
        END AS day_of_week,
        COUNT(ride_id) AS num_rides,
    FROM rides
    WHERE canceled = 'N'
    GROUP BY day
    ORDER BY day
)

SELECT 
    day_of_week,
    num_rides
FROM rides_by_day;

-- Creating a view of important fields for future reference
CREATE OR REPLACE VIEW cities_consolidate_view AS
WITH driver_data AS (
    SELECT
        city AS city_name,
        COUNT(driver_id) AS num_drivers,
        ROUND(AVG(rating),3) AS avg_driver_rating
    FROM drivers
    WHERE status = 'active'
    GROUP BY city
    ORDER BY num_drivers DESC
),

rides_data AS (
    SELECT
        city AS city_name,
        SUM(CASE
                WHEN canceled = 'N' THEN 1
                ELSE 0
            END) AS num_rides,
        ROUND(SUM(fare_amount),0) AS fares_collected
    FROM rides
    GROUP BY city_name
    ORDER BY num_rides DESC
),

cities_data AS (
    SELECT
        city AS city_name,
        nightlife_score,
        eventfulness AS eventfulness_score
    FROM cities_view
)

SELECT
    d.city_name,
    d.num_drivers,
    d.avg_driver_rating,
    r.num_rides,
    r.fares_collected,
    c.nightlife_score,
    c.eventfulness_score
FROM driver_data AS d
INNER JOIN rides_data AS r
USING(city_name)
INNER JOIN cities_data AS c
USING(city_name);

SELECT * FROM cities_consolidate_view;