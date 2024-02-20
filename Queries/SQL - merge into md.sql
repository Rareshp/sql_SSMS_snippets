MERGE INTO Manual_Data_Electro_TOT AS target
USING (VALUES 
('2024-01-31 22:00:00.000', '2024-02-01 00:00:00.000', SYSUTCDATETIME(), SYSDATETIME(), 'Tag1', 895284, 1, 1,7644, 3985, 'username'),
('2024-02-01 22:00:00.000', '2024-02-02 00:00:00.000', SYSUTCDATETIME(), SYSDATETIME(), 'Tag2', 898393, 1, 1,7648, 3989, 'username')
) AS source (Orig_TS_UTC, Orig_TS_Local, Last_Op_TS_UTC, Last_Op_TS_Local, Tag_Name, Num_Value, Operation_Type, Status, Transfer_Id, Transaction_Id, [User])
ON target.Orig_TS_Local = source.Orig_TS_Local AND target.Tag_Name = source.Tag_Name
WHEN MATCHED THEN
  UPDATE SET 
    target.Num_Value = source.Num_Value,
    target.Orig_TS_UTC = source.Orig_TS_UTC,
    target.Orig_TS_Local = source.Orig_TS_Local,
    target.[User] = source.[User]
WHEN NOT MATCHED THEN
  INSERT (
    Orig_TS_UTC, Orig_TS_Local, Last_Op_TS_UTC, Last_Op_TS_Local, Tag_Name, Num_Value, Operation_Type, Status, Transfer_Id, Transaction_Id, [User]
  )
  VALUES (
    source.Orig_TS_UTC, source.Orig_TS_Local, source.Last_Op_TS_UTC, source.Last_Op_TS_Local, source.Tag_Name, source.Num_Value, source.Operation_Type, source.Status, source.Transfer_Id, source.Transaction_Id, source.[User]
);
