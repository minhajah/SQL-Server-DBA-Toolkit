/* Module 15: Latest full backups as recovery context, NOT proof of integrity. Read-only. */
SET NOCOUNT ON;
;WITH FullBackup AS (
 SELECT bs.database_name, bs.backup_finish_date, bs.is_copy_only,
        bs.has_backup_checksums, bs.is_damaged,
        ROW_NUMBER() OVER (PARTITION BY bs.database_name ORDER BY bs.backup_finish_date DESC, bs.backup_set_id DESC) AS rn
 FROM msdb.dbo.backupset AS bs
 WHERE bs.type = 'D'
)
SELECT d.name AS database_name, d.state_desc, fb.backup_finish_date AS latest_full_backup_finish,
       fb.is_copy_only, fb.has_backup_checksums, fb.is_damaged
FROM sys.databases AS d
LEFT JOIN FullBackup AS fb ON fb.database_name = d.name AND fb.rn = 1
WHERE d.database_id > 4
ORDER BY d.name;
/* msdb history may be purged or incomplete; enterprise backups may not appear here.
   Backup checksums are not equivalent to a successful DBCC CHECKDB or restore test. */
