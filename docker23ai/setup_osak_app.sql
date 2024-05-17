DROP DIRECTORY OSAK_KAFKA_ACCESS;
DROP DIRECTORY OSAK_KAFKA_CONFIG;
CREATE DIRECTORY OSAK_KAFKA_ACCESS AS '';
CREATE DIRECTORY OSAK_KAFKA_CONFIG AS '/home/oracle';
-- credentials used for accessing OCI Streaming service
-- need to create Authentication token
-- below is user name in form <OCI_TENANCY>/<OCI_USER>/<STREAM_POOL_OCID>
BEGIN
        DBMS_CREDENTIAL.CREATE_CREDENTIAL(
                CREDENTIAL_NAME => 'KAFKA1CRED',
                USERNAME => 'oraclebigdatadb/petr.blaha@oracle.com/ocid1.streampool.oc1.phx.amaaaaaayrywvyyapg5gacjrcdwsx5w27uv4iewhvdx6wvtxditkqeb4c5ha',
                PASSWORD => 'jBYI9yvQkTp1zv4XcWq+' -- Authentication token
        );
END;
/
SELECT
        DBMS_KAFKA_ADM.REGISTER_CLUSTER (
                CLUSTER_NAME => 'OSSCLUSTER', -- name of cluster
                BOOTSTRAP_SERVERS =>'cell-1.streaming.us-phoenix-1.oci.oraclecloud.com:9092', -- OCI streaming end point
                KAFKA_PROVIDER => 'OSS', -- supported types ar APACHE or OSS (OCI Streaming Service)
                CLUSTER_ACCESS_DIR => 'OSAK_KAFKA_ACCESS', -- The Oracle directory object for determining access to this cluster
                CREDENTIAL_NAME => 'KAFKA1CRED', -- Credential names associated with this cluster
                CLUSTER_CONFIG_DIR => 'OSAK_KAFKA_CONFIG',
                CLUSTER_DESCRIPTION => 'My test OCI Streaming consumer',
                OPTIONS => NULL
        )
FROM
        DUAL;
-- Check Kafka broker status
EXEC SYS.DBMS_OUTPUT.PUT_LINE (SYS.DBMS_KAFKA_ADM.CHECK_CLUSTER ('OSSCLUSTER'));
-- Create OSAK load application
DECLARE
        V_OPTIONS VARCHAR2(512);
BEGIN
        V_OPTIONS := '{"fmt" : "JSON"}';
        SYS.DBMS_KAFKA.CREATE_LOAD_APP ( 'OSSCLUSTER', -- the name of cluster created by DBMS_KAFKA_ADM.REGISTER_CLUSTER
        'OSSLOADAPP', -- The application name
        'osak_test', -- The topic name
        V_OPTIONS);
END;
/
-- Create table to persist loaded data
CREATE TABLE MY_LOADED_DATA(
        VALUE VARCHAR2(4000),
        KAFKA_OFFSET NUMBER(38)
);