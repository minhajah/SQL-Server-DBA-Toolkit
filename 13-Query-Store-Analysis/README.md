# 13 – Query Store Analysis

## Purpose
Investigate historical query performance, expensive plans, regressions and query-level waits using SSMS. All four SQL scripts are read-only. Run in the **affected user database**.

## Files
| Script | Purpose |
|---|---|
| `01_Query_Store_Status.sql` | Check Query Store operating state, storage and settings |
| `02_Top_Resource_Queries.sql` | Rank CPU, duration, and logical reads for a specified UTC interval |
| `03_Query_Plan_Regression.sql` | Compare multiple plans for a query over a specified UTC interval |
| `04_Query_Wait_Analysis.sql` | Aggregate Query Store waits by query, plan and wait category (SQL Server 2017+) |

## SSMS procedure
1. Connect to the intended instance, open a new query window, and select the affected database. **Do not run in `master`** unless it is specifically the database being investigated.
2. Run `01_Query_Store_Status.sql`. Check `actual_state_desc`, `desired_state_desc`, storage and `readonly_reason`. Normal capture requires `READ_WRITE`. `READ_ONLY`, `OFF`, or `ERROR` needs investigation; do not automatically enable or modify Query Store.
3. Record the incident's **UTC** start and end. Set `@StartUtc` and `@EndUtc` in scripts 02–04. Query Store interval timestamps are UTC. Pick a representative window and compare with an equivalent healthy window.
4. Run `02_Top_Resource_Queries.sql`. Check **total** versus **per-execution** CPU/duration/reads and execution counts. High total CPU can reflect frequency; high average duration with modest CPU may indicate waits.
5. Note a `query_id` of interest and set `@QueryId` in script 03. Compare plan IDs and their per-execution metrics. Multiple plans alone do not prove regression. Open SSMS Object Explorer → Databases → *database* → Query Store → Regressed Queries or Top Resource Consuming Queries to inspect graphical plans.
6. Run `04_Query_Wait_Analysis.sql` if Query Store wait stats are supported and enabled. Wait categories indicate investigation directions, not definitive causes. Correlate with current requests, blocking, storage and application symptoms.
7. Record query ID, plan ID, incident window, evidence, suspected cause, approved remediation, and post-change measurements. Compare equivalent workloads before declaring improvement.

## Query Store configuration checks
- SQL Server 2016+ supports Query Store; Query Store wait statistics require SQL Server 2017+.
- Query Store may not be enabled or may not have retained the incident window. It does not provide historical data from before it was enabled.
- Query Store is per database. SQL Server 2022 typically enables it by default for new databases, but confirm actual state.
- Read access generally requires `VIEW DATABASE STATE` on SQL Server 2016–2019 or `VIEW DATABASE PERFORMANCE STATE` on SQL Server 2022+; permissions can differ by operation/version.
- Do not enable Query Store, change capture settings, force plans, or clear data without change approval. These scripts make no changes.

## Interpretation
| Finding | What to verify |
|---|---|
| High total CPU | Execution frequency, per-execution CPU, workload change |
| High duration but modest CPU | Lock, I/O or other waits; correlate with wait data |
| Plan metrics changed | Plans, cardinality estimates, statistics, data volume, parameter sensitivity |
| High logical reads | Access paths, predicates, joins, row counts, existing indexes |
| Query Store read-only | Storage quota, database state, `readonly_reason` bitmask |
| No results | Capture mode, retention, interval, permissions and Query Store state |

## Caveats
- Runtime and wait metrics are aggregated. The scripts use completed runtime intervals only to avoid double-counting active-interval rows; the current interval is intentionally excluded. A result may lag the live incident.
- `avg_cpu_time`, `avg_duration` and `avg_logical_io_reads` are reported in Query Store units (CPU/duration microseconds; reads in 8-KB pages). CPU/duration scripts convert to milliseconds.
- A query may have multiple plan IDs. All scripts are for triage, not proof of root cause.
- Query text and plans can contain confidential information. Do not commit production output to a public repository.
- Some reports/columns differ by SQL Server version and edition. Validate scripts on your versions in UAT before production use.

## Example incident
A report previously finished in 5 seconds but now takes 45 seconds. Check Query Store status, select the affected UTC interval, rank duration in script 02, compare plan IDs in script 03, inspect plans in SSMS, correlate waits with script 04, then test an approved correction and compare against an equivalent baseline.

## Related modules
`02-Performance-Analysis`, `03-Blocking-Deadlocks`, `08-Index-Analysis`, `10-Storage-IO-Analysis`, `12-Maintenance-Analysis`.
