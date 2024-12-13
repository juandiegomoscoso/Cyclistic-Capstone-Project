# Cyclistic-Capstone-Project

## Backgroud

### About Cyclistic:
In 2016, Cyclistic launched a successful bike-share offering across Chicago. The bikes can be unlocked from one station and returned to any other station anytime.

Until now, Cyclistic’s marketing strategy relied on building general awareness and appealing to broad consumer segments. One approach that helped make these things possible was the flexibility of its pricing plans: single-ride passes, full-day passes, and annual memberships. Customers who purchase single-ride or full-day passes are referred to as casual riders. Customers who purchase annual memberships are Cyclistic members. 

Cyclistic’s finance analysts have concluded that annual members are much more profitable than casual riders. The director of marketing, Lily Moreno, believes that maximizing the number of annual members will be key to future growth. Rather than creating a marketing campaign that targets all-new customers, Moreno believes there is a solid opportunity to convert casual riders into members. 

Moreno has set a clear goal: Design marketing strategies aimed at converting casual riders into annual members. In order to do that, however, the team needs to better understand how annual members and casual riders differ, why casual riders would buy a membership, and how digital media could affect their marketing tactics. 

As a junior data analyst working on the marketing analyst team at Cyclistic, under the direction of Moreno, my role is to analyze Cyclistic historic bike trip data to spot trends and make insight about how casual riders and annual members use Cyclistic bikes differently. From these insights, my team will design a new marketing strategy to convert casual riders into annual members. 


## Ask Phase

Three questions will guide the future marketing program:
1. How do annual members and casual riders use Cyclistic bikes differently?
2. Why would casual riders buy Cyclistic annual memberships?
3. How can Cyclistic use digital media to influence casual riders to become members?

Moreno has assigned me the first question to answer: How do annual members and casual riders use Cyclistic bikes differently?

### Key Components

- **Business Task**: Analyze the differences in bike usage between casual riders and annual members to design a marketing strategy that converts casual riders into annual members. 
      
- **Problem Statement**:
Identify trends in bike usage patterns between annual and casual members to provide actionable insights for the marketing team.
      
- **Impact on Business Decisions**:
My insights will assist the marketing team to designing targeted campaigns to increase annual memberships by conveting casual riders.
      
- **Stakeholders**:

    * Cyclistic Management: This includes the director of marketing, Lily Moreno, and other executives who are interested in increasing profitability and growth.
    * Marketing Team: Analysts and strategists that design and implement the marketing strategies based on the data analysis.
    * Data Analysts: My team, responsible for identifying trends and insights.
    * Casual Riders: Users who purchase single-ride or full-day passes, whose behaviors and preferences need to be understood to convert them into annual members.
    * Annual Members: Current subscribers whose behaviors serve as a reference for strategies to atract casual riders.


## Prepare phase:

- **Data Used**: The last 12 months (June 2023 to June 2024) of Cyclistic’s historical trip data will be analized to indentify trends.
	
- **Data Location**: The data is stored in a public repository provided by Motivate International Inc., where monthly datasets are uploaded as new data becomes available. 

- **Data License**: The data is available to the public. Bikeshare grants a non-exclusive, royalty-free, limited, perpetual license to access, reproduce, analyze, copy, modify, distribute and use the Data for any lawful purpose. 

- **Data Organization**: The data is organized in CSV files containing the rides for a one-month period. Each entry includes the start and end times, the start and end stations, the locations of the stations, the type of bike and the type of member for each ride.

- **Credibility and Bias**: The data is provided by Cyclistic itself, which means that it is reliable and comprehensive, capturing all necessary trip details. Its regular updates ensure relevance and the inclusion of all riders supports unbiased analysis.

- **Relevance to Business Questions**: The data provides insights into the differences in bike usage patterns between casual riders and annual members, helpung to identify key behaviors for marketing strategies.

- **Data Limitations**: The data does not include personal information that can identify a user, ensuring privaxy but restricting into user-specific patterns.

- **Selected Tools**: To clean the data, I decided to use SQL Server for its ability to handle large datasets efficiently. To visualize the data, I chose Tableau Public for its capability to create interactive and visually engaging dashboards.

- **Importing the Data**: First, I created a database called “CyclisticBikeshare” in SQL server and imported each csv file into its own table using SQL Server import and export wizard. Then, I combined the tables from the different files into a single table called “rides_data”.


## Process Phase

After importing the data, I performed the following data cleaning steps:

1. Checked for Duplicates: Verified that there were no duplicated rows in the dataset.

```sql
WITH CTE_row_count AS (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY ride_id, rideable_type, started_at, ended_at, 
		start_station_name, start_station_id, end_station_name, end_station_id, start_lat, 
		start_lng, end_lat, end_lng, member_casual ORDER BY ride_id) AS row_count
	FROM dbo.rides_data)
SELECT COUNT(*)
FROM CTE_row_count
WHERE row_count > 1;
````

2. Validated Column Values:

    - Ensured all values in the member_casual column are valid: either "member" or "casual".
      
    ```sql
    SELECT DISTINCT(member_casual)
    FROM dbo.rides_data;
    ```

    - Ensured all values in the rideable_type column are valid: "electric_bike", "classic_bike", or "docked_bike".

    ```sql
    SELECT DISTINCT(rideable_type)
    FROM dbo.rides_data;
    ```

3. Checked for Missing Values: Verified if there were any NULL values in the started_at and ended_at columns.
   
```sql
SELECT COUNT(ride_id)
FROM dbo.rides_data
WHERE ended_at IS NULL;

SELECT COUNT(ride_id)
FROM dbo.rides_data
WHERE started_at IS NULL;
```

4. Calculated Ride Duration:
    
    - Created a new column, ride_length, to store the ride duration.
      
    ```sql
    ALTER TABLE dbo.rides_data
    ADD ride_length INT;
    ```

    - Computed the duration by subtracting the started_at timestamp from the ended_at timestamp.
      
    ```sql
    UPDATE dbo.rides_data
    SET ride_length = DATEDIFF(SECOND, started_at, ended_at);
    ```

5. Filtered Outliers:
   
    - Removed rides with negative durations.
      
   ```sql
   DELETE FROM dbo.rides_data
   WHERE ride_length < 0;
    ```

    - Removed rides lasting longer than a day.
      
    ```sql
    DELETE FROM dbo.rides_data
    WHERE ride_length > 86400; -- A day has 86400 seconds
    ```
    
    - Removed rides shorter than 30 seconds, as most of these started and ended at the same station, indicating likely user cancellation.
    
    ```sql
    DELETE FROM dbo.rides_data
    WHERE ride_length < 30;
    ```

6. Added Time-Based Columns:
   
    - Added the following columns to analyze user behavior over time:
      
        * week_day (day of the week)
          
        ```sql
        ALTER TABLE dbo.rides_data
        ADD week_day NVARCHAR(50);
        
        UPDATE dbo.rides_data
        SET week_day = DATENAME(dw, started_at);
        ```
        
        * month_week (week of the month)
    
        ```sql
        ALTER TABLE dbo.rides_data
        ADD month_day INT;
        
        UPDATE dbo.rides_data
        SET month_day = DATEPART(dd, started_at);
        ```

        * month (month of the year)
    
        ```sql
        ALTER TABLE dbo.rides_data
        ADD month NVARCHAR(50);
        
        UPDATE dbo.rides_data
        SET month = DATENAME(mm, started_at);
        ```

7. Dropped Irrelevant Columns:
    - Dropped start_station and end_station due to many NULL values and their irrelevance to the analysis.
      
    ```sql
    ALTER TABLE dbo.rides_data
    DROP COLUMN start_station_name, start_station_id, end_station_name, end_station_id;
    ```
	
    - Dropped latitude and longitude columns, as ride duration was determined to be a better indicator of bike usage.

    ```sql
    ALTER TABLE dbo.rides_data
    DROP COLUMN start_lat, start_lng, end_lat, end_lng;
    ```
