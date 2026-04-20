-- Verify that the full backup file is readable and structurally valid.
-- This does not restore the database.
RESTORE VERIFYONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';

-- Read the backup header metadata from the full backup file.
-- Returns information such as backup type, database name, and backup start time.
RESTORE HEADERONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';

-- Read the header metadata from the transaction log backup file.
-- Use this to validate the log backup and confirm its sequence.
RESTORE HEADERONLY
FROM DISK = 'C:\Backup\SirketDB_log1.trn';

-- List the logical and physical files contained in the full backup.
-- Useful for confirming the database file layout before restore.
RESTORE FILELISTONLY
FROM DISK = 'C:\Backup\SirketDB_full.bak';