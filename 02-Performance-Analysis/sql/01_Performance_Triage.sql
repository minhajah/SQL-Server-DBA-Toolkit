/*
MODULE 02 - PERFORMANCE TRIAGE
Read-only | SQL Server 2016 SP1+
Run during the slowdown. Query text may contain sensitive literals.
Permissions: typically VIEW SERVER STATE; SQL Server 2022+ may require
VIEW SERVER PERFORMANCE STATE. VIEW DATABASE STATE may be needed for Query Store.
*/

SET NOCOUNT ON;
SET DEADLOCK_PRIORITY LOW;
SET LOCK_TIMEOUT 5000;

-- 1. Requests running right now
SELECT
    SYSDATETIME() AS capture_time,
    r.session_id,
    s.login_name,
    s.host_name,
    s.program_name,
    DB_NAME(r.database_id) AS database_name,
    r.status,
    r.command,
    r.start_time,
    r.cpu_time AS cpu_ms,
    r.total_elapsed_time AS elapsed_ms,
    r.wait_type,
    r.wait_time AS wait_ms,
    r.wait_resource,
    r.blocking_session_id,
    r.logical_reads,
    r.reads,
    r.writes,
    SUBSTRING
    (
        st.text,
        (r.statement_start_offset / 2) + 1,
        (
            CASE WHEN r.statement_end_offset = -1 THEN DATALENGTH(st.text)
                 ELSE r.statement_end_offset END - r.statement_start_offset
        ) / 2 + 1
    ) AS running_statement,
    st.text AS batch_text
FROM sys.dm_exec_requests AS r
JOIN sys.dm_exec_sessions AS s ON s.session_id = r.session_id
OUTER APPLY sys.dm_exec_sql_text(r.sql_handle) AS st
WHERE s.is_user_process = 1
ORDER BY r.total_elapsed_time DESC;

-- 2. Top cached statements by total worker time (CPU)
SELECT TOP (50)
    DB_NAME(CONVERT(int, pa.value)) AS database_name,
    qs.execution_count,
    qs.total_worker_time / 1000.0 AS total_cpu_ms,
    (qs.total_worker_time / NULLIF(qs.execution_count, 0)) / 1000.0 AS avg_cpu_ms,
    qs.total_elapsed_time / 1000.0 AS total_elapsed_ms,
    (qs.total_elapsed_time / NULLIF(qs.execution_count, 0)) / 1000.0 AS avg_elapsed_ms,
    qs.total_logical_reads,
    qs.total_logical_reads / NULLIF(qs.execution_count, 0) AS avg_logical_reads,
    qs.total_physical_reads,
    qs.total_logical_writes,
    qs.last_execution_time,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            CASE WHEN qs.statement_end_offset = -1 THEN DATALENGTH(st.text)
                 ELSE qs.statement_end_offset END - qs.statement_start_offset
        ) / 2 + 1
    ) AS statement_text,
    st.text AS batch_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
OUTER APPLY
(
    SELECT TOP (1) CONVERT(int, value) AS value
    FROM sys.dm_exec_plan_attributes(qs.plan_handle)
    WHERE attribute = N'dbid'
) AS pa
ORDER BY qs.total_worker_time DESC;

-- 3. Top cached statements by total logical reads
SELECT TOP (30)
    qs.execution_count,
    qs.total_logical_reads,
    qs.total_logical_reads / NULLIF(qs.execution_count, 0) AS avg_logical_reads,
    qs.total_worker_time / 1000.0 AS total_cpu_ms,
    qs.last_execution_time,
    LEFT(st.text, 4000) AS batch_text
FROM sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
ORDER BY qs.total_logical_reads DESC;

-- 4. Wait statistics (cumulative since startup / last reset)
SELECT TOP (30)
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0 AS wait_seconds,
    signal_wait_time_ms / 1000.0 AS signal_wait_seconds,
    CASE WHEN waiting_tasks_count = 0 THEN NULL
         ELSE wait_time_ms * 1.0 / waiting_tasks_count END AS avg_wait_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT LIKE N'SLEEP%'
  AND wait_type NOT IN
  (
    N'BROKER_EVENTHANDLER', N'BROKER_RECEIVE_WAITFOR', N'BROKER_TASK_STOP',
    N'BROKER_TO_FLUSH', N'SQLTRACE_BUFFER_FLUSH', N'CLR_AUTO_EVENT',
    N'CLR_MANUAL_EVENT', N'LAZYWRITER_SLEEP', N'XE_TIMER_EVENT',
    N'XE_DISPATCHER_WAIT', N'REQUEST_FOR_DEADLOCK_SEARCH', N'LOGMGR_QUEUE',
    N'CHECKPOINT_QUEUE'
  )
ORDER BY wait_time_ms DESC;

-- 5. Missing-index suggestions (advisory only; do not create automatically)
SELECT TOP (30)
    DB_NAME(mid.database_id) AS database_name,
    OBJECT_SCHEMA_NAME(mid.object_id, mid.database_id) AS schema_name,
    OBJECT_NAME(mid.object_id, mid.database_id) AS table_name,
    migs.user_seeks,
    migs.user_scans,
    migs.avg_total_user_cost,
    migs.avg_user_impact,
    (migs.user_seeks + migs.user_scans) * migs.avg_total_user_cost
        * (migs.avg_user_impact / 100.0) AS estimated_benefit,
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns
FROM sys.dm_db_missing_index_group_stats AS migs
JOIN sys.dm_db_missing_index_groups AS mig
  ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details AS mid
  ON mig.index_handle = mid.index_handle
ORDER BY estimated_benefit DESC;

-- 6. Query Store availability by database; does not enable or modify it
SELECT
    name AS database_name,
    is_query_store_on
FROM sys.databases
ORDER BY name;

-- Optional: after identifying a database with Query Store enabled, use its
-- Query Store reports in SSMS or a separately reviewed Query Store query.
