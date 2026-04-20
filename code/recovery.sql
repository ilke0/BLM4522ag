-- Recovery script for SirketDB.
-- This sets the database to single-user mode, restores the full backup, then applies a sequence of transaction log backups.
-- The final WITH RECOVERY brings the database online after all logs have been applied.
USE master;

ALTER DATABASE SirketDB
SET SINGLE_USER WITH ROLLBACK IMMEDIATE;


RESTORE DATABASE SirketDB
FROM DISK = 'C:\Backup\SirketDB_full.bak'
WITH NORECOVERY;

RESTORE LOG SirketDB
FROM DISK = 'C:\Backup\SirketDB_log1.trn'
WITH NORECOVERY;

RESTORE LOG SirketDB
FROM DISK = 'C:\Backup\SirketDB_log2.trn'
WITH NORECOVERY;

RESTORE LOG SirketDB
FROM DISK = 'C:\Backup\SirketDB_log3.trn'
WITH RECOVERY;