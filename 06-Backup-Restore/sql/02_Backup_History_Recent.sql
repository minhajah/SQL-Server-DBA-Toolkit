/* 06 Backup & Restore | Recent backup history | master | Read-only */
SET NOCOUNT ON;
DECLARE @LookbackDays int=30;
SELECT bs.database_name,CASE bs.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFFERENTIAL' WHEN 'L' THEN 'LOG' ELSE bs.type END backup_type,
       bs.backup_start_date,bs.backup_finish_date,DATEDIFF(SECOND,bs.backup_start_date,bs.backup_finish_date) duration_seconds,
       CAST(bs.backup_size/1048576.0 AS decimal(18,2)) backup_size_mb,
       CAST(bs.compressed_backup_size/1048576.0 AS decimal(18,2)) compressed_size_mb,
       CAST(bs.compressed_backup_size/NULLIF(DATEDIFF(SECOND,bs.backup_start_date,bs.backup_finish_date),0)/1048576.0 AS decimal(18,2)) compressed_mb_per_sec,
       bs.is_copy_only,bs.recovery_model,bs.user_name,bmf.physical_device_name
FROM msdb.dbo.backupset bs LEFT JOIN msdb.dbo.backupmediafamily bmf ON bmf.media_set_id=bs.media_set_id
WHERE bs.backup_start_date>=DATEADD(DAY,-@LookbackDays,GETDATE()) ORDER BY bs.backup_finish_date DESC,bs.database_name;
