-- ============================================================================
-- DATABASE CHECK SCRIPT
-- ============================================================================
-- Quick script to check what's actually in the database
-- ============================================================================

\echo '========================================================================'
\echo 'DATABASE CONTENT CHECK'
\echo '========================================================================'
\echo ''

-- Check total number of tables
\echo 'Total Tables:'
SELECT COUNT(*) as total_tables 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'BASE TABLE';

\echo ''
\echo '========================================================================'
\echo 'TABLES WITH DATA (Row count > 0)'
\echo '========================================================================'
\echo ''

-- Show tables with row counts
DO $$
DECLARE
    r RECORD;
    row_count INTEGER;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', r.table_name) INTO row_count;
        IF row_count > 0 THEN
            RAISE NOTICE '% : % rows', RPAD(r.table_name, 40), row_count;
        END IF;
    END LOOP;
END $$;

\echo ''
\echo '========================================================================'
\echo 'EMPTY TABLES'
\echo '========================================================================'
\echo ''

DO $$
DECLARE
    r RECORD;
    row_count INTEGER;
BEGIN
    FOR r IN 
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_type = 'BASE TABLE'
        ORDER BY table_name
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM %I', r.table_name) INTO row_count;
        IF row_count = 0 THEN
            RAISE NOTICE '%', r.table_name;
        END IF;
    END LOOP;
END $$;

\echo ''
\echo '========================================================================'
\echo 'SAMPLE DATA FROM KEY TABLES'
\echo '========================================================================'
\echo ''

\echo 'Organisations:'
SELECT COUNT(*) as count FROM organisations;
SELECT * FROM organisations LIMIT 3;

\echo ''
\echo 'Users:'
SELECT COUNT(*) as count FROM users;
SELECT * FROM users LIMIT 3;

\echo ''
\echo 'Jobs:'
SELECT COUNT(*) as count FROM jobs;
SELECT * FROM jobs LIMIT 3;

\echo ''
\echo '========================================================================'
\echo 'DBLINK CHECK'
\echo '========================================================================'
\echo ''

-- Check if dblink extension exists
SELECT EXISTS(
    SELECT 1 FROM pg_extension WHERE extname = 'dblink'
) as dblink_installed;

\echo ''
\echo 'Check complete!'
