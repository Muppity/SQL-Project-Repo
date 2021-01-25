
USE [master]
GO
CREATE LOGIN [Usuario1] WITH PASSWORD=N'Clave01*' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
CREATE LOGIN [Usuario2] WITH PASSWORD=N'Clave01*' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
CREATE LOGIN [Usuario3] WITH PASSWORD=N'Clave01*' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO
CREATE LOGIN [Usuario4] WITH PASSWORD=N'Clave01*' MUST_CHANGE, DEFAULT_DATABASE=[master], CHECK_EXPIRATION=ON, CHECK_POLICY=ON
GO


USE DWM_Local
go

-- Add Database Users
--------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_grantdbaccess 'Usuario1'
EXEC sp_grantdbaccess 'Usuario2'
EXEC sp_grantdbaccess 'Usuario3'
EXEC sp_grantdbaccess 'Usuario4'

-- Create Roles
-------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_addrole 'db_accessadmin',dbo 
EXEC sp_addrole 'db_backupoperator',dbo 
EXEC sp_addrole 'db_datareader',dbo 
EXEC sp_addrole 'db_datawriter',dbo 
EXEC sp_addrole 'db_ddladmin',dbo 
EXEC sp_addrole 'db_denydatareader',dbo 
EXEC sp_addrole 'db_denydatawriter',dbo 
EXEC sp_addrole 'db_owner',dbo 
EXEC sp_addrole 'db_securityadmin',dbo 

-- Add Role Users
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
EXEC sp_addrolemember 'db_datareader','Usuario1'
EXEC sp_addrolemember 'db_datareader','Usuario2'
EXEC sp_addrolemember 'db_datareader','Usuario3'
EXEC sp_addrolemember 'db_datareader','Usuario4'
EXEC sp_addrolemember 'db_datareader','Usuario1'
EXEC sp_addrolemember 'db_owner','Usuario4'

-- Setup Object privileges
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Setup Column privileges
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- End of script

--SYNC ORPHANS
-- Secure Orphaned User AutoFix 
DECLARE @autoFix bit; 
SET @autoFix = 'TRUE';  -- FALSE = Report only those user who could be auto fixed. 
                         -- TRUE  = Report and fix !!! 
 
DECLARE @user sysname, @principal sysname, @sql nvarchar(500), @found int, @fixed int; 
 
DECLARE orphans CURSOR LOCAL FOR 
    SELECT QUOTENAME(SU.[name]) AS UserName 
          ,QUOTENAME(SP.[name]) AS PrincipalName 
    FROM sys.sysusers AS SU 
         LEFT JOIN sys.server_principals AS SP 
             ON SU.[name] = SP.[name] collate SQL_Latin1_General_CP1_CI_AS 
                AND SP.[type] = 'S' 
    WHERE SU.issqluser = 1          -- Only SQL logins 
          AND NOT SU.[sid] IS NULL  -- Exclude system user 
          AND SU.[sid] <> 0x0       -- Exclude guest account 
          AND LEN(SU.[sid]) <= 16   -- Exclude Windows accounts & roles 
          AND SUSER_SNAME(SU.[sid]) IS NULL  -- Login for SID is null 
    ORDER BY SU.[name]; 
 
SET @found = 0; 
SET @fixed = 0; 
OPEN orphans; 
FETCH NEXT FROM orphans 
    INTO @user, @principal; 
WHILE @@FETCH_STATUS = 0 
BEGIN 
    IF @principal IS NULL 
        PRINT N'Orphan: ' + @user; 
    ELSE 
    BEGIN 
        PRINT N'Orphan: ' + @user + N' => Autofix possible, principal with same name found!'; 
        IF @autoFix = 'TRUE' 
        BEGIN 
            -- Build the DDL statement dynamically. 
            SET @sql = N'ALTER USER ' + @user + N' WITH LOGIN = ' + @principal + N';'; 
            EXEC sp_executesql @sql; 
            PRINT N'        ' + @user + N' is auto fixed.'; 
            SET @fixed = @fixed + 1; 
        END 
    END 
    SET @found = @found + 1; 
     
    FETCH NEXT FROM orphans 
        INTO @user, @principal; 
END; 
 
CLOSE orphans; 
DEALLOCATE orphans; 
 
PRINT ''; 
PRINT CONVERT(nvarchar(15), @found) + N' orphan(s) found, ' 
    + CONVERT(nvarchar(15), @fixed) + N' orphan(s) fixed.';

