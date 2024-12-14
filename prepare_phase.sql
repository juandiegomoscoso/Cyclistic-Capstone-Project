
-- Create database
CREATE DATABASE CyclisticBikeshare;
GO

USE CyclisticBikeshare
GO

-- First, I imported each csv file into its own table using SQL Server Import and Export Wizard

-- Create rides_data table, where I will store all the data from the 12 individual .csv files
CREATE TABLE rides_data (
	ride_id NVARCHAR(50) NOT NULL PRIMARY KEY,
	rideable_type NVARCHAR(50) NULL,
	started_at DATETIME2(7) NULL,
	ended_at DATETIME2(7) NULL,
	start_station_name NVARCHAR(100) NULL,
	start_station_id NVARCHAR(50) NULL,
	end_station_name NVARCHAR(100) NULL,
	end_station_id NVARCHAR(50) NULL,
	start_lat FLOAT NULL,
	start_lng FLOAT NULL,
	end_lat FLOAT NULL,
	end_lng FLOAT NULL,
	member_casual NVARCHAR(50) NULL
)


-- Insert the data from each month table into the rides_data table

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202306-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202307-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202308-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202309-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202310-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202311-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202312-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202401-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202402-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202403-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202404-divvy-tripdata];

INSERT INTO dbo.[rides_data] 
SELECT *
FROM dbo.[202405-divvy-tripdata];

