--- The first CTE CTE calculates the RowNum and Prev_Num_Value for each row in the original table
WITH CTE AS (
    SELECT
        Tag_Name,
        Num_Value,
        LAG(Num_Value) OVER (PARTITION BY Tag_Name ORDER BY Last_Op_TS_Local) AS Prev_Num_Value,
        ROW_NUMBER() OVER (PARTITION BY Tag_Name ORDER BY Last_Op_TS_Local) AS RowNum
    FROM Manual_Data_md
	--- you can use the clause below to select just the tags you want
	WHERE Tag_Name IN ('Tag1', 'Tag2')
)
--- Calculates the maximum RowNum for each distinct Tag_Name where Prev_Num_Value is not null.
--- This will help us identify the rows with the maximum RowNum for each distinct Tag_Name
--- which is the equivalent to the difference between Last and 2nd to Last
, MaxRowNumCTE AS (
    SELECT Tag_Name, MAX(RowNum) AS MaxRowNum
    FROM CTE
    WHERE Prev_Num_Value IS NOT NULL
    GROUP BY Tag_Name
)
--- Finally, we join the CTE with MaxRowNumCTE on Tag_Name and RowNum to select only the rows 
--- Where RowNum is the maximum for each Tag_Name
--- AND calculate the Difference
SELECT 
	c.Tag_Name, 
	c.Prev_Num_Value as Penultim,
	c.Num_Value as Ultim,
	c.Num_Value - c.Prev_Num_Value as Difference
FROM CTE c
INNER JOIN MaxRowNumCTE m ON c.Tag_Name = m.Tag_Name AND c.RowNum = m.MaxRowNum
WHERE c.Prev_Num_Value IS NOT NULL
ORDER BY c.Tag_Name DESC
