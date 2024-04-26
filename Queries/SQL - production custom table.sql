-- below is example for Production table and insert


CREATE TABLE Production (
    Id BIGINT IDENTITY(1,1) PRIMARY KEY, -- Identity column starting from 1, incrementing by 1
	TimeLoc DATETIME NOT NULL,
	TimeUtc DATETIME NOT NULL,
	Area VARCHAR(50) NOT NULL,
	Equipment VARCHAR(255),
	PlannedProduction FLOAT NOT NULL, -- usually 770
	ActualProduction FLOAT NOT NULL,  -- as reported 
	TotalLostProduction FLOAT, -- Planned - Actual or 0
	DowntimeLostProduction FLOAT, -- ROUND(TotalLostPorduction - PlannedProduction / 24 * SUM(Downtime.DownHours WHERE Downtime.TimeLoc = Production.TimeLoc)) ; if negative then 0
	LostProductionLowCapacity FLOAT, 
	Comments NVARCHAR(255)
);



-- next putting all the items together, have an Action Button with this merge command
-- not a simple insert because this also doubles as updating the data and deals with 
-- no selections

DECLARE @LocalDateTime DATETIME = '[tp#Data]';
-- better to let SQL Server deal with UTC instead 
DECLARE @UTCDateTime DATETIME = @LocalDateTime AT TIME ZONE 'E. Europe Standard Time' AT TIME ZONE 'UTC';

MERGE INTO Production AS target 
USING (VALUES
	(@LocalDateTime, @UTCDateTime, '[cb#Area]', [f#PlannedProduction], [f#ActualProduction], [f#TotalLostProduction], [f#DowntimeLostProduction], [f#LostProductionLowCapacity], [f#Comments])
) 
AS source (
	TimeLoc, TimeUtc, Area, PlannedProduction, ActualProduction, TotalLostProduction, DowntimeLostProduction, LostProductionLowCapacity, Comments
)
ON target.TimeLoc = source.TimeLoc AND target.Area = source.Area
WHEN MATCHED THEN
  UPDATE SET 
	target.PlannedProduction = source.PlannedProduction,
	target.ActualProduction = source.ActualProduction,
	target.TotalLostProduction = source.TotalLostProduction,
	target.DowntimeLostProduction = source.DowntimeLostProduction,
	target.LostProductionLowCapacity = source.LostProductionLowCapacity,
	target.Comments = source.Comments

WHEN NOT MATCHED THEN
  INSERT (
	TimeLoc, TimeUtc, Area, PlannedProduction, ActualProduction, TotalLostProduction, DowntimeLostProduction, LostProductionLowCapacity, Comments
  )
  VALUES (
	source.TimeLoc, source.TimeUtc, source.Area, source.PlannedProduction, source.ActualProduction, source.TotalLostProduction, source.DowntimeLostProduction , source.LostProductionLowCapacity,  source.Comments
  );
