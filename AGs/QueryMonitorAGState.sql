--AlwaysOn Availability Replica State, Identification and Configuration
PRINT '====================================================================='
PRINT 'AlwaysOn Availability Replica State, Identification and Configuration'
PRINT '====================================================================='
PRINT ''
SELECT 
    group_name=cast(arc.group_name as varchar(30)), 
    replica_server_name=cast(arc.replica_server_name as varchar(30)), 
    node_name=cast(arc.node_name as varchar(30)),
    role_desc=cast(ars.role_desc as varchar(30)), 
    ar.availability_mode_Desc,
    connected_state_desc=cast(ars.connected_state_desc as varchar(30)), 
    recovery_health_desc=cast(ars.recovery_health_desc as varchar(30)),
    synhcronization_health_desc=cast(ars.synchronization_health_desc as varchar(30))
from sys.dm_hadr_availability_replica_cluster_nodes arc 
join sys.dm_hadr_availability_replica_cluster_states arcs on arc.replica_server_name=arcs.replica_server_name
join sys.dm_hadr_availability_replica_states ars on arcs.replica_id=ars.replica_id
join sys.availability_replicas ar on ars.replica_id=ar.replica_id
join sys.availability_groups ag 
on ag.group_id = arcs.group_id 
and ag.name = arc.group_name 
--dm_hadr_availability_replica_cluster_nodes doesn't have a group_id, so we have to join by name
ORDER BY 
cast(arc.group_name as varchar(30)), 
cast(ars.role_desc as varchar(30)) 
