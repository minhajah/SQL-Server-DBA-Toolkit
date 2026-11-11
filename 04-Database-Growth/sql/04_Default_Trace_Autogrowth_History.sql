/* 04 Database Growth | Default trace growth history | Run in master | Read-only */
SET NOCOUNT ON;
DECLARE @TraceFile nvarchar(260);
SELECT TOP(1) @TraceFile=path FROM sys.traces WHERE is_default=1;
IF @TraceFile IS NULL
BEGIN PRINT 'Default trace is disabled or unavailable; no retained growth history can be read.'; RETURN; END;
SELECT DatabaseName AS database_name,FileName AS logical_file_name,
       CASE EventClass WHEN 92 THEN 'DATA FILE AUTO GROW' WHEN 93 THEN 'LOG FILE AUTO GROW'
                       WHEN 94 THEN 'DATA FILE AUTO SHRINK' WHEN 95 THEN 'LOG FILE AUTO SHRINK' END AS event_name,
       StartTime AS event_time,IntegerData AS growth_amount_pages,
       CAST(IntegerData*8.0/1024 AS decimal(18,2)) AS growth_amount_mb,
       HostName AS host_name,ApplicationName AS application_name,LoginName AS login_name
FROM sys.fn_trace_gettable(@TraceFile,DEFAULT) WHERE EventClass IN(92,93,94,95) ORDER BY StartTime DESC;
