SET NOCOUNT ON;
SELECT f.file_id,f.name,f.type_desc,f.physical_name,CAST(f.size/128.0 AS decimal(18,2)) AS size_mb,CASE WHEN f.max_size=-1 THEN 'UNLIMITED' ELSE CONVERT(varchar(30),CAST(f.max_size/128.0 AS decimal(18,2))) END AS max_size_mb,CASE WHEN f.is_percent_growth=1 THEN CONCAT(f.growth,'%') ELSE CONCAT(CAST(f.growth/128.0 AS decimal(18,2)),' MB') END AS autogrowth,v.volume_mount_point,CAST(v.available_bytes/1048576.0 AS decimal(18,2)) AS volume_free_mb
FROM tempdb.sys.database_files f OUTER APPLY sys.dm_os_volume_stats(2,f.file_id) v ORDER BY f.file_id;
