/* 04 Database Growth | Instance file inventory | Run in master | Read-only | SQL Server 2016+ */
SET NOCOUNT ON;
SELECT @@SERVERNAME AS server_name, d.name AS database_name, d.state_desc, d.recovery_model_desc,
       mf.file_id, mf.name AS logical_file_name, mf.type_desc, mf.physical_name,
       CAST(mf.size/128.0 AS decimal(18,2)) AS allocated_size_mb,
       CASE WHEN mf.max_size=-1 THEN 'UNLIMITED' WHEN mf.max_size=0 THEN 'NO_GROWTH'
            ELSE CONVERT(varchar(30),CAST(mf.max_size/128.0 AS decimal(18,2)))+' MB' END AS max_size,
       CASE WHEN mf.is_percent_growth=1 THEN CONCAT(mf.growth,'%') WHEN mf.growth=0 THEN 'DISABLED'
            ELSE CONCAT(CAST(mf.growth/128.0 AS decimal(18,2)),' MB') END AS autogrowth_setting,
       vs.volume_mount_point,
       CAST(vs.total_bytes/1073741824.0 AS decimal(18,2)) AS volume_total_gb,
       CAST(vs.available_bytes/1073741824.0 AS decimal(18,2)) AS volume_free_gb,
       CAST(100.0*vs.available_bytes/NULLIF(vs.total_bytes,0) AS decimal(6,2)) AS volume_free_percent
FROM sys.master_files mf JOIN sys.databases d ON d.database_id=mf.database_id
OUTER APPLY sys.dm_os_volume_stats(mf.database_id,mf.file_id) vs
ORDER BY d.name,mf.file_id;
