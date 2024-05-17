#!/bin/bash

# read passwords from env file
# create .env in current directory with required passwords
# DB_SYS_PASSWORD=Fooo
set -o allexport
source .env set

# start DB 23 ai container
docker run --name oracledb -p 1521:1521 -e ORACLE_PWD=$DB_SYS_PASSWORD container-registry.oracle.com/database/free

cat << EOF
You can stop and start container as docker stop|start oracledb

Copy osak config file as "docker cp osakafka.properties oracledb:/home/oracle/osakafka.properties"
EOF


