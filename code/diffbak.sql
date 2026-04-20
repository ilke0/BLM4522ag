-- Differential backup for SirketDB.
-- This backs up only the data changed since the last full backup, reducing backup size and time.
BACKUP DATABASE SirketDB
TO DISK = 'C:\Backup\SirketDB_diff.bak'
WITH DIFFERENTIAL;