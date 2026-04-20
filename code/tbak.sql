-- Transaction log backup for SirketDB.
-- This captures all committed transactions since the last log backup and enables point-in-time recovery.
BACKUP LOG SirketDB
TO DISK = 'C:\Backup\SirketDB_log.trn';