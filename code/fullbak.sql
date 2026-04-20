-- Full database backup for SirketDB.
-- This creates a complete backup file that can be used to restore the database to this point in time.
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\SirketDB_full.bak'
WITH INIT;