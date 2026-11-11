# 05 – Always On Availability Groups

Scripts: `sql/01_AG_Replica_Overview.sql` reports AG replica role, mode, connection and health; `sql/02_AG_Database_Queue_Status.sql` reports per-database synchronization, log-send and redo queues. Run in master on every replica when possible. On a non-AG instance the scripts return an explanatory message or no rows.

Interpretation: synchronous-commit databases are normally expected to reach SYNCHRONIZED; asynchronous replicas may remain SYNCHRONIZING. A growing log-send queue can indicate transport or secondary log-hardening pressure; a growing redo queue can indicate secondary redo pressure. Queue sizes are snapshots in KB, not rates—capture repeatedly. Role, connection, synchronization and cluster/quorum health must be considered together; one query does not prove failover readiness.

SQL Server 2016 SP1+. Typically requires VIEW SERVER STATE (SQL Server 2022+: review VIEW SERVER PERFORMANCE STATE). Read-only; no failover or AG configuration changes.
