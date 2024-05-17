## Ingest data from OCI Streaming into Oracle 23ai

These scripts are used for OSAK setup in Oracle 23 ai running in docker container and consume messages from OCI Streaming. The messages producers are in dirrecry _stream-client-go_ The code produces messages in json format and following schema
```
type Payload struct {
	Id        int       `json:"key"`   // Unique identifier
	EventType string    `json:"type"`  // Type of message
	TimeStamp time.Time `json:"ts"`    // Creation time
	Message   string    `json:"value"` // Message value
}
```

### Prerequistites
* Installed and Configured docker engine, sqlplus and golang development environemnt
* Created OCI tenancy with created OCI Streaming instance
* Configured OCI user as documented [here](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm#Required_Keys_and_OCIDs)

### Setup
Oracle RDBMS 23 ai is delivered as docker image in public [registry](https://www.oracle.com/uk/database/free/get-started/). The database can be started as `docker run --name oracledb -p 1521:1521 -e ORACLE_PWD=<PASSWORD> container-registry.oracle.com/database/free`

Next step is to connect to PDB as `sqlplus sys@localhost:1521/FREEPDB1 as sysdba` with password provided for running container and create testing user, see script *create_osk_user.sql*

Modify osakafka.properties with OCI Streaming configuration and copy file into running container as `docker cp osakafka.properties oracledb:/home/oracle/osakafka.properties`

Update *setup_osak_app.sql* and execute
login to database as new user and setup osak
```
export CONNECT=OSAK_USER/<PASSWORD>
sqlplus $CONNECT@localhost:1521/FREEPDB1 < setup_osak_app.sql
```

### Load data
Execute Producer at second command window from *stream-client-go* and load data into table as
```
sqlplus $CONNECT@localhost:1521/FREEPDB1 < load_data.sql
```
