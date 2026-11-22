/* 14 - Deadlock reports from the existing system_health event-file target.
   Read-only. Requires an accessible system_health event-file target. Run in master.
   XE timestamps are UTC. This query reads retained rollover files only.
*/
SET NOCOUNT ON;
DECLARE @file nvarchar(4000);
DECLARE @pattern nvarchar(4000);

SELECT TOP (1) @file = TRY_CAST(t.target_data AS xml)
    .value('(EventFileTarget/File/@name)[1]', 'nvarchar(4000)')
FROM sys.dm_xe_sessions AS s
JOIN sys.dm_xe_session_targets AS t ON t.event_session_address = s.address
WHERE s.name = N'system_health' AND t.target_name = N'event_file';

IF @file IS NULL OR LEN(@file) = 0
BEGIN
    RAISERROR('No running system_health event-file target found. Check XE target status and permissions.', 10, 1);
END
ELSE
BEGIN
    -- Use a filename prefix wildcard to include the current and rollover .xel files.
    SET @pattern = LEFT(@file, LEN(@file) - CHARINDEX(N'\', REVERSE(@file)) + 1)
                 + N'system_health*.xel';
    -- The system_health filename may be customized. Prefer matching its actual base name.
    IF CHARINDEX(N'system_health', LOWER(@file)) = 0
        SET @pattern = @file;

    SELECT TOP (100)
        x.event_xml.value('(/event/@timestamp)[1]', 'datetime2(3)') AS event_time_utc,
        x.event_xml.query('(/event/data[@name="xml_report"]/value/deadlock)[1]') AS deadlock_xml,
        f.file_name,
        f.file_offset
    FROM sys.fn_xe_file_target_read_file(@pattern, NULL, NULL, NULL) AS f
    CROSS APPLY (SELECT TRY_CAST(f.event_data AS xml) AS event_xml) AS x
    WHERE x.event_xml.value('(/event/@name)[1]', 'sysname') = N'xml_deadlock_report'
    ORDER BY event_time_utc DESC;
END;
