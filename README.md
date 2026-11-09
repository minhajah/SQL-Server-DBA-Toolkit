# SQL Server DBA Toolkit

A reusable SQL Server DBA repository for investigation, analysis, reporting and operational checks.

## Scope and status

**Phase 1 is implemented:** server health, performance triage, and blocking/deadlock investigation.

**Later phases are scaffolded:** database growth, Always On, backup/restore, SQL Agent, indexes, TempDB, storage I/O, security and maintenance.

| Module | Status | Main purpose |
|---|---|---|
| 01 Server Health Check | Phase 1 | Instance configuration, memory, schedulers, databases and file I/O |
| 02 Performance Analysis | Phase 1 | Active requests, cached expensive queries, waits and missing-index leads |
| 03 Blocking & Deadlocks | Phase 1 | Blocking chains, head blockers, open transactions and system_health deadlock evidence |
| 04 Database Growth | Planned | Database, file and table growth |
| 05 Always On AG | Planned | Replica health, queues and failover readiness |
| 06 Backup & Restore | Planned | Backup coverage, gaps and restore verification |
| 07 SQL Agent Jobs | Planned | Job failures, durations and history |
| 08 Index Analysis | Planned | Index usage, fragmentation and index candidates |
| 09 TempDB Analysis | Planned | Space, version store and contention |
| 10 Storage I/O Analysis | Planned | File latency and storage trends |
| 11 Security Audit | Planned | Logins, permissions and security posture |
| 12 Maintenance Analysis | Planned | Integrity checks, statistics and maintenance coverage |

## Quick start

### Requirements
- SQL Server 2016 SP1 or later is the target baseline for Phase 1 scripts.
- SSMS or `sqlcmd` for manual execution.
- PowerShell 5.1+ and the Microsoft `sqlcmd` utility for the collection wrapper.
- Diagnostic permissions: typically `VIEW SERVER STATE`; SQL Server 2022+ may require `VIEW SERVER PERFORMANCE STATE` for some DMVs. `VIEW ANY DEFINITION` may be needed to see all query text and object definitions.
- Run under an approved DBA account. Do not grant permissions solely to run these scripts without security review.

### Run manually
1. Read the module README and safety notes.
2. Connect to the intended SQL instance in SSMS.
3. Execute one script at a time, preferably during the symptom.
4. Save all result sets with incident ID, server, database, and timestamp.
5. Compare repeated captures rather than interpreting cumulative counters from a single snapshot.

### Run the PowerShell collector
Open PowerShell in the repository root:

```powershell
.\powershell\Invoke-DBAToolkit.ps1 `
  -ServerInstance "SQLSERVER\INSTANCE" `
  -IncidentId "INC-2026-00123"
```

For a default instance, `-ServerInstance "SQLSERVER"` is sufficient. The collector uses Windows integrated authentication (`sqlcmd -E`) and writes text outputs under `output\<IncidentId>_<timestamp>`. It does not store passwords.

To capture a second snapshot during the same incident, run the command again using the same incident ID. Each run gets its own timestamped folder.

## Safety model

- Phase 1 SQL scripts are designed as read-only diagnostics. They do not kill sessions, clear wait statistics, change server/database configuration, rebuild indexes, update statistics or restart services.
- Some queries inspect cached SQL text and may expose sensitive literals, hostnames, logins, database names or business data. Restrict output access and sanitize before sharing.
- Wait statistics and file I/O counters are cumulative since SQL Server startup or a counter reset. Compare deltas between captures.
- Query Store may be disabled or unavailable. The performance script checks availability and reports a note rather than enabling it.
- Missing-index DMVs are suggestions, not instructions to create indexes.
- The deadlock query reads retained `system_health` ring-buffer data only. For durable deadlock history, deploy a separately reviewed Extended Events event-file session and retention policy.
- The PowerShell wrapper calls `sqlcmd` separately for each script. It does not change SQL Server state.

## Output and reporting

Use `reports/templates/Incident-Analysis-Report.md` to document symptoms, evidence, interpretation, actions and root cause. Keep raw output in a restricted incident evidence location; do not commit production output to Git.

## Compatibility notes

The repository targets SQL Server 2016 SP1+. Optional features vary by version and configuration. Test in a non-production environment before production use. Review each script's header for permissions, scope and caveats.

## Contribution convention

Every module should contain:
- `README.md` — purpose, execution, permissions, output and interpretation
- `sql/` — numbered, commented SQL scripts
- `powershell/` — optional automation
- `docs/` — operational runbook and interpretation guide
- `reports/` — templates or sanitized sample reports

Name scripts `NN_Descriptive_Name.sql`. Mark every script clearly as read-only or state-changing.
