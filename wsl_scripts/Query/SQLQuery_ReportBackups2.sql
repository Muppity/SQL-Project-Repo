SET NOCOUNT ON;
Declare @SQLSentence varchar(8000);

IF OBJECT_ID('##rowstablePreHTML', 'U') IS NOT NULL
	 DROP TABLE ##rowstablePreHTML ;


declare @condition tinyint;
SET @condition = 24;

with
    backupInsight_cte (database_id, last_backup, health_check)
    as
    (
        
        select d.database_id, max(b.backup_start_date) AS last_backup, case when (datediff( hh , max(b.backup_start_date) , getdate()) < @condition) then 1 else 0 end as health_check
       from sys.databases as d left join msdb..backupset as b on d.name = b.database_name
       where d.database_id > 4
        group by d.database_id
    )
select
    coalesce(sum(health_check),0) [Within 24hrs],
    coalesce(sum(case when health_check = 0 AND last_backup IS NOT NULL then 1 else 0 end),0) [Older than 24hrs],
    coalesce(sum(case when health_check = 0 AND last_backup IS NULL then 1 else 0 end),0) [No backup found]
into ##rowstablePreHTML
from backupInsight_cte

EXEC sp_TabletoHTML @stTable = @SQLSentence,@TableStyle=2,@bypass=1
DROP TABLE ##rowstablePreHTML ;