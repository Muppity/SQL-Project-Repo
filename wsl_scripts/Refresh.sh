#!/bin/bash
#restore a database
docker exec -it Daltanious  /opt/mssql-tools/bin/sqlcmd  -Usa -PClave01* -i "/mnt/SQL/SQLQuery_Restore.sql"  -t10   -y5000 
#inspect information from engine running
docker exec -it Daltanious  /opt/mssql-tools/bin/sqlcmd  -Usa -PClave01* -i "/mnt/SQL/SQLQuery_Inspect.sql"  -t10   -y50 
#verifying SQL Log
docker exec -it Daltanious  /opt/mssql-tools/bin/sqlcmd  -Usa -PClave01* -i "exec sp_readerrorlog 0"  -t10   -y50 
