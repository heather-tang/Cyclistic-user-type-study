-- Combine 12 tables into a view twelve months, 
-- each for a month's worth of rideship info in the past 12 months

CREATE VIEW twelve_months AS
SELECT 
	*
FROM
	dbo.[202106-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202105-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202104-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202103-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202102-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202101-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202012-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202011-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202010-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202009-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202008-divvy-tripdata]
UNION ALL
SELECT 
	*
FROM
	dbo.[202007-divvy-tripdata]



-- Create a temp table with "SELECT INTO" 
-- With every column in a monthly table + new columns "month", "year" and "day_of_week"

-- Data cleaning: exclude the observations where ended at time is earlier than started at time
-- Takes 7m17s to run

SELECT 
	CAST(DATEPART(MONTH, started_at) AS int) AS month
	, CAST(DATEPART(YEAR, started_at) AS int) year
	, CAST(DATEPART(WEEKDAY, started_at) AS int) AS day_of_week
	, *
INTO
	TEMP
FROM
	twelve_months
WHERE
	DATEDIFF(MINUTE, started_at, ended_at) > = 0


-- Quickly checked if there are cases where there is a station name but no matching station ID
-- And vice versa
-- I scrolled through the result and found if station is null, station ID is also null

SELECT 
	[ride_id]
      --,[started_at]
      --,[ended_at]
      ,[start_station_name]
      ,[start_station_id]
      ,[end_station_name]
      ,[end_station_id]
FROM TEMP
WHERE
	(
	start_station_id IS NULL OR
	start_station_id IS NULL
	) OR (
	end_station_name IS NULL OR
	end_station_id IS NULL
	)

-- Check if there are duplicate records on ride_id
SELECT DISTINCT	
	COUNT(ride_id)
FROM
	twelve_months
-- count: 4,460,151

SELECT
	COUNT(ride_id)
FROM
	TEMP
-- count: 4460151
-- But if select all, there will be 4,456,914 rows


-- Find the rides of the past 12 months, by year, month, day of week and member_casual
-- Takes 23 sec to run
SELECT 
	month 
	, year
	, day_of_week
	, COUNT(ride_id) AS total_rides
	, member_casual
	, rideable_type
FROM 
	TEMP
GROUP BY
	year
	, month
	, day_of_week
	, member_casual
	, rideable_type
ORDER BY
	year DESC
	, month
	, day_of_week
	, member_casual

-- Find the rides of the past 12 months, by year, month, day of week and member_casual
-- Takes 4 sec to run
SELECT 
	month 
	, year
	, day_of_week
	, COUNT(ride_id) AS total_rides
	, member_casual
	, rideable_type
FROM 
	TEMP
GROUP BY
	year
	, month
	, day_of_week
	, member_casual
	, rideable_type
ORDER BY
	year DESC
	, month
	, day_of_week
	, member_casual

-- Find the average length of ride by member_casual and by month
SELECT 
	month 
	, year
	, day_of_week
	, ABS(AVG(DATEDIFF(MINUTE, started_at, ended_at))) AS length_of_ride
	, member_casual
FROM 
	TEMP
GROUP BY
	year
	, month
	, day_of_week
	, member_casual
ORDER BY
	year DESC
	, month
	, day_of_week
	, member_casual