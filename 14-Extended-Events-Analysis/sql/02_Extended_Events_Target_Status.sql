/* 14 - Running XE targets and session health. Read-only. Run in master. */
SET NOCOUNT ON;
SELECT
    xs.name AS session_name,
    xs.create_time AS session_start_time,
    xs.total_buffer_size,
    xs.buffer_policy_desc,
    xs.dropped_event_count,
    xs.dropped_buffer_count,
    xt.target_name,
    xt.execution_count,
    xt.execution_duration_ms,
    CASE WHEN xt.target_name = N'event_file'
         THEN TRY_CAST(xt.target_data AS xml).value('(EventFileTarget/File/@name)[1]', 'nvarchar(4000)')
         ELSE NULL END AS current_event_file_name
FROM sys.dm_xe_sessions AS xs
LEFT JOIN sys.dm_xe_session_targets AS xt ON xt.event_session_address = xs.address
ORDER BY xs.name, xt.target_name;

/* Configured event-file names, including stopped sessions. */
SELECT
    s.name AS session_name,
    t.name AS target_name,
    f.name AS target_setting,
    f.value AS configured_value
FROM sys.server_event_sessions AS s
JOIN sys.server_event_session_targets AS t ON t.event_session_id = s.event_session_id
JOIN sys.server_event_session_fields AS f
  ON f.event_session_id = t.event_session_id
 AND f.object_id = t.target_id
WHERE t.name = N'event_file'
  AND f.name IN (N'filename', N'max_file_size', N'max_rollover_files')
ORDER BY s.name, f.name;
