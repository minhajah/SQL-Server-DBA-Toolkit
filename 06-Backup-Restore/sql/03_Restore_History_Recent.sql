/* 06 Backup & Restore | Recent restore history | master | Read-only */
SET NOCOUNT ON;
DECLARE @LookbackDays int=90;
SELECT rh.destination_database_name,rh.restore_date,rh.restore_type,
       CASE rh.restore_type WHEN 'D' THEN 'DATABASE' WHEN 'F' THEN 'FILE' WHEN 'G' THEN 'FILEGROUP'
            WHEN 'I' THEN 'DIFFERENTIAL' WHEN 'L' THEN 'LOG' ELSE 'OTHER' END restore_type_desc,
       rh.recovery,rh.replace,rh.restart,rh.stop_at,rh.user_name,bs.database_name AS source_database_name,
       bs.backup_start_date,bs.backup_finish_date
FROM msdb.dbo.restorehistory rh LEFT JOIN msdb.dbo.backupset bs ON bs.backup_set_id=rh.backup_set_id
WHERE rh.restore_date>=DATEADD(DAY,-@LookbackDays,GETDATE()) ORDER BY rh.restore_date DESC;
