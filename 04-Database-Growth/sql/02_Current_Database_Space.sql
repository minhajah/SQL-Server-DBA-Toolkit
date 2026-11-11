/* 04 Database Growth | Current database space | Run in target database | Read-only */
SET NOCOUNT ON;
SELECT DB_NAME() AS database_name, SYSDATETIME() AS capture_time, file_id, name AS logical_file_name,
       type_desc, physical_name, CAST(size/128.0 AS decimal(18,2)) AS allocated_size_mb,
       CASE WHEN type_desc='ROWS' THEN CAST(FILEPROPERTY(name,'SpaceUsed')/128.0 AS decimal(18,2)) END AS used_data_file_mb,
       CASE WHEN type_desc='ROWS' THEN CAST((size-FILEPROPERTY(name,'SpaceUsed'))/128.0 AS decimal(18,2)) END AS free_inside_data_file_mb,
       CASE WHEN max_size=-1 THEN 'UNLIMITED' WHEN max_size=0 THEN 'NO_GROWTH'
            ELSE CONVERT(varchar(30),CAST(max_size/128.0 AS decimal(18,2)))+' MB' END AS max_size,
       CASE WHEN is_percent_growth=1 THEN CONCAT(growth,'%') WHEN growth=0 THEN 'DISABLED'
            ELSE CONCAT(CAST(growth/128.0 AS decimal(18,2)),' MB') END AS autogrowth_setting
FROM sys.database_files ORDER BY file_id;
SELECT DB_NAME() AS database_name,total_log_size_in_bytes/1048576.0 AS total_log_size_mb,
       used_log_space_in_bytes/1048576.0 AS used_log_space_mb,used_log_space_in_percent,
       log_space_in_bytes_since_last_backup/1048576.0 AS log_generated_since_last_backup_mb
FROM sys.dm_db_log_space_usage;
SELECT name AS database_name,recovery_model_desc,log_reuse_wait_desc FROM sys.databases WHERE database_id=DB_ID();
