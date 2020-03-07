--STEPS TO CONFIGURE AG'S READSCALE
--GTSSUG/Meetups
/* Enable Always On availability groups and restart mssql-server(s) 
** RS01 and RS02
*/
Enable-SqlAlwaysOn -ServerInstance read-scale-01 -Force
Enable-SqlAlwaysOn -ServerInstance read-scale-02 -Force

/*
** Enable an AlwaysOn_health event session
** To help with root-cause diagnosis when you troubleshoot an availability group
** you can optionally enable an Always On availability groups extended events (XEvents) session.
*/

ALTER EVENT SESSION  AlwaysOnhealth ON SERVER WITH (STARTUPSTATE=ON);
GO
/*
** Service account Creation
** For this configuration since it is a mixed environment NO FCI a SQL login is created
*/
CREATE LOGIN clopez WITH PASSWORD = ‘***********’;
CREATE USER clopez_user FOR LOGIN clopez;

/* Certificate authentication
** Since the configuration  use a secondary replica that requires authentication with SQL authentication, a certificate is necesary to authenticate between endpoints.
** The following Transact-SQL script creates a master key and a certificate. It then backs up the certificate and secures the file with a private key. 
** Update the script with strong passwords. Run the script on the primary SQL Server instance to create the certificate:
**  
**/
------Primary Replica
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '********';
CREATE CERTIFICATE dbm_certificate WITH SUBJECT = 'dbm';

BACKUP CERTIFICATE dbm_certificate
   TO FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\dbm_certificate.cer'
   WITH PRIVATE KEY (FILE = 'c:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\dbm_certificate.pvk',
           ENCRYPTION BY PASSWORD = '*********');

-----Secondary Replica
CREATE MASTER KEY ENCRYPTION BY PASSWORD = '*******';
CREATE CERTIFICATE dbm_certificate
    AUTHORIZATION clopez_user
    FROM FILE = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\dbm_certificate.cer'
    WITH PRIVATE KEY (
    FILE = 'c:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\dbm_certificate.pvk',
    DECRYPTION BY PASSWORD = '***********'

/** Connected in Primary 
    Create the Primary Endpoint followed by the AG 
    NOTE:  Care to select your configuration
          AVAILABILITYMODE : {SYNCRONOUS, ASYNCRONOUS} 
          FAILOVER_MODE:     {AUTOMATIC,MANUAL,FORCED} 
          SEEDING_MODE:      {AUTOMATIC,MANUAL}

    ------
    If you require to change SEEDING_MODE you can use following alter command.
    ALTER AVAILABILITY GROUP [ag_rs]
    MODIFY REPLICA ON 'read-scale-02'
    WITH (SEEDING_MODE = MANUAL)

**/
CREATE ENDPOINT [hadr_endpoint]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (
	    ROLE = ALL,
	    AUTHENTICATION = CERTIFICATE dbm_certificate,
		ENCRYPTION = REQUIRED ALGORITHM AES
		);
ALTER ENDPOINT [hadr_endpoint] STATE = STARTED;

GRANT CONNECT ON ENDPOINT::[hadr_endpoint] TO [clopez];

CREATE AVAILABILITY GROUP [ag_rs]
    WITH (CLUSTER_TYPE = NONE)
    FOR REPLICA ON
        N'read-scale-01' WITH (
            ENDPOINT_URL = N'tcp://read-scale-01:5022',
		    AVAILABILITYMODE = ASYNCHRONOUSCOMMIT,
		    FAILOVER_MODE = MANUAL,
		    SEEDING_MODE = AUTOMATIC,
                    SECONDARYROLE (ALLOWCONNECTIONS = ALL)
		    ),
        N'read-scale-02' WITH (
		    ENDPOINT_URL = N'tcp://read-scale-02:5022',
		    AVAILABILITYMODE = ASYNCHRONOUSCOMMIT,
		    FAILOVER_MODE = MANUAL,
		    SEEDING_MODE = AUTOMATIC,
		    SECONDARYROLE (ALLOWCONNECTIONS = ALL)
		    );

ALTER AVAILABILITY GROUP [ag_rs] GRANT CREATE ANY DATABASE;

-------Secondary
/* Connect to Secondary and create the Endpoint
** Add it to the Availability GROUP
**
*/
CREATE ENDPOINT [hadr_endpoint]
    AS TCP (LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (
	    ROLE = ALL,
	    AUTHENTICATION = CERTIFICATE dbm_certificate,
		ENCRYPTION = REQUIRED ALGORITHM AES
		);
ALTER ENDPOINT [hadr_endpoint] STATE = STARTED;
GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [clopez];

ALTER AVAILABILITY GROUP [agrs] JOIN WITH (CLUSTERTYPE = NONE);

ALTER AVAILABILITY GROUP [ag_rs] GRANT CREATE ANY DATABASE;

------Primary
/* Take full backup from primary and transport 
*/
CREATE DATABASE [db1];
ALTER DATABASE [db1] SET RECOVERY FULL;
BACKUP DATABASE [db1]
TO DISK = N'c:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\db1.bak';

ALTER AVAILABILITY GROUP [ag_rs] ADD DATABASE [db1];

-------Third

CREATE USER clopez_user FOR LOGIN clopez;
EXEC sp_addsrvrolemember 'clopez' , 'sysadmin';  
GO

CREATE MASTER KEY ENCRYPTION BY PASSWORD = '***********';
CREATE CERTIFICATE dbm_certificate
    FROM FILE = '/var/opt/mssql/data/dbm_certificate.cer'
    WITH PRIVATE KEY (
    FILE = '/var/opt/mssql/data/dbm_certificate.pvk',
    DECRYPTION BY PASSWORD = '********');

-------Primary

ALTER AVAILABILITY GROUP [ag_rs]
ADD REPLICA ON
    N'read-scale-03' WITH (
        ENDPOINT_URL = N'tcp://read-scale-03:5022',
		AVAILABILITYMODE = ASYNCHRONOUSCOMMIT,
		FAILOVER_MODE = MANUAL,
		SEEDING_MODE = AUTOMATIC,
                SECONDARYROLE (ALLOWCONNECTIONS = ALL));

---------Third
ALTER AVAILABILITY GROUP [agrs] JOIN WITH (CLUSTERTYPE = NONE);
		 
ALTER AVAILABILITY GROUP [ag_rs] GRANT CREATE ANY DATABASE;

------Secondary and third
SELECT * FROM sys.databases WHERE name = 'db1';
GO
SELECT DBNAME(databaseid) AS 'database', synchronizationstatedesc FROM sys.dmhadrdatabasereplicastates;