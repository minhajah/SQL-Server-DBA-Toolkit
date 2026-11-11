/* 05 Always On | Replica overview | master | Read-only | SQL Server 2016+ */
SET NOCOUNT ON;
IF NOT EXISTS(SELECT 1 FROM sys.availability_groups) BEGIN PRINT 'No Availability Groups are configured on this instance.'; RETURN; END;
SELECT ag.name AS availability_group_name,ar.replica_server_name,
       ar.availability_mode_desc,ar.failover_mode_desc,ar.seeding_mode_desc,
       ars.role_desc,ars.operational_state_desc,ars.connected_state_desc,ars.recovery_health_desc,
       ars.synchronization_health_desc,ars.last_connect_error_number,ars.last_connect_error_description,
       ars.last_connect_error_timestamp
FROM sys.availability_groups ag JOIN sys.availability_replicas ar ON ar.group_id=ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states ars ON ars.replica_id=ar.replica_id
ORDER BY ag.name,ar.replica_server_name;
