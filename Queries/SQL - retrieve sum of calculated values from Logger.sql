DECLARE @StartTime DATETIME = DATEADD(DAY, -1, SYSDATETIME()) --- '[tp#Data]'
DECLARE @EndTime DATETIME = DATEADD(DAY, 1, @StartTime);

WITH CTE AS (
    -- first we need to give each distinct ItemId a row number to filter them later 
	-- row 1 is the most recent
    SELECT
        tItemValue.*,
        ROW_NUMBER() OVER (PARTITION BY tItemValue.ItemId ORDER BY tItemValue.TimeLoc DESC) AS RowNum
    FROM
        tItemValue
    JOIN tItem ON tItemValue.ItemId = tItem.Id
    WHERE
	    --- change this value to an object in reports, or use DATEADD(DAY, -1, SYSDATETIME())
	    --- below can break if names are similar
        tItemValue.TimeLoc >= @StartTime
        AND tItemValue.TimeLoc < @EndTime
        AND (
               tItem.Address LIKE '%Tag1%'
            OR tItem.Address LIKE '%Tag2%'
        )
)
 SELECT *
--SELECT SUM(NumValue) AS TotalNumValue
FROM CTE
WHERE RowNum = 1;
