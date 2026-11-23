/* Module 15: Database integrity overview. Read-only. Run from master. */
SET NOCOUNT ON;
SELECT GETDATE() AS capture_time_local, @@SERVERNAME AS server_name,
       d.name AS database_name, d.state_desc, d.user_access_desc,
       d.recovery_model_desc, d.page_verify_option_desc,
       d.is_read_only, d.is_auto_close_on, d.is_auto_shrink_on,
       d.log_reuse_wait_desc,
       CASE WHEN d.page_verify_option_desc = 'CHECKSUM' THEN 'CHECKSUM configured'
            ELSE 'Review PAGE_VERIFY setting (change requires approval)' END AS page_verify_note
FROM sys.databases AS d
ORDER BY d.database_id;
