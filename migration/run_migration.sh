#!/bin/bash
# Complete Migration Script (No dblink required)

set -e  # Exit on error

echo "========================================================================"
echo "DATABASE MIGRATION - STAGING TO DEV"
echo "========================================================================"
echo ""

# Load .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ .env loaded"
else
    echo "✗ .env file not found!"
    exit 1
fi

echo ""
echo "========================================================================="
echo "STEP 1: Test Connections"
echo "========================================================================="
echo ""

echo "Testing staging connection..."
PGPASSWORD=$STAGING_PASSWORD psql -h $STAGING_HOST -U $STAGING_USER -d $STAGING_DB -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Staging connection successful"
else
    echo "✗ Staging connection failed!"
    exit 1
fi

echo "Testing dev connection..."
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✓ Dev connection successful"
else
    echo "✗ Dev connection failed!"
    exit 1
fi

echo ""
echo "========================================================================="
echo "STEP 2: Create Schema (if not done)"
echo "========================================================================="
echo ""

echo "Checking if tables exist..."
TABLE_COUNT=$(PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';")

if [ "$TABLE_COUNT" -lt 100 ]; then
    echo "Only $TABLE_COUNT tables found. Creating schema..."
    PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02_setup_schema.sql
    PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/02b_add_missing_columns.sql
else
    echo "✓ Schema already created ($TABLE_COUNT tables)"
fi

echo ""
echo "========================================================================="
echo "STEP 3: Migrate Data (Python - No dblink)"
echo "========================================================================="
echo ""

python3 migrate_data_python.py

echo ""
echo "========================================================================="
echo "STEP 4: Reset Sequences"
echo "========================================================================="
echo ""

PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/04_reset_sequences.sql

echo ""
echo "========================================================================="
echo "STEP 5: Drop FK Constraints"
echo "========================================================================="
echo ""

PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f scripts/06_drop_fk_constraints.sql

echo ""
echo "========================================================================="
echo "STEP 6: Verify Data"
echo "========================================================================="
echo ""

PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -U $DEV_USER -d $DEV_DB -f check_data_quick.sql

echo ""
echo "========================================================================"
echo "MIGRATION COMPLETE!"
echo "========================================================================"
echo ""
