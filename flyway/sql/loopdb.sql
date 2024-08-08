DECLARE @DB_PREFIX VARCHAR(5) = 'v3_';
DECLARE @dbname SYSNAME

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR SELECT db.name 
FROM master.sys.databases AS db 
WHERE db.name LIKE CONCAT(@DB_PREFIX,'%')
	AND ISNUMERIC(dbo.udf_GetNumeric(REPLACE(db.name,@DB_PREFIX,''))) = 1
  AND [state] = 0
ORDER BY db.name
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @dbname  
WHILE @@FETCH_STATUS = 0 BEGIN  

  PRINT @dbname

  FETCH NEXT FROM db_cursor INTO @dbname  

END  

CLOSE db_cursor
DEALLOCATE db_cursor
