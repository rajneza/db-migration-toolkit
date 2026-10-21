-- Quick check of database status
\echo 'Checking database status...'
\echo ''

\echo '1. Total tables:'
SELECT COUNT(*) as total_tables 
FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

\echo ''
\echo '2. Tables with data:'
SELECT 
    schemaname,
    tablename,
    n_live_tup as row_count
FROM pg_stat_user_tables
WHERE n_live_tup > 0
ORDER BY n_live_tup DESC
LIMIT 20;

\echo ''
\echo '3. Key table counts:'
SELECT 
    'organisations' as table_name, 
    (SELECT COUNT(*) FROM organisations) as row_count
UNION ALL
SELECT 'users', (SELECT COUNT(*) FROM users)
UNION ALL
SELECT 'jobs', (SELECT COUNT(*) FROM jobs)
UNION ALL
SELECT 'sequence_enrollments', (SELECT COUNT(*) FROM sequence_enrollments)
UNION ALL
SELECT 'partners', (SELECT COUNT(*) FROM partners);

\echo ''
\echo '4. dblink extension installed?'
SELECT EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'dblink') as dblink_installed;
