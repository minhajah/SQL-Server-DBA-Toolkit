/* Module 15: Suspect pages recorded in msdb. Read-only. Run from master. */
SET NOCOUNT ON;
SELECT GETDATE() AS capture_time_local,
       DB_NAME(sp.database_id) AS database_name,
       sp.database_id, sp.file_id, sp.page_id, sp.event_type,
       CASE sp.event_type
            WHEN 1 THEN '823 or 824 (non-checksum/torn-page)'
            WHEN 2 THEN 'Bad checksum'
            WHEN 3 THEN 'Torn page'
            WHEN 4 THEN 'Restored'
            WHEN 5 THEN 'Repaired (DBCC)'
            WHEN 7 THEN 'Deallocated by DBCC'
            ELSE 'Other / unknown' END AS event_description,
       sp.error_count, sp.last_update_date
FROM msdb.dbo.suspect_pages AS sp
ORDER BY sp.last_update_date DESC, sp.database_id, sp.file_id, sp.page_id;
/* No rows does NOT prove that all databases are corruption-free. */
