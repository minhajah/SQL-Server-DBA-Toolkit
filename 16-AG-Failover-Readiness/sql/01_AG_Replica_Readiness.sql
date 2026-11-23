/* Module 16: AG replica readiness snapshot. Run on each replica. Read-only. */
SET NOCOUNT ON;
SELECT GETDATE() AS captured_at, @@SERVERNAME AS connected_instance,
       ag.name AS availability_group, ar.replica_server_name,
       ar.availability_mode_desc, ar.failover_mode_desc,
       ar.secondary_role_allow_connections_desc,
       ars.role_desc, ars.operational_state_desc,
       ars.connected_state_desc, ars.recovery_health_desc,
       ars.synchronization_health_desc,
       ars.last_connect_error_number, ars.last_connect_error_description,
       ars.last_connect_error_timestamp
FROM sys.availability_groups AS ag
JOIN sys.availability_replicas AS ar ON ar.group_id = ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON ars.replica_id = ar.replica_id
ORDER BY ag.name, ar.replica_server_name;
/* Remote replica state fields may be NULL; check from each replica. */
