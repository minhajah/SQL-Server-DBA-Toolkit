/* Read-only: scan current SQL Server error log for common incident markers.
   Keywords are broad indicators, NOT verified severity or complete error coverage.
   Time is server-local. Review context before making decisions. */
USE master;
GO
SET NOCOUNT ON;
CREATE TABLE #ErrorLog (LogDate datetime, ProcessInfo nvarchar(64), [Text] nvarchar(max));
INSERT INTO #ErrorLog EXEC sys.xp_readerrorlog 0, 1;
SELECT TOP (200) LogDate, ProcessInfo, [Text]
FROM #ErrorLog
WHERE LogDate >= DATEADD(DAY,-7,GETDATE())
  AND ([Text] LIKE N'%Error: 823%'
    OR [Text] LIKE N'%Error: 824%'
    OR [Text] LIKE N'%Error: 825%'
    OR [Text] LIKE N'%Error: 9002%'
    OR [Text] LIKE N'%Error: 352%'
    OR [Text] LIKE N'%severity: 20%'
    OR [Text] LIKE N'%severity: 21%'
    OR [Text] LIKE N'%severity: 22%'
    OR [Text] LIKE N'%severity: 23%'
    OR [Text] LIKE N'%severity: 24%'
    OR [Text] LIKE N'%severity: 25%')
ORDER BY LogDate DESC;
DROP TABLE #ErrorLog;
