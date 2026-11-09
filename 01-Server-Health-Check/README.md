# 01 - Server Health Check

## Purpose
Capture a point-in-time overview of the SQL Server instance: version, startup time, configuration, memory, scheduler pressure, database states and file-level I/O counters.

## Scripts
- `sql/01_Server_Health_Snapshot.sql`

## Execution
Run in SSMS against the target instance. The script is server-scoped and does not require changing the current database. Save every result set.

## Permissions
Typically `VIEW SERVER STATE`. SQL Server 2022+ may require `VIEW SERVER PERFORMANCE STATE` for specific DMV access. Server configuration visibility may require additional metadata permissions.

## Interpretation
- SQL memory usage alone is not evidence of memory pressure. Correlate process memory, host available memory, memory flags, max server memory and workload.
- Runnable queues and scheduler metrics are clues; compare during normal and incident periods.
- File I/O average latency is cumulative since startup. Use two snapshots to calculate interval deltas.
- Database states and `log_reuse_wait_desc` identify areas for further investigation, not automatic remediation.

## Safety
Read-only. Does not change configuration or clear counters.
