#!/bin/bash
# Fix schema references in new_server_schema_combined.sql

echo "Fixing schema references in new_server_schema_combined.sql..."

# Create backup
cp new_server_schema_combined.sql new_server_schema_combined.sql.backup

# Replace all "Schema: dev" with "Schema: public" in comments
sed -i 's/Schema: dev/Schema: public/g' new_server_schema_combined.sql

# Replace all "CREATE TYPE dev." with "CREATE TYPE public."
sed -i 's/CREATE TYPE dev\./CREATE TYPE public./g' new_server_schema_combined.sql

# Replace all "CREATE TABLE dev." with "CREATE TABLE public."
sed -i 's/CREATE TABLE dev\./CREATE TABLE public./g' new_server_schema_combined.sql

# Replace all "ALTER TABLE dev." with "ALTER TABLE public."
sed -i 's/ALTER TABLE dev\./ALTER TABLE public./g' new_server_schema_combined.sql

# Replace all "CREATE SEQUENCE dev." with "CREATE SEQUENCE public."
sed -i 's/CREATE SEQUENCE dev\./CREATE SEQUENCE public./g' new_server_schema_combined.sql

# Replace all "ALTER SEQUENCE dev." with "ALTER SEQUENCE public."
sed -i 's/ALTER SEQUENCE dev\./ALTER SEQUENCE public./g' new_server_schema_combined.sql

# Replace all "CREATE VIEW dev." with "CREATE VIEW public."
sed -i 's/CREATE VIEW dev\./CREATE VIEW public./g' new_server_schema_combined.sql

# Replace all "CREATE INDEX ... ON dev." with "CREATE INDEX ... ON public."
sed -i 's/ ON dev\./ ON public./g' new_server_schema_combined.sql

# Replace all "ALTER SCHEMA dev" with "ALTER SCHEMA public"
sed -i 's/ALTER SCHEMA dev /ALTER SCHEMA public /g' new_server_schema_combined.sql

# Replace "CREATE SCHEMA dev" with comment (we'll use existing public schema)
sed -i 's/CREATE SCHEMA dev;/-- CREATE SCHEMA public; (using existing public schema)/g' new_server_schema_combined.sql

echo "✓ Schema references fixed!"
echo "✓ Backup saved as: new_server_schema_combined.sql.backup"
echo ""
echo "Now run:"
echo "  psql -h localhost -U root -d postgres -f scripts/02_setup_schema.sql"
