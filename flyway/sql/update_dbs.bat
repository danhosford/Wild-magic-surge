@ECHO OFF

set SERVER=%1
set U_LOGIN=%2
set U_PASSWORD=%3

set "DB_LIST_FILE=%~dp0loopdb.sql"

echo *************************************
echo ******* Start Core DB updates *******
echo *************************************

call flyway -url="jdbc:sqlserver://%SERVER%;databaseName=v3_sp;encrypt=false" -locations="filesystem:./core/**/migrations" -user=%U_LOGIN% -password=%U_PASSWORD% -baselineOnMigrate=true migrate 


echo **************************************
echo ********* End Core DB updates ********
echo **************************************

echo *************************************
echo **** Start LOGIN AUDIT DB updates ***
echo *************************************

::Run update script for each sql file
call flyway -url="jdbc:sqlserver://%SERVER%;databaseName=v3_spLoginAudit;encrypt=false" -locations="filesystem:./login_audit/**/migrations" -user=%U_LOGIN% -password=%U_PASSWORD% -baselineOnMigrate=true migrate 


echo **************************************
echo ******* End LOGIN AUDIT DB updates ***
echo **************************************

echo *************************************
echo ******* Start Translation updates ***
echo *************************************

::Run update script for each sql file
call flyway -url="jdbc:sqlserver://%SERVER%;databaseName=v3_spTranslation;encrypt=false" -locations="filesystem:./translation/**/migrations" -user=%U_LOGIN% -password=%U_PASSWORD% -baselineOnMigrate=true migrate 


echo **************************************
echo ********* End Translation updates ****
echo **************************************

echo **************************************
echo ****** Start Clients DB updates ******
echo **************************************

for /f "delims=" %%i in ('sqlcmd  -S %SERVER% -U %U_LOGIN% -P %U_PASSWORD% -d v3_sp -i %DB_LIST_FILE%') do (
	
	echo =================================================
	echo Working on %%i
	echo =================================================
	::Update with each scripts
	call flyway -url="jdbc:sqlserver://%SERVER%;databaseName=%%i;encrypt=false" -locations="filesystem:./client/**/migrations" -user=%U_LOGIN% -password=%U_PASSWORD% -baselineOnMigrate=true migrate

)

echo **************************************
echo ******** End Clients DB updates ******
echo **************************************



