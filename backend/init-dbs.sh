#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE kivop;
	GRANT ALL PRIVILEGES ON DATABASE kivop TO vapor;
EOSQL
