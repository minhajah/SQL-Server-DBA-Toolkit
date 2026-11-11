# 10 – Storage & I/O Analysis

Scripts: cumulative file I/O statistics, volume free space, and database-level I/O summary. Run from `master`. Capture baseline and incident snapshots and compare deltas over a known interval. DMV values are cumulative since startup or file lifecycle events; average latency is not necessarily current latency. Correlate with workload, OS/storage metrics, waits, and application symptoms before assigning root cause.
