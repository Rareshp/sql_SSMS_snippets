--IF OBJECT_ID ( 'getEntalpie', 'P' ) IS NOT NULL   
--    DROP PROCEDURE getEntalpie;  
--GO  

-- this procedure takes in real values for Pressure, Temperature and a table
-- then returns the enthalpy for that P-T pair in a precomputed table

-- use ALTER instead of droping the procedure
CREATE PROCEDURE getEntalpie
    @Presiune_R    REAL,
    @Temperatura_R REAL,
	@TableName     char(50),
	@Result REAL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Temp INT;
	SET @Temp = CAST(ROUND(@Temperatura_R, 0) AS INT);

	DECLARE @Presiune INT;
	SET @Presiune = CAST(ROUND(@Presiune_R, 0) AS INT);

	-- Check if @Presiune is lower than what it should
    IF @Presiune < 2
    BEGIN
        SET @Result = NULL;
        RETURN;
    END

	-- the column name is a numbeer = @Presiune, example [10]
	DECLARE @ColumnName NVARCHAR(255);
	SET @ColumnName = QUOTENAME(CONVERT(NVARCHAR, @Presiune));

	DECLARE @SqlQuery NVARCHAR(MAX);
	SET @SqlQuery = 'SELECT ' + @ColumnName + ' FROM ' + @TableName + ' WHERE Temp = @Temp'

	BEGIN TRY
        EXEC sp_executesql @SqlQuery, N'@Temp INT OUTPUT', @Temp = @Temp OUTPUT;
        SET @Result = @Temp;  -- Assign the result to the output parameter
    END TRY
    BEGIN CATCH
        -- Handle the error as needed
        PRINT 'getEntalpie: An error occurred: ' + ERROR_MESSAGE();
        SET @Result = NULL;  -- Set the result to NULL or any other default value
    END CATCH;
END;
