/* 06 Backup & Restore | Backup age status | master | Read-only. Set thresholds to policy. */
SET NOCOUNT ON;
DECLARE @FullBackupMaxAgeHours int=168,@DiffBackupMaxAgeHours int=48,@LogBackupMaxAgeMinutes int=60;
;WITH B AS
(
 SELECT database_name,
 MAX(CASE WHEN type='D' AND is_copy_only=0 THEN backup_finish_date END) last_full_backup,
 MAX(CASE WHEN type='I' THEN backup_finish_date END) last_diff_backup,
 MAX(CASE WHEN type='L' THEN backup_finish_date END) last_log_backup
 FROM msdb.dbo.backupset GROUP BY database_name
)
SELECT d.name AS database_name,d.state_desc,d.recovery_model_desc,
       b.last_full_backup,DATEDIFF(MINUTE,b.last_full_backup,GETDATE())/60.0 AS full_backup_age_hours,
       CASE WHEN b.last_full_backup IS NULL THEN 'NO FULL BACKUP IN MSDB HISTORY'
            WHEN DATEDIFF(HOUR,b.last_full_backup,GETDATE())>@FullBackupMaxAgeHours THEN 'REVIEW' ELSE 'WITHIN THRESHOLD' END full_backup_status,
       b.last_diff_backup,DATEDIFF(MINUTE,b.last_diff_backup,GETDATE())/60.0 AS diff_backup_age_hours,
       CASE WHEN b.last_diff_backup IS NULL THEN 'NO DIFFERENTIAL RECORDED'
            WHEN DATEDIFF(HOUR,b.last_diff_backup,GETDATE())>@DiffBackupMaxAgeHours THEN 'REVIEW' ELSE 'WITHIN THRESHOLD' END diff_backup_status,
       b.last_log_backup,DATEDIFF(MINUTE,b.last_log_backup,GETDATE()) AS log_backup_age_minutes,
       CASE WHEN d.recovery_model_desc='SIMPLE' THEN 'NOT APPLICABLE - SIMPLE'
            WHEN b.last_log_backup IS NULL THEN 'NO LOG BACKUP IN MSDB HISTORY'
            WHEN DATEDIFF(MINUTE,b.last_log_backup,GETDATE())>@LogBackupMaxAgeMinutes THEN 'REVIEW' ELSE 'WITHIN THRESHOLD' END log_backup_status
FROM sys.databases d LEFT JOIN B b ON b.database_name=d.name WHERE d.source_database_id IS NULL ORDER BY d.name;
