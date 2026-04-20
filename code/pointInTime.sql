-- Point-in-time recovery of SirketDB using the transaction log.
-- Restores the transaction log and recovers the database to the specified moment.
RESTORE LOG SirketDB
FROM DISK = 'C:\Backup\SirketDB_log.trn'
WITH STOPAT = '2026-04-19 18:20:00',
RECOVERY;