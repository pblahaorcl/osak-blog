#!/bin/bash

set -o allexport
source .env set

# you will need to export CONNECT=OSAK_USER/<PASSWORD> or add this .env file
sqlplus $CONNECT@localhost:1521/FREEPDB1 < load_data.sql
