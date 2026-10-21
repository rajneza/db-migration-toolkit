#!/bin/bash
#
# Dump datasets and dataset_rows from staging and restore to dev
# Handles FK dependencies properly
#

set -e

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "========================================================================"
echo "DUMP AND RESTORE datasets + dataset_rows (WITH DEPENDENCIES)"
echo "========================================================================"
echo ""

DUMP_DIR="/tmp/dataset_migration"
mkdir -p $DUMP_DIR

# Tables to migrate in order (parent first, then child)
TABLES=("datasets" "dataset_rows")

echo "Step 1: Dumping tables from staging..."
echo "------------------------------------------------------------------------"
for TABLE in "${TABLES[@]}"; do
    echo "  Dumping $TABLE..."
    PGPASSWORD=$STAGING_PASSWORD pg_dump \
        -h $STAGING_HOST \
        -p ${STAGING_PORT:-5432} \
        -U $STAGING_USER \
        -d $STAGING_DB \
        --schema=$STAGING_SCHEMA \
        --table=$TABLE \
        --data-only \
        --column-inserts \
        > $DUMP_DIR/${TABLE}.sql
    
    LINE_COUNT=$(wc -l < $DUMP_DIR/${TABLE}.sql)
    echo "    ✓ Dumped $LINE_COUNT lines to $DUMP_DIR/${TABLE}.sql"
done
echo ""

echo "Step 2: Truncating tables in dev (reverse order)..."
echo "------------------------------------------------------------------------"
# Truncate in reverse order (child first)
for (( idx=${#TABLES[@]}-1 ; idx>=0 ; idx-- )) ; do
    TABLE=${TABLES[idx]}
    echo "  Truncating $TABLE..."
    PGPASSWORD=$DEV_PASSWORD psql \
        -h $DEV_HOST \
        -p ${DEV_PORT:-5432} \
        -U $DEV_USER \
        -d $DEV_DB \
        -c "TRUNCATE TABLE ${DEV_SCHEMA}.${TABLE} CASCADE;" 2>&1 | grep -v "^NOTICE" || true
    echo "    ✓ Truncated"
done
echo ""

echo "Step 3: Restoring data to dev (parent first)..."
echo "------------------------------------------------------------------------"
for TABLE in "${TABLES[@]}"; do
    echo "  Restoring $TABLE..."
    
    # Replace schema name if needed
    if [ "$STAGING_SCHEMA" != "$DEV_SCHEMA" ]; then
        sed -i "s/${STAGING_SCHEMA}\./${DEV_SCHEMA}./g" $DUMP_DIR/${TABLE}.sql
    fi
    
    PGPASSWORD=$DEV_PASSWORD psql \
        -h $DEV_HOST \
        -p ${DEV_PORT:-5432} \
        -U $DEV_USER \
        -d $DEV_DB \
        -f $DUMP_DIR/${TABLE}.sql \
        -v ON_ERROR_STOP=1 > /dev/null 2>&1
    
    echo "    ✓ Restored"
done
echo ""

echo "Step 4: Verifying row counts..."
echo "------------------------------------------------------------------------"
echo "Table                  Staging         Dev         Status"
echo "------------------------------------------------------------------------"

ALL_MATCH=true
for TABLE in "${TABLES[@]}"; do
    STAGING_COUNT=$(PGPASSWORD=$STAGING_PASSWORD psql -h $STAGING_HOST -p ${STAGING_PORT:-5432} -U $STAGING_USER -d $STAGING_DB -t -c "SELECT COUNT(*) FROM ${STAGING_SCHEMA}.${TABLE};" | xargs)
    DEV_COUNT=$(PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p ${DEV_PORT:-5432} -U $DEV_USER -d $DEV_DB -t -c "SELECT COUNT(*) FROM ${DEV_SCHEMA}.${TABLE};" | xargs)
    
    if [ "$STAGING_COUNT" = "$DEV_COUNT" ]; then
        STATUS="✓ MATCH"
    else
        STATUS="✗ MISMATCH"
        ALL_MATCH=false
    fi
    
    printf "%-20s %10s %10s     %s\n" "$TABLE" "$STAGING_COUNT" "$DEV_COUNT" "$STATUS"
done
echo ""

if [ "$ALL_MATCH" = true ]; then
    echo "✓✓✓ SUCCESS: All tables migrated successfully! ✓✓✓"
else
    echo "✗✗✗ WARNING: Some tables have mismatched counts ✗✗✗"
fi
echo ""

echo "Cleaning up dump files..."
rm -rf $DUMP_DIR
echo "✓ Done"
echo ""
