/* Read-only SQL Server Agent log search. Run in master.
   @LogNumber 0=current Agent log, 1=previous. Agent service may be unavailable. */
USE master;
GO
SET NOCOUNT ON;
DECLARE @LogNumber int = 0;
DECLARE @SearchText1 nvarchar(4000) = N'failed';
DECLARE @SearchText2 nvarchar(4000) = NULL;
DECLARE @StartTime datetime = DATEADD(DAY,-2,GETDATE());
DECLARE @EndTime datetime = GETDATE();
EXEC sys.xp_readerrorlog @LogNumber, 2, @SearchText1, @SearchText2,
                         @StartTime, @EndTime, N'desc';
