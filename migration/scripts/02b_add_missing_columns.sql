-- ============================================================================
-- ADD MISSING COLUMNS TO DEV SCHEMA
-- ============================================================================
-- Purpose: Add columns that exist in staging but not in dev
-- Run on: DEV database (new server)
-- When: After 02_setup_schema.sql, before 03_migrate_data.sql
--
-- This preserves all data - no columns will be dropped
-- ============================================================================

\echo '========================================================================';
\echo 'ADDING MISSING COLUMNS TO DEV SCHEMA';
\echo '========================================================================';
\echo '';

-- ============================================================================
-- 1. apn_opportunities - Add summary_json column
-- ============================================================================

\echo '1. Adding summary_json to apn_opportunities...';

ALTER TABLE apn_opportunities 
ADD COLUMN IF NOT EXISTS summary_json JSONB;

COMMENT ON COLUMN apn_opportunities.summary_json IS 
  'Migrated from staging - contains opportunity summary data';

\echo '   ✓ apn_opportunities.summary_json added';
\echo '';

-- ============================================================================
-- 2. sequence_enrollments - Add 7 tracking columns
-- ============================================================================

\echo '2. Adding 7 tracking columns to sequence_enrollments...';

ALTER TABLE sequence_enrollments 
ADD COLUMN IF NOT EXISTS cancellation_reason VARCHAR(50),
ADD COLUMN IF NOT EXISTS cc_emails JSON,
ADD COLUMN IF NOT EXISTS chain_status VARCHAR(30),
ADD COLUMN IF NOT EXISTS last_regenerated_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS last_replan_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS last_reply_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS last_sent_at TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN sequence_enrollments.cancellation_reason IS 
  'Migrated from staging - reason for enrollment cancellation';
COMMENT ON COLUMN sequence_enrollments.cc_emails IS 
  'Migrated from staging - CC email addresses for sequence emails';
COMMENT ON COLUMN sequence_enrollments.chain_status IS 
  'Migrated from staging - status of email chain';
COMMENT ON COLUMN sequence_enrollments.last_regenerated_at IS 
  'Migrated from staging - timestamp of last content regeneration';
COMMENT ON COLUMN sequence_enrollments.last_replan_at IS 
  'Migrated from staging - timestamp of last sequence replan';
COMMENT ON COLUMN sequence_enrollments.last_reply_at IS 
  'Migrated from staging - timestamp of last recipient reply';
COMMENT ON COLUMN sequence_enrollments.last_sent_at IS 
  'Migrated from staging - timestamp of last email sent';

\echo '   ✓ sequence_enrollments - 7 columns added';
\echo '';

-- ============================================================================
-- 3. sequence_steps - Add 2 metadata columns
-- ============================================================================

\echo '3. Adding 2 metadata columns to sequence_steps...';

ALTER TABLE sequence_steps 
ADD COLUMN IF NOT EXISTS generation_reason VARCHAR(40),
ADD COLUMN IF NOT EXISTS user_edited BOOLEAN DEFAULT FALSE;

COMMENT ON COLUMN sequence_steps.generation_reason IS 
  'Migrated from staging - reason for step generation (AI/manual/template)';
COMMENT ON COLUMN sequence_steps.user_edited IS 
  'Migrated from staging - whether user manually edited the step';

\echo '   ✓ sequence_steps - 2 columns added';
\echo '';

-- ============================================================================
-- Verification
-- ============================================================================

\echo '========================================================================';
\echo 'VERIFICATION - Checking added columns exist';
\echo '========================================================================';
\echo '';

-- Check apn_opportunities
SELECT 
    'apn_opportunities' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'apn_opportunities'
  AND column_name = 'summary_json';

-- Check sequence_enrollments
SELECT 
    'sequence_enrollments' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'sequence_enrollments'
  AND column_name IN (
    'cancellation_reason', 'cc_emails', 'chain_status',
    'last_regenerated_at', 'last_replan_at', 'last_reply_at', 'last_sent_at'
  )
ORDER BY column_name;

-- Check sequence_steps
SELECT 
    'sequence_steps' as table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'sequence_steps'
  AND column_name IN ('generation_reason', 'user_edited')
ORDER BY column_name;

\echo '';
\echo '========================================================================';
\echo 'COLUMN ADDITIONS COMPLETE';
\echo '';
\echo 'Summary:';
\echo '  - apn_opportunities: +1 column (summary_json)';
\echo '  - sequence_enrollments: +7 columns (tracking fields)';
\echo '  - sequence_steps: +2 columns (metadata)';
\echo '  Total: 10 columns added';
\echo '';
\echo 'Next: Run 02c_create_staging_tables.sql to create 13 additional tables';
\echo '========================================================================';
