# SQL Server DBA Toolkit

A practical collection of reusable SQL Server DBA scripts, PowerShell utilities, troubleshooting guides, and incident-report templates.

The toolkit is organized into 12 modules covering routine health checks, performance investigations, blocking and deadlocks, database growth, Always On availability, backup and restore, SQL Agent, index analysis, TempDB, storage I/O, security, and maintenance.

> **Safety:** Scripts are intended primarily for read-only diagnostics. Review each script and test it in a non-production environment before production use. Never commit production outputs, credentials, query text, hostnames, or other sensitive information to this repository.

## Toolkit scope

| Module | Area | Purpose |
|---|---|---|
| 01 | Server Health Check | Instance configuration, memory, scheduler, database state, I/O, and wait-stat snapshots |
| 02 | Performance Analysis | Active requests, expensive cached queries, waits, and missing-index suggestions |
| 03 | Blocking & Deadlocks | Blocking chains, open transactions, locks, and available deadlock evidence |
| 04 | Database Growth | File sizes, free space, autogrowth, largest tables, and growth history |
| 05 | Always On AG | Replica roles, availability, synchronization, send and redo queues |
| 06 | Backup & Restore | Backup coverage, recent backup history, and restore history |
| 07 | SQL Agent Jobs | Job inventory, recent failures, and duration history |
| 08 | Index Analysis | Index definitions, usage, missing-index requests, and physical statistics |
| 09 | TempDB Analysis | TempDB files, space consumption, session/task allocations, and active requests |
| 10 | Storage & I/O Analysis | File-level I/O latency, read/write activity, and volume free space |
| 11 | Security Audit | Principals, role membership, permissions, database users, and audit configuration |
| 12 | Maintenance Analysis | Maintenance jobs, statistics metadata, index condition, and database maintenance indicators |

## Repository structure

```text
SQL-Server-DBA-Toolkit/
├── README.md
├── .gitignore
├── 01-Server-Health-Check/
├── 02-Performance-Analysis/
├── 03-Blocking-Deadlocks/
├── 04-Database-Growth/
├── 05-AlwaysOn-AG/
├── 06-Backup-Restore/
├── 07-SQL-Agent-Jobs/
├── 08-Index-Analysis/
├── 09-TempDB-Analysis/
├── 10-Storage-IO-Analysis/
├── 11-Security-Audit/
├── 12-Maintenance-Analysis/
├── powershell/
│   └── Invoke-DBAToolkit.ps1
├── reports/
│   └── templates/
└── docs/
```

Each numbered module contains its own README and SQL scripts. Supporting PowerShell utilities, report templates, and operational documentation are maintained separately.

## Modules

### Phase 1 – Core diagnostics

**01 – Server Health Check**
- Instance identity, SQL Server version, and uptime
- Server configuration and memory indicators
- Scheduler and worker information
- Database state and log reuse wait
- File I/O and wait-stat snapshots

**02 – Performance Analysis**
- Active request analysis
- Cached queries ranked by CPU and logical reads
- Wait-stat review
- Missing-index DMV suggestions
- Query Store availability checks

**03 – Blocking & Deadlocks**
- Blocked requests and blocker details
- Sessions with open transactions
- Active transaction age and lock summary
- Deadlock reports available from the `system_health` Extended Events session

`system_health` is a finite diagnostic source. For durable deadlock history, use an approved Extended Events event-file session.

### Phase 2 – Database operations and availability

**04 – Database Growth**
- Database file inventory and configured growth
- Current data and log space usage
- Largest tables
- Available default-trace autogrowth history

**05 – Always On Availability Groups**
- Availability Group and replica overview
- Replica role and connection state
- Database synchronization health
- Log send and redo queue indicators

**06 – Backup & Restore**
- Latest full, differential, and transaction-log backup indicators
- Recent backup history and throughput
- Recent restore history

`msdb` history may be purged. Compare SQL Server metadata with the enterprise backup platform (for example, Commvault or PPDM) where applicable. A backup record does not prove that a restore will succeed.

**07 – SQL Agent Jobs**
- Job inventory and enabled state
- Last execution status
- Recent failed job steps
- Job duration history

### Phase 3 – Deeper diagnostics and governance

**08 – Index Analysis**
- Index keys, included columns, and definitions
- Index usage and operational counters
- Missing-index DMV requests
- Index physical statistics

**09 – TempDB Analysis**
- TempDB file configuration and volume information
- TempDB space usage
- Session and task allocation usage
- Active requests with TempDB allocation context

**10 – Storage & I/O Analysis**
- Database file read/write activity
- Average read and write stall indicators
- Volume capacity and free space
- Database-level I/O summaries

**11 – Security Audit**
- Server principals and server role membership
- Explicit server-level permissions
- Database users and role membership
- Explicit database permissions
- SQL Server Audit configuration

**12 – Maintenance Analysis**
- Maintenance-related SQL Agent job inventory
- Statistics metadata and modification counters
- Index physical-statistics review candidates
- Database recovery, state, and maintenance-related settings

## Getting started

### 1. Clone or download the repository

```bash
git clone https://github.com/minhajah/SQL-Server-DBA-Toolkit.git
```

Alternatively, download the repository ZIP from GitHub and extract it locally.

### 2. Read the module instructions

Open the `README.md` inside the module you intend to use. Check its prerequisites, target database, permissions, and interpretation notes before running SQL.

### 3. Execute the SQL scripts

1. Open SQL Server Management Studio (SSMS).
2. Connect to the intended SQL Server instance.
3. Select the database specified in the module instructions.
4. Review the script and its permissions requirements.
5. Execute during an appropriate diagnostic window.
6. Save results in an approved incident or evidence location.

### 4. Record collection context

For meaningful comparisons, record the SQL Server instance and version, database, collection date/time, SQL Server uptime, incident/change reference, and relevant workload symptoms.

Repeated snapshots are especially useful for wait statistics, I/O counters, TempDB allocations, and index usage.

## PowerShell collector

The repository includes `powershell/Invoke-DBAToolkit.ps1`.

The collector uses `sqlcmd` and Windows integrated authentication to execute supported modules and organize output by incident ID and timestamp.

Example:

```powershell
.\Invoke-DBAToolkit.ps1 `
    -ServerInstance "SQLSERVER01" `
    -IncidentId "INC001234" `
    -Module Health
```

Check the current script help and supported module values before use:

```powershell
Get-Help .\Invoke-DBAToolkit.ps1 -Full
```

Requirements and notes:
- PowerShell 5.1 or later.
- `sqlcmd` must be available on `PATH`, or use the script's supported path parameter.
- Windows integrated authentication is used; no password is stored in the script.
- Confirm the module names supported by the current collector version.
- Protect generated output because it may contain sensitive server, login, database, and query information.
- Do not commit production output to Git.

## Permissions and compatibility

Permissions vary by script and SQL Server version. Common requirements include:
- `VIEW SERVER STATE` for many server-level diagnostic DMVs.
- `VIEW DATABASE STATE` for database-level diagnostic DMVs.
- On SQL Server 2022 and later, some performance DMV access requires `VIEW SERVER PERFORMANCE STATE` or `VIEW DATABASE PERFORMANCE STATE`, as applicable.
- Appropriate metadata visibility for security and SQL Agent inventory scripts.

The toolkit targets commonly deployed SQL Server versions, but not every DMV, column, permission, or feature is available on every release and edition.

**Validate scripts against the exact SQL Server version and edition in a test environment before production execution.** Check each module README for script-specific requirements.

## Production safety guidelines

1. Run scripts only on instances and databases where you are authorized.
2. Review the SQL before execution, even when described as read-only.
3. Test in development or UAT before production.
4. Use an approved diagnostic account with minimum required permissions.
5. Avoid expensive diagnostics during peak workload periods.
6. Do not interpret cumulative counters as current rates without comparing snapshots over a known interval.
7. Treat missing-index recommendations as investigation leads, not automatic index-creation instructions.
8. Do not rebuild or reorganize indexes solely because of a fragmentation percentage.
9. Do not resize TempDB or database files based on one snapshot.
10. Do not kill sessions, clear caches, reset wait statistics, or change configuration as part of these diagnostic scripts.
11. Protect output files and sanitize sensitive details before sharing.
12. Follow change control and obtain application/vendor approval before corrective actions.

See `docs/Production-Safety-Checklist.md` for the detailed checklist.

## Reports and documentation

The `reports/templates/` folder contains templates for documenting diagnostic findings, evidence, impact, analysis, and follow-up actions.

The `docs/` folder contains supporting guidance, including the production safety checklist, repository roadmap, and Phase 3 execution guide.

Keep findings separate from assumptions. Include collection time and relevant limitations in every incident report.

## Roadmap

Modules 01 through 12 are grouped into the first three toolkit phases. Potential future enhancements include:
- Query Store deep-dive and plan regression analysis
- Extended Events session templates and analysis
- DBCC CHECKDB history and integrity-check reporting
- Log shipping and disaster recovery checks
- Replication diagnostics
- SQL Server configuration and compliance baselines
- PowerShell collection improvements and consolidated HTML/CSV reporting

Future modules will be added after scripts, documentation, compatibility, and safety requirements are reviewed.

## Disclaimer

This repository is a DBA productivity and troubleshooting resource. It does not replace Microsoft documentation, vendor guidance, tested operational procedures, backup/restore validation, or your organization's change-management process.

The scripts are provided as a starting point. Validate their behavior and output in your own environment before relying on them for operational decisions.
