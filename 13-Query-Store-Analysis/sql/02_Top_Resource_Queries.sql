/* Read-only. Set UTC interval. Completed Query Store intervals only. */
SET NOCOUNT ON;
DECLARE @StartUtc datetimeoffset = '2026-11-17T00:00:00+00:00';
DECLARE @EndUtc datetimeoffset   = '2026-11-18T00:00:00+00:00';
;WITH PlanStats AS (
 SELECT q.query_id, p.plan_id, qt.query_sql_text,
        SUM(CONVERT(bigint,rs.count_executions)) AS executions,
        SUM(CONVERT(float,rs.avg_cpu_time)*rs.count_executions) AS cpu_us,
        SUM(CONVERT(float,rs.avg_duration)*rs.count_executions) AS duration_us,
        SUM(CONVERT(float,rs.avg_logical_io_reads)*rs.count_executions) AS logical_reads
 FROM sys.query_store_query q
 JOIN sys.query_store_query_text qt ON qt.query_text_id=q.query_text_id
 JOIN sys.query_store_plan p ON p.query_id=q.query_id
 JOIN sys.query_store_runtime_stats rs ON rs.plan_id=p.plan_id
 JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id=rs.runtime_stats_interval_id
 WHERE rsi.start_time>=@StartUtc AND rsi.end_time<=@EndUtc
   AND rsi.end_time < SYSUTCDATETIME()
 GROUP BY q.query_id,p.plan_id,qt.query_sql_text
)
SELECT TOP (50) query_id,plan_id,executions,
 CAST(cpu_us/1000.0 AS decimal(20,2)) AS total_cpu_ms,
 CAST(cpu_us/NULLIF(executions,0)/1000.0 AS decimal(20,2)) AS avg_cpu_ms,
 CAST(duration_us/NULLIF(executions,0)/1000.0 AS decimal(20,2)) AS avg_duration_ms,
 CAST(logical_reads/NULLIF(executions,0) AS decimal(20,2)) AS avg_logical_reads_pages,
 LEFT(query_sql_text,4000) AS query_text
FROM PlanStats
ORDER BY total_cpu_ms DESC;
