-- below we have example of Downtime reports based on custom table
-- this is much better for OEE later, but feel free to check out
-- my other example with queries from Manual_Data tables
-- NOTE: some names have been altered; you may have to fix a bug or two

-- first we need to create the tables
CREATE TABLE Downtime (
	Id BIGINT IDENTITY(1,1) PRIMARY KEY, -- Identity column starting from 1, incrementing by 1
	TimeLoc DATETIME NOT NULL,
	TimeUtc DATETIME NOT NULL,
	Area VARCHAR(50),
	DowntimeCategory VARCHAR(100),
	DowntimeReason VARCHAR(255),
	LowProductionCategory VARCHAR(100),
	LowProductionReason VARCHAR(255),
	BadActorsCategory VARCHAR(100),
	BadActorsReason VARCHAR(255),
	DownHours FLOAT,
	Comments NVARCHAR(255)
);

-- also this: 
CREATE TABLE DowntimeReasons (
	Category1  VARCHAR(100) NOT NULL,
	Category2  VARCHAR(100) NOT NULL,
	Category3  VARCHAR(100) NOT NULL,
	Category4  VARCHAR(100) NOT NULL
);

-- you will then have to insert into this table the reasons 
INSERT INTO DowntimeReasons (Category1, Category2, Category3, Category4)
VALUES ('DownReason11', 'DownReason12', 'DownReason13', 'DownReason13', 'DownReason14');


-- for combo boxes needing a reason from a category column, first we need a combobox as SQL with this: 

SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = N'DowntimeReasons'

-- then, this combobox sends an **Update** to the next combobox. Now we can select the reason.

Select "[cb#DowntimeCategoryComboBox]"
From DowntimeReasons


-- you can repeat the above for LowProduction and BadActors


--------

-- next putting all the items together, have an Action Button with this merge command
-- not a simple insert because this also doubles as updating the data and deals with 
-- no selections


DECLARE @LocalDateTime DATETIME = '[tp#Data]';
-- better to let SQL Server deal with UTC instead 
DECLARE @UTCDateTime DATETIME = @LocalDateTime AT TIME ZONE 'E. Europe Standard Time' AT TIME ZONE 'UTC';

MERGE INTO Downtime AS target 
USING (VALUES
	(
	@LocalDateTime, 
	@UTCDateTime, 
	'[cb#Area]', 
	'[cb#DowntimeCategoryComboBox]', 
	'[cb#DowntimeReasonComboBox]', 
	'[cb#LowProductionCategory]',
	'[cb#LowProductionReason]',
	'[cb#BadActorsCategory]', 
	'[cb#BadActorsReason]', 
	[f#DownHoursField], 
	'[f#Comments]' -- NOTE: you may or may not need quotes here depending if you changed the `C:\ODS\AVEVA Reports\System\AvevaReports.ini` [AutoAddQuotes]:
	) 
) 
AS source (
	TimeLoc, TimeUtc, 
	Area, Equipment, 
	DowntimeCategory, DowntimeReason, 
	LowProductionCategory, LowProductionReason, 
	BadActorsCategory, BadActorsReason, 
	DownHours, Comments
)
ON target.TimeLoc = source.TimeLoc AND target.Area = source.Area
WHEN MATCHED THEN
    UPDATE SET
        target.DowntimeCategory = source.DowntimeCategory,
	target.DowntimeCategory = CASE WHEN source.DowntimeCategory = '[cb#' + 'DowntimeCategoryComboBox]' THEN NULL ELSE source.DowntimeCategory END,
        target.DowntimeReason = CASE WHEN source.DowntimeReason = '[cb#' + 'DowntimeReasonComboBox]' THEN NULL ELSE source.DowntimeReason END,
        target.LowProductionCategory = CASE WHEN source.LowProductionCategory = '[cb#' + 'LowProductionCategory]' THEN NULL ELSE source.LowProductionCategory END,
        target.LowProductionReason = CASE WHEN source.LowProductionReason = '[cb#' + 'LowProductionReason]' THEN NULL ELSE source.LowProductionReason END,
        target.BadActorsCategory = CASE WHEN source.BadActorsCategory = '[cb#' + 'BadActorsCategory]' THEN NULL ELSE source.BadActorsCategory END,
        target.BadActorsReason = CASE WHEN source.BadActorsReason = '[cb#' + 'BadActorsReason]' THEN NULL ELSE source.BadActorsReason END,
        target.DownHours = source.DownHours,
        target.Comments = source.Comments

WHEN NOT MATCHED THEN
    INSERT (
        TimeLoc, TimeUtc, Area, Equipment, DowntimeCategory, DowntimeReason, LowProductionCategory, LowProductionReason, BadActorsCategory, BadActorsReason, DownHours, Comments
    )
    -- the cases deal with possible empty comboboxes. You must change the syntax for other than Microsoft SQL 
    VALUES (
        source.TimeLoc, 
        source.TimeUtc, 
        CASE WHEN source.Area = '[cb#' + 'Area]' THEN NULL ELSE source.Area END,  -- this will error out because NULL is not allowed
        CASE WHEN source.DowntimeCategory = '[cb#' + 'DowntimeCategoryComboBox]' THEN NULL ELSE source.DowntimeCategory END,
        CASE WHEN source.DowntimeReason = '[cb#' + 'DowntimeReasonComboBox]' THEN NULL ELSE source.DowntimeReason END,
        CASE WHEN source.LowProductionCategory = '[cb#' + 'LowProductionCategory]' THEN NULL ELSE source.LowProductionCategory END,
        CASE WHEN source.LowProductionReason = '[cb#' + 'LowProductionReason]' THEN NULL ELSE source.LowProductionReason END,
        CASE WHEN source.BadActorsCategory = '[cb#' + 'BadActorsCategory]' THEN NULL ELSE source.BadActorsCategory END,
        CASE WHEN source.BadActorsReason = '[cb#' + 'BadActorsReason]' THEN NULL ELSE source.BadActorsReason END,
        source.DownHours,  -- this has a default value of 1; no need for case
        source.Comments
    );

    
    
--------
-- reports based on these are rather simple

SELECT SUM(DownHours), DowntimeCategory
FROM Downtime 
GROUP BY DowntimeCategory


SELECT SUM(DownHours), DowntimeReason
FROM Downtime 
WHERE DowntimeCategory = 'Category1'
GROUP BY DowntimeReason



-- if you need to show in bar graph you must have columns not rows 
SELECT 
    SUM(CASE WHEN DowntimeReason = 'DownReason11' THEN DownHours ELSE 0 END) AS DownReason11,
    SUM(CASE WHEN DowntimeReason = 'DownReason21' THEN DownHours ELSE 0 END) AS DownReason21,
    SUM(CASE WHEN DowntimeReason = 'DownReason23' THEN DownHours ELSE 0 END) AS DownReason23
FROM 
    DownTime
WHERE 
    Area = 'Area1';
    
    
    
-- the PARETO option will not work; 
-- the following query can show the results in desc order
-- this was generated wtih AI

-- Step 1: Execute the original query and store the result in a temporary table
IF OBJECT_ID('tempdb..#TempDownTime') IS NOT NULL
    DROP TABLE #TempDownTime;

SELECT DowntimeReason, SUM(DownHours) AS Value 
INTO #TempDownTime
FROM Downtime
WHERE Area = 'Area1'
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

-- Step 3: Execute the dynamic SQL query
EXEC sp_executesql @DynamicSQL;
