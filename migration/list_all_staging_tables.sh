#!/bin/bash
#
# List all tables in staging schema with row counts
#

set -e

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "========================================================================"
echo "ALL TABLES IN STAGING SCHEMA"
echo "========================================================================"
echo ""

PGPASSWORD=$STAGING_PASSWORD psql \
    -h $STAGING_HOST \
    -p ${STAGING_PORT:-5432} \
    -U $STAGING_USER \
    -d $STAGING_DB \
    -c "
SELECT 
    schemaname,
    tablename,
    (SELECT COUNT(*) FROM ${STAGING_SCHEMA}.\"\${tablename}\") as row_count
FROM pg_tables
WHERE schemaname = '${STAGING_SCHEMA}'
ORDER BY tablename;
"

echo ""
echo "Total tables:"
PGPASSWORD=$STAGING_PASSWORD psql \
    -h $STAGING_HOST \
    -p ${STAGING_PORT:-5432} \
    -U $STAGING_USER \
    -d $STAGING_DB \
    -t \
    -c "SELECT COUNT(*) FROM pg_tables WHERE schemaname = '${STAGING_SCHEMA}';"

echo ""
