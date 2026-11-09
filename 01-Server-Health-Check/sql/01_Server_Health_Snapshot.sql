/*
MODULE 01 - SERVER HEALTH SNAPSHOT
Read-only | SQL Server 2016 SP1+
Run against the target instance in SSMS. Save all result sets.
Permissions: typically VIEW SERVER STATE; SQL Server 2022+ may require
VIEW SERVER PERFORMANCE STATE for some DMV access.
*/

SET NOCOUNT ON;
SET DEADLOCK_PRIORITY LOW;
SET LOCK_TIMEOUT 5000;

-- 1. Instance identity and uptime
SELECT
    SYSDATETIMEOFFSET() AS capture_time_local,
    SYSUTCDATETIME() AS capture_time_utc,
    @@SERVERNAME AS server_name,
    SERVERPROPERTY('MachineName') AS machine_name,
    SERVERPROPERTY('InstanceName') AS instance_name,
    SERVERPROPERTY('ProductVersion') AS product_version,
    SERVERPROPERTY('ProductLevel') AS product_level,
    SERVERPROPERTY('Edition') AS edition,
    SERVERPROPERTY('EngineEdition') AS engine_edition,
    osi.sqlserver_start_time,
    DATEDIFF(MINUTE, osi.sqlserver_start_time, SYSDATETIME()) AS uptime_minutes
FROM sys.dm_os_sys_info AS osi;

-- 2. Important instance configuration
SELECT
    name,
    value AS configured_value,
    value_in_use,
    is_dynamic,
    is_advanced
FROM sys.configurations
WHERE name IN
(
    'max server memory (MB)',
    'min server memory (MB)',
    'max degree of parallelism',
    'cost threshold for parallelism',
    'max worker threads',
    'backup compression default',
    'optimize for ad hoc workloads',
    'remote admin connections',
    'blocked process threshold (s)',
    'default trace enabled'
)
ORDER BY name;

-- 3. SQL process memory
SELECT
    physical_memory_in_use_kb / 1024 AS sql_process_memory_mb,
    locked_page_allocations_kb / 1024 AS locked_pages_mb,
    memory_utilization_percentage,
    page_fault_count,
    process_physical_memory_low,
    process_virtual_memory_low
FROM sys.dm_os_process_memory;

-- 4. Host memory
SELECT
    total_physical_memory_kb / 1024 AS host_total_memory_mb,
    available_physical_memory_kb / 1024 AS host_available_memory_mb,
    system_memory_state_desc
FROM sys.dm_os_sys_memory;

-- 5. Scheduler pressure snapshot
SELECT
    scheduler_id,
    status,
    current_tasks_count,
    runnable_tasks_count,
    current_workers_count,
    active_workers_count,
    work_queue_count,
    load_factor
FROM sys.dm_os_schedulers
WHERE status = N'VISIBLE ONLINE'
ORDER BY scheduler_id;

-- 6. Worker thread summary
SELECT
    max_workers_count,
    (SELECT COUNT(*) FROM sys.dm_os_workers) AS worker_count,
    (SELECT COUNT(*) FROM sys.dm_os_workers WHERE state = N'RUNNING') AS running_workers,
    (SELECT COUNT(*) FROM sys.dm_os_workers WHERE state = N'RUNNABLE') AS runnable_workers
FROM sys.dm_os_sys_info;

-- 7. Database states and log reuse waits
SELECT
    name AS database_name,
    state_desc,
    user_access_desc,
    recovery_model_desc,
    log_reuse_wait_desc,
    compatibility_level,
    is_read_only,
    is_auto_close_on,
    is_auto_shrink_on
FROM sys.databases
ORDER BY name;

-- 8. File-level I/O counters (cumulative since startup / reset)
SELECT
    DB_NAME(vfs.database_id) AS database_name,
    mf.name AS logical_file_name,
    mf.type_desc,
    mf.physical_name,
    vfs.num_of_reads,
    vfs.io_stall_read_ms,
    CASE WHEN vfs.num_of_reads = 0 THEN NULL
         ELSE vfs.io_stall_read_ms * 1.0 / vfs.num_of_reads END AS avg_read_latency_ms,
    vfs.num_of_writes,
    vfs.io_stall_write_ms,
    CASE WHEN vfs.num_of_writes = 0 THEN NULL
         ELSE vfs.io_stall_write_ms * 1.0 / vfs.num_of_writes END AS avg_write_latency_ms,
    vfs.size_on_disk_bytes / 1048576.0 AS size_on_disk_mb
FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS vfs
JOIN sys.master_files AS mf
  ON mf.database_id = vfs.database_id
 AND mf.file_id = vfs.file_id
ORDER BY (vfs.io_stall_read_ms + vfs.io_stall_write_ms) DESC;

-- 9. Current wait statistics (cumulative; compare captures)
SELECT TOP (30)
    wait_type,
    waiting_tasks_count,
    wait_time_ms / 1000.0 AS wait_seconds,
    signal_wait_time_ms / 1000.0 AS signal_wait_seconds
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
