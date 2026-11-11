SET NOCOUNT ON;
SELECT GETDATE() AS captured_at,SUM(unallocated_extent_page_count)*8.0/1024 AS unallocated_mb,SUM(version_store_reserved_page_count)*8.0/1024 AS version_store_mb,SUM(user_object_reserved_page_count)*8.0/1024 AS user_objects_mb,SUM(internal_object_reserved_page_count)*8.0/1024 AS internal_objects_mb FROM tempdb.sys.dm_db_file_space_usage;
