#Connect to ReadScale node 3 Linux VM

ssh clopez@sql-rs03.southcentralus.cloudapp.azure.com


#mostrar version de linux
uname -a -r
whoami
ls /opt/
/opt/mssql-tools/bin/./sqlcmd -S localhost -y 30 -Y 30

##ejecutar query para demostrar AG Node 3

SELECT primary_replica,primary_recovery_health_desc,secondary_recovery_health_desc,synchronization_health_desc FROM master.sys.dm_hadr_availability_group_states;
go 