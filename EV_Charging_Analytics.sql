-- Creating warehouses for loading and querying
CREATE OR REPLACE WAREHOUSE charging_loading_wh;
CREATE OR REPLACE WAREHOUSE charging_query_wh;

-- Creating a new database for the data
CREATE DATABASE IF NOT EXISTS charging;

-- Setting up a stage to access the data files
CREATE OR REPLACE STAGE charging_stage
    url = 's3://charging-3920/';

-- Looking at the files in the staging environment
LIST @charging_stage;

-- Previewing files in the stage to understand their structure
SELECT $1 FROM @charging_stage/charging LIMIT 100;
SELECT $1 FROM @charging_stage/stations LIMIT 100;
SELECT $1, $2, $3 FROM @charging_stage/user LIMIT 100;

-- Creating tables for the data
CREATE OR REPLACE TABLE charging_sessions (
    session_id integer,
    station_id integer,
    user_id integer,
    start_time timestamp,
    end_time timestamp,
    kwh_delivered number(8,2),
    idle_minutes integer
);

CREATE OR REPLACE TABLE stations (
    station_id integer,
    location_city string,
    bay_count integer,
    power_rating_kw integer,
    installation_date date
);

CREATE OR REPLACE TABLE user_feedback (
    feedback_id integer,
    user_id integer,
    rating integer,
    comments_text string,
    submitted_at timestamp
);

-- Loading data into the tables
COPY INTO charging_sessions
    FROM @charging_stage/charging
    FILE_FORMAT = (field_delimiter = '|'
                   skip_header = 1);

COPY INTO stations
    FROM @charging_stage/stations
    FILE_FORMAT = (field_delimiter = '\t'
                   skip_header = 0
                   error_on_column_count_mismatch = TRUE);

COPY INTO user_feedback
    FROM @charging_stage/user
    FILE_FORMAT = (field_delimiter = '|'
                   skip_header = 1);

-- Previewing the tables to ensure the data loaded correctly
SELECT * FROM charging_sessions LIMIT 100;
SELECT * FROM stations LIMIT 100;
SELECT * FROM user_feedback LIMIT 100;

-- Creating a resource monitor to control costs
CREATE OR REPLACE RESOURCE MONITOR charging_query_rm
WITH CREDIT_QUOTA = 200
     FREQUENCY = monthly
     START_TIMESTAMP = immediately
     TRIGGERS 
        ON 80 PERCENT DO NOTIFY -- notify admins
        ON 100 PERCENT DO SUSPEND_IMMEDIATE; -- suspend (cancel queries)

-- Applying the resource monitor to the query warehouse
ALTER WAREHOUSE charging_query_wh
SET RESOURCE_MONITOR = charging_query_rm;

-- Ensuring the resource monitor was deployed correctly
SHOW WAREHOUSES LIKE 'charging_%';

-- Adjusting the statement timeouts for queries
ALTER WAREHOUSE charging_query_wh
SET statement_timeout_in_seconds = 3600; -- 60 mins
SET statement_queued_timeout_in_seconds = 900; -- 15 mins

-- Looking at the new parameters
SHOW PARAMETERS IN WAREHOUSE charging_query_wh;

-- Switching to useradmin to create a new role
USE ROLE useradmin;

-- Creating a role for the analyst team
CREATE OR REPLACE ROLE charging_analyst_role;

-- Allowing the useradmin, to access the new role
SET my_user = CURRENT_USER();
GRANT ROLE charging_analyst_role TO USER identifier($my_user);

-- Switching to the securityadmin role to grant privileges to the new analyst role
USE ROLE securityadmin;

-- Granting warehouse privileges
GRANT OPERATE, USAGE ON WAREHOUSE charging_query_wh TO ROLE charging_analyst_role;

-- Granting database, schema, and table privileges
GRANT USAGE ON DATABASE charging TO ROLE charging_analyst_role; -- see into the database (not its objects)
GRANT USAGE ON ALL SCHEMAS IN DATABASE charging TO ROLE charging_analyst_role; -- see into all the schemas
GRANT SELECT ON ALL TABLES IN SCHEMA charging.public TO ROLE charging_analyst_role; -- query all existing tables
GRANT SELECT ON FUTURE TABLES IN SCHEMA charging.public TO ROLE charging_analyst_role; -- query all future tables

-- Looking at the grants, for the new analyst role
SHOW GRANTS TO ROLE charging_analyst_role;

-- Using the new role to query the data, and switching our warehouse
USE ROLE charging_analyst_role;
USE WAREHOUSE charging_query_wh;

-- Creating an informative overview about the charging stations
SELECT
    COUNT(DISTINCT(station_id)) AS num_charging_stations,
    SUM(bay_count) AS num_charging_bays,
    ROUND(num_charging_bays/num_charging_stations, 0) AS avg_bays_per_station,
    SUM(power_rating_kw) AS total_kw_power
FROM stations;

-- Looking at how many charging stations were installed each year
SELECT
    EXTRACT(YEAR FROM installation_date) AS year,
    COUNT(station_id) AS num_new_stations,
    SUM(num_new_stations) OVER (ORDER BY year ROWS UNBOUNDED PRECEDING) AS cumulative_total
FROM stations
GROUP BY year
ORDER BY year;

-- Finding the date range for the charging sessions data
SELECT
    MIN(start_time) AS first_charge,
    MAX(start_time) AS last_charge
FROM charging_sessions;

-- Seeing how many charging sessions were completed in 2024
SELECT COUNT(DISTINCT(session_id)) AS num_charging_sessions
FROM charging_sessions;

-- Looking at the average charges by user
SELECT
    COUNT(DISTINCT(session_id)) AS num_charging_sessions,
    COUNT(DISTINCT(user_id)) AS num_users,
    ROUND(num_charging_sessions/num_users,2) AS avg_charges_by_user
FROM charging_sessions;

-- Finding statistics about the charging sessions and customer time spent idling
WITH time_info AS (
    SELECT
        SUM(DATEDIFF(MINUTE, start_time, end_time)) AS charging_time,
        SUM(idle_minutes) AS idle_time,
        charging_time+idle_time AS total_time
    FROM charging_sessions
)

SELECT
    charging_time,
    idle_time,
    total_time,
    ROUND((charging_time/total_time)*100,0) AS percent_time_spent_charging,
    ROUND((idle_time/total_time)*100,0) AS percent_time_spent_idle
FROM time_info;

-- Looking at the number of reviews (via feedback forms) that were submitted from customers
SELECT COUNT(DISTINCT(feedback_id)) AS num_feedback_forms
FROM user_feedback;

-- Finding the average rating for reviews
SELECT ROUND(AVG(rating),2) AS avg_rating
FROM user_feedback;

-- Creating a field to translate reviews to English
ALTER TABLE user_feedback
ADD COLUMN comments_translation string;

-- Translating the reviews
UPDATE user_feedback
SET comments_translation = AI_TRANSLATE(comments_text, '', 'en');

-- Creating a field to analyze the sentiment of customer comments
ALTER TABLE user_feedback
ADD COLUMN comments_sentiment variant;

-- Using AI to find the sentiment
UPDATE user_feedback
SET comments_sentiment = AI_SENTIMENT(comments_translation);

-- Creating a new field to find comments regarding idle vehicles
ALTER TABLE user_feedback
ADD COLUMN comments_classification variant;

-- Classifying comments as idling, if they mention customer opinion regarding idle vehicles
UPDATE user_feedback
SET comments_classification = AI_CLASSIFY(comments_translation, ['idling', 'other']);

-- Previewing the new user_feedback table
SELECT * FROM user_feedback LIMIT 10;

-- Looking at the count of comments by sentiment around idling
SELECT 
    comments_sentiment:"categories"[0]:"sentiment"::string AS sentiment,
    comments_classification:"labels"[0]::string AS classification,
    COUNT(*) AS num_responses
FROM user_feedback
WHERE classification = 'idling'
GROUP BY sentiment, classification
ORDER BY num_responses DESC;

-- Previewing comments that in support of creating a fee for idling
SELECT
    comments_translation AS comment,
    comments_sentiment:"categories"[0]:"sentiment"::string AS sentiment,
    comments_classification:"labels"[0]::string AS classification,
FROM user_feedback
WHERE classification = 'idling' AND sentiment = 'mixed';

-- Previewing commentst that are against creating an idle fee
SELECT
    comments_translation AS comment,
    comments_sentiment:"categories"[0]:"sentiment"::string AS sentiment,
    comments_classification:"labels"[0]::string AS classification,
FROM user_feedback
WHERE classification = 'idling' AND sentiment = 'negative';

--Looking at idle time by city
SELECT
    s.location_city,
    SUM(DATEDIFF(MINUTE, c.start_time, c.end_time)) AS charging_time,
    SUM(c.idle_minutes) AS idle_time,
    charging_time+idle_time AS total_time,
    ROUND((charging_time/total_time)*100,0) AS percent_time_spent_charging,
    ROUND((idle_time/total_time)*100,0) AS percent_time_spent_idle
FROM charging_sessions c
INNER JOIN stations s
ON c.station_id=s.station_id
GROUP BY s.location_city
ORDER BY percent_time_spent_idle DESC;

-- Creating at a histogram for minutes spent idling
SELECT
    CASE
        WHEN idle_minutes BETWEEN 1 AND 10 THEN '1-10'
        WHEN idle_minutes BETWEEN 11 AND 20 THEN '11-20'
        WHEN idle_minutes BETWEEN 21 AND 30 THEN '21-30'
        WHEN idle_minutes BETWEEN 31 AND 40 THEN '31-40'
        ELSE '40+'
    END AS idle_minutes_range,
    COUNT(*)
FROM charging_sessions
GROUP BY idle_minutes_range
ORDER BY idle_minutes_range;