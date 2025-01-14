#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE DATABASE kivop;
	GRANT ALL PRIVILEGES ON DATABASE kivop TO vapor;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname 'kivop' <<-EOSQL
	CREATE TABLE IF NOT EXISTS "_fluent_migrations" ("id" UUID PRIMARY KEY, "name" TEXT NOT NULL, "batch" BIGINT NOT NULL, "created_at" TIMESTAMPTZ, "updated_at" TIMESTAMPTZ, CONSTRAINT "uq:_fluent_migrations.name" UNIQUE ("name"));
	CREATE TABLE IF NOT EXISTS "_fluent_enums" ("id" UUID PRIMARY KEY, "name" TEXT NOT NULL, "case" TEXT NOT NULL, CONSTRAINT "uq:_fluent_enums.name+_fluent_enums.case" UNIQUE ("name", "case"));
	
	CREATE GROUP services;
	GRANT CREATE, CONNECT ON DATABASE kivop TO GROUP services;

	GRANT SELECT, REFERENCES, INSERT, UPDATE, DELETE ON TABLE "_fluent_migrations" TO GROUP services;
	GRANT SELECT, REFERENCES, INSERT, UPDATE, DELETE ON TABLE "_fluent_enums" TO GROUP services;
	GRANT SELECT, REFERENCES ON ALL TABLES IN SCHEMA public TO GROUP services;
	GRANT USAGE, CREATE ON SCHEMA public TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR ROLE services IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;

	-- Service-Users
	CREATE USER ${AI_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${AI_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${RIDE_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${RIDE_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${POSTER_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${POSTER_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${NOTIFICATIONS_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${NOTIFICATIONS_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${AUTH_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${AUTH_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${MEETING_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${MEETING_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;
	CREATE USER ${CONFIG_SERVICE_POSTGRES_USERNAME} WITH PASSWORD '${CONFIG_SERVICE_POSTGRES_PASSWORD}' IN GROUP services;

	-- Service-User-Privileges
	ALTER DEFAULT PRIVILEGES FOR USER ${AI_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${RIDE_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${POSTER_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${NOTIFICATIONS_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${AUTH_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${MEETING_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
	ALTER DEFAULT PRIVILEGES FOR USER ${CONFIG_SERVICE_POSTGRES_USERNAME} IN SCHEMA public GRANT SELECT, REFERENCES ON TABLES TO GROUP services;
EOSQL
