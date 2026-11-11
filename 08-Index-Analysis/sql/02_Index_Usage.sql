SET NOCOUNT ON;
SELECT OBJECT_SCHEMA_NAME(i.object_id) AS schema_name, OBJECT_NAME(i.object_id) AS table_name, i.name AS index_name, i.index_id, COALESCE(u.user_seeks,0) AS user_seeks, COALESCE(u.user_scans,0) AS user_scans, COALESCE(u.user_lookups,0) AS user_lookups, COALESCE(u.user_updates,0) AS user_updates, u.last_user_seek,u.last_user_scan,u.last_user_lookup,u.last_user_update
FROM sys.indexes i LEFT JOIN sys.dm_db_index_usage_stats u ON u.database_id=DB_ID() AND u.object_id=i.object_id AND u.index_id=i.index_id
WHERE i.object_id>0 AND i.index_id>0 AND OBJECTPROPERTY(i.object_id,'IsUserTable')=1 ORDER BY COALESCE(u.user_seeks,0)+COALESCE(u.user_scans,0)+COALESCE(u.user_lookups,0);
