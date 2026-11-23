/* Module 16: Advisory failover indicators (NOT an automated go/no-go decision). */
SET NOCOUNT ON;
SELECT GETDATE() AS captured_at, @@SERVERNAME AS connected_instance,
       ag.name AS availability_group, ar.replica_server_name,
       ar.availability_mode_desc, ar.failover_mode_desc,
       ars.role_desc, ars.connected_state_desc,
       ars.synchronization_health_desc,
       CASE WHEN ar.availability_mode_desc = 'SYNCHRONOUS_COMMIT'
                      AND ar.failover_mode_desc = 'AUTOMATIC'
                 THEN 'Configured for automatic failover; verify other prerequisites'
            WHEN ar.availability_mode_desc = 'SYNCHRONOUS_COMMIT'
                 THEN 'Synchronous commit; manual failover may be possible after validation'
            ELSE 'Asynchronous commit; assess data-loss risk before any forced failover'
       END AS configuration_observation
FROM sys.availability_groups AS ag
JOIN sys.availability_replicas AS ar ON ar.group_id = ag.group_id
LEFT JOIN sys.dm_hadr_availability_replica_states AS ars ON ars.replica_id = ar.replica_id
ORDER BY ag.name, ar.replica_server_name;

SELECT ag.name AS availability_group,
       adc.database_name,
       ar.replica_server_name,
       drs.synchronization_state_desc,
       drs.synchronization_health_desc,
       drs.is_suspended,
       drs.database_state_desc,
       CASE WHEN drs.is_suspended = 1 THEN 'Investigate suspended data movement'
            WHEN drs.synchronization_state_desc = 'SYNCHRONIZED'
                 AND drs.synchronization_health_desc = 'HEALTHY'
                 THEN 'Healthy synchronization indicator; verify all failover prerequisites'
            ELSE 'Review synchronization state and potential data-loss exposure'
       END AS review_observation
FROM sys.dm_hadr_database_replica_states AS drs
JOIN sys.availability_groups AS ag ON ag.group_id = drs.group_id
JOIN sys.availability_replicas AS ar ON ar.replica_id = drs.replica_id
LEFT JOIN sys.availability_databases_cluster AS adc
  ON adc.group_id = drs.group_id AND adc.group_database_id = drs.group_database_id
ORDER BY ag.name, adc.database_name, ar.replica_server_name;
/* No ALTER AVAILABILITY GROUP, failover, or other state-changing commands. */
