SET NOCOUNT ON;
SELECT OBJECT_SCHEMA_NAME(p.object_id) AS schema_name,OBJECT_NAME(p.object_id) AS table_name,i.name AS index_name,p.index_id,p.partition_number,p.page_count,p.avg_fragmentation_in_percent,p.avg_page_space_used_in_percent,p.index_type_desc
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,'LIMITED') p LEFT JOIN sys.indexes i ON i.object_id=p.object_id AND i.index_id=p.index_id WHERE p.index_id>0 AND p.page_count>0 ORDER BY p.page_count DESC;
