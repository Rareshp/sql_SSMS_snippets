DECLARE @StartTime DATETIME = '2024-06-01 00:00:00.000';
DECLARE @EndTime DATETIME = DATEADD(HOUR, 24, '2024-06-30 00:00:00.000');

-- to compare
SELECT TOP 1 TimeLoc from Downtime 
	where Area='Area' AND @StartTime <= TimeLoc and TimeLoc < @EndTime
	AND DowntimeCategory = 'Fiabilitate'

-- number of days between failure and end time
DECLARE @Found DATETIME;
SET @Found = ISNULL((
	SELECT TOP 1 TimeLoc from Downtime 
	where Area='Area' AND @StartTime <= TimeLoc and TimeLoc < @EndTime
	AND DowntimeCategory = 'Fiabilitate'
	)
, @EndTime);

DECLARE @D FLOAT = DATEDIFF(HOUR, @Found, @EndTime);

-- if result > than 4 hours then print
IF (@D > 4) SELECT ROUND((@D / 24),1)
ELSE SELECT 0;
