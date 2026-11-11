/* 04 Database Growth | Largest tables | Run in target database | Read-only */
SET NOCOUNT ON;
;WITH A AS
(
 SELECT object_id,SUM(CASE WHEN index_id IN (0,1) THEN row_count ELSE 0 END) row_count,
        SUM(reserved_page_count) reserved_pages,
        SUM(used_page_count) used_pages,
        SUM(in_row_data_page_count+lob_used_page_count+row_overflow_used_page_count) data_pages,
        SUM(used_page_count-in_row_data_page_count-lob_used_page_count-row_overflow_used_page_count) index_pages
 FROM sys.dm_db_partition_stats GROUP BY object_id
)
SELECT TOP(100) s.name AS schema_name,t.name AS table_name,a.row_count,
       CAST(a.reserved_pages*8.0/1024 AS decimal(18,2)) reserved_mb,
       CAST(a.used_pages*8.0/1024 AS decimal(18,2)) used_mb,
       CAST(a.data_pages*8.0/1024 AS decimal(18,2)) data_mb,
       CAST(a.index_pages*8.0/1024 AS decimal(18,2)) index_mb
FROM A a JOIN sys.tables t ON t.object_id=a.object_id JOIN sys.schemas s ON s.schema_id=t.schema_id
WHERE t.is_ms_shipped=0 ORDER BY a.reserved_pages DESC;
