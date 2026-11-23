# 15 – Database Integrity Analysis

## Purpose
Use **SSMS** to review database integrity indicators, suspect-page history, and backup context, then plan an approved `DBCC CHECKDB` validation. All four packaged SQL scripts are **read-only**; none runs CHECKDB or repairs a database.

## Scripts

| File | Purpose | Run from |
|---|---|---|
| `sql/01_Database_Integrity_Overview.sql` | Database states and `PAGE_VERIFY` configuration | `master` |
| `sql/02_Suspect_Pages_History.sql` | Recorded suspect-page events from `msdb` | `master` |
| `sql/03_Integrity_Backup_Context.sql` | Latest full backup metadata as recovery context | `master` |
| `sql/04_CHECKDB_Command_Preview.sql` | Generate (but do not execute) CHECKDB command text | `master` |

## SSMS investigation procedure

1. **Record the incident.** Note instance, affected database, SQL Server version, exact incident time, error messages (for example 823, 824, 825,  suspect database, or CHECKDB failures), and application impact.
2. **Run `01_Database_Integrity_Overview.sql`.** Look for unexpected database states and `PAGE_VERIFY` settings. `CHECKSUM` is recommended for page verification, but its presence is not proof of integrity.
3. **Run `02_Suspect_Pages_History.sql`.** Review `msdb.dbo.suspect_pages` for affected databases, file/page IDs, event type, and last update. Correlate with SQL Server error logs, Windows System logs, and storage alerts. **No rows does not mean no corruption.** The table has limited retention and is not a complete corruption audit.
4. **Run `03_Integrity_Backup_Context.sql`.** Check backup metadata and whether the last recorded full backup reported damage or used backup checksums. Confirm actual coverage in PPDM/Commvault or other backup tools; `msdb` may not reflect external backup history. Backup checksums are **not** a substitute for CHECKDB or restore testing.
5. **Run `04_CHECKDB_Command_Preview.sql`.** Review generated commands for online user databases. This script **only displays text**; it does not execute CHECKDB.
6. **Schedule CHECKDB separately.** Obtain change approval and verify sufficient CPU, I/O, TempDB, and snapshot/storage capacity. Prefer your organization's established integrity-check maintenance process. Consider the Always On AG replica and workload, but do not assume a CHECKDB on one replica proves another replica's physical storage is healthy.
7. **If corruption is suspected or confirmed, preserve evidence.** Capture exact errors, affected object/page IDs, backup/restore options, and infrastructure findings. Escalate through incident response. **Do not run `REPAIR_ALLOW_DATA_LOSS`, detach/attach, or delete files as a first response.** A tested restore from a known-good backup is generally preferable to repair.
8. **Document the outcome.** Record what was checked, what remains unverified, CHECKDB results (if separately run), backup restore-test evidence, owner, and follow-up actions.

## Running CHECKDB manually (separate approved operation)

After approval and capacity review, a DBA may execute a targeted command in SSMS:

```sql
-- MANUAL OPERATION: resource intensive; do not run during peak hours without approval.
DBCC CHECKDB (N'YourDatabaseName') WITH NO_INFOMSGS, ALL_ERRORMSGS;
```

A clean CHECKDB result is evidence for the database at the time of execution. CHECKDB can be resource-intensive, may require substantial TempDB and internal database-snapshot space, and should be scheduled appropriately. `PHYSICAL_ONLY` can reduce work but does **not** replace periodic full CHECKDB validation.

### How to find last successful CHECKDB

There is **no universally reliable, documented, persistent catalog history** of every successful CHECKDB execution. Review SQL Agent/Ola Hallengren job history and `CommandLog` if your organization uses them, centralized monitoring, or retained SQL Server error logs. Do not claim the last successful CHECKDB date from a missing or undocumented metadata field.

## Interpretation

| Finding | Interpretation / next step |
|---|---|
| Database not `ONLINE` | Investigate database state and SQL error log immediately |
| `PAGE_VERIFY` not `CHECKSUM` | Review configuration under change control; not proof of corruption |
| Suspect-page event 1, 2, or 3 | Investigate I/O and corruption evidence urgently |
| Suspect-page event 4, 5, or 7 | Indicates recorded restore/repair/deallocation event; validate recovery and context |
| `is_damaged = 1` on backup metadata | Investigate backup operation, source database, and restore viability |
| No suspect pages or clean backup metadata | **Not sufficient** to certify database integrity |
| CHECKDB reports consistency errors | Preserve full output, assess restore options, engage storage/application owners |

## Permissions and compatibility

- SQL Server 2016+ intended; validate in UAT for your exact version and edition.
- Catalog visibility and access to `msdb.dbo.suspect_pages` and backup history depend on the account's permissions. Obtain approved access rather than automatically elevating rights.
- `DBCC CHECKDB` execution (shown only as an example) requires appropriate permissions, typically `db_owner` or `sysadmin`, and can consume significant resources.
- Do not commit production logs, database names, paths, or incident evidence to a public repository.

## Related modules

- `04-Database-Growth` – file capacity and autogrowth
- `05-AlwaysOn-AG` – AG replica and synchronization health
- `06-Backup-Restore` – backup and restore history
- `10-Storage-IO-Analysis` – storage I/O symptoms
- `12-Maintenance-Analysis` – maintenance jobs and scheduling

**Scope note:** This module inventories evidence and provides a safe CHECKDB planning workflow. It does not claim to detect all corruption or verify successful recovery without separately executed integrity checks and restore tests.
