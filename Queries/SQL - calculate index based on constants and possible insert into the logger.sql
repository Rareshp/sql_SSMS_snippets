--- The query below only works if in the logger we don't have multiple tags with similar names,
--- that is, multiple tags named "Tag1" for example

--- The first CTE CTE calculates the RowNum and Prev_Num_Value for each row in the original table
WITH CTE AS (
    SELECT
        Tag_Name,
        Num_Value,
        LAG(Num_Value) OVER (PARTITION BY Tag_Name ORDER BY Last_Op_TS_Local) AS Prev_Num_Value,
        ROW_NUMBER() OVER (PARTITION BY Tag_Name ORDER BY Last_Op_TS_Local) AS RowNum
    FROM Manual_Data_md
	--- You can use the clause below to select just the tags you want
	WHERE Tag_Name IN ('Tag1', 'Tag2', 'Tag3')
	--- You can use this to select distinct tags, but in case there is no coresponding logger tag, the ItemId will be NULL, insert will fail
	--- WHERE Tag_Name IN ( SELECT DISTINCT Tag_Name From Manual_Data_md)
)
--- Calculates the maximum RowNum for each distinct Tag_Name where Prev_Num_Value is not null.
--- This will help us identify the rows with the maximum RowNum for each distinct Tag_Name
---   which is the equivalent to the difference between Last and 2nd to Last
, MaxRowNumCTE AS (
    SELECT Tag_Name, MAX(RowNum) AS MaxRowNum
    FROM CTE
    WHERE Prev_Num_Value IS NOT NULL
    GROUP BY Tag_Name
)

-- We can also insert the result into the tItemValue table
-- INSERT INTO tItemValue ([TimeUtc], [TimeLoc], [NumValue], [StrValue], [Quality], [ItemId])

--- We join the CTE with MaxRowNumCTE on Tag_Name and RowNum to select only the rows 
--- Where RowNum is the maximum for each Tag_Name
--- AND calculate the Difference
SELECT
	--- in case we want to do SQL Table calculated values, then uncomment the row_number below

	-- ROW_NUMBER() OVER(ORDER BY c.Num_Value),
	--- to simply insert datatime, use the functions below; in Reports you should use dynamic tokens
	SYSUTCDATETIME() as TimeUtc,
	SYSDATETIME() as TimeLoc,
	-- you can use the following to insert yesterday; else use the Reports token
	-- DATEADD(DAY, -1, SYSDATETIME()) as TimeLoc,

	--- below you can multiply the calculation with a value
	--- or make another select query to retrieve a constant for the specific Id
	(c.Num_Value - c.Prev_Num_Value) * (
        SELECT Constant
        FROM [dbo].[Constants]
        WHERE Id = (SELECT i.Id FROM tItem i WHERE i.address LIKE '%' + c.Tag_Name + '%')
    ) as NumValue,
	NULL AS StrValue,
	1 As Quality,
	(SELECT i.Id FROM tItem i WHERE i.address LIKE '%' + c.Tag_Name + '%') AS ItemId
FROM CTE c
INNER JOIN MaxRowNumCTE m ON c.Tag_Name = m.Tag_Name AND c.RowNum = m.MaxRowNum
WHERE c.Prev_Num_Value IS NOT NULL
ORDER BY ItemId asc;
