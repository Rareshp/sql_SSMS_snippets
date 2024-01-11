WITH result AS (
SELECT TOP 1
      [Last_Op_TS_Local]
      ,[Tag_Name]
      ,[Num_Value],
      Num_Value - LAG(Num_Value)
      OVER (ORDER BY Last_OP_TS_Local) AS difference
  FROM Manual_Data_md
  WHERE Tag_Name in('Tag1')
  ORDER BY [Last_Op_TS_Local] DESC
 )
 SELECT TOP 1 Tag_Name, (difference*1) FROM result
