-- this is an example of OEE calculations, insert, and query
-- using my other custom Production and Downtime tables

CREATE TABLE OEE_Results (
	TimeLoc DATETIME,
	ExecutionDate DATETIME,
	Area CHAR(10),
	OEE FLOAT,
	Availability FLOAT,
	Rate FLOAT,
	Quality INT,
	Reliability FLOAT,
	TotalPlannedHours FLOAT,
	TotalDowntimeHours FLOAT,
	TotalProductionHours FLOAT,
	CompletedProduction FLOAT,
	ProductionCapacity FLOAT,
	LostProductionDueToDowntime FLOAT,
	LostProductionDueToLowProduction FLOAT
);


-- this query will calculate all things

DECLARE @DateTime DATETIME = '2024-01-26 00:00:00.000';
DECLARE @EndTime DATETIME = DATEADD(HOUR, 24, @DateTime);
DECLARE @DateDiff INT = DATEDIFF(day, @DateTime, @EndTime);
DECLARE @Area CHAR(10) = 'Area1';

-- needed for Reliability
DECLARE @TotalDowntimeHoursTechnicalReasons FLOAT;
SET @TotalDowntimeHoursTechnicalReasons = ISNULL((
	SELECT SUM(DownHours) FROM DownTime 
	WHERE TimeLoc BETWEEN @DateTime AND @EndTime
	AND DowntimeCategory = 'Category1'
	AND Area = @Area
), 0);

WITH CTE_AV AS (
	-- needed for Reliability
	SELECT 
		((@DateDiff + 1)*24) as TotalPlannedHours,
		SUM(d.DownHours) as TotalDowntimeHours,
		((@DateDiff + 1)*24) - SUM(d.DownHours) as TotalProductionHours
	FROM Downtime d
	WHERE TimeLoc BETWEEN @DateTime AND @EndTime
	  AND Area = @Area
),
CTE_REL AS (
	SELECT 
		SUM(ActualProduction) AS CompletedProduction,
		SUM(PlannedProduction) AS ProductionCapacity,
		SUM(DowntimeLostProduction) AS LostProductionDueToDowntime
		SUM(LostProductionLowCapacity) AS LostProductionDueToLowProduction
	FROM Production
	WHERE TimeLoc BETWEEN @DateTime AND @EndTime
	AND Area = @Area
),
CTE_RATE AS (
	SELECT 
		ROUND((CompletedProduction / (ProductionCapacity - LostProductionDueToDowntime) * 100), 2) AS Rate
	FROM CTE_REL
),
CombinedCTE AS (
	SELECT 
		AV.*,
		REL.CompletedProduction,
		REL.ProductionCapacity,
		REL.LostProductionDueToDowntime,
		REL.LostProductionDueToLowProduction,
		ROUND((AV.TotalProductionHours / AV.TotalPlannedHours) * 100, 2) AS Availability,
		ROUND((AV.TotalPlannedHours - @TotalDowntimeHoursTechnicalReasons) / AV.TotalPlannedHours * 100, 2) AS Reliability,
		RATE.Rate
	FROM CTE_AV AV
	CROSS JOIN CTE_REL REL
	CROSS JOIN CTE_RATE RATE
)
SELECT 
	GETDATE() as ExecutionDate,
	@DateTime as TimeLoc,
	@Area as Area,
	ROUND(Availability * Rate / 100, 2) AS OEE,  -- we have to divide by 100 because we are not really using %
	Availability, 
	Rate, 
	100 as Quality, 
	Reliability, 
	TotalPlannedHours, 
	TotalDowntimeHours, 
	TotalProductionHours, 
	CompletedProduction, 
	ProductionCapacity, 
	LostProductionDueToDowntime,
	LostProductionDueToLowProduction
FROM CombinedCTE;

-- if the data is ok, you can modify the query to also INSERT into OEE_Results


---------------

-- to display a table 
DECLARE @StartTime DATETIME = '[tp#StartTime]';
DECLARE @EndTime DATETIME = '[tp#EndTime]';

select
	Area,
	AVG(OEE) as OEE,
	AVG(Availability) as Availability,
	AVG(Rate) as Rate,
	AVG(Quality) as Quality,
	AVG(Reliability) as Reliability
from OEE_Results
where TimeLoc BETWEEN @StartTime and @EndTime
group by Area
