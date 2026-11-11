SET NOCOUNT ON;
SELECT DISTINCT v.volume_mount_point,v.logical_volume_name,CAST(v.total_bytes/1048576.0 AS decimal(18,2)) AS total_mb,CAST(v.available_bytes/1048576.0 AS decimal(18,2)) AS available_mb,CAST(100.0*v.available_bytes/NULLIF(v.total_bytes,0) AS decimal(6,2)) AS free_percent
FROM sys.master_files f CROSS APPLY sys.dm_os_volume_stats(f.database_id,f.file_id) v ORDER BY v.volume_mount_point;
