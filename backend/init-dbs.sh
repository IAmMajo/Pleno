#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE meeting_db;
	GRANT ALL PRIVILEGES ON DATABASE meeting_db TO vapor;
	CREATE DATABASE config_db;
	GRANT ALL PRIVILEGES ON DATABASE config_db TO vapor;
EOSQL
