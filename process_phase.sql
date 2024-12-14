
USE CyclisticBikeshare;
GO

-- Now that I have all the data I need in one place, I clean the data


-- See how many duplicated rows there are
WITH CTE_row_count AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ride_id, rideable_type, started_at, ended_at, 
		start_station_name, start_station_id, end_station_name, end_station_id, start_lat, 
		start_lng, end_lat, end_lng, member_casual ORDER BY ride_id) AS row_count
	FROM dbo.rides_data)
SELECT COUNT(*)
FROM CTE_row_count
WHERE row_count > 1;
-- There are no duplicated rows so I it's not necessary to delete any


-- Check that all the values in the column "member_casual" are valid:
-- "member" and "casual"
SELECT DISTINCT(member_casual)
FROM dbo.rides_data;
-- The query returned the correct results!


-- Check that all the values in the column "rideable_type" are valid:
-- "electric_bike", "classic_bike" or "docked_bike"
SELECT DISTINCT(rideable_type)
FROM dbo.rides_data;
-- The query returned the correct results!


-- Check how many NULL values there are in the "ended_at" column
SELECT COUNT(ride_id)
FROM dbo.rides_data
WHERE ended_at IS NULL;
-- There are no NULL values!


--Check how many NULL values there are in the "started_at" column
SELECT COUNT(ride_id)
FROM dbo.rides_data
WHERE started_at IS NULL;
-- There are no NULL values!


-- I will use the duration from when the user took the bike until the user returned it in my analysis process,
-- so I will create a new column that will store the duration so I don't have to calculate the duration every time I need it.


-- Create a new column "ride_length"
ALTER TABLE dbo.rides_data
ADD ride_length INT;


-- Calculate and store (in minutes) the values of "ride_length" column using the 
-- "started_at" and "ended_at" columns
UPDATE dbo.rides_data
SET ride_length = DATEDIFF(SECOND, started_at, ended_at);


-- Check the shortest bike rental duration
SELECT TOP 100 CAST((ride_length / 60) AS NVARCHAR(50)) + ' minutes' AS 'rental_duration'
FROM dbo.rides_data
ORDER BY ride_length ASC;
-- It seems that we have some negative durations, which means something is wrong

-- Count how many rides have negative duration
SELECT COUNT(ride_id) AS 'rides_with_negative_duration'
FROM dbo.rides_data
WHERE ride_length < 0;
-- 441 rides have negative duration! That's a lot. 
-- I must remove this rides from my dataset so they don't interfere with my analisis

-- Remove rows that have negative bike_rental_duration
DELETE FROM dbo.rides_data
WHERE ride_length < 0;

-- Check the longest bike rental duration
SELECT TOP 100 CAST((CAST(ride_length AS FLOAT) / 60) AS NVARCHAR(50)) + ' minutes' AS ride_length
FROM dbo.rides_data
ORDER BY ride_length DESC;
-- It seems we have some really long rides. The longest rides lasted 999.867 minutes, that's a lot!

-- Check how many days the longest rides last
SELECT TOP 100 CAST(CAST(ride_length AS FLOAT) / 86400 AS NVARCHAR(50)) + ' dias' AS ride_length -- A day has 86400 seconds
FROM dbo.rides_data
ORDER BY ride_length DESC;
-- Some rides last longer than a day. Since our bussiness task is to convert casual riders into members,
-- we only care about the rides that last less than a day

-- Check how many rides last longer than a day
SELECT COUNT(*) AS rides_longer_than_a_day
FROM dbo.rides_data
WHERE ride_length > 86400; -- A day has 86400 seconds
-- There are 7544 rides that last longer than a day


-- Remove rides that last longer than a day
DELETE FROM dbo.rides_data
WHERE ride_length > 86400; 


-- Check how many rides last less than a half a minute
SELECT COUNT(ride_id) AS "rides_less_than_half_a_minute"
FROM dbo.rides_data
WHERE ride_length < 30;
-- there are 135727 rides that last less than half a minute


-- Check the start and end stations of the rides that last less than half a minute
SELECT TOP 100 *
FROM dbo.rides_data
WHERE ride_length < 30
	AND start_station_id IS NOT NULL 
	AND end_station_id IS NOT NULL
	AND start_station_id != end_station_id
ORDER BY ride_length DESC;
-- I found out that most of the rides that last less than half a minute start and end in the same station,
-- which probably means that the user returned the bike as soon they take it and didn't use it


-- Remove rides that last less than a half a minute
DELETE FROM dbo.rides_data
WHERE ride_length < 30;


-- To analize the behavior of the users thoughout the week and month, I will need to store the week day,
-- week month and month of year


-- Create column to store the week day of each ride
ALTER TABLE dbo.rides_data
ADD week_day NVARCHAR(50);


-- Store the week day of each ride in the new column "week_day" using the "started_at" column
UPDATE dbo.rides_data
SET week_day = DATENAME(dw, started_at);


-- Create column to store the month day of each ride
ALTER TABLE dbo.rides_data
ADD month_day INT;


-- Store the week day of each ride in the new column "week_day" using the "started_at" column
UPDATE dbo.rides_data
SET month_day = DATEPART(dd, started_at);


-- Create column to store the month of each ride
ALTER TABLE dbo.rides_data
ADD month NVARCHAR(50);


-- Store the week day of each ride in the new column "month" using the "started_at" column
UPDATE dbo.rides_data
SET month = DATENAME(mm, started_at);


-- I will use tableau to visualize my data, so I will remove the columns that I will not
-- need in my analysis.


-- Since there's a lot of NULL values in the start and end stations, I will delete them
ALTER TABLE dbo.rides_data
DROP COLUMN start_station_name, start_station_id, end_station_name, end_station_id;


-- I decide to remove the latitud and longitud columns too because I think the ride_length is
-- a better indicator to analize the user's bike use
ALTER TABLE dbo.rides_data
DROP COLUMN start_lat, start_lng, end_lat, end_lng;

