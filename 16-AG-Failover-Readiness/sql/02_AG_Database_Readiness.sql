/* Module 16: Per-database synchronization and queue snapshot. Run on each replica. */
SET NOCOUNT ON;
SELECT GETDATE() AS captured_at, @@SERVERNAME AS connected_instance,
       ag.name AS availability_group, ar.replica_server_name,
       adc.database_name, drs.is_local, drs.is_primary_replica,
       drs.database_state_desc, drs.synchronization_state_desc,
       drs.synchronization_health_desc, drs.is_suspended,
       drs.suspend_reason_desc, drs.log_send_queue_size AS log_send_queue_kb,
       drs.log_send_rate AS log_send_rate_kb_sec,
       drs.redo_queue_size AS redo_queue_kb,
       drs.redo_rate AS redo_rate_kb_sec,
       drs.last_sent_time, drs.last_received_time,
       drs.last_hardened_time, drs.last_redone_time, drs.last_commit_time
FROM sys.dm_hadr_database_replica_states AS drs
JOIN sys.availability_replicas AS ar ON ar.replica_id = drs.replica_id
JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
LEFT JOIN sys.availability_databases_cluster AS adc
  ON adc.group_id = drs.group_id AND adc.group_database_id = drs.group_database_id
ORDER BY ag.name, adc.database_name, ar.replica_server_name;
/* NULLs/queues are point-in-time; synchronization is not a zero-data-loss guarantee. */
