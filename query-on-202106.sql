/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [ride_id]
      ,[rideable_type]
      ,[started_at]
      ,[ended_at]
      ,[start_station_name]
      ,[start_station_id]
      ,[end_station_name]
      ,[end_station_id]
      ,[start_lat]
      ,[start_lng]
      ,[end_lat]
      ,[end_lng]
      ,[member_casual]
  FROM [PortfolioProject].[dbo].[202106-divvy-tripdata]

USE PortfolioProject
GO


-- Find out the longest trip, excluding docked_bike type
SELECT 
	ride_id
	, rideable_type
	, started_at
	, ended_at
	, DATEDIFF(minute, started_at, ended_at) AS dur
FROM	dbo.[202106-divvy-tripdata]	
WHERE 
	NOT rideable_type = 'docked_bike'
ORDER BY dur DESC


-- Find the average trip duration by rideable_type
-- 18m for electric_bike
-- 21m for classic_bike

SELECT 
	--COUNT(ride_id),
	rideable_type,
	--, started_at
	--, ended_at
	AVG(DATEDIFF(minute, started_at, ended_at)) AS avg_dur
FROM	dbo.[202106-divvy-tripdata]	
WHERE 
	NOT rideable_type = 'docked_bike'
GROUP BY
	rideable_type


-- Find the longest and shortest trip (>=0) of each rideable_type
-- 481m for electric_bike 
-- and 1501m for classic_bike
SELECT 
	--COUNT(ride_id),
	rideable_type,
	--, started_at
	--, ended_at
	MAX(DATEDIFF(minute, started_at, ended_at)) AS max_dur
	, MIN(DATEDIFF(minute, started_at, ended_at)) AS min_dur
FROM	dbo.[202106-divvy-tripdata]	
WHERE 
	NOT rideable_type = 'docked_bike' AND
	DATEDIFF(minute, started_at, ended_at) >= 0
GROUP BY
	rideable_type

-- Adding a new column week_of_day
ALTER TABLE dbo.[202106-divvy-tripdata]
ADD week_of_day varchar(8)

--ALTER TABLE dbo.[202106-divvy-tripdata]
--DROP COLUMN week_of_day 

-- Fill in the new column week_of_day the data, for example "3" for 2021-06-15
UPDATE dbo.[202106-divvy-tripdata]
SET week_of_day = CONVERT(varchar(8), DATEPART(weekday,started_at))



-- Find and arrange in descending order the most rides on a weekday, by rideable_type
SELECT 
	--, rideable_type
	--, started_at
	--, ended_at
	--, DATEDIFF(minute, started_at, ended_at) AS dur
	rideable_type,
	COUNT(ride_id) AS total_rides,
	week_of_day
FROM	dbo.[202106-divvy-tripdata]	
WHERE 
	NOT rideable_type = 'docked_bike'
GROUP BY 
	week_of_day
	, rideable_type
ORDER BY
	COUNT(ride_id) DESC


-- Find the ride totals by customer type and rideable_type
SELECT
	COUNT(ride_id),
	member_casual,
	rideable_type
FROM 
	dbo.[202106-divvy-tripdata]
WHERE
	NOT rideable_type = 'docked_bike'
GROUP BY
	member_casual,
	rideable_type
ORDER BY
	member_casual,
	rideable_type


-- Find the sum of durations of all trips by customer type
SELECT
	SUM(DATEDIFF(MINUTE,started_at, ended_at)) AS sum_dur
	, member_casual
FROM dbo.[202106-divvy-tripdata]
WHERE
	NOT rideable_type = 'docked_bike'
GROUP BY
	member_casual

-- Functions used in this query
-- DATEDIFF(), DATEPART(), CONVERT()
-- ALTER TABLE |ADD 
-- UPDATE |SET |WHERE 


