/* 14 - Generic reader for EXISTING XE event files. Read-only. Run in master.
   1) Replace @file_pattern with an approved .xel path/wildcard.
   2) Set optional event name and UTC time range.
   3) Keep wildcard narrow to avoid excessive I/O.
*/
SET NOCOUNT ON;
DECLARE @file_pattern nvarchar(4000) = N'C:\XE\YourSession*.xel'; -- CHANGE THIS
DECLARE @event_name sysname = NULL; -- e.g. N'blocked_process_report'
DECLARE @from_utc datetime2(3) = NULL; -- e.g. '2026-11-22T06:00:00'
DECLARE @to_utc datetime2(3) = NULL; -- e.g. '2026-11-22T07:00:00'

IF @file_pattern = N'C:\XE\YourSession*.xel'
BEGIN
    RAISERROR('Set @file_pattern to the actual existing .xel file path before executing.', 16, 1);
    RETURN;
END;

;WITH Events AS
(
    SELECT
        f.file_name,
        f.file_offset,
        TRY_CAST(f.event_data AS xml) AS event_xml
    FROM sys.fn_xe_file_target_read_file(@file_pattern, NULL, NULL, NULL) AS f
), Parsed AS
(
    SELECT
        file_name,
        file_offset,
        event_xml.value('(/event/@timestamp)[1]', 'datetime2(3)') AS event_time_utc,
        event_xml.value('(/event/@name)[1]', 'sysname') AS event_name,
        event_xml
    FROM Events
    WHERE event_xml IS NOT NULL
)
SELECT TOP (200)
    event_time_utc,
    event_name,
    file_name,
    file_offset,
    event_xml
FROM Parsed
WHERE (@event_name IS NULL OR event_name = @event_name)
  AND (@from_utc IS NULL OR event_time_utc >= @from_utc)
  AND (@to_utc IS NULL OR event_time_utc < @to_utc)
ORDER BY event_time_utc DESC;
