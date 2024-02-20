DECLARE @targetDateTime DATETIME = '2024-02-01 02:00:00.000';

UPDATE Manual_Data_md
SET 
    Orig_Ts_Local = DATEADD(HOUR, -2, @targetDateTime),
    Orig_Ts_UTC = DATEADD(HOUR, -4, @targetDateTime)
WHERE Orig_Ts_Local = @targetDateTime;
