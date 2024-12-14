
USE CyclisticBikeshare;
GO

-- We're done cleaning our dataset, we can start analizing our data!

-- Check the total number of rides
SELECT COUNT(*)
FROM dbo.rides_data;


-- Check the number of rides made by members and the number made by casual riders
SELECT member_casual AS user_status, COUNT(ride_id) AS user_count
FROM dbo.rides_data
GROUP BY member_casual;


-- Calculate the mean of the ride lenghts (as minutes)
SELECT CONCAT(AVG(CAST(ride_length AS BIGINT)) / 60.0, ' min') AS avg_ride_length -- I cast ride_lenght to BIGINT to avoid arithmetic overflow
FROM dbo.rides_data;


-- Calculate the longest rides length (as minutes)
SELECT MAX(ride_length) / 60.0 AS longest_length
FROM dbo.rides_data;


-- Find the days of the week with most bike rents
SELECT week_day, COUNT(*) AS bike_rents
FROM dbo.rides_data
GROUP BY week_day
ORDER BY bike_rents DESC;
-- The day with the most bike rents is saturday


-- Find the month with the most bike rents
SELECT month, COUNT(*) AS bike_rents
FROM dbo.rides_data
GROUP BY month
ORDER BY bike_rents DESC;
-- The month with the most bike rents is August


-- Calculate average ride length (in minutes) for members and casuals
SELECT member_casual, CONCAT(AVG(CAST(ride_length AS BIGINT)) / 60.0, ' min') AS avg_ride_length
FROM dbo.rides_data
GROUP BY member_casual;
-- Casuals have a 12 min average ride_length while members have a 12 min ride_legth


-- Calculate average ride length (in minutes) by casual and member users per week_day
WITH RideLength (user_type, week_day, ride_length) AS (
	SELECT member_casual, week_day, CAST(ride_length AS BIGINT) / 60.0
	FROM dbo.rides_data
)
SELECT *
FROM RideLength
PIVOT(AVG(ride_length) FOR week_day IN([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])) p;







