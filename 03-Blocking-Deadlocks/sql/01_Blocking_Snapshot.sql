/*
MODULE 03 - BLOCKING SNAPSHOT
Read-only | SQL Server 2016 SP1+
Run while blocking is occurring. Repeated snapshots may be needed.
Query text and login/host details may be sensitive.
*/

SET NOCOUNT ON;
SET DEADLOCK_PRIORITY LOW;
SET LOCK_TIMEOUT 5000;

-- 1. Current blocked requests and their blocker details
SELECT
    SYSDATETIME() AS capture_time,
    r.session_id AS blocked_session_id,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS database_name,
    r.status AS request_status,
    r.wait_type,
    r.wait_time AS wait_ms,
    r.wait_resource,
    r.command,
    r.cpu_time AS cpu_ms,
    r.total_elapsed_time AS elapsed_ms,
    s.login_name AS blocked_login,
    s.host_name AS blocked_host,
    s.program_name AS blocked_program,
    bs.login_name AS blocker_login,
    bs.host_name AS blocker_host,
    bs.program_name AS blocker_program,
    st.text AS blocked_batch_text
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
LEFT JOIN sys.dm_exec_sessions AS bs ON bs.session_id = r.blocking_session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE r.blocking_session_id <> 0
ORDER BY r.wait_time DESC;

-- 2. User sessions with open transactions, including sleeping sessions
SELECT
    s.session_id,
    s.status AS session_status,
    s.login_name,
    s.host_name,
    s.program_name,
    s.last_request_start_time,
    s.last_request_end_time,
    s.open_transaction_count,
    s.transaction_isolation_level,
    c.client_net_address,
    c.connect_time,
    c.net_transport,
    c.protocol_type,
    c.encrypt_option,
    ib.event_info AS most_recent_input
FROM sys.dm_exec_sessions AS s
LEFT JOIN sys.dm_exec_connections AS c ON c.session_id = s.session_id
OUTER APPLY sys.dm_exec_input_buffer(s.session_id, NULL) AS ib
WHERE s.is_user_process = 1
  AND (s.open_transaction_count > 0 OR s.session_id IN
       (SELECT blocking_session_id FROM sys.dm_exec_requests WHERE blocking_session_id > 0))
ORDER BY s.open_transaction_count DESC, s.last_request_end_time;

-- 3. Active transactions and age
SELECT
    st.session_id,
    at.transaction_id,
    at.name AS transaction_name,
    at.transaction_begin_time,
    DATEDIFF(SECOND, at.transaction_begin_time, SYSDATETIME()) AS transaction_age_seconds,
    at.transaction_type,
    at.transaction_state,
    dt.database_id,
    DB_NAME(dt.database_id) AS database_name,
    s.login_name,
    s.host_name,
    s.program_name
FROM sys.dm_tran_active_transactions AS at
JOIN sys.dm_tran_session_transactions AS st
  ON st.transaction_id = at.transaction_id
LEFT JOIN sys.dm_tran_database_transactions AS dt
  ON dt.transaction_id = at.transaction_id
LEFT JOIN sys.dm_exec_sessions AS s
  ON s.session_id = st.session_id
ORDER BY at.transaction_begin_time;

-- 4. Lock summary by request/session
SELECT
    request_session_id AS session_id,
    DB_NAME(resource_database_id) AS database_name,
    resource_type,
    request_mode,
    request_status,
    COUNT(*) AS lock_count
FROM sys.dm_tran_locks
GROUP BY request_session_id, resource_database_id, resource_type, request_mode, request_status
ORDER BY request_session_id, lock_count DESC;
