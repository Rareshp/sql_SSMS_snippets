ALTER PROCEDURE CalculateProductionForArea
    @StartDate DATETIME,
	@EndDate DATETIME,
    @Area CHAR(10),
	@ItemId INT,
	@Capacity FLOAT
AS
BEGIN
	-- better to let SQL Server deal with UTC instead 
	DECLARE @UTCDateTime DATETIME = @StartDate AT TIME ZONE 'E. Europe Standard Time' AT TIME ZONE 'UTC';

	DECLARE @DowntimeHours FLOAT;
	SET @DowntimeHours = ISNULL((
		SELECT SUM(DownHours) FROM Downtime
		WHERE Area=@Area -- variable
		and @StartDate <= TimeLoc and TimeLoc < @EndDate
	), 0);

	with CTE as (
		select 
			@StartDate as TimeLoc, 
			@UTCDateTime as TimeUtc,
			@Area as Area, 
			@Capacity * ( DATEDIFF(DAY, @StartDate, @EndDate) + 1) as PlannedProduction, 
			ISNULL(SUM(NumValue),0) as ActualProduction
		from tItemValue 
		where ItemId in (@ItemId)
		and @StartDate <= TimeLoc and TimeLoc < @EndDate
	),
	CTE2 as (
		select *, 
		CASE 
			WHEN (PlannedProduction - ActualProduction) < 0 THEN 0
			ELSE (PlannedProduction - ActualProduction)
		END AS TotalLostProduction, -- do not allow negative
		(PlannedProduction / 24 * @DowntimeHours) as DowntimeLostProduction
		from CTE
	)

	MERGE INTO Production AS target 
	USING (
		SELECT TimeLoc, TimeUtc, Area, PlannedProduction, ActualProduction, TotalLostProduction, DowntimeLostProduction, 
		(TotalLostProduction - DowntimeLostProduction) AS LostProductionLowCapacity
	    FROM CTE2
	) 
	AS source (
		TimeLoc, TimeUtc, Area, PlannedProduction, ActualProduction, TotalLostProduction, DowntimeLostProduction, LostProductionLowCapacity
	)
	ON target.TimeLoc = source.TimeLoc AND target.Area = source.Area
	WHEN MATCHED THEN
	  UPDATE SET 
		target.PlannedProduction = source.PlannedProduction,
		target.ActualProduction = source.ActualProduction,
		target.TotalLostProduction = source.TotalLostProduction,
		target.DowntimeLostProduction = source.DowntimeLostProduction,
		target.LostProductionLowCapacity = source.LostProductionLowCapacity
	WHEN NOT MATCHED THEN
	  INSERT (
		TimeLoc, TimeUtc, Area, PlannedProduction, ActualProduction, TotalLostProduction, DowntimeLostProduction, LostProductionLowCapacity
	  )
	  VALUES (
		source.TimeLoc, source.TimeUtc, source.Area, 
		source.PlannedProduction, source.ActualProduction, source.TotalLostProduction, source.DowntimeLostProduction, source.LostProductionLowCapacity
	  );
END;
