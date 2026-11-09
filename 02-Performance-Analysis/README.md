# 02 - Performance Analysis

## Purpose
Identify currently expensive requests, high-cost cached statements, top cumulative waits and missing-index leads.

## Scripts
- `sql/01_Performance_Triage.sql`

## Execution
Run during the reported slowdown. Run again after a short interval if the problem continues. Save all result sets.

## Interpretation
- Active requests show what is running now; a query may finish before capture.
- Cached query statistics are cumulative since the plan entered cache and may reset after eviction/restart/recompile.
- Compare CPU, elapsed time, reads and execution count. High total cost and high average cost answer different questions.
- Wait statistics are cumulative. Compare deltas across snapshots.
- Missing-index DMVs are workload hints and can overlap or recommend oversized indexes. Review query plans, existing indexes, write overhead and storage before creating anything.
- Query Store output is conditional on Query Store already being enabled.

## Safety
Read-only. Does not force plans, clear cache, enable Query Store or create indexes.
