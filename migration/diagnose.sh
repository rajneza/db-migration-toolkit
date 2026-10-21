#!/bin/bash
# Diagnostic script to check migration status

echo "========================================================================="
echo "DATABASE MIGRATION DIAGNOSTIC"
echo "========================================================================="
echo ""

# Load .env file
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✓ .env file loaded"
else
    echo "✗ .env file not found!"
    exit 1
fi

echo ""
echo "========================================================================="
echo "1. CHECK PSQL INSTALLATION"
echo "========================================================================="
echo ""
which psql
psql --version

echo ""
echo "========================================================================="
echo "2. TEST DEV DATABASE CONNECTION"
echo "========================================================================="
echo ""
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p $DEV_PORT -U $DEV_USER -d $DEV_DB -c "SELECT version();" 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Dev database connection successful"
else
    echo "✗ Dev database connection failed!"
fi

echo ""
echo "========================================================================="
echo "3. TEST STAGING DATABASE CONNECTION"
echo "========================================================================="
echo ""
PGPASSWORD=$STAGING_PASSWORD psql -h $STAGING_HOST -p $STAGING_PORT -U $STAGING_USER -d $STAGING_DB -c "SELECT version();" 2>&1

if [ $? -eq 0 ]; then
    echo "✓ Staging database connection successful"
else
    echo "✗ Staging database connection failed!"
fi

echo ""
echo "========================================================================="
echo "4. CHECK TABLES IN DEV DATABASE"
echo "========================================================================="
echo ""
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p $DEV_PORT -U $DEV_USER -d $DEV_DB -c "\dt" 2>&1 | head -20

echo ""
echo "========================================================================="
echo "5. COUNT TABLES IN DEV DATABASE"
echo "========================================================================="
echo ""
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p $DEV_PORT -U $DEV_USER -d $DEV_DB -c "SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';" 2>&1

echo ""
echo "========================================================================="
echo "6. CHECK ROW COUNTS IN KEY TABLES"
echo "========================================================================="
echo ""
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p $DEV_PORT -U $DEV_USER -d $DEV_DB << 'EOF'
SELECT 
    'organisations' as table_name, 
    COUNT(*) as row_count 
FROM organisations
UNION ALL
SELECT 'users', COUNT(*) FROM users
UNION ALL
SELECT 'jobs', COUNT(*) FROM jobs
UNION ALL
SELECT 'sequence_enrollments', COUNT(*) FROM sequence_enrollments;
EOF

echo ""
echo "========================================================================="
echo "7. CHECK DBLINK EXTENSION"
echo "========================================================================="
echo ""
PGPASSWORD=$DEV_PASSWORD psql -h $DEV_HOST -p $DEV_PORT -U $DEV_USER -d $DEV_DB -c "SELECT * FROM pg_extension WHERE extname = 'dblink';" 2>&1

echo ""
echo "========================================================================="
echo "8. CHECK IF SCRIPTS EXIST"
echo "========================================================================="
echo ""
ls -lh scripts/*.sql

echo ""
echo "========================================================================="
echo "9. CHECK PYTHON SCRIPT"
echo "========================================================================="
echo ""
python3 --version
python3 -c "import psycopg2; print('psycopg2:', psycopg2.__version__)" 2>&1
python3 -c "from dotenv import load_dotenv; print('python-dotenv: installed')" 2>&1

echo ""
echo "========================================================================="
echo "10. CHECK BACKUPS FOLDER"
echo "========================================================================="
echo ""
if [ -d "backups" ]; then
    ls -lh backups/
else
    echo "No backups folder found"
fi

echo ""
echo "========================================================================="
echo "DIAGNOSTIC COMPLETE"
echo "========================================================================="
echo ""
echo "Summary:"
echo "  - If tables exist but are empty: SQL scripts didn't run or failed"
echo "  - If tables don't exist: Schema creation failed"
echo "  - If dblink is missing: Install with: CREATE EXTENSION dblink;"
echo ""
