/*
MODULE 03 - RECENT DEADLOCKS FROM system_health RING BUFFER
Read-only | SQL Server 2016 SP1+
This reads only events still present in the in-memory ring buffer.
The ring buffer is finite and events can be overwritten. Not a durable archive.
For durable history, configure a reviewed Extended Events event-file session.
*/

SET NOCOUNT ON;
SET DEADLOCK_PRIORITY LOW;
SET LOCK_TIMEOUT 5000;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.dm_xe_sessions
    WHERE name = N'system_health'
)
BEGIN
    SELECT N'system_health session is not currently running on this instance.' AS diagnostic_message;
    RETURN;
END;

;WITH TargetData AS
(
    SELECT TRY_CONVERT(xml, t.target_data) AS target_xml
    FROM sys.dm_xe_sessions AS s
    JOIN sys.dm_xe_session_targets AS t
      ON t.event_session_address = s.address
    WHERE s.name = N'system_health'
      AND t.target_name = N'ring_buffer'
),
Deadlocks AS
(
    SELECT
        n.value('@timestamp', 'datetime2(3)') AS event_time_utc,
        n.query('(data/value/deadlock)[1]') AS deadlock_xml
    FROM TargetData
    CROSS APPLY target_xml.nodes('/RingBufferTarget/event[@name="xml_deadlock_report"]') AS q(n)
)
SELECT
    event_time_utc,
    deadlock_xml
FROM Deadlocks
ORDER BY event_time_utc DESC;
