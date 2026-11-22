/* Read-only. Execute in the affected database. */
SET NOCOUNT ON;
SELECT DB_NAME() AS database_name, actual_state_desc, desired_state_desc,
       readonly_reason, current_storage_size_mb, max_storage_size_mb,
       query_capture_mode_desc, size_based_cleanup_mode_desc,
       stale_query_threshold_days
FROM sys.database_query_store_options;
