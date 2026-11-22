/* Read-only. Set Query ID and UTC interval; compare plan metrics. */
SET NOCOUNT ON;
DECLARE @QueryId bigint = 0; -- Replace 0 with query_id from script 02
DECLARE @StartUtc datetimeoffset = '2026-11-17T00:00:00+00:00';
DECLARE @EndUtc datetimeoffset   = '2026-11-18T00:00:00+00:00';
SELECT p.query_id,p.plan_id,p.is_forced_plan,p.force_failure_count,
       p.last_force_failure_reason_desc,
       SUM(CONVERT(bigint,rs.count_executions)) AS executions,
       CAST(SUM(CONVERT(float,rs.avg_duration)*rs.count_executions)/NULLIF(SUM(CONVERT(bigint,rs.count_executions)),0)/1000.0 AS decimal(20,2)) AS avg_duration_ms,
       CAST(SUM(CONVERT(float,rs.avg_cpu_time)*rs.count_executions)/NULLIF(SUM(CONVERT(bigint,rs.count_executions)),0)/1000.0 AS decimal(20,2)) AS avg_cpu_ms,
       CAST(SUM(CONVERT(float,rs.avg_logical_io_reads)*rs.count_executions)/NULLIF(SUM(CONVERT(bigint,rs.count_executions)),0) AS decimal(20,2)) AS avg_logical_reads_pages
FROM sys.query_store_plan p
JOIN sys.query_store_runtime_stats rs ON rs.plan_id=p.plan_id
JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id=rs.runtime_stats_interval_id
WHERE p.query_id=@QueryId AND @QueryId>0
  AND rsi.start_time>=@StartUtc AND rsi.end_time<=@EndUtc
  AND rsi.end_time < SYSUTCDATETIME()
GROUP BY p.query_id,p.plan_id,p.is_forced_plan,p.force_failure_count,p.last_force_failure_reason_desc
ORDER BY avg_duration_ms DESC;
