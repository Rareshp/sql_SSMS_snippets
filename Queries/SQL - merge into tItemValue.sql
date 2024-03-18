-- get the local time from a picker
DECLARE @LocalDateTime DATETIME = '[tp#Data]';
-- better to let SQL Server deal with UTC instead 
DECLARE @UTCDateTime DATETIME = @LocalDateTime AT TIME ZONE 'E. Europe Standard Time' AT TIME ZONE 'UTC';

MERGE INTO tItemValue AS target 
USING (VALUES
	(@UTCDateTime, @LocalDateTime, [f#Tag1_Calc], NULL, 0, 39),
	(@UTCDateTime, @LocalDateTime, [f#Tag2_Calc], NULL, 0, 41)
	
) AS source ([TimeUtc], [TimeLoc], [NumValue], [StrValue], [Quality], [ItemId])
ON target.TimeLoc = source.TimeLoc AND target.ItemId = source.ItemId
WHEN MATCHED THEN
  UPDATE SET 
    target.NumValue = source.NumValue,
    target.StrValue = source.StrValue,
	target.TimeUtc = source.TimeUtc
WHEN NOT MATCHED THEN
  INSERT (
    [TimeUtc], [TimeLoc], [NumValue], [StrValue], [Quality], [ItemId]
  )
  VALUES (
    source.TimeUtc, source.TimeLoc, source.NumValue, source.StrValue, source.Quality, source.ItemId
  );
