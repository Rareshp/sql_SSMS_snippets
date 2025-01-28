-- FULL Backup
USE [YourDatabaseName];

DECLARE @DatabaseName NVARCHAR(128) = 'YourDatabaseName'
DECLARE @BackupFilePath NVARCHAR(256) = 'C:\ODS\AVEVA Reports\Project\Backups\SQL_Server_Backup_' +
    REPLACE(CONVERT(NVARCHAR(10), GETDATE(), 120), '-', '_') + '_full.bak'

BACKUP DATABASE @DatabaseName
TO DISK = @BackupFilePath
WITH FORMAT,
     MEDIANAME = 'SQLServerBackups',
     NAME = 'Full Backup of YourDatabaseName';

-- Differential Backup:
-- Diff Backup captures changes made since the full backup.

USE [YourDatabaseName];

DECLARE @DatabaseName NVARCHAR(128) = 'YourDatabaseName'
DECLARE @BackupFilePath NVARCHAR(256) = 'C:\ODS\AVEVA Reports\Project\Backups\SQL_Server_Backup_' +
    REPLACE(CONVERT(NVARCHAR(10), GETDATE(), 120), '-', '_') + '_differential.bak'

BACKUP DATABASE @DatabaseName
TO DISK = @BackupFilePath
WITH DIFFERENTIAL,
     FORMAT,
     MEDIANAME = 'SQLServerBackups',
     NAME = 'Full Backup of YourDatabaseName';


-- To restore, you first restore the FULL then the diff if needed
RESTORE DATABASE YourDatabaseName
FROM DISK = 'C:\ODS\AVEVA Reports\Project\Backups\SQL_Server_Backup_xxx_full.bak'
WITH NORECOVERY;

RESTORE DATABASE YourDatabaseName
FROM DISK = 'C:\ODS\AVEVA Reports\Project\Backups\SQL_Server_Backup_xxx_differential.bak'
WITH NORECOVERY;
