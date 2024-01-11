SELECT Num_Value
  FROM (
    SELECT ROW_NUMBER() OVER (ORDER BY Last_Op_TS_Local DESC) as RowNum,
    Last_Op_TS_Local,Tag_Name,Num_Value
    FROM Manual_Data_md
    WHERE Tag_Name='Tag1'
) T
WHERE RowNum IN(2)
