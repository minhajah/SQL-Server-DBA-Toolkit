# 06 – Backup & Restore Monitoring

Scripts: `sql/01_Backup_Coverage_Status.sql` reports latest full/differential/log backup timestamps and configurable age flags; `sql/02_Backup_History_Recent.sql` reports recent duration, size, compression and destination; `sql/03_Restore_History_Recent.sql` reports recent restore operations recorded in msdb. Run in master. Adjust example thresholds in script 01 to match approved RPO and backup policy.

A backup history row does not prove restorable media. Schedule test restores and application validation. Log-backup age applies to FULL/BULK_LOGGED recovery; SIMPLE does not use log backups. msdb history can be purged or lost, so reconcile with the enterprise backup platform (e.g. Commvault/PPDM). Read-only; no backup, restore, cleanup or recovery-model changes.

SQL Server 2016 SP1+. Requires appropriate msdb visibility.
