-- ============================================================================
-- SCHEMA SETUP SCRIPT - COMBINED DEV + STAGING TABLES
-- ============================================================================
-- Purpose: Create complete schema structure on new database server
-- Run on: NEW (target) database
-- When: BEFORE data migration
-- 
-- This script creates:
--   - 88 tables from dev schema
--   - 13 additional tables from staging schema
--   - Total: 101 tables
-- 
-- Source: new_server_schema_combined.sql (generated from dev + staging schemas)
-- 
-- ============================================================================

\echo '========================================================================'
\echo 'SCHEMA SETUP - COMBINED SCHEMA (101 TABLES)'
\echo '========================================================================'
\echo ''
\echo 'Creating schema structure from new_server_schema_combined.sql...'
\echo ''

-- Include the combined schema file
\i new_server_schema_combined.sql

\echo ''
\echo '========================================================================'
\echo 'VERIFICATION - Checking created tables'
\echo '========================================================================'
\echo ''

-- Count tables
SELECT 
    COUNT(*) as table_count,
    CASE 
        WHEN COUNT(*) >= 101 THEN '✓ Expected 101+ tables'
        ELSE '⚠️ Expected 101 tables, found ' || COUNT(*)::TEXT
    END as status
FROM pg_tables 
WHERE schemaname = 'public';

\echo ''
\echo 'Tables created:'
\echo ''

-- List all tables
SELECT 
    tablename,
    CASE 
        -- Dev-only tables (remain empty)
        WHEN tablename IN (
            'alliance_alerts', 'alliance_insights', 
            'co_sell_readiness_ai', 'co_sell_rooms', 
            'microsoft_referrals', 'partner_account_overlaps',
            'partner_engagement_events', 'partner_matches'
        ) THEN '(dev-only, starts empty)'
        -- Staging-only tables (will be migrated)
        WHEN tablename IN (
            'datasets', 'dataset_rows', 'dataset_history',
            'outreach_sequences', 'outreach_enrollments', 'outreach_steps', 'outreach_reply_log',
            'vault_documents', 'vault_chunks',
            'sequence_replies', 'llm_calls', 'run_stats', 'usage'
        ) THEN '(from staging, will receive data)'
        -- Common tables
        ELSE '(will receive staging data)'
    END as data_source
FROM pg_tables 
WHERE schemaname = 'public'
ORDER BY tablename;

\echo ''
\echo '========================================================================'
\echo 'SCHEMA SETUP COMPLETE'
\echo '========================================================================'
\echo ''
\echo 'Summary:'
\echo '  - Dev tables (88): Created'
\echo '  - Staging-only tables (13): Created'
\echo '  - Total tables: 101'
\echo ''
\echo 'Next steps:'
\echo '  1. Run 02b_add_missing_columns.sql (add 10 columns)'
\echo '  2. Run 03_migrate_data.sql (migrate all 93 tables)'
\echo ''
\echo '========================================================================'
