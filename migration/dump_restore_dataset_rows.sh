#!/bin/bash
#
# Dump dataset_rows from staging and restore to dev
# This bypasses Python type conversion issues
#

set -e

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "========================================================================"
echo "DUMP AND RESTORE dataset_rows TABLE"
echo "========================================================================"
echo ""

DUMP_FILE="/tmp/dataset_rows_dump.sql"

echo "[1/4] Dumping dataset_rows from staging..."
PGPASSWORD=$STAGING_PASSWORD pg_dump \
    -h $STAGING_HOST \
    -p ${STAGING_PORT:-5432} \
    -U $STAGING_USER \
    -d $STAGING_DB \
    --schema=$STAGING_SCHEMA \
    --table=dataset_rows \
    --data-only \
    --column-inserts \
    > $DUMP_FILE

echo "✓ Dumped to $DUMP_FILE"
echo ""

echo "[2/4] Checking dump file..."
LINE_COUNT=$(wc -l < $DUMP_FILE)
echo "✓ Dump file has $LINE_COUNT lines"
echo ""

echo "[3/4] Truncating dataset_rows in dev..."
PGPASSWORD=$DEV_PASSWORD psql \
    -h $DEV_HOST \
    -p ${DEV_PORT:-5432} \
    -U $DEV_USER \
    -d $DEV_DB \
    -c "TRUNCATE TABLE ${DEV_SCHEMA}.dataset_rows CASCADE;"

echo "✓ Table truncated"
echo ""

echo "[4/4] Restoring data to dev..."
# Replace schema name in dump file if needed
if [ "$STAGING_SCHEMA" != "$DEV_SCHEMA" ]; then
    sed -i "s/${STAGING_SCHEMA}\./${DEV_SCHEMA}./g" $DUMP_FILE
fi

PGPASSWORD=$DEV_PASSWORD psql \
    -h $DEV_HOST \
    -p ${DEV_PORT:-5432} \
    -U $DEV_USER \
    -d $DEV_DB \
    < $DUMP_FILE

echo "✓ Data restored"
echo ""

echo "[5/4] Verifying row counts..."
STAGING_COUNT=$(PGPASSWORD=$STAGING_PASSWORD psql -h $STAGING_HOST -p ${STAGING_PORT:-5432} -U $STAGING_USER -d $STAGING_DB -t -c "SELECT COUNT(*) FROM ${STAGING_SCHEMA}.dataset_rows;")
DEV_COUNT=$(PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p ${DEV_PORT:-5432} -U $DEV_USER -d $DEV_DB -t -c "SELECT COUNT(*) FROM ${DEV_SCHEMA}.dataset_rows;")

echo "Staging: $STAGING_COUNT rows"
echo "Dev:     $DEV_COUNT rows"
echo ""

if [ "$STAGING_COUNT" = "$DEV_COUNT" ]; then
    echo "✓✓✓ SUCCESS: Row counts match! ✓✓✓"
else
    echo "✗✗✗ WARNING: Row counts differ ✗✗✗"
fi

echo ""
echo "Cleaning up dump file..."
rm -f $DUMP_FILE
echo "✓ Done"
echo ""
