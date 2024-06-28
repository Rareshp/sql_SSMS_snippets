-- SQL - OEE dashboard examples
-- [cb#Area] means value of combobox token. Use [f#Area] for expression instead


DECLARE @StartTime DATETIME = '2024-06-01 00:00:00.000';
DECLARE @EndTime DATETIME = DATEADD(HOUR, 24, '2024-06-30 00:00:00.000');
-- below is an example with dynamic tokens 
DECLARE @StartTime DATETIME = '[tp#StartDate]';
DECLARE @EndTime DATETIME = DATEADD(HOUR, 24, '[tp#EndDate]');


---------------------------------------------
-- Piecharts---------------------------------
---------------------------------------------

SELECT SUM(CompletedProduction) AS Value, 'CompletedProduction' AS Metric 
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime
UNION ALL
SELECT SUM(ProductionCapacity )-SUM(CompletedProduction) AS Value, 'LostProduction' AS Metric
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime;

--

SELECT AVG(TotalProductionHours) AS Value, 'AvgTotalProductionHours' AS Metric 
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime
UNION ALL
SELECT 24-AVG(TotalProductionHours)-AVG(TotalDowntimeHours) AS Value, 'TotalHoursNotFunc' AS Metric
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime;



SELECT SUM(LostProductionDueToDowntime) AS Value, 'LostProductionDueToDowntime' AS Metric 
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime
UNION ALL
SELECT SUM(LostProductionDueToLowProduction) AS Value, 'LostProductionDueToLowProduction' AS Metric
FROM OEE_Results
where Area='[cb#Area]' and @StartTime <= TimeLoc and TimeLoc < @EndTime;


---------------------------------------------
-- Tables -----------------------------------
---------------------------------------------
-- for OEE is as simple as using a procedure 
EXEC CalculateOEE @DateTime = @StartDate, @EndTime = @EndDate, @Area = @Area;

-- otherwise you must create a temporary table, insert into that, then select back


-- users with most inserted values in downtime form
select top 10 username, count(*) as 'Insert' from Downtime
WHERE username IS NOT NULL AND Area='[cb#Area]' AND @StartTime <= TimeLoc and TimeLoc < @EndTime
GROUP BY username
ORDER BY 'Insert' DESC

-- last 10 comments from users
select top 10 TimeLoc, UserName, Comments from Downtime
WHERE Area='[cb#Area]' AND @StartTime <= TimeLoc and TimeLoc < @EndTime
order by TimeLoc desc


-- PARETO downtime categories 
-- do not check the "web" checkbox for pareto to work
SELECT 
    SUM(CASE WHEN DowntimeCategory = 'Category1' THEN DownHours ELSE 0 END) AS Category1,
    SUM(CASE WHEN DowntimeCategory = 'Category2' THEN DownHours ELSE 0 END) AS Category2,
    SUM(CASE WHEN DowntimeCategory = 'Category3' THEN DownHours ELSE 0 END) AS Category3,
    SUM(CASE WHEN DowntimeCategory = 'Category4' THEN DownHours ELSE 0 END) AS Category4
FROM 
    DownTime
WHERE @StartTime <= TimeLoc and TimeLoc < @EndTime AND Area='[cb#Area]';



-- PARETO downtime reasons
-- do not check the "web" checkbox for pareto to work
-- you can do as above, but here is a dynamic way: 

-- Step 0: Drop the temp table if it exists
IF OBJECT_ID('tempdb..#TempDownTime') IS NOT NULL
    DROP TABLE #TempDownTime;

-- Step 1: Execute the original query and store the result in a temporary table
SELECT DowntimeReason, SUM(DownHours) AS Value 
INTO #TempDownTime
FROM DownTime
WHERE @StartTime <= TimeLoc AND TimeLoc < @EndTime
AND Area='[cb#Area]'
GROUP BY DowntimeReason;

-- Step 2: Generate dynamic SQL for pivoting the data
DECLARE @PivotColumns NVARCHAR(MAX),
        @DynamicSQL NVARCHAR(MAX);

SELECT @PivotColumns = COALESCE(@PivotColumns + ', ', '') + QUOTENAME(DowntimeReason)
FROM (
    SELECT DowntimeReason, SUM(Value) AS Value
    FROM #TempDownTime
    GROUP BY DowntimeReason
) AS GroupedData
ORDER BY Value DESC; -- Order by summed values in descending order

-- Step 3: This mess
SET @DynamicSQL = '
SELECT *
FROM (
    SELECT DowntimeReason, Value
    FROM (
        SELECT DowntimeReason, SUM(Value) AS Value
        FROM #TempDownTime
        GROUP BY DowntimeReason
    ) AS Src
) AS Src
PIVOT (
    SUM(Value)
    FOR DowntimeReason IN (' + @PivotColumns + ')
) AS PivotTable
ORDER BY ' + @PivotColumns + ' DESC;'; -- Order the columns in descending order

-- Step 4: Profit
EXEC sp_executesql @DynamicSQL;



---------------------------------------------
-- How much production was lost per Bad Actor 
---------------------------------------------

-- requires some new columns to be easier to actually read back 
-- this did require changing some logic for inserting the data in the project
-- ALTER TABLE Downtime 
-- ADD DowntimeLostProduction FLOAT
-- ALTER TABLE Production
-- ADD BadActorLowProduction VARCHAR(255), LowProductionCategory VARCHAR(100), LowProductionReason VARCHAR(255)

WITH DowntimeCTE AS (
	select BadActorDowntime as BadActor, ISNULL(SUM(DowntimeLostProduction), 0) as DowntimeLostProduction from Downtime
	where Area = '[cb#Area]' and BadActorDowntime IS NOT NULL
	and TimeLoc >= @StartDate
	and TimeLoc < @EndDate
	group by BadActorDowntime
),
ProductionCTE AS (
	select BadActorLowProduction as BadActor, ISNULL(SUM(LostProductionLowCapacity), 0) as LostProductionLowCapacity from Production
	where Area = '[cb#Area]' and BadActorLowProduction IS NOT NULL
	and TimeLoc >= @StartDate
	and TimeLoc < @EndDate
	group by BadActorLowProduction
)

-- here we need to SUM the production lost due to downtime and due to low production
SELECT TOP 30
    COALESCE(DowntimeCTE.BadActor, ProductionCTE.BadActor) AS BadActor,
    ISNULL((DowntimeLostProduction + LostProductionLowCapacity),0) as LostProduction
FROM 
    DowntimeCTE
FULL OUTER JOIN 
    ProductionCTE
ON 
    DowntimeCTE.BadActor = ProductionCTE.BadActor
