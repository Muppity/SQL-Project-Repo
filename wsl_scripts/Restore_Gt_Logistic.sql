USE [master]
RESTORE DATABASE [Gt_Logistic] FROM  DISK = N'/mnt/SQL/MIRROR_Gt_Logistic_FULL_20180801_203845.bak' 
WITH  FILE = 1,  MOVE N'Gt_Logistic' TO N'/var/opt/mssql/data/Gt_Logistic.mdf',  
MOVE N'Gt_Logistic_log' TO N'/var/opt/mssql/data/Gt_Logistic_1.ldf',  NOUNLOAD,  STATS = 5
GO

