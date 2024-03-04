-- this procedure takes in real values for Pressure, Temperature and a table
-- then returns the enthalpy for that P-T pair in a precomputed table

DECLARE @Result REAL;

EXEC getEntalpie
     @Presiune_R = 4.2,
     @Temperatura_R = 154,
	 @TableName  = 'entalpii_kjkg',
     @Result = @Result OUTPUT;

-- Now @Result contains the output from the stored procedure
PRINT ISNULL(CONVERT(VARCHAR, @Result), 'NULL');
