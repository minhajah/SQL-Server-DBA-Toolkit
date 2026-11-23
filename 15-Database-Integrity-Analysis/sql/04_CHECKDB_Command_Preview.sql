/* Module 15: Generate DBCC CHECKDB commands as text. NO CHECKDB EXECUTION. */
SET NOCOUNT ON;
SELECT d.name AS database_name,
       'DBCC CHECKDB (' + QUOTENAME(d.name, CHAR(39)) + ') WITH NO_INFOMSGS, ALL_ERRORMSGS;' AS suggested_command,
       'Manual execution only, after sizing impact and scheduling approved window' AS caution
FROM sys.databases AS d
WHERE d.database_id > 4 AND d.state_desc = 'ONLINE'
ORDER BY d.name;
/* Do not run all generated commands together without assessing CPU, I/O, tempdb,
   snapshot space, AG replica role, and vendor/maintenance policy. */
