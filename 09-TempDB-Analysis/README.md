# 09 – TempDB Analysis

Scripts: file configuration, space usage, session allocation, and active request snapshots. Run during the incident and repeat at intervals. These are point-in-time measurements; allocations change rapidly. Internal objects include sorts, hashes, spools, and worktables. Version-store growth may relate to long-running transactions or row-versioning. Do not resize files or change file counts from one snapshot. Server DMV access is required.
