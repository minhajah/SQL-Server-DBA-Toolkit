# 08 – Index Analysis

Scripts: `01_Index_Inventory.sql`, `02_Index_Usage.sql`, `03_Missing_Index_Requests.sql`, `04_Index_Physical_Stats.sql`. Run in the target database.

Usage counters reset after restart or certain database lifecycle events. Missing-index DMVs are estimates, memory-resident, and do not account for all workload/index interactions. Fragmentation alone is not a rebuild reason; consider page count, density, workload, and maintenance window. Validate existing indexes and execution plans before proposing changes. Typically requires database performance-state visibility.
