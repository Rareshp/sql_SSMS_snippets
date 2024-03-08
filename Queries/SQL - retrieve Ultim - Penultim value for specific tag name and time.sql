DECLARE @StartTime DATETIME = '2024-01-10 00:00:00.000' --- '[tp#Data]'
DECLARE @EndTime DATETIME = DATEADD(DAY, -3, @StartTime);  
-- -3 to account monday-friday with missing data on weekend
-- select top 2 below will only choose the first 2 results, monday-friday or monday-sunday

WITH result AS (
SELECT TOP 2
      Orig_TS_Local, [Last_Op_TS_Local]
      ,[Tag_Name]
      ,[Num_Value],
      CASE
        WHEN Num_Value > LAG(Num_Value) OVER (ORDER BY Last_OP_TS_Local)
            THEN Num_Value - LAG(Num_Value) OVER (ORDER BY Last_OP_TS_Local)
        ELSE
            (1000000 - LAG(Num_Value) OVER (ORDER BY Last_OP_TS_Local)) + Num_Value
      END AS difference
  FROM Manual_Data_md
  WHERE Tag_Name='Tag1'
  AND Orig_TS_Local BETWEEN @EndTime AND @StartTime
  ORDER BY Orig_TS_Local DESC
)
SELECT TOP 1 (difference*1) FROM result
-- you can also make calculations based on difference here
