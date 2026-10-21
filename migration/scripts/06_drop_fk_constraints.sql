-- ============================================================================
-- DROP PROBLEMATIC FK CONSTRAINTS
-- ============================================================================
-- Purpose: Drop FK constraints that have orphaned data in staging
-- Run on: DEV database (new server)
-- When: AFTER all data migration completes (after 05_post_validation.sql)
--
-- Why: Staging has orphaned data:
--   - 90 sequence_enrollments with non-existent job_id
--   - 66 sequence_enrollments with non-existent user_id
--
-- These FK constraints are NEW in dev (don't exist in staging)
-- Dropping them allows the orphaned data to exist in dev
-- ============================================================================

\echo '========================================================================';
\echo 'DROPPING FK CONSTRAINTS WITH ORPHANED DATA';
\echo '========================================================================';
\echo '';

-- ============================================================================
-- 1. Check if constraints exist
-- ============================================================================

\echo '1. Checking existing FK constraints on sequence_enrollments...';
\echo '';

SELECT 
    conname as constraint_name,
    contype as constraint_type,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'sequence_enrollments'::regclass
  AND contype = 'f'  -- foreign key
ORDER BY conname;

\echo '';

-- ============================================================================
-- 2. Drop sequence_enrollments.user_id FK constraint
-- ============================================================================

\echo '2. Dropping FK: sequence_enrollments.user_id → users...';

ALTER TABLE sequence_enrollments 
DROP CONSTRAINT IF EXISTS fk_sequence_enrollments_user_id CASCADE;

ALTER TABLE sequence_enrollments 
DROP CONSTRAINT IF EXISTS sequence_enrollments_user_id_fkey CASCADE;

\echo '   ✓ FK constraint on user_id dropped';
\echo '';

-- ============================================================================
-- 3. Drop sequence_enrollments.job_id FK constraint
-- ============================================================================

\echo '3. Dropping FK: sequence_enrollments.job_id → jobs...';

ALTER TABLE sequence_enrollments 
DROP CONSTRAINT IF EXISTS fk_sequence_enrollments_job_id CASCADE;

ALTER TABLE sequence_enrollments 
DROP CONSTRAINT IF EXISTS sequence_enrollments_job_id_fkey CASCADE;

\echo '   ✓ FK constraint on job_id dropped';
\echo '';

-- ============================================================================
-- 4. Verify orphaned data can now exist
-- ============================================================================

\echo '========================================================================';
\echo 'VERIFICATION - Checking orphaned data';
\echo '========================================================================';
\echo '';

-- Count orphaned enrollments by job_id
SELECT 
    'Orphaned by job_id' as check_type,
    COUNT(*) as orphan_count,
    '(FK constraint dropped - this is OK now)' as status
FROM sequence_enrollments
WHERE job_id NOT IN (SELECT id FROM jobs);

-- Count orphaned enrollments by user_id
SELECT 
    'Orphaned by user_id' as check_type,
    COUNT(*) as orphan_count,
    '(FK constraint dropped - this is OK now)' as status
FROM sequence_enrollments
WHERE user_id NOT IN (SELECT id FROM users);

\echo '';

-- ============================================================================
-- 5. Remaining FK constraints
-- ============================================================================

\echo '========================================================================';
\echo 'REMAINING FK CONSTRAINTS on sequence_enrollments';
\echo '========================================================================';
\echo '';

SELECT 
    conname as constraint_name,
    pg_get_constraintdef(oid) as definition
FROM pg_constraint
WHERE conrelid = 'sequence_enrollments'::regclass
  AND contype = 'f'
ORDER BY conname;

\echo '';
\echo '========================================================================';
\echo 'FK CONSTRAINT DROP COMPLETE';
\echo '';
\echo 'Summary:';
\echo '  ✓ Dropped: sequence_enrollments.user_id → users';
\echo '  ✓ Dropped: sequence_enrollments.job_id → jobs';
\echo '  ✓ Orphaned data can now exist in dev';
\echo '';
\echo 'Note: These FK constraints were NEW in dev schema.';
\echo '      Staging never enforced these relationships.';
\echo '      Application must handle missing job/user references.';
\echo '';
\echo 'Next: Document this in application code and monitor for issues';
\echo '========================================================================';

-- ============================================================================
-- 6. Create documentation comment
-- ============================================================================

\echo '';
\echo 'Adding table comments to document missing FKs...';

COMMENT ON TABLE sequence_enrollments IS 
  'WARNING: FK constraints on user_id and job_id were dropped during migration. ' ||
  'Orphaned data exists: ~90 enrollments with non-existent job_id, ~66 with non-existent user_id. ' ||
  'Application must handle missing references gracefully. ' ||
  'Migrated from staging 2026-10-16.';

\echo '   ✓ Documentation comment added';
\echo '';
