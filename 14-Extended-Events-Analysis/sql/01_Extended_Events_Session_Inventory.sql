/* 14 - Configured XE sessions and their events/targets. Read-only. Run in master. */
SET NOCOUNT ON;
SELECT
    s.name AS session_name,
    CASE WHEN xs.name IS NULL THEN 'STOPPED' ELSE 'RUNNING' END AS runtime_state,
    s.startup_state,
    s.event_retention_mode_desc,
    s.max_dispatch_latency,
    s.max_memory,
    e.name AS event_name,
    e.package AS event_package,
    t.name AS target_name,
    t.package AS target_package
FROM sys.server_event_sessions AS s
LEFT JOIN sys.dm_xe_sessions AS xs ON xs.name = s.name
LEFT JOIN sys.server_event_session_events AS e ON e.event_session_id = s.event_session_id
LEFT JOIN sys.server_event_session_targets AS t ON t.event_session_id = s.event_session_id
ORDER BY s.name, e.name, t.name;
-- Multiple rows per session are expected when a session has multiple events and targets.
