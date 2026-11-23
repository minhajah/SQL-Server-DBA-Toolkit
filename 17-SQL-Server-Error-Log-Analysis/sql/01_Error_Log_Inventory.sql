/* Read-only: available SQL Server error log archives. Run in master. */
USE master;
GO
SET NOCOUNT ON;
EXEC sys.sp_enumerrorlogs;
