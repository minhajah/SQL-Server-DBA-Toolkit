# Phase 3 Execution Guide

1. Index Analysis: inventory first; then review usage, missing-index suggestions, and physical stats.
2. TempDB: capture during the incident and repeat at intervals.
3. Storage & I/O: collect baseline and incident snapshots; compare deltas.
4. Security: use an approved audit account; protect output.
5. Maintenance: map SQL Agent and external tool ownership before proposing changes.

Record instance, database, version, uptime, capture time, and incident ID. Mask sensitive metadata before sharing. Test scripts on the exact SQL Server version/edition in UAT. This phase is diagnostic only and does not perform tuning or maintenance.
