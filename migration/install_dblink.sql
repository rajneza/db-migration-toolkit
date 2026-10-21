-- ============================================================================
-- INSTALL DBLINK EXTENSION
-- ============================================================================
-- Purpose: Install dblink extension required for cross-database queries
-- When: BEFORE running data migration
-- ============================================================================

\echo '========================================================================'
\echo 'INSTALLING DBLINK EXTENSION'
\echo '========================================================================'
\echo ''

-- Check if dblink is already installed
SELECT 
    CASE 
        WHEN EXISTS(SELECT 1 FROM pg_extension WHERE extname = 'dblink') 
        THEN '✓ dblink is already installed'
        ELSE '⚠️ dblink is NOT installed - installing now...'
    END as status;

-- Install dblink extension
CREATE EXTENSION IF NOT EXISTS dblink;

\echo ''
\echo 'Verifying installation...'
\echo ''

-- Verify installation
SELECT 
    extname as extension_name,
    extversion as version,
    '✓ Installed successfully' as status
FROM pg_extension 
WHERE extname = 'dblink';

\echo ''
\echo '========================================================================'
\echo 'DBLINK INSTALLATION COMPLETE'
\echo '========================================================================'
\echo ''
\echo 'You can now run data migration scripts that use dblink.'
\echo ''
