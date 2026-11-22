/* Read-only. SQL Server 2017+ only; requires Query Store wait capture. */
SET NOCOUNT ON;
DECLARE @StartUtc datetimeoffset = '2026-11-17T00:00:00+00:00';
DECLARE @EndUtc datetimeoffset   = '2026-11-18T00:00:00+00:00';
SELECT TOP (50) p.query_id,ws.plan_id,ws.wait_category_desc,
       CAST(SUM(ws.total_query_wait_time_ms) AS decimal(20,2)) AS total_wait_ms,
       SUM(CONVERT(bigint,ws.count_executions)) AS wait_stat_executions
FROM sys.query_store_wait_stats ws
JOIN sys.query_store_plan p ON p.plan_id=ws.plan_id
JOIN sys.query_store_runtime_stats_interval rsi ON rsi.runtime_stats_interval_id=ws.runtime_stats_interval_id
WHERE rsi.start_time>=@StartUtc AND rsi.end_time<=@EndUtc
  AND rsi.end_time < SYSUTCDATETIME()
GROUP BY p.query_id,ws.plan_id,ws.wait_category_desc
ORDER BY total_wait_ms DESC;
