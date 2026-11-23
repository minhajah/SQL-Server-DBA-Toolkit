# 17 – SQL Server Error Log Analysis

## Purpose
Use **SSMS** to investigate SQL Server and SQL Server Agent error logs without changing server settings or recycling log files. Scripts are read-only and use SQL Server's built-in log-reading procedures.

## Scripts

| File | Purpose | Run from |
|---|---|---|
| `sql/01_Error_Log_Inventory.sql` | List available SQL Server error-log archives | `master` |
| `sql/02_SQL_Error_Log_Search.sql` | Search a chosen SQL Server error log by keyword and time | `master` |
| `sql/03_Recent_Critical_Error_Messages.sql` | Scan the current error log for selected incident markers | `master` |
| `sql/04_SQL_Agent_Error_Log_Search.sql` | Search SQL Server Agent logs | `master` |

## SSMS investigation procedure

1. Record the **instance, database, incident timestamp and time zone, application symptoms**, and exact error text or number.
2. Run `01_Error_Log_Inventory.sql` to identify the current and archived SQL Server logs. The incident may be in an older archive.
3. Open `02_SQL_Error_Log_Search.sql`. Set `@LogNumber`, `@SearchText1`, `@SearchText2`, `@StartTime`, and `@EndTime`. Execute and review surrounding entries. Search terms are case-insensitive or case-sensitive according to server collation and procedure behavior.
4. Run `03_Recent_Critical_Error_Messages.sql` as a quick scan. **It only checks the current log and selected text patterns**; a blank result does not mean the server is healthy. For an older incident, inspect archived logs individually.
5. For Agent-related incidents, run `04_SQL_Agent_Error_Log_Search.sql` and compare the output with job history from Module 07.
6. Correlate messages with Windows Event Viewer, AG status, database state, disk space, backup history, and application logs. Identify the earliest relevant failure rather than treating downstream errors as the root cause.
7. Record findings in your incident report. Escalate suspected corruption, disk failures, and service crashes using your organization's recovery procedure. Do not restart SQL Server or recycle error logs simply to troubleshoot.

## Common searches

Change `@SearchText1` in script 02 to values such as:

- `N'Error: 823'`, `N'Error: 824'`, `N'Error: 825'` — possible I/O or page issues
- `N'Error: 9002'` — transaction log full
- `N'Login failed'` — authentication failures
- `N'Always On'` or `N'availability'` — AG-related messages
- `N'backup'` or `N'restore'` — backup/restore activity
- `N'memory'` — memory-related messages

These are starting points, not exhaustive error signatures.

## How to interpret results

| Finding | Interpretation | Next step |
|---|---|---|
| Repeated 823/824/825 errors | Potential I/O or page-read problems | Check integrity, storage and error context; coordinate recovery |
| Error 9002 | Transaction log cannot reuse/grow space | Review log reuse wait, space, backups and active transactions |
| Login failures | Authentication or connection issue | Review state, principal, application and network context |
| AG connection/lease errors | Availability or cluster issue | Correlate with Modules 05 and 16 and Windows cluster logs |
| Agent job failure messages | Scheduled task or job problem | Correlate with Module 07 job-step history |

## Permissions and safety

- SQL Server 2019 and earlier commonly require `VIEW SERVER STATE` for error-log reading; SQL Server 2022+ may require `VIEW ANY ERROR LOG`. Confirm permissions on your version.
- Log contents may expose server names, usernames, file paths, query text, and other sensitive information. Do not commit outputs to GitHub.
- Error-log archives are finite and may be recycled; a missing entry does not prove an event never occurred.
- `xp_readerrorlog` and `sp_enumerrorlogs` are built-in procedures, but availability and supported argument behavior can vary by version. Test in UAT.
- The temporary table in script 03 is session-local; it does not alter permanent user data.

## Related toolkit modules

- `03-Blocking-Deadlocks` — blocking and deadlocks
- `05-AlwaysOn-AG` and `16-AG-Failover-Readiness` — AG health
- `06-Backup-Restore` — backup and restore evidence
- `07-SQL-Agent-Jobs` — job failures
- `10-Storage-IO-Analysis` — storage and I/O
- `15-Database-Integrity-Analysis` — corruption investigation
