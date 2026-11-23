/* Read-only SQL Server error-log search. Change search parameters for your incident.
   @LogNumber: 0=current, 1=previous archive. Dates use server-local time.
   Requires permission to read error logs; availability varies by SQL Server version. */
USE master;
GO
SET NOCOUNT ON;
DECLARE @LogNumber int = 0;
DECLARE @SearchText1 nvarchar(4000) = N'Error:';
DECLARE @SearchText2 nvarchar(4000) = NULL;
DECLARE @StartTime datetime = DATEADD(HOUR,-24,GETDATE());
DECLARE @EndTime datetime = GETDATE();
EXEC sys.xp_readerrorlog @LogNumber, 1, @SearchText1, @SearchText2,
                         @StartTime, @EndTime, N'desc';
