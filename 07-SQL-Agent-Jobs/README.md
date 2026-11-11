# 07 – SQL Server Agent Jobs

Scripts: `sql/01_Job_Inventory_and_Last_Run.sql` lists job state, owner, schedules and last outcome; `sql/02_Job_Failures_Recent.sql` lists failed job steps in a configurable window; `sql/03_Job_Duration_Trend.sql` reports job-level duration and outcome history. Run in msdb. SQL Server Agent must be installed; SQL Server Agent is not available in Azure SQL Database.

A job can be enabled but unscheduled. Review step history and error text, not only the last outcome. Compare duration with that job's own baseline. msdb history is subject to retention/purge settings. Visibility depends on msdb role membership and SQL Agent permissions. Read-only: jobs are not started, stopped, enabled, disabled, edited or deleted.
