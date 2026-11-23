/* Module 16: WSFC quorum and cluster membership indicators. Read-only. */
SET NOCOUNT ON;
SELECT GETDATE() AS captured_at, @@SERVERNAME AS connected_instance,
       cluster_name, quorum_type_desc, quorum_state_desc
FROM sys.dm_hadr_cluster;

SELECT member_name, member_type_desc, member_state_desc, number_of_quorum_votes
FROM sys.dm_hadr_cluster_members
ORDER BY member_type_desc, member_name;

SELECT quorum_type_desc, quorum_state_desc
FROM sys.dm_hadr_cluster_quorum;
/* Cluster DMV visibility depends on topology, WSFC state, and permissions.
   For authoritative quorum/network/witness assessment, also review Failover Cluster Manager and cluster logs. */
