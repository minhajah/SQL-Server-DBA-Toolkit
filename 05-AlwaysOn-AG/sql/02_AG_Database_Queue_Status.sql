/* 05 Always On | Database queues and synchronization | master | Read-only */
SET NOCOUNT ON;
IF NOT EXISTS(SELECT 1 FROM sys.availability_groups) BEGIN PRINT 'No Availability Groups are configured on this instance.'; RETURN; END;
SELECT ag.name AS availability_group_name,adc.database_name,ar.replica_server_name,ars.role_desc,
       drs.is_local,drs.is_primary_replica,drs.synchronization_state_desc,drs.synchronization_health_desc,
       drs.database_state_desc,drs.is_suspended,drs.suspend_reason_desc,
       drs.log_send_queue_size AS log_send_queue_kb,drs.log_send_rate AS log_send_rate_kb_sec,
       drs.redo_queue_size AS redo_queue_kb,drs.redo_rate AS redo_rate_kb_sec,drs.last_commit_time
FROM sys.dm_hadr_database_replica_states drs
JOIN sys.availability_replicas ar ON ar.replica_id=drs.replica_id
JOIN sys.availability_groups ag ON ag.group_id=ar.group_id
LEFT JOIN sys.availability_databases_cluster adc ON adc.group_id=ag.group_id AND adc.group_database_id=drs.group_database_id
LEFT JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id=ar.replica_id AND ars.is_local=drs.is_local
ORDER BY ag.name,adc.database_name,ar.replica_server_name;
