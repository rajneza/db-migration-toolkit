-- Quick check of actual data in database (no dblink needed)

\echo 'Checking data in key tables...'
\echo ''

\echo 'Table Row Counts:'
\echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'

SELECT 
    'organisations' as table_name, 
    COUNT(*) as row_count,
    CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END as status
FROM organisations
UNION ALL
SELECT 'users', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM users
UNION ALL
SELECT 'jobs', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM jobs
UNION ALL
SELECT 'partners', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM partners
UNION ALL
SELECT 'sequence_enrollments', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM sequence_enrollments
UNION ALL
SELECT 'sequence_steps', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM sequence_steps
UNION ALL
SELECT 'alerts', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM alerts
UNION ALL
SELECT 'batches', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM batches
UNION ALL
SELECT 'crm_tokens', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM crm_tokens
UNION ALL
SELECT 'datasets', COUNT(*), CASE WHEN COUNT(*) > 0 THEN '✓' ELSE '✗ EMPTY' END FROM datasets
ORDER BY row_count DESC;

\echo ''
\echo 'Total Tables in Database:'
SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

\echo ''
\echo 'dblink Status:'
SELECT 
    CASE 
        WHEN EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'dblink') 
        THEN '✓ dblink IS installed'
        ELSE '✗ dblink NOT installed (required for data migration)'
    END as status;
