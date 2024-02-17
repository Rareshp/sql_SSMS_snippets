DECLARE @LastTransferId INT
DECLARE @LastTransactionId INT

-- Get the last Transfer_Id and Transaction_Id values
SELECT @LastTransferId = MAX(Transfer_Id), @LastTransactionId = MAX(Transaction_Id)
FROM Manual_Data_md;

-- Increment the Transfer_Id and Transaction_Id values
SET @LastTransferId = @LastTransferId + 1;
SET @LastTransactionId = @LastTransactionId + 1;

-- Insert the new record with incremented values
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
VALUES
    (SYSUTCDATETIME(), 
    SYSDATETIME(),
    SYSUTCDATETIME(), 
    SYSDATETIME(), 
    'Tag1', 2, 1, 1, @LastTransferId, @LastTransactionId, 'admin');
