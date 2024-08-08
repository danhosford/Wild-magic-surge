#!/bin/bash

# install sqlcmd tools
if [ ! -f /opt/mssql-tools/bin/sqlcmd ]
then
	curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
	curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
	apt-get update
	export ACCEPT_EULA=y 
	export DEBIAN_FRONTEND=noninteractive
	apt-get -y install mssql-tools unixodbc-dev
fi

DBHOSTNAME="${DBHOSTNAME:-safepermit-db}"
USERNAME="${USERNAME:-sa}"
PASSWORD="${PASSWORD:-@1LookSystems}"

echo
echo '================================================='
echo 'Working on core (v3_sp)'
echo '================================================='

flyway -url="jdbc:sqlserver://$DBHOSTNAME;databaseName=v3_sp;encrypt=false" -locations="filesystem:./sql/core" -user=$USERNAME -password=$PASSWORD -baselineOnMigrate=true migrate

echo
echo
echo '================================================='
echo 'Working on login audit (v3_spLoginAudit)'
echo '================================================='

flyway -url="jdbc:sqlserver://$DBHOSTNAME;databaseName=v3_spLoginAudit;encrypt=false" -locations="filesystem:./sql/login_audit" -user=$USERNAME -password=$PASSWORD -baselineOnMigrate=true migrate

echo
echo
echo '================================================='
echo 'Working on translation (v3_spTranslation)'
echo '================================================='

flyway -url="jdbc:sqlserver://$DBHOSTNAME;databaseName=v3_spTranslation;encrypt=false" -locations="filesystem:./sql/translation" -user=$USERNAME -password=$PASSWORD -baselineOnMigrate=true migrate

/opt/mssql-tools/bin/sqlcmd -S $DBHOSTNAME -U $USERNAME -P $PASSWORD -d v3_sp -i ./sql/loopdb.sql | 
while IFS= read -r database 
do 
	current_db="$(echo -e "${database}" | tr -d '[:space:]')"
	echo
	echo
	echo '================================================='
	echo 'Working on client '$current_db
	echo '================================================='

	flyway -url="jdbc:sqlserver://$DBHOSTNAME;databaseName=$current_db;encrypt=false" -locations="filesystem:./sql/client" -user=$USERNAME -password=$PASSWORD -baselineOnMigrate=true migrate
done
