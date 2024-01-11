DECLARE @LocalDateTime DATETIME = '[tp#Data]'
DECLARE @UTCDateTime DATETIME = DATEADD(HOUR, -2, @LocalDateTime)

-- get last time for one of the inserts, to check if insert is needed
DECLARE @LastTime DATETIME = (
SELECT Top 1 TimeLoc
  FROM tItemValue
  WHERE ItemId='39'  
  AND TimeLoc=@LocalDateTime
  ORDER BY TimeLoc DESC
);
IF (@LastTime IS NULL)
	INSERT INTO tItemValue ([TimeUtc], [TimeLoc], [NumValue], [StrValue], [Quality], [ItemId])
VALUES
	-- unfortunately you must know the ItemId from the Items table... you can use an Excel workbook to create these inserts 
	(@UTCDateTime, @LocalDateTime, [f#Token1], NULL, 1, 39),
	(@UTCDateTime, @LocalDateTime, [f#Token2], NULL, 1, 41)
ELSE 
	RAISERROR (15600, -1, -1, 'Values already exist');


-- how to delete the data
DELETE tItemValue
WHERE ItemId IN (39, 41))
AND TimeLoc >= @LocalDateTime
AND TimeLoc < DATEADD(Day, 1, @LocalDateTime)
