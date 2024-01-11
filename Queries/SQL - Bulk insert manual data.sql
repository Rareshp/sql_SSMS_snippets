-- Example of manual bulk insert into a manual table

INSERT INTO Manual_Data_md ([Orig_TS_UTC]
      ,[Orig_TS_Local]
      ,[Last_Op_TS_UTC]
      ,[Last_Op_TS_Local],
	  Tag_Name, 
	  Num_Value,
	  [Operation_Type],
      [Status],
	  Transfer_Id,
	  Transaction_Id,
	  [User])
	  --- you must change the Transfer_Id and Transaction_Id values 
VALUES
	(SYSUTCDATETIME(), SYSDATETIME(),SYSUTCDATETIME(), SYSDATETIME(), 'Tag1', 2, 1, 1, 1005, 138, 'admin'),
	(SYSUTCDATETIME(), SYSDATETIME(),SYSUTCDATETIME(), SYSDATETIME(), 'Tag2', 2, 1, 1, 1005, 138, 'admin')
	

-- month example
INSERT INTO Manual_Data_md ([Orig_TS_UTC]
      ,[Orig_TS_Local]
      ,[Last_Op_TS_UTC]
      ,[Last_Op_TS_Local],
	  Tag_Name, 
	  Num_Value,
	  [Operation_Type],
      [Status],
	  Transfer_Id,
	  Transaction_Id,
	  [User])
	  --- you must change the Transfer_Id and Transaction_Id values 
VALUES
	(DATEADD(MONTH, -1, SYSUTCDATETIME()), 
	DATEADD(MONTH, -1, SYSDATETIME()),
	DATEADD(MONTH, -1, SYSUTCDATETIME()), 
	DATEADD(MONTH, -1, SYSDATETIME()), 
	'Tag1', 2, 1, 1, 1006, 139, 'admin'),

	(DATEADD(MONTH, -1, SYSUTCDATETIME()), 
	DATEADD(MONTH, -1, SYSDATETIME()),
	DATEADD(MONTH, -1, SYSUTCDATETIME()), 
	DATEADD(MONTH, -1, SYSDATETIME()), 
	'Tag2', 2, 1, 1, 1006, 139, 'admin'),

